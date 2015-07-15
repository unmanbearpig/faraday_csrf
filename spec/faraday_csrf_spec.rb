require 'faraday_csrf'

describe Faraday::CSRF do
  let(:url) { 'https://example.com/' }

  let(:stubs) { Faraday::Adapter::Test::Stubs.new }

  let(:connection) do
    connection_with_csrf extractor: extractor, injector: injector
  end

  def connection_with_csrf params
    Faraday.new url do |conn|
      conn.use Faraday::CSRF, params
      conn.request :url_encoded
      conn.adapter :test, stubs
    end
  end

  def make_request! body = ''
    stubs.get('/') { |_env| [ 200, {}, body ] }
    connection.get '/'
  end

  def stub_token token
    expect(extractor).to receive(:extract_from)
                          .and_return(token)
  end

  def expect_token expected_token
    expect(injector).to receive(:inject).with(expected_token, anything)
  end

  it 'registers a middleware' do
    expect(Faraday::Middleware.lookup_middleware(:csrf))
      .to eq Faraday::CSRF
  end

  describe 'initialization' do
    it 'initializes the handler'

    context "has url to fetch a token from" do
      it 'initializes the fetcher'
    end

    context "don't have url to fetch a token from" do
      it 'does not initialize the fetcher'
    end
  end

  it 'passes the request env to handle_request'
  it 'passes the response env to handle response'
end
