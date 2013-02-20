require File.join(File.dirname(__FILE__), 'app')

# warden setup
Warden::Manager.serialize_into_session{|user| user.id }
Warden::Manager.serialize_from_session{|id| User.get(id) }

Warden::Manager.before_failure do |env,opts|
  env['REQUEST_METHOD'] = "POST"
end

Warden::Strategies.add(:password) do
  def valid?
    params['email'] || params['password']
  end

  def authenticate!
    user = User.authenticate(
      params['email'], 
      params['password']
      )
    user.nil? ? fail!('Could not log in') : success!(user, 'Successfully logged in')
  end
end

# rack middleware setup
use Rack::Session::Cookie, :secret => "temporarydevsecretkey"
use Rack::Flash
use Warden::Manager do |manager|
  manager.default_strategies :password
  manager.failure_app = Sinatra::Application
end

# run application
run Sinatra::Application

# To use thin as the server, uncomment thin line in Gemfile, then run 'thin -R config.ru start'
