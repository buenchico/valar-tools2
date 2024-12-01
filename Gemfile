source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem "rails", "~> 7.0.6"
# database gems
gem 'pg', '1.5.2'
gem 'rails_12factor'
# Use Puma as the app server
gem 'puma', '~> 5.0'
# Use SCSS for stylesheets
gem 'sassc-rails', '>= 2.1.2'
# Use jquery
gem 'jquery-rails', '>= 4.4.0'
gem 'jquery-ui-rails', '>= 6.0.1'
# Use terser to compress js
gem 'terser', '~> 1.2', '>= 1.2.3'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Bootstrap framework for CSS
gem 'bootstrap', '~> 5.3', '>= 5.3.3'
# support for API calls
gem 'faraday'
gem 'faraday-net_http_persistent'
# accessing the clipboard
gem 'clipboard-rails'
# sorting tables
gem 'jquery-tablesorter'
# markdown
gem 'kramdown', '~> 2.4'
# leaflef support
gem 'leaflet-rails'
gem 'leaflet-draw-rails'
gem 'csv'
# Use pg_search for native searches
gem 'pg_search', '~> 2.3', '>= 2.3.7'
# Use pagination
gem 'kaminari', '~> 1.2', '>= 1.2.2'
gem 'bootstrap5-kaminari-views', '~> 0.0.1'

# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'faker'

  gem 'wdm', '>= 0.1.0', platforms: :mswin
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.1.0'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'rack-mini-profiler', '~> 2.0'
  gem 'listen', '~> 3.3'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data'

# To prevent heroku failing, remove once fix is in place
gem "ffi", "< 1.17.0"
