require 'faraday_csrf'

describe Faraday::CSRF do
  before do
    @body = 'body'
  end

  let(:url) { 'https://example.com/' }
  let(:extractor) { double(:extractor).as_null_object }
  let(:injector) { double(:injector).as_null_object }

  let(:connection) do
    Faraday.new url do |conn|
      conn.use Faraday::CSRF, extractor: extractor, injector: injector
      conn.request :url_encoded
      conn.adapter :test do |stub|
        stub.get('/') { |env| [ 200, {}, @body ] }
      end
    end
  end

  def stub_get body
    @body = body
  end

  def make_request! body = ''
    stub_get body
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

  def expect_body expected_body
    expect(extractor).to receive(:extract_from) do |body|
      expect(body).to eq expected_body
    end
  end

  it 'passes request env to the extractor' do
    expect_body 'hello body'
    make_request! 'hello body'
  end

  it 'passes the token to the injector' do
    stub_token 'our token'

    # first request, not extracted token yet
    expect_token nil
    make_request!

    expect_token 'our token'
    make_request!
  end

  it 'registers a middleware' do
    expect(Faraday::Middleware.lookup_middleware(:csrf))
      .to eq Faraday::CSRF
  end
end
