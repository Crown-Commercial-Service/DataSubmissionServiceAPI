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

  desc 'Export coda finance report to CSV'
  task coda_finance_report: :environment do
    export_path = "/tmp/coda_finance_report_#{Time.zone.today}.csv"
    puts "Exporting to #{export_path}"
    Export::CodaFinanceReport.new(Submission.completed, File.open(export_path, 'w')).run
  end
end
