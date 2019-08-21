namespace :db do
  PRODUCTION_BACKUP_TARS = 'backups/production-backup-*.tar'.freeze

  def database_url
    ENV.fetch('DATABASE_URL').split('?').first
  end

  def find_latest_backup
    Dir[PRODUCTION_BACKUP_TARS].sort.reverse.first
  end

  def filter_toc(path)
    # We filter the database dump, modifying its table of contents to remove
    # elements that we do not wish to restore:
    #
    # - The PostGIS extension and the spatial_ref_sys table that it creates.
    #   This extension exists in the production dump because it is always enabled
    #   for GOV.UK Platform as a Service Postgres instances
    #   (https://docs.cloud.service.gov.uk/deploying_services/postgresql/#add-or-remove-extensions-for-a-postgresql-service-instance).
    #   However, we do not make use of it in our app, and if we kept it in the
    #   dump then we would need to use a custom Postgres Docker image with the PostGIS
    #   extension installed. So it's easier to just get rid of it.
    #
    # - The reassign_owned function and event trigger. If we do not get rid of
    #   these, then something happens that causes migrations that alter columns
    #   to fail in development, with an error like 'role
    #   "rdsbroker_e8e8d7d2_5890_4f9d_8c9c_da43a9918e4c_manager" does not
    #   exist'.
    new_toc_lines = File.read(path).each_line.reject do |line|
      line =~ /EXTENSION.*postgis|spatial_ref_sys|reassign_owned/
    end

    File.open(path, 'w') { |f| f << new_toc_lines.join("\n") }
  end

  desc 'Restore from a backup'
  task :restore, %i[filename user] => :environment do |_task, args|
    filename = args[:filename] || find_latest_backup or
      raise ArgumentError, "[filename] required when no #{PRODUCTION_BACKUP_TARS} found"

    STDERR.puts("Restoring from #{filename}")

    Tempfile.create do |toc_file|
      sh "pg_restore --list #{filename} > #{toc_file.path}"

      filter_toc(toc_file.path)

      sh 'pg_restore', \
         # Fail when first error is encountered, instead of reporting mutiple
         # errors at the end
         '--exit-on-error', \
         '-d', database_url, \
         # Only restore the objects specified by our filtered table of contents
         '-L', toc_file.path, \
         # Do not attempt to set object ownership, since the roles referred to
         # by the dump will not exist locally
         '--no-owner', \
         # Do not attempt to set access privileges, since the roles referred to
         # by the dump will not exist locally
         '--no-privileges', \
         filename
    end
  end

  desc 'Wipe out your local DB and replace with latest from ./backups'
  task reset_to_production: %i[environment db:drop db:create db:restore]
end
