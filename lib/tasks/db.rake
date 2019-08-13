namespace :db do
  PRODUCTION_BACKUP_TARS = 'backups/production-backup-*.tar'.freeze

  def database_url
    ENV.fetch('DATABASE_URL').split('?').first
  end

  def find_latest_backup
    Dir[PRODUCTION_BACKUP_TARS].sort.reverse.first
  end

  desc 'Restore from a backup'
  task :restore, %i[filename user] => :environment do |_task, args|
    filename = args[:filename] || find_latest_backup or
      raise ArgumentError, "[filename] required when no #{PRODUCTION_BACKUP_TARS} found"

    STDERR.puts("Restoring from #{filename}")
    system 'pg_restore', '-d', database_url, filename
  end

  desc 'Wipe out your local DB and replace with latest from ./backups'
  task reset_to_production: %i[environment db:drop db:create db:restore]
end
