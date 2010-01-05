require "rack"

module Rack::Webtranslateit
  def new(app, mount_point = "/translations/")
    builder = Rack::Builder.new
    builder.use Rack::Auth::Basic, &method(:authenticator) if Configuration.password
    builder.map(mount_point){ run Ui.new }
    builder.map("/"){ run app }
    builder.to_app
  end

  def authenticator(username, password)
    username == "admin" and password == Configuration.password
  end

  autoload :Configuration, "rack/webtranslateit/configuration"
  autoload :Ui, "rack/webtranslateit/ui"
  autoload :TranslationFile, "rack/webtranslateit/translation_file"

  extend self
end
