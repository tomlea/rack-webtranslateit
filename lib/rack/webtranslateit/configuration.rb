require 'yaml'

class Rack::Webtranslateit::Configuration
  attr_accessor :api_key, :files, :master_locale, :password

  def initialize
    unless file = self.class.config_location
      root = defined?(RAILS_ROOT) && RAILS_ROOT
      root ||= defined?(RACK_ROOT) && RACK_ROOT
      root ||= File.expand_path(".")
      file = File.join(root, 'config', 'translation.yml')
    end

    configuration       = YAML.load_file(file)
    self.api_key        = configuration['api_key']
    self.password       = configuration['password']
    self.master_locale  = configuration['master_locale'].to_s
    self.files          = []
    configuration['files'].each do |file_id, file_path|
      self.files.push(Rack::Webtranslateit::TranslationFile.new(file_id, file_path, api_key, master_locale))
    end
  end

  def locales
    http              = Net::HTTP.new('webtranslateit.com', 443)
    http.use_ssl      = true
    http.verify_mode  = OpenSSL::SSL::VERIFY_NONE
    http.read_timeout = 10
    request           = Net::HTTP::Get.new("/api/projects/#{api_key}/locales")
    response          = http.request(request)
    if response.code.to_i == 200
      response.body.split
    else
      []
    end
  end

  class << self
    def method_missing(name, *args)
      @configuration ||= new
      @configuration.send(name, *args)
    end

    attr_accessor :config_location
  end
end
