source "https://rubygems.org"

gem "rails", "~> 8.1.1"
gem "propshaft"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "tailwindcss-rails", "~> 4.4.0"
gem "jbuilder"
gem "money"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "image_processing", "~> 1.2"

gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

gem "bootsnap", require: false
gem "kamal", require: false
gem "thruster", require: false

gem "karafka"
gem "waterdrop"

gem "bundle-audit", require: false

gem "dry-transaction"

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
  gem "memory_profiler"
end

group :development do
  gem "web-console"
  gem "pry"
end

group :test do
  gem "rspec-rails"
  gem "shoulda-matchers"
  gem "factory_bot_rails"
  gem "rails-controller-testing"
  gem "cucumber-rails", require: false
  gem "database_cleaner"
  gem "capybara"
  gem "selenium-webdriver"
  gem "karafka-testing"
end
