require 'faraday_csrf/token_extractors/composite_extractor'

describe Faraday::CSRF::CompositeExtractor do
  Token = Faraday::CSRF::Token

  let(:data) { double(:data) }
  let(:successful) { double(:successful) }
  let(:successful_extractor) do
    x = double(:successful_extractor)
    allow(x).to receive(:extract_from)
                 .and_return successful
    x
  end
  let(:unsuccessful_extractor) do
    x = double(:unsuccessful_extractor)
    allow(x).to receive(:extract_from).and_raise Token::NotFound.new
    x
  end

  let(:extractor_that_should_not_be_called) do
    double(:extractor_that_should_not_be_called)
  end

  def call_with_extractors *extractors
    composite = described_class.new(extractors)
    composite.extract_from(data)
  end

  it 'passes input to each extractor' do
    expect(successful_extractor).to receive(:extract_from).with(data)
    call_with_extractors successful_extractor
  end

  it 'returns result of first token if it\'s successful' do
    expect(call_with_extractors(successful_extractor))
      .to eq successful
  end

  it 'takes result from the first successful extractor' do
    expect(call_with_extractors(unsuccessful_extractor, successful_extractor))
      .to eq successful
  end

  it 'does not use other extractors when one is succeeded' do
    call_with_extractors successful_extractor, extractor_that_should_not_be_called
  end

  it 'raises error if none of the extractors were successful' do
    expect { call_with_extractors unsuccessful_extractor }
      .to raise_error Token::NotFound
  end

  it 'returns argument error when there are no extractors' do
    expect { call_with_extractors }.to raise_error ArgumentError
  end
end
