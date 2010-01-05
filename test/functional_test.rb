require 'base64'
require 'test/unit'
require 'shoulda'
require 'rack'
require 'webmock/test_unit'

WebMock.disable_net_connect!

require File.join(File.dirname(__FILE__), *%w[.. lib rack webtranslateit])

class FunctionalTest < Test::Unit::TestCase
  include WebMock

  def app
    Rack::Builder.new do
      use Rack::Webtranslateit, "/translations/"
      run lambda{|env| [ 200, {"Content-Type" => "text/plain"}, ["inner_app"] ] }
    end.to_app
  end

  should "pass through none /translation.* urls to the inner app" do
    get "/foo"
    assert_equal 'inner_app', last_response.body
  end

  should "disallow access without password" do
    get "/translations"
    assert_equal 401, last_response.status
  end

  should "allow access with wrong password" do
    get "/translations/", 'HTTP_AUTHORIZATION' => encode_credentials('admin', 'fail')
    assert_equal 401, last_response.status
  end

  should "redirect to root with a /" do
    get "/translations", 'HTTP_AUTHORIZATION' => encode_credentials('admin', 'password')
    assert_equal 302, last_response.status
    assert_equal "/translations/", last_response["Location"]
  end

  should "get a list of available locales from webtranslateit.com" do
    stub_request(:get, "https://webtranslateit.com/api/projects/api_key/locales").to_return(:body => "fr")
    stub_request(:get, "https://webtranslateit.com/api/projects/api_key/files/1234/locales/fr").to_return(:status => 304)
    get "/translations/", 'HTTP_AUTHORIZATION' => encode_credentials('admin', 'password')
    assert_equal 200, last_response.status, last_response.errors
    assert_requested :get, "https://webtranslateit.com/api/projects/api_key/locales"
  end

private
  attr_accessor :last_response
  def get(*args)
    self.last_response = Rack::MockRequest.new(app).get(*args)
  end

  def encode_credentials(username, password)
    "Basic " + Base64.encode64("#{username}:#{password}")
  end
end
