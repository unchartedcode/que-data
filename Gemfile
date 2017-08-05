source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

group :development, :test do
  gem 'rake'
  gem 'sequel',          :require => nil
  gem 'activerecord',    :require => nil
  gem 'pg',              :require => nil, :platform => :ruby
  gem 'minitest-reporters', require: nil
  gem 'minitest-line', require: nil
  gem 'byebug'
end

# Specify your gem's dependencies in que-data.gemspec
gemspec
