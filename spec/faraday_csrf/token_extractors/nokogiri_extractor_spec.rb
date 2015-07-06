require 'faraday_csrf/token'
require 'faraday_csrf/token_extractors/nokogiri_extractor'
require_relative './meta_tag_extractor_examples'

describe Faraday::CSRF::NokogiriExtractor do
  it_behaves_like 'meta tag token extractor'
end
