require 'net/https'
require 'ftools'
class Rack::Webtranslateit::TranslationFile
  attr_accessor :id, :file_path, :api_key, :master_locale

  def initialize(id, file_path, api_key, master_locale)
    self.id        = id
    self.file_path = file_path
    self.api_key   = api_key
    self.master_locale = master_locale
  end

  def for(locale)
    ForLocale.new(self, locale)
  end

  class ForLocale
    attr_reader :file, :locale
    def initialize(file, locale)
      @file, @locale = file, locale
    end

    def exists?
      File.exists?(file_path)
    end

    def committed?
      Dir.chdir(File.dirname(file_path)) do
        system "git status | grep 'modified:   #{File.basename(file_path)}' > /dev/null"
      end
      ! $?.success?
    end

    def master?
      @file.master_locale == locale
    end

    def modified_remotely?
      get_translations.code.to_i == 200
    end

    def get_translations(respect_modified_since = true)
      http_connection do |http|
        request           = Net::HTTP::Get.new(api_url)
        request.add_field('If-Modified-Since', File.mtime(File.new(file_path, 'r')).rfc2822) if File.exist?(file_path) and respect_modified_since
        return http.request(request)
      end
    end

    def fetch
      response = get_translations
      File.open(file_path, 'w'){|f| f << response.body } if response.code.to_i == 200 and not response.body.blank?
    end

    def fetch!
      response = get_translations(false)
      File.open(file_path, 'w'){|f| f << response.body } if response.code.to_i == 200 and not response.body.blank?
    end

    def send
      File.open(file_path) do |file|
        http_connection do |http|
          request  = Net::HTTP::Put::Multipart.new(api_url, "file" => UploadIO.new(file, "text/plain", file.path))
          response = http.request(request)
          return response.code.to_i
        end
      end
    end

    def file_path
      @file_path ||= File.expand_path(file.file_path.gsub("[locale]", locale))
    end

    def http_connection
      http = Net::HTTP.new('webtranslateit.com', 443)
      http.use_ssl      = true
      http.verify_mode  = OpenSSL::SSL::VERIFY_NONE
      http.read_timeout = 10
      yield http
    end

    def api_url
      "/api/projects/#{file.api_key}/files/#{file.id}/locales/#{locale}"
    end
  end
end
