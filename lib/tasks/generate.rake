namespace :generate do
  desc 'Generate monthly tasks for agreements. call with [MM,YY] to specify period, e.g. rake generate:tasks[8,2018]'
  task :tasks, %i[month year] => :environment do |_task, args|
    month = args[:month] or raise 'Error: Month argument not specified!'
    year = args[:year] or raise 'Error: Year argument not specified!'
    Task::Generator.new(month: month.to_i, year: year.to_i, logger: Logger.new(STDOUT)).generate!
  end
end
