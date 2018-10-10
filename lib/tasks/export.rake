# Tasks to export per-entity CSV files for CCS BI
namespace :export do
  desc 'Export everything to CSV'
  task all: %i[environment tasks submissions invoices contracts]

  desc 'Export task entities to CSV'
  task :tasks, [:output] => [:environment] do |_task, args|
    Export::Anything.new(Task.includes(:framework, :supplier), args[:output]).run
  end

  desc 'Export submission entities to CSV'
  task :submissions, [:output] => [:environment] do |_task, args|
    Export::Anything.new(Export::Submissions::Extract.all_relevant, args[:output]).run
  end

  desc 'Export invoice entities to CSV'
  task :invoices, [:output] => [:environment] do |_task, args|
    Export::Anything.new(Export::Invoices::Extract.all_relevant, args[:output]).run
  end

  desc 'Export contract entities to CSV'
  task :contracts, [:output] => [:environment] do |_task, args|
    Export::Anything.new(Export::Contracts::Extract.all_relevant, args[:output]).run
  end
end
