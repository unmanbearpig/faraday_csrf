require 'faraday_csrf'

describe Faraday::CSRF do
  def look_like_a_request_to(url)
    be_kind_of(Faraday::Env) &
      have_attributes(status: nil) &
      satisfy { |value| value.url.path == url }
  end

  def look_like_a_response_to(url, *args)
    be_kind_of(Faraday::Env) &
      have_attributes(*args) &
      satisfy { |value| value.url.path == url }
  end

  let(:url) { 'https://example.com/' }
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:token_handler) { double(:token_handler, handle_request: nil, handle_response: nil) }

  let(:connection) do
    Faraday.new url do |conn|
      conn.use Faraday::CSRF, token_handler: token_handler
      conn.request :url_encoded
      conn.adapter :test, stubs
    end
  end

  it 'registers a middleware' do
    expect(Faraday::Middleware.lookup_middleware(:csrf))
      .to eq Faraday::CSRF
  end

  it 'passes the request env to handle_request' do
    expect(token_handler).to receive(:handle_request) do |request_env|
      expect(request_env).to look_like_a_request_to('/handle_me')
    end

    stubs.get('/handle_me') { [200, {}, 'hello'] }
    connection.get '/handle_me'
  end

  it 'passes the response env to handle response' do
    expect(token_handler).to receive(:handle_response) do |response_env|
      expect(response_env).to look_like_a_response_to('/handle_me', status: 200)
    end

    stubs.get('/handle_me') { [200, {}, 'hello'] }
    connection.get '/handle_me'
  end
end
