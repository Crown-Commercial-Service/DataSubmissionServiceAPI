namespace :fdl do
  desc 'Transpile a framework from source'
  task :transpile, %i[file_name] => [:environment] do |_task, args|
    file_name = args[:file_name] or raise ArgumentError, 'file_name required'

    fdl_source = File.read(file_name)
    generator = Framework::Definition::Generator.new(fdl_source)
    # Transpiles using STDERR as output. If all ok, no output
    generator.success?
  end
end
