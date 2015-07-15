require 'faraday_csrf'

describe Faraday::CSRF do
  let(:url) { 'https://example.com/' }
  let(:extractor) { double(:extractor).as_null_object }
  let(:injector) { double(:injector).as_null_object }

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

  it 'passes response body to the extractor' do
    make_request! 'hello body'

    expect(extractor).to have_received(:extract_from)
                          .with 'hello body'
  end

  it 'passes the token to the injector' do
    stub_token 'our token'

    # first request, not extracted token yet
    expect_token nil
    make_request!

    expect_token 'our token'
    make_request!
  end
end
