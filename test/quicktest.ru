$:.unshift File.expand_path(File.join(File.dirname(__FILE__), *%w[.. lib]))
require "rack/webtranslateit"
Dir.chdir File.dirname(__FILE__)
use Rack::Webtranslateit
run proc{|env| Rack::Response.new(["All Good!"]).finish }
