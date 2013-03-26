require 'data_mapper'


# Set up DB
DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'sqlite3://' + File.join( File.dirname(__FILE__), 'test.db' ))


# Require all Models
require_relative '../models/User'
require_relative '../models/Outlet'
require_relative '../models/Schedule'

#Finalize Models, update if needed
DataMapper.finalize
#DataMapper.auto_migrate! # wipes existing data
DataMapper.auto_upgrade!  # doesnt wipe existing data

DataMapper::Model.raise_on_save_failure = true
