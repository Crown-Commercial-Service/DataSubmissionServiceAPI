require 'ingest/test'

namespace :ingest do
  desc 'Tests new ingest against existing submission entries'
  task :test, %i[file_ids] => [:environment] do |_task, args|
    file_ids = args[:file_ids]

    test = Ingest::Test.new(file_ids)
    test.run

    puts test.formatted_report
  end
end
