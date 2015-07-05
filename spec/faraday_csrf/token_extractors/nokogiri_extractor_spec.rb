require 'faraday_csrf/token'
require 'faraday_csrf/token_extractors/nokogiri_extractor'

describe Faraday::CSRF::NokogiriExtractor do
  Token = Faraday::CSRF::Token
  NokogiriExtractor = Faraday::CSRF::NokogiriExtractor

  def expect_token(name, value, from_html:)
    expect(NokogiriExtractor.extract_from(from_html))
      .to eq Faraday::CSRF::Token.new(name: name,
                                      value: value)
  end

  it 'extracts the token' do
    expect_token 'testicity_token', 'the-token', from_html: <<-HTML
    <head>
      <meta name="csrf-param" content="testicity_token" />
      <meta name="csrf-token" content="the-token" />
    </head>
    HTML
  end
end
