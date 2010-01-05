require "rack"

module Rack::Webtranslateit
  def new(app)
    builder = Rack::Builder.new

    builder.map("/translations/"){run Ui.new}
    builder.map("/"){ run app }
    builder.to_app
  end

  autoload :Configuration, "rack/webtranslateit/configuration"
  autoload :Ui, "rack/webtranslateit/ui"
  autoload :TranslationFile, "rack/webtranslateit/translation_file"

  extend self
end
