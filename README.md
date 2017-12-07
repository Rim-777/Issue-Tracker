### Ruby(Rails) API for the Simple Issue Tracker with ActiveRecord, RSpec, ApiPie

### Dependencies:
- Ruby 2.4.2
- PostgreSQL

### Installation:
   - Clone poject
   - Run bundler:

   ```shell
   $ bundle install
   ```
   Create database.yml:
   ```shell
   $ cp config/database.yml.sample config/database.yml
   $ bundle exec rake db:create db:migrate
   ```
   - Run application:
   ```shell
    $ rails s -p 3000
   ```
   
   ##### Tests:

   To execute tests, run following commands:

   ```shell
    $ bundle exec rake db:migrate RAILS_ENV=test #(the first time only)
    $ bundle exec rspec
   ```
   
   #### Api documentation:
   Enter the following address in the browser:
   
   ```
   http://localhost:3000/apipie
   ```
   
### License

The software is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
