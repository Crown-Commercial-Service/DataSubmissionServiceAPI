# Tasks to export per-entity CSV files for CCS BI
namespace :export do
  desc 'Export everything to CSV'
  task all: %i[environment tasks submissions invoices contracts]

  namespace :all do
    desc 'Export everything that has updated since the last export to CSV'
    task incremental: :environment do
      puts 'Generating incremental export...'
      export = DataWarehouseExport.generate!
      puts "Generated incremental export for #{export.date_range}"
    end
  end

  desc 'Export task entities to CSV'
  task :tasks, [:output] => [:environment] do
    Export::Anything.new(Export::Tasks::Extract.all_relevant).run
  end

  desc 'Export submission entities to CSV'
  task :submissions, [:output] => [:environment] do
    Export::Anything.new(Export::Submissions::Extract.all_relevant).run
  end

  desc 'Export invoice entities to CSV'
  task :invoices, [:output] => [:environment] do
    Export::Anything.new(Export::Invoices::Extract.all_relevant).run
  end

  desc 'Export contract entities to CSV'
  task :contracts, [:output] => [:environment] do
    Export::Anything.new(Export::Contracts::Extract.all_relevant).run
  end

  desc 'Export coda finance report to CSV'
  task coda_finance_report: :environment do
    export_path = "/tmp/coda_finance_report_#{Time.zone.today}.csv"
    puts "Exporting to #{export_path}"
    Export::CodaFinanceReport.new(Submission.completed, File.open(export_path, 'w')).run
  end
end
