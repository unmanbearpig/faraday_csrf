require 'faraday_csrf'
require 'webmock/rspec'
require 'faraday_csrf/token'

# TODO: extract token extractor and token injector parts
describe Faraday::CSRF do
  Token = Faraday::CSRF::Token

  let(:url) { 'https://example.com/' }
  let(:extractor) { double(:extractor) }

  def connection_with_extractor extractor
    Faraday.new url do |conn|
      conn.use Faraday::CSRF, extractor
      conn.request :url_encoded
      conn.adapter Faraday.default_adapter
    end
  end

  def stub_get body
    stub_request(:get, url)
      .to_return(body: body)
  end

  it 'uses the extractor' do
    expect(extractor)
      .to receive(:extract_from).with('-~-body-~-') { 'the-token' }

    conn = connection_with_extractor extractor

    stub_get '-~-body-~-'
    response = conn.get('/')

    expect(response.env[:csrf_token])
      .to eq 'the-token'
  end

  it 'injects the token into POST requests' do
    allow(extractor).to receive :extract_from do
      Token.new name: 'hello-token',
                value: 'the-token-itself'
    end

    conn = connection_with_extractor extractor

    stub_get 'blah'
    conn.get('/')

    post_request_stub = stub_request(:post, url)
                        .with(body: { 'post_data' => 'data',
                                      'hello-token' => 'the-token-itself' })

    conn.post('/', post_data: 'data')
    expect(post_request_stub).to have_been_made
  end

  it 'does not set the csrf_token if it is not found' do
    allow(extractor).to receive :extract_from do
      raise Faraday::CSRF::Token::NotFound.new
    end

    conn = connection_with_extractor extractor

    stub_get 'blah'
    response = conn.get('/')

    expect(response.env.key?(:csrf_token))
      .to be_falsey
  end

  it 'does not add token to get or head'
  it 'removes the token after it was used'

  it 'registers the middleware'
end
