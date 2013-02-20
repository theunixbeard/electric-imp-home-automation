require 'data_mapper'
require 'date'

class Schedule
  include DataMapper::Resource

  property :id,           Serial
  property :state,        Binary, :required => true
  property :time,         Integer, :required => true, :index => true # Not sure if this is the best choice here...
  property :day,          String, :required => true, :index => true
  property :created_at,   DateTime, :default => DateTime.now

  belongs_to :outlet, :index => true
  belongs_to :user, :index => true

end

