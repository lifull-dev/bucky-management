# frozen_string_literal: true

source 'https://rubygems.org'
ruby '2.5.1'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'bcrypt', '3.1.11'
gem 'bulma-rails'
gem 'gon'
gem 'jbuilder', '~> 2'
gem 'jquery-rails'
gem 'kaminari'
gem 'mysql2', '~> 0.3'
gem 'puma', '~> 3.12'
gem 'rails', '~> 5.2.2.1'
gem 'ransack'
gem 'sass-rails', '~> 5.0'
gem 'slim-rails'
gem 'therubyracer', platforms: :ruby
gem 'uglifier', '>= 1.3.0'
gem 'webpacker'
gem 'yaml_db'

group :development, :test, optional: true do
  gem 'awesome_print'
  gem 'bullet'
  gem 'byebug', platform: :mri
  gem 'pry-byebug'
  gem 'pry-doc', '~> 0.13'
  gem 'pry-rails'
  gem 'pry-stack_explorer'
  gem 'rails_best_practices'
  gem 'rspec-rails', '~> 3'
  gem 'rubocop', '~> 0.58.2', require: false
  gem 'simplecov'
end

group :development, optional: true do
  gem 'annotate'
  gem 'better_errors'
  gem 'brakeman', require: false
  gem 'debase'
  gem 'listen', '~> 3.0.5'
  gem 'meta_request'
  gem 'rack-env_ribbon'
  gem 'rack-mini-profiler', require: false
  gem 'ruby-debug-ide'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end
