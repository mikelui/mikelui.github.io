# frozen_string_literal: true

source "https://rubygems.org"
gemspec

gem "jekyll", "~> 3.6.0"
gem "nokogiri"

group :jekyll_plugins do
  gem "jekyll-feed", "~> 0.6"
  gem "jekyll-paginate", "~> 1.1.0"
  gem "jekyll-paginate-v2", "~> 1.9.4"
  gem "jekyll-seo-tag"
end

require 'rbconfig'
  if RbConfig::CONFIG['target_os'] =~ /darwin(1[0-3])/i
    gem 'rb-fsevent', '<= 0.9.4'
  end
