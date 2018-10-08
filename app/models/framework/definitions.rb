require 'framework/definition/base'

# Require all the framework definitions up-front
Dir['app/models/framework/definition/*'].reject { |d| d =~ /base\.rb$/ }.each do |definition|
  # `Dir` needs an app-relative path argument, but `require` needs one relative to
  # the $LOAD_PATH. Remove app/models/ to e.g. only `require 'framework/definition/RM1234'`
  relative_definition = Pathname(definition).sub('app/models/', '').sub_ext('').to_s
  require relative_definition
end
