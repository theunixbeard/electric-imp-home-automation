require 'rubygems'
require 'bundler/setup' #Clears all gems from the load path EXCEPT those in the Gemfile
require 'sinatra'
require 'rack-flash'


get '/' do
  #erb 'Hello!'
  erb :home
end

post '/led_state' do
  logger.info "Setting led_state..."
  session[:led_state] = params[:value]
  logger.info "Set led_state to: " + params[:value].to_s
end

# view helpers

def is_led_on
	html = ''
	if session[:led_state] == 1
		html << 'active'
	end
	html
end