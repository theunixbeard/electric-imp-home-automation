# view helpers

def is_led_on
  html = ''
  if settings.led_state == 1
    html << 'active'
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
