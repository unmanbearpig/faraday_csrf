require 'faraday_csrf/token'
require 'faraday_csrf/token_extractors/meta_tag_nokogiri_extractor'
require_relative './meta_tag_extractor_examples'

describe Faraday::CSRF::MetaTagNokogiriExtractor do
  it_behaves_like 'meta tag token extractor'
end
