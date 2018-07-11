require 'task_generator'

namespace :task_generator do
  desc 'Generate a new task for each supplier on each framework'
  task generate: [:environment] do
    Framework.all.each do |framework|
      framework.suppliers.each do |supplier|
        puts "Creating task for Supplier: #{supplier.name} on Framework: #{framework.id}"
        TaskGenerator.new(supplier: supplier, framework: framework).create
      end
    end
  end
end
