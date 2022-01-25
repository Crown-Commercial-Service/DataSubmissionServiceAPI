Sidekiq.configure_server do |_config|
  Sidekiq.options[:poll_interval] = 5
  schedule_file = 'config/sidekiq_schedule.yml'
  Sidekiq::Cron::Job.load_from_hash! YAML.load_file(schedule_file)
end
