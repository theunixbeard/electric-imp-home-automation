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
require 'json'

# helper methods
require_relative './helpers.rb'

configure do
  # current_led_status # For original proof-of-concept to get LED state pre-DB when backend restarts
  set :led_state, -1
  set :user_id, 1
end

################ Start iPhone Routes #################

# Used for iphone control + settings screens
get '/outlets.json' do
  content_type :json
  @outlets = Outlet.all(:user_id => settings.user_id)
  @outlets.to_json
end

get '/outlets/:outlet_id/schedules.json' do
  content_type :json
  @schedule = Schedule.all(:user_id => settings.user_id, :outlet_id => params[:outlet_id], :order => [ :time.asc ])
  @schedule.to_json
end

# post '/outlets/:outlet_id/schedule-toggle'
# post '/outlets/:id/rename' 

post '/outlets/:outlet_id/schedules/new' do
  # Ensure user has access rights to this outlet!!!
  begin
    state_num = params[:state].to_i
    time_num = params[:time].to_i
    day_num = params[:day].to_i
    outlet_id_num = params[:outlet_id].to_i
    user_id_num = params[:user_id].to_i

    if (state_num == 0 || state_num == 1)
      if(time_num >= 0 && time_num < 96)
        if(day_num >= 0 && day_num < 7)
          schedule = Schedule.create(:state => state_num,
                                     :time => time_num,
                                     :day => day_num,
                                     :outlet_id => outlet_id_num,
                                     :user_id => user_id_num)
          return schedule.id.to_s
        end
      end
    end
  rescue Exception => e
    logger.error e.message
    logger.error e.backtrace.inspect
  end
  return 'bad schedule'
end

post '/outlets/:outlet_id/schedules/:schedule_id/delete' do
  # Ensure user has access rights to this outlet!!!
  begin
    schedule_id_num = params[:schedule_id].to_i
    schedule = Schedule.get(schedule_id_num)
    schedule.destroy
    return schedule_id_num.to_s
  rescue Exception => e
    logger.error e.message
    logger.error e.backtrace.inspect
  end
  return 'bad schedule delete'
end

post '/outlets/:outlet_id/power-toggle' do
  begin
    outlet_id_num = params[:outlet_id].to_i
    value_num = params[:value].to_i
    set_outlet_state outlet_id_num, value_num
    return 'good power-toggle'
  rescue Exception => e
    logger.error e.message
    logger.error e.backtrace.inspect
  end
  return 'bad outlet power-toggle'
end

post '/outlets/init' do
  begin
    outlets = Outlet.all(:user_id => settings.user_id) 
    outlets.each do |outlet|
      set_outlet_state outlet.id, (outlet.state ? 1 : 0)
    end
    return "good outlet init"
  rescue Exception => e
    logger.error e.message
    logger.error e.backtrace.inspect
  end
  return "problem with outlet init"
end

post '/outlets/set-state' do
  begin
    response_json = JSON.parse(params[:value])
    outlet_id_num = response_json['outlet_id'].to_i
    state_num = response_json['state'].to_i
    logger.info 'Changed outlet #' + outlet_id_num.to_s +
                ' to state: ' + state_num.to_s
    # ACTUALLY COMMIT VALUE IN DB!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    Outlet.get(outlet_id_num).update(:state => (state_num == 1 ? true : false))
  rescue Exception => e
    logger.error e.message
    logger.error e.backtrace.inspect
  end
end

################ End iPhone Routes ####################

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

get '/outlets/:id/rename' do
  # Ensure user has access rights to this outlet!!!
  erb :outlet_rename
end

post '/outlets/:id/rename' do
  # Ensure user has access rights to this outlet!!!
  outlet = Outlet.get!(params[:id])
  if params[:name] && params[:name] != ''
    outlet.update(:user_outlet_name => params[:name])
    return params[:name]
  end
  'bad name'
end

get '/outlet/:id/schedule' do
  # Ensure user has access rights to this outlet!!!
  erb :outlet_schedule
end


post '/outlets/:outlet_id/schedule-toggle' do
  # Ensure user has access rights to this outlet!!!
  outlet = Outlet.get!(params[:outlet_id])
  if params[:value] == "0"
    # disable schedule, override active is true
    if !outlet.update(:override_active => true)
      logger.error 'Bad update!'
    end
  elsif params[:value] == "1"
    # enable schedule, override active is false
    if !outlet.update(:override_active => false)
      logger.error 'Bad update!'
    end
  else
    logger.error "Post to /outlets/:outlet_id/schedule-toggle with BAD value of " + params[:value]
    return 'bad value'
  end
  'good value'
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

get '/test.json' do
  content_type :json
  { :key1 => 'value1', :key2 => 'value2' }.to_json
end

