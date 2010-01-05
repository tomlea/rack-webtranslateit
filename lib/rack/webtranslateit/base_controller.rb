require 'erb'
require 'ostruct'

class Rack::Webtranslateit::BaseController
  TEMPLATES_PATH = File.join(File.dirname(__FILE__), *%w[.. .. .. templates])
  STATIC_PATH = File.join(File.dirname(__FILE__), *%w[.. .. .. static])
  def call(env)
    @app.call(env)
  end

protected
  module Helpers
    def highlight_unless_equal(value, expected)
      if value == expected
        value
      else
        "<em>#{value}</em>"
      end
    end
  end

  def not_found
    Rack::Response.new(404).finish
  end

  def handle(action)
    lambda{|env|
      @request = Rack::Request.new(env)
      @response = Rack::Response.new
      send(action)
      @response.finish
    }
  end

  def redirect_to(path)
    @response.status = 301
    @response["Location"] = "#{@request.url.sub(@request.fullpath, "")}/translations#{path}"
  end

  def render(template, locals = {})
    vars = OpenStruct.new( locals.merge(:request => @request) )
    vars.extend(Helpers)
    template = File.read(File.join(TEMPLATES_PATH, "#{template}.html.erb"))
    @response["Content-Type"] = "text/html; charset=utf-8"
    @response.write ERB.new(template).result(vars.send(:binding))
  end
end
