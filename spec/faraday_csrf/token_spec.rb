require 'faraday_csrf/token'

describe Faraday::CSRF::Token do
  Token = Faraday::CSRF::Token

  it 'has a default name' do
    expect(Token.new(value: 'blah').name)
      .to eq('authenticity_token')
  end

  it 'returns its value via to_s method (or to_str?)' do
    expect(Token.new(value: 'token').to_s)
      .to eq('token')
  end

  it 'is convertable to hash' do
    expect(Token.new(name: 'the-name', value: 'the-value').to_h)
      .to eq 'the-name' => 'the-value'
  end

  it 'has inspect method' do
    token = Token.new(name: 'hello', value: 'kitty')
    expect(token.inspect)
      .to eq "CSRF::Token('hello' => 'kitty')"
  end
end
