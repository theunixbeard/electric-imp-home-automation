


task :seed_db do
  require_relative './config/database'
  DataMapper.auto_migrate!
  @user = User.create(
    :email          => 'ee459group1@gmail.com',
    :password_hash  => '123',
    :salt           => '456',
    :imp_url        => 'https://api.electricimp.com/v1/15c991e47cd2d556/30106fa2633694d6'
  )
  @outlets = Array.new
  # Main board outlets
  (0..3).each do |n|
    @outlets[n] = Outlet.create(
      :user_outlet_number   => n,
      :state                => (n%2 == 0),
      :override_active      => false,
      :user                 => @user,
      :board_product_key    => '1234567890',
      :board_outlet_number  => n
    )
  end
  # Remote board #1 outlets
  (4..7).each do |n|
    @outlets[n] = Outlet.create(
      :user_outlet_number   => n,
      :state                => (n%2 == 0),
      :override_active      => false,
      :user                 => @user,
      :board_product_key    => '1234511111',
      :board_outlet_number  => (n - 4)
    )
  end
  # Remote board #2 outlets
  (8..11).each do |n|
    @outlets[n] = Outlet.create(
      :user_outlet_number   => n,
      :state                => (n%2 == 0),
      :override_active      => false,
      :user                 => @user,
      :board_product_key    => '1234522222',
      :board_outlet_number  => (n - 8)
    )
  end

  # 15 min intervals, so times range from 0-95 (24*4)
  @schedules = Array.new
  (0..15).each do |n|
    if n < 4
      @schedules[n] = Schedule.create(
        :state  => ((n % 2) == 0),
        :time   => n*6 % 96,
        :day    => 0,
        :outlet => @outlets[0],
        :user   => @user
      )
    elsif n < 8
      @schedules[n] = Schedule.create(
        :state  => ((n % 2) == 0),
        :time   => n+4 % 96,
        :day    => 1,
        :outlet => @outlets[0],
        :user   => @user
      )
    elsif n < 12
      @schedules[n] = Schedule.create(
        :state  => ((n % 2) == 0),
        :time   => n*4 + 11 % 96,
        :day    => n%7,
        :outlet => @outlets[1],
        :user   => @user
      )
    else
      @schedules[n] = Schedule.create(
        :state  => ((n % 2) == 0),
        :time   => n%4 +6,
        :day    => 4,
        :outlet => @outlets[2],
        :user   => @user
      )
    end
  end
end

task :schedule_execute do
  require_relative './config/database'
  require_relative './helpers.rb'
  # Check if any Outlets need to change at this time
  current_time = Time.new
  # puts current_time
  # puts current_time.wday # sunday == 0, monday == 1 etc.
  quarter_hour_section = (current_time.hour * 4) + (current_time.min / 15)
  schedules = Schedule.all(:time => quarter_hour_section, :day => current_time.wday)
  File.open("/Users/primary/programming/electric-imp-home-automation/schedule_log.txt", "a") do |f|
  #File.open("/home/primaryubuntu/programming/sinatra/electric-imp-home-automation/schedule_log.txt", "a") do |f|
  #File.open("/home/ubuntu/programming/electric-imp-home-automation/schedule_log.txt", "a") do |f|
    f.write "Schedule task run at: " + current_time.to_s + "\n"
    f.write "quarter_hour_section: " + quarter_hour_section.to_s + "\n"
    f.write "wday: " + current_time.wday.to_s + "\n"
    f.write "----------------------------------------------------------\n"
    schedules.each do |s|
      # Make function call
      set_outlet_state s.outlet_id, s.state ? 1 : 0
      f.write(s.id.to_s + "\t " + 
              s.state.to_s + "\t " + 
              s.time.to_s + "\t " + 
              s.day.to_s + "\t " +
              s.outlet_id.to_s + "\t " + 
              s.user_id.to_s + "\t \n"
             )
    f.write "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n\n\n\n"
    end
  end
end
