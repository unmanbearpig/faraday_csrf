[![Build Status](https://travis-ci.org/unmanbearpig/faraday_csrf.svg?branch=master)](https://travis-ci.org/unmanbearpig/faraday_csrf)
[![Code Climate](https://codeclimate.com/github/unmanbearpig/faraday_csrf/badges/gpa.svg)](https://codeclimate.com/github/unmanbearpig/faraday_csrf)

# Faraday CSRF

Transparently handles Rails (and maybe not only Rails) CSRF protection, in case you need to send requests to an app that doesn't provide an API.
It tries to extract a CSRF token from each request and later inserts it into (POST, PUT, DELETE, etc.) requests that probably require it.

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
conn = Faraday.new url: 'https://a-rails-app.example.com/' do |conn|
  conn.use :csrf
  conn.request :url_encoded
  conn.use :cookie_jar
  conn.adapter Faraday.default_adapter
end
```

When you would make a get request, the CSRF thingy would try to
parse the page and extract the token from it.
When you make a POST request after that, it would add the token to it.

You have to use faraday-cookie_jar gem for handling cookies, and use :url_encoded middleware or something of that nature to allow this middleware to insert tokens.

You can get the token it extracted by accessing response_env[:csrf_token].

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/unmanbearpig/faraday_csrf.
