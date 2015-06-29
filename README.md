# Faraday CSRF

Saves a (Rails) CSRF token, and later adds it to POST requests.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'faraday_csrf'
```
You need to add it to your stack, you would also need a cookie_jar
(gem 'faraday-cookie_jar').


## Usage

Create a Faraday connection like this:

```ruby
conn = Faraday.new url: 'https://a-rails-app.com/' do |conn|
  conn.use Middleware::CSRF
  conn.request :url_encoded
  conn.use :cookie_jar
  conn.adapter Faraday.default_adapter
end
```

When you would make a get request, the CSRF thingy would try to
parse the page and extract the token from it.
When you make a POST request after that, it would add the token to it.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/unmanbearpig/faraday_csrf.
