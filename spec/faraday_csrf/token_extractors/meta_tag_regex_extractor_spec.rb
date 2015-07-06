require 'faraday_csrf/token_extractors/meta_tag_regex_extractor'
require_relative './meta_tag_extractor_examples'

describe Faraday::CSRF::MetaTagRegexExtractor do
  it_behaves_like 'meta tag token extractor'
end
