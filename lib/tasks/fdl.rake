require 'fdl/validations/test'

namespace :fdl do
  # rake fdl:validations:test[CM/OSG/05/3565,10]
  namespace :validations do
    desc 'Test validations transpiled from FDL against validations from the hand-coded Ruby equivalent'
    task :test, %i[framework_short_name sample_row_count] => [:environment] do |_task, args|
      framework_short_name = args[:framework_short_name] or raise ArgumentError 'framework_short_name required'
      sample_row_count = args[:sample_row_count] || 5000

      FDL::Validations::Test.new(framework_short_name, sample_row_count).run
    end
  end
end
