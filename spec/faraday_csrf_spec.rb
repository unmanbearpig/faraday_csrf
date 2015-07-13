require 'faraday_csrf'

describe Faraday::CSRF do
  let(:url) { 'https://example.com/' }
  let(:extractor) { double(:extractor).as_null_object }
  let(:injector) { double(:injector) }

  let(:connection) do
    connection_with_csrf extractor: extractor, injector: injector do |stub|
      stub.get('/') { |env| [ 200, {}, @body ] }
    end
  end

  def connection_with_csrf params, &block
    Faraday.new url do |conn|
      conn.use Faraday::CSRF, params
      conn.request :url_encoded
      conn.adapter :test, &block
    end
  end

  def make_request! body = ''
    @body = body
    connection.get '/'
  end

  def stub_token token
    expect(extractor).to receive(:extract_from)
                          .and_return(token)
  end

  def expect_token expected_token
    expect(injector).to receive(:inject) do |token, _request_env|
      expect(token).to eq expected_token
    end
  end

  it 'registers a middleware' do
    expect(Faraday::Middleware.lookup_middleware(:csrf))
      .to eq Faraday::CSRF
  end

  it 'passes request env to the extractor' do
    make_request! 'hello body'

    expect(extractor).to have_received(:extract_from) do |body|
      expect(body).to eq 'hello body'
    end
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
