require 'sinatra/base'

class Rack::Webtranslateit::Ui < Sinatra::Base
  set :views => File.join(File.dirname(__FILE__), *%w[.. .. .. templates])

  use Rack::ShowExceptions
  use Rack::Lint
  use Rack::Static, :urls => ["/static"], :root => File.join(File.dirname(__FILE__), *%w[.. .. .. public])

  helpers do
    def highlight_unless_equal(value, expected)
      if value == expected
        value
      else
        "<em>#{value}</em>"
      end
    end

    def base_path
      request.script_name
    end
  end

  get '/' do
    content_type 'text/html', :charset => 'utf-8'
    erb :index, :locals => {:files => config.files, :locales => config.locales}
  end

  post '/update' do
    fetch_translations
    redirect "/"
  end

protected

  def redirect(path, *args)
    super(base_path + path, *args)
  end

  def config
    @config ||= Rack::Webtranslateit::Configuration.new
  end

  def fetch_translations
    config.files.each do |file|
      config.locales.each do |locale|
        next if config.ignore_locales.include?(locale)
        response_code = file.for(locale).fetch!
      end
    end
  end

end
