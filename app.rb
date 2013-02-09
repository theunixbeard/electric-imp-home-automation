require 'rubygems'
require 'bundler/setup' #Clears all gems from the load path EXCEPT those in the Gemfile
require 'sinatra'
require 'rack-flash'
require 'net/http'
require 'net/https'
require 'uri'

# helper methods
require_relative './helpers.rb'

configure do
  current_led_status
  set :led_state, -1
end

get '/' do
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

