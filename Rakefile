require_relative 'config/environment'
require 'sinatra/activerecord/rake'

desc 'starts a console'
task :console do
  #ActiveRecord::Base.logger = Logger.new(STDOUT)
  ActiveRecord::Base.connection.execute("BEGIN TRANSACTION; END;")
  Pry.start
end
