require 'fdl/validations/test'

namespace :fdl do
  # rake fdl:validations:test[CM/OSG/05/3565,10]
  namespace :validations do
    desc 'Test validations transpiled from FDL against validations from the hand-coded Ruby equivalent'
    task :test, %i[framework_short_name sample_row_count] => [:environment] do |_task, args|
      framework_short_name = args[:framework_short_name] or raise ArgumentError 'framework_short_name required'
      sample_row_count = args[:sample_row_count] || 5000

      test = FDL::Validations::Test.new(framework_short_name, sample_row_count)
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
