ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.
# Speed up boot time by caching expensive operations,
# but allow disabling for debuggers like RubyMine 2018.1
# that won't hit breakpoints when bootsnap is used.
# This +unless+ can be removed from 2019.1 onwards.
require 'bootsnap/setup' unless /ruby-debug-ide/.match?(ENV['RUBYLIB'])
