require 'rubygems'
require 'bundler/setup' #Clears all gems from the load path EXCEPT those in the Gemfile
require 'sinatra'
require 'rack-flash'
require 'data_mapper'
require_relative './config/database'
require 'warden'
require 'net/http'
require 'net/https'
require 'uri'

# helper methods
require_relative './helpers.rb'

configure do
  current_led_status
  set :led_state, -1
  set :user_id, 1
end

def control_route
  @outlets = Outlet.all(:user_id => settings.user_id)
  #control assumes outlets instance variable w/ all current user's outlets
  erb :control
end

get '/' do
  control_route
end

get '/control' do
  control_route
end

get '/setup' do
  @outlets = Outlet.all(:user_id => settings.user_id)
  #setup assumes outlets instance variable w/ all current user's outlets
  erb :setup
end

get '/outlet/:id' do
  # Ensure user has access rights to this outlet!!!
  erb :outlet_settings
end

get '/led-state' do
  'GET to led-state'
end

post '/led-state' do
  logger.info "Setting led_state..."
  settings.led_state = params[:value].to_i
  logger.info "POST to /led-state HAS BEEN RECORDED"
  logger.info "value: " + params[:value].to_s
  logger.info "target: " + params[:target].to_s
  logger.info "channel: " + params[:channel].to_s
  logger.info "DONE WITH POST"
end

