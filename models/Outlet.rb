require 'data_mapper'
require 'date'

class Outlet
  include DataMapper::Resource

  property :id,                 Serial
  property :user_outlet_number, Integer, :required => true
  property :user_outlet_name,   String # Default length of 50 character should be sufficient...
  property :state,              Boolean, :required => true
  property :override_active,    Boolean, :required => true
  property :created_at,         DateTime, :default => DateTime.now

  belongs_to :user, :index => true

end

