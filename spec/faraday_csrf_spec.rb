require 'faraday_csrf'
require 'webmock/rspec'
require 'faraday_csrf/token'

describe Faraday::CSRF do
  Token = Faraday::CSRF::Token

  let(:url) { 'https://example.com/' }
  let(:extractor) { double(:extractor) }

  let(:connection) do
    Faraday.new url do |conn|
      conn.use Faraday::CSRF, extractor: extractor
      conn.request :url_encoded
      conn.adapter Faraday.default_adapter
    end
  end

  def stub_get body
    stub_request(:get, url)
      .to_return(body: body)
  end

  def stub_extractor &block
    allow(extractor).to receive :extract_from, &block
    extractor
  end

  it 'uses the extractor' do
    expect(extractor)
      .to receive(:extract_from).with('-~-body-~-') { 'the-token' }

    stub_get '-~-body-~-'
    response = connection.get('/')

    expect(response.env[:csrf_token])
      .to eq 'the-token'
  end

  it 'injects the token into POST requests' do
    stub_extractor do
      Token.new name: 'hello-token',
                value: 'the-token-itself'
    end

    stub_get 'blah'
    connection.get('/')

    post_request_stub = stub_request(:post, url)
                        .with(body: { 'post_data' => 'data',
                                      'hello-token' => 'the-token-itself' })

    connection.post('/', post_data: 'data')
    expect(post_request_stub).to have_been_made
  end

  it 'does not set the csrf_token if it is not found' do
    stub_extractor do
      raise Faraday::CSRF::Token::NotFound.new
    end

    stub_get 'blah'
    response = connection.get('/')

    expect(response.env.key?(:csrf_token))
      .to be_falsey
  end

  it 'does not reuse the token' do
    stub_extractor do
      Token.new value: 'the-token'
    end

    stub_get 'test'
    connection.get '/'

    stub_request(:post, url)
      .to_return body: 'does not matter'

    stub_extractor do
      raise Token::NotFound.new
    end

    connection.post '/', test: 'hello' # expiring the token

    post_request = stub_request(:post, url)
      .with(body: { 'hello' => 'kitty' })
      .to_return body: 'does not mater again'

    connection.post '/', 'hello' => 'kitty'

    expect(post_request).to have_been_made
  end

  it 'registers a middleware' do
    expect(Faraday::Middleware.lookup_middleware(:csrf))
      .to eq Faraday::CSRF
  end
end
