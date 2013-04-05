# view helpers

def toggle_active_html
  html = ''
  if get_led_state == 1
    html << 'active'
  end
  html
end

def get_led_state
  settings.led_state
end

# layout.erb helpers
def tab_is_active(actual_app_title, tab_title)
  if actual_app_title == tab_title
    "active"
  else
    ""
  end
end

def back_button back_button_url
  html = ''
  if back_button_url != ''
    html << '<a class="button-prev" href="' + back_button_url + '">'
    html << 'Back'
    html << '</a>'
  end
  html
end

# control.erb helpers

def outlet_number_human outlet
  (outlet.user_outlet_number + 1).to_s
end

def outlet_active_html outlet
  html = ''
  if outlet.state
    html << ' active'
  end
  html
end

def outlet_name outlet
  if outlet.user_outlet_name && outlet.user_outlet_name != ""
    outlet.user_outlet_name
  else
    'Outlet ' + outlet_number_human(outlet)
  end
end

def outlet_toggle_list
=begin
  <li>
    <strong>Toggle LED On/Off</strong>
    <div class="toggle <%= toggle_active_html %>" id="toggleLED">
      <div class="toggle-handle"></div>
    </div>
  </li>
=end
  html = ''
  @outlets.each do |outlet|
    html << '<li>'
    html << '<strong>' << outlet_name(outlet) << '</strong>'
    html << '<div class="toggle' << outlet_active_html(outlet) << '" id="outlet' << outlet_number_human(outlet) << '">'
    html << '<div class="toggle-handle"></div>'
    html << '</div>'
    html << '</li>'
  end
  html
end
=begin
  <li>
    <a href="#" onclick="toggleLED()">
      <strong>Web Test Button</strong>
      <span class="chevron"></span>
    </a>
  </li>
=end

# setup.erb helpers

def outlet_settings_list
=begin
  <li>List item 1 <a class="button-main" href="/outlet1">Button</a></li>
=end
  html = ''
  @outlets.each do |outlet|
    html << '<li>'
    html << '<strong>' << outlet_name(outlet) << '</strong>'
    html << '<a class="button-main" href="/outlet/' << outlet_number_human(outlet) << '">Settings</a>'
    html << '</li>'
  end
  html
end

# outlet_settings.erb helpers

def toggle_schedule
=begin
<a class="button-positive button-block">Block button</a>
=end
  html = ''
  outlet = Outlet.get!(params[:id])
  if Schedule.count(:outlet_id => params[:id]) > 0
    if(outlet.override_active)
      html << '<a class="button-positive button-block" id="schedule_change_button">Enable Schedule</a>'
    else
      html << '<a class="button-negative button-block" id="schedule_change_button">Disable Schedule</a>'
    end
  end
end

# outlet_schedule.erb helpers

def human_readable_time integer_time
  hour = integer_time / 4
  minute = (integer_time % 4) * 15
  modifier = 'am'
  if hour == 0
    hour = 12
  elsif hour > 12
    hour = hour % 12
    modifier = 'pm'
  end
  if minute == 0
    minute = '00'
  end
  hour.to_s + ':' + minute.to_s + ' ' + modifier
end

def display_schedule wday
=begin
  <li>List item 1 <a class="button-negative">Remove</a></li>
=end
  html = ''
  schedules = Schedule.all(:outlet_id => params[:id], :day => wday)
  schedules.each do |schedule|
    html << '<li>'
    html << human_readable_time(schedule.time)
    html << " "
    if schedule.state
      html << "ON"
    else
      html << "OFF"
    end
    html << '<a id="schedule' + schedule.id.to_s + '" class="button-negative">Remove</a>'
    html << '</li>'
  end
  html
end

# other helpers

def current_led_status
  uri = URI.parse 'https://api.electricimp.com/v1/15c991e47cd2d556/305b47ad02f145bf?value=status&channel=2'
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Post.new(uri.request_uri)
  request.set_form_data({"value" => "-1", "channel" => "2"})
  response = http.request(request)
  puts response
end

def set_outlet_state outlet_id_num, value_num
  puts 'Changed outlet #' + outlet_id_num.to_s +
              ' to value: ' + value_num.to_s
  imp_url = User.get(settings.user_id).imp_url
  outlet = Outlet.get(outlet_id_num)
  # Begin HTTP Post Boilerplate
  uri = URI.parse imp_url.to_s #convert addressable/uri to stdlib URI
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Post.new(uri.request_uri)
  value_json_hash = {
    :board_product_key    => outlet.board_product_key.to_s,
    :board_outlet_number  => outlet.board_outlet_number.to_s,
    :state                => value_num.to_s,
    :outlet_id            => outlet_id_num.to_s
  }
  puts value_json_hash.to_json
  request.set_form_data(
    {
      'value' => value_json_hash.to_json,
      'channel' => '1'
    })
  response = http.request(request)
  puts response.to_s
  #end HTTP Post Boilerplate
end
