require 'erb'
require 'ostruct'

class Rack::Webtranslateit::Ui < Rack::Webtranslateit::BaseController

  def initialize(default_app)
    handle = method(:handle)
    @app = Rack::Builder.app do
      use Rack::CommonLogger
      use Rack::ShowExceptions
      map "/translations" do
        use Rack::Lint

        map "/" do
          run handle[:index]
        end

        map "/update" do
          run handle[:update]
        end

        map "/static" do
          use Rack::Static, :urls => ["/"], :root => STATIC_PATH
          run handle[:not_found]
        end

      end

      map "/" do
        run default_app
      end
    end
  end

  def index
    render :index, :files => config.files, :locales => config.locales
  end

  def update
    fetch_translations
    redirect_to "/"
  end

protected

  def config
    @config ||= Rack::Webtranslateit::Configuration.new
  end

  def fetch_translations
    puts "Looking for translations..."
    config.files.each do |file|
      config.locales.each do |locale|
        next if config.ignore_locales.include?(locale)
        response_code = file.for(locale).fetch!
        puts "Done. Response code: #{response_code}"
      end
    end
  end

end
