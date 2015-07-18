require 'faraday_csrf/creates_token_handler'

module Faraday
  class CSRF
    describe CreatesTokenHandler do
      context "don't have url to fetch a token from" do
        it 'does not initialize the fetcher' do
          factory = CreatesTokenHandler.new(app: double(:app), fetch_token_from_url: nil)

          expect(factory.fetcher).to be_kind_of(Proc)
        end
      end

      context "has url to fetch a token from" do
        it 'initializes the fetcher' do
          factory = CreatesTokenHandler.new(app: double(:app), fetch_token_from_url: '/url')

          expect(factory.fetcher).to be_kind_of(TokenFetcher)
        end
      end
    end
  end
end
