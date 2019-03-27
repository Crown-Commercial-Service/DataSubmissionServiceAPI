require 'fdl/validations/test'

namespace :fdl do
  ##
  # e.g.
  # rake fdl:validations:test[CM/OSG/05/3565,10] tests against 10 sample entries
  #   in your development database for the Laundry framework
  #
  # cat failures.txt | rake fdl:validations:test[CM/OSG/05/3565] tests
  #   against submission UUIDs you've previously found to be failing and which are in
  #   failures.txt with one UUID one per line
  namespace :validations do
    desc 'Test validations transpiled from FDL against validations from the hand-coded Ruby equivalent'
    task :test, %i[framework_short_name sample_row_count] => [:environment] do |_task, args|
      framework_short_name = args[:framework_short_name] or raise ArgumentError 'framework_short_name required'

      options = if STDIN.tty?
                  { sample_row_count: args[:sample_row_count].to_i || 5000 }
                else
                  { submission_ids: STDIN.read.split("\n") }
                end

      test = FDL::Validations::Test.new(framework_short_name, options)
      test.run
      puts test.formatted_report
    end
  end

  desc 'Transpile a framework from source'
  task :transpile, %i[framework_short_name] => [:environment] do |_task, args|
    framework_short_name = args[:framework_short_name] or raise ArgumentError 'framework_short_name required'

    Framework::Definition::Language[framework_short_name]
  end
end
