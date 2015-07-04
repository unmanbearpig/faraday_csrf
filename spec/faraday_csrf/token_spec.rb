require 'faraday_csrf/token'

describe Faraday::CSRF::Token do
  Token = Faraday::CSRF::Token

  it 'has a default name' do
    expect(Token.new(value: 'blah').to_h)
      .to eq('authenticity_token' => 'blah')
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

  describe '#expire' do
    subject { Token.new(name: 'hello', value: 'kitty').expire! }

    it 'clears the to_h' do
      expect(subject.to_h).to eq({})
    end

    it 'shows that it is expired in inspect' do
      expect(subject.inspect).to eq 'CSRF::Token(~expired~)'
    end

    it 'returns itself' do
      subject = Token.new name: 'hello', value: 'kitty'

      expect(subject.expire!).to eq subject
    end
  end
end
