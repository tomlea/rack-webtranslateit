require "rack"

module Rack::Webtranslateit
  def new(app, mount_point = "/translations/")
    authenticator = method(:authenticator)
    builder = Rack::Builder.new
    builder.map(mount_point) do
      use Rack::Auth::Basic, &authenticator if Configuration.password
      run Ui.new
    end
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
