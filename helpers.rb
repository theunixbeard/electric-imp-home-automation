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
