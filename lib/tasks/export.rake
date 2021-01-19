# Tasks to export per-entity CSV files for CCS BI
namespace :export do
  namespace :all do
    desc 'Export everything that has updated since the last export to CSV'
    task incremental: :environment do
      puts 'Generating incremental export...'
      export = DataWarehouseExport.generate!
      puts "Generated incremental export for #{export.date_range}"
    end

    desc 'reexport everything from scratch'
    task reexport: :environment do
      puts 'Generating re-export...'
      export = DataWarehouseExport.generate!(reexport: true)
      puts "Generated re-export for #{export.date_range}"
    end
  end
end
