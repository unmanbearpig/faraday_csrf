require 'faraday'
require 'faraday_csrf'
require 'faraday-cookie_jar'
require 'vcr_helper'

describe Faraday::CSRF do
  let(:url) { 'https://post-ping.herokuapp.com/' }

  let(:connection) do
    Faraday.new url: url do |conn|
      conn.use Faraday::CSRF

      conn.request :url_encoded
      conn.use :cookie_jar
      conn.adapter Faraday.default_adapter
    end
  end

  context 'simple Rails app' do
    it 'successfully posts to rails app' do
      post_response = VCR.use_cassette 'simple_rails_app_simple_post' do
        connection.get '/'

        # POST in rails have csrf protection
        connection.post '/echo', 'some data': 'blah'
      end

      expect(post_response.status).to eq 200
    end
  end
end
