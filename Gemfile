# frozen_string_literal: true

source 'https://rubygems.org'
ruby '3.1.6'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'bcrypt'
gem 'bulma-rails'
gem 'gon'
gem 'jquery-rails'
gem 'kaminari'
gem 'mini_racer', platforms: :ruby
gem 'mysql2'
gem 'psych', '~> 4.0'
gem 'puma'
gem 'rails', '~> 7.1.0'
gem 'ransack'
gem 'sass-rails'
gem 'slim-rails'
gem 'webpacker'

group :development, :test do
  gem 'awesome_print'
  gem 'bullet'
  gem 'byebug', platform: :mri
  gem 'factory_bot_rails'
  gem 'pry-byebug'
  gem 'pry-doc'
  gem 'pry-rails'
  gem 'pry-stack_explorer'
  gem 'rails_best_practices'
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'rubocop-rails'
  gem 'simplecov'
end

group :development do
  gem 'annotate'
  gem 'better_errors'
  gem 'brakeman', require: false
  gem 'debase'
  gem 'listen'
  gem 'rack-mini-profiler', require: false
  gem 'ruby-debug-ide'
  gem 'spring'
  gem 'spring-watcher-listen'
  gem 'web-console'
end
