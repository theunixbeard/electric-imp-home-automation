require 'data_mapper'
require 'date'
require 'bcrypt'

class User
  include DataMapper::Resource
  include BCrypt

  property :id,               Serial
  property :email,            String, 
                              :format => :email_address, 
                              :required => true, 
                              :unique => true, 
                              :length => 254, # max email length 254 char per IETF standard
                              :index => true
  property :password_hash,    String, :required => true, :length => 70
  property :salt,             String, :required => true
  property :created_at,       DateTime, :default => DateTime.now

  has n, :outlets
 
  validates_presence_of :email, :password_hash, :salt

  def password_hash_and_salt(password)
    if password.length <= 6
      raise 'Hmmmmm! Please use a password that is longer than 6 characters'
    end
    self.salt = Engine.generate_salt
    self.password_hash = Engine.hash_secret(password, self.salt)
  end

  def self.authenticate(email, password)
    u = User.first(:email => email)
    return nil if u.nil?
    return u if u.password_hash == Engine.hash_secret(password, u.salt)
    nil
  end
end
