require 'faraday_csrf/token_handler'

module Faraday
  class CSRF
    describe TokenHandler do
      let(:extractor) { double(:extractor) }
      let(:injector) { double(:injector) }
      let(:fetcher) { double(:fetcher) }

      subject do
        TokenHandler.new extractor: extractor,
                         injector: injector,
                         fetcher: fetcher
      end

      describe '#handle_request' do
        context 'injector does its thing' do
          it 'passes the token to the injector' do
            token = double(:token)
            subject.token = token
            request_env = double(:request_env)

            expect(injector)
              .to receive(:inject).with(token, into: request_env)

            subject.handle_request request_env
          end
        end

        context 'injector asks for a token by raising error' do
          it 'calls token fetcher and calls injector' do
            request_env = double(:request_env)

            expect(injector)
              .to receive(:inject)
                   .and_raise(TokenInjector::MissingToken)

            expect(fetcher).to receive(:call).with(request_env) do
              expect(injector).to receive(:inject).and_return(:the_token)
            end

            subject.handle_request request_env
          end
        end
      end

      describe '#handle_response' do
        context 'extractor returns the token' do
          it 'passes response body to the extractor and saves the token' do
            body = double(:body)
            token = double(:token)

            expect(extractor)
              .to receive(:extract_from).with(body)
                   .and_return(token)

            subject.handle_response double(:response, body: body)
            expect(subject.token).to eq token
          end
        end

        context "extractor can't find the token" do
          it 'catches error and does not change the token' do
            subject.token = 'the token'

            expect(extractor).to receive(:extract_from)
                                  .and_raise(Token::NotFound)

            subject.handle_response double(:respones, body: 'body')

            expect(subject.token).to eq('the token')
          end
        end
      end
    end
  end
end
