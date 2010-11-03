source "http://rubygems.org"

group :development do
  if RUBY_VERSION.match(/^1\.8/)
    gem 'ruby-debug'
  elsif RUBY_VERSION.match(/^1\.9/)
    gem 'ruby-debug19'
  end
  gem "rspec", ">= 2.0.0.beta.19"
  gem "bundler", "~> 1.0.0"
  gem "jeweler", "~> 1.5.0.pre3"
  gem "rcov", ">= 0"
end
