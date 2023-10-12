Sidekiq.configure_server do |config|
  config.super_fetch!
  schedule_file = 'config/sidekiq_schedule.yml'
  Rails.application.reloader.to_prepare do
    Sidekiq::Cron::Job.load_from_hash! YAML.load_file(schedule_file)
  end
end
