require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'averager'
require 'rspec'
require 'rspec/autorun'
require "timecop"

if defined?(Debugger) && Debugger.respond_to?(:settings)
  Debugger.settings[:autolist] = 1
  Debugger.settings[:autoeval] = true 
end

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

def project_root
  Pathname.new(File.expand_path("..", File.basename(__FILE__)))
end

RSpec.configure do |config|
  
end
