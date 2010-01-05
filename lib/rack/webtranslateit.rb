require "rack"

module Rack::Webtranslateit
  def new(app)
    Ui.new(app)
  end

  def call(env)
    @app ||= UI.new(lambda{|env| [404, {"Content-Type" => "text/html"}, ["Not found"]] })
    @app.call(env)
  end

  autoload :Configuration, "rack/webtranslateit/configuration"
  autoload :Ui, "rack/webtranslateit/ui"
  autoload :BaseController, "rack/webtranslateit/base_controller"
  autoload :TranslationFile, "rack/webtranslateit/translation_file"

  extend self
end
