require 'rubygems'
require 'bundler/setup' #Clears all gems from the load path EXCEPT those in the Gemfile
require 'sinatra'
require 'rack-flash'

# helper methods
require_relative './helpers.rb'

configure do
  #https://api.electricimp.com/v1/15c991e47cd2d556/305b47ad02f145bf
  set :led_state, 
end

get '/' do
  #erb 'Hello!'
  erb :home
end

get '/led-state' do
  'GET to led-state'
end

post '/led-state' do
  logger.info "Setting led_state..."
  logger.info "POST to /led-state HAS BEEN RECOREDED"
  logger.info "value: " + params[:value].to_s
  logger.info "target: " + params[:target].to_s
  logger.info "channel: " + params[:channel].to_s
  logger.info "DONE WITH POST"
end

# view helpers

def is_led_on
	html = ''
	if session[:led_state] == 1
		html << 'active'
	end
	html
end
