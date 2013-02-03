require File.join(File.dirname(__FILE__), 'app')

# rack middleware setup
use Rack::Session::Cookie, :secret => "temporarydevsecretkey"
use Rack::Flash

# run application
run Sinatra::Application

# To use thin as the server, uncomment thin line in Gemfile, then run 'thin -R config.ru start'
