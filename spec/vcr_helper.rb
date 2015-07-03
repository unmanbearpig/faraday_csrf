require 'vcr'

VCR.configure do |c|
  c.default_cassette_options = { record: :once }
  c.cassette_library_dir = 'vcr_cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
end
