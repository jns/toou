source 'https://rubygems.org'
ruby "2.6.5"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~>5.2.1'
# Use sqlite3 as the database for Active Record
gem 'pg'

# Use AWS S3 for persistent file storage
gem 'aws-sdk-s3', '~> 1'

# Use SCSS for stylesheets
gem 'sassc-rails', '~>2.1.1'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~>4.2.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use bootstrap
gem 'bootstrap', '~>4.1.3'
# Use iconic icons
gem 'open-iconic-rails'

# Use jquery as the JavaScript library
gem 'jquery-rails', '~>4.3.3'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks', '~> 5.2.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use the nomad command line tools for generating apple passes
gem 'dubai', '~> 0.1.0'

# Use the twilio gem for sending SMS
gem 'twilio-ruby'

# Use jason web tokens for authentication
gem 'jwt'

# Use SimpleCommand for dispatching commands
gem 'simple_command'

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Use Apnotic for Apple User Notifications
gem 'apnotic', '~> 1.4.1'

# Use Stripe for payment processing
gem 'stripe', '~> 4.24.0'

# Use pundit for authorization policies
gem 'pundit', '~> 2.0.1'

# Use barby for barcode generation
#gem 'barby'

# For image resizing
gem 'image_processing', '~> 1.2'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 3.7.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '2.0.2'
end

group :test do
  gem 'cucumber-rails', require: false
  # database_cleaner is not required, but highly recommended
  gem 'database_cleaner'
end