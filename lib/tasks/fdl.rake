namespace :fdl do
  desc 'Transpile a framework from source'
  task :transpile, %i[framework_short_name] => [:environment] do |_task, args|
    framework_short_name = args[:framework_short_name] or raise ArgumentError, 'framework_short_name required'

    Framework::Definition::Language[framework_short_name]
  end
end
