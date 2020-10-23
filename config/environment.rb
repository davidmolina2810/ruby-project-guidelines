require 'bundler'
Bundler.require

prompt = TTY::Prompt.new

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'db/development.db')
ActiveRecord::Base.logger = Logger.new('/dev/null')
require_all 'lib'
require_all 'app'
