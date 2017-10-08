source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.1.4'
gem 'pg', '~> 0.18'
gem 'puma', '~> 3.7'
gem 'devise'
gem 'simple_token_authentication', '~> 1.15', '>= 1.15.1'
gem 'api-versions', '~> 1.2', '>= 1.2.1'
gem 'responders', '~> 2.3'
gem 'active_model_serializers', '~> 0.10.2'
gem 'rolify', '~> 5.1'
gem 'state_machines-activerecord'
gem 'pundit', '~> 1.1'
gem 'will_paginate'
gem 'api-pagination'
gem 'apipie-rails'

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :test do
  gem 'shoulda-matchers'
  gem 'json_spec'
  gem "json_matchers"
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
