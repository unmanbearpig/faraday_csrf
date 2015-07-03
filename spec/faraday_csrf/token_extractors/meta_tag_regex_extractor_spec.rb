require 'faraday_csrf/token_extractors/meta_tag_regex_extractor'

describe Faraday::CSRF::MetaTagRegexExtractor do
  MetaTagRegexExtractor = Faraday::CSRF::MetaTagRegexExtractor

  def expect_token(name, value, from_html:)
    expect(MetaTagRegexExtractor.extract_from(from_html))
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

  it 'works when name comes after the content' do
    expect_token 'testicity_token', 'the-token', from_html: <<-HTML
    <head>
      <meta name="csrf-param" content="testicity_token" />
      <meta name="csrf-token" content="the-token" />
    </head>
    HTML
  end

  it 'works when tags are in a different order' do
    expect_token 'testicity_token', 'the-token', from_html: <<-HTML
    <head>
      <meta content="the-token" name="csrf-token"/>
      <meta content="testicity_token" name="csrf-param"/>
    </head>
    HTML
  end

  it 'has a value even when there is no name' do
    expect_token 'authenticity_token', 'the-token', from_html: <<-HTML
    <head>
      <meta content="the-token" name="csrf-token"/>
    </head>
    HTML
  end



  it 'raises TokenNotFound error' do
    expect { MetaTagRegexExtractor.extract_from('hello') }
      .to raise_error Faraday::CSRF::Token::NotFound
  end
end
