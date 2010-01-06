require 'sinatra/base'

class Rack::Webtranslateit::Ui < Sinatra::Base
  set :views => File.join(File.dirname(__FILE__), *%w[.. .. .. templates])

  use Rack::ShowExceptions
  use Rack::Lint
  use Rack::Static, :urls => ["/static"], :root => File.join(File.dirname(__FILE__), *%w[.. .. .. public])

  get(''){redirect "/"}

  get '/' do
    content_type 'text/html', :charset => 'utf-8'
    erb :index, :locals => {:files => config.files, :locales => config.locales}
  end

  post '/update' do
    fetch_translations
    redirect "/"
  end

  post '/upload' do
    upload_master_file
    redirect '/'
  end

  helpers do
    def highlight_unless_equal(value, expected)
      value == expected ? value : "<em>#{value}</em>"
    end

    def base_path
      request.script_name
    end
  end

protected

  def redirect(path, *args)
    super(base_path + path, *args)
  end

  def config
    @config ||= Rack::Webtranslateit::Configuration
  end

  def fetch_translations
    config.files.each do |file|
      config.locales.each do |locale|
        next if config.master_locale == locale
        response_code = file.for(locale).fetch!
      end
    end
  end

  def upload_master_file
    config.files.each do |file|
      file.for(config.master_locale).upload
    end
  end

end
