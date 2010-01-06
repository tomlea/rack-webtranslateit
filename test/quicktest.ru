$:.unshift File.expand_path(File.join(File.dirname(__FILE__), *%w[.. lib]))
Dir.chdir File.dirname(__FILE__) + "/.."

require "rack/webtranslateit"

Rack::Webtranslateit::Configuration.config_location = File.join(File.dirname(__FILE__), *%w[config translation.yml])

use Rack::Webtranslateit
run proc{|env| Rack::Response.new(["All Good!"]).finish }
