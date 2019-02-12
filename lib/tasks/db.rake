namespace :db do
  PRODUCTION_BACKUP_TAR_GZS = 'backups/production-backup-*.tar.gz'.freeze

  def find_latest_backup
    Dir[PRODUCTION_BACKUP_TAR_GZS].sort.reverse.first
  end

  desc 'Restore from a gzipped backup'
  task :restore, %i[filename user] => :environment do |_task, args|
    filename = args[:filename] || find_latest_backup or
      raise ArgumentError, "[filename] required when no #{PRODUCTION_BACKUP_TAR_GZS} found"

    user = args[:user] || 'postgres'

    STDERR.puts("Unzipping / restoring from #{filename}")
    system(
      "gunzip -c #{filename} | pg_restore -h localhost -U #{user} " \
      '-d DataSubmissionServiceApi_development'
    )
  end

  desc 'Wipe out your local DB and replace with latest from ./backups'
  task reset_to_production: %i[environment db:drop db:create db:restore]
end
