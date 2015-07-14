require 'faraday_csrf/token_injector'

describe Faraday::CSRF::TokenInjector do
  subject { described_class.new }

  it 'injects the token' do
    token = double :token,
                   to_h: { 'hello' => 'kitty' },
                   'expire!': nil

    body_hash = {}

    env = double(:env, body: body_hash, method: :post)

    subject.inject token, into: env

    expect(body_hash).to eq 'hello' => 'kitty'
  end

  it 'expires the token' do
    token = double to_h: { 'hello' => 'kitty' }

    expect(token).to receive 'expire!'
    subject
      .inject token, into: double(method: :post, body: {})
  end

  it 'has default safe methods' do
    expect(subject.ignore_methods)
      .to eq [:get, :head]
  end

  it 'does not inject into ignored method' do
    injector = described_class.new ignore_methods: [:post]

    token = double(:token_without_to_h)

    injector.inject token,
                    into: double(:env_that_should_not_change,
                                 method: :post, body: '')
  end

  it 'raises error if we need a token that we don\'t have' do
    expect do
      subject.inject nil, into: double(:env, method: :post, body: {})
    end.to raise_error Faraday::CSRF::TokenInjector::MissingToken
  end

  it 'does not raise error if we don\' have a token when we don\'t need one' do
    subject.inject nil, into: double(:env, method: :get)
  end

  it 'ignores string body' do
    token = double to_h: { 'hello' => 'kitty' }
    subject.inject token, into: double(:env, method: :post, body: 'body string')
  end
end
