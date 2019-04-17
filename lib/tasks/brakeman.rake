if Rails.env.development? || Rails.env.test?
  namespace :brakeman do
    desc 'Run Brakeman'
    task :run do
      `bundle exec brakeman --quiet --no-pager #{Rails.root}`
    end
  end
end
