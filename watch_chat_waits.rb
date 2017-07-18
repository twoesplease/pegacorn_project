## Trigger when chat wait times are below 40s ##
# Zendesk streaming chat API documentation here: 
#https://developer.zendesk.com/rest_api/docs/chat/apis 

# Websocket gem documentation here:
# https://github.com/imanel/websocket-ruby

# Faye-Websocket gem documentation: 
# https://github.com/faye/faye-websocket-ruby

# Treehouse article on websockets: 
# http://blog.teamtreehouse.com/an-introduction-to-websockets

# Other Websockets 101 article:
# http://lucumr.pocoo.org/2012/9/24/websockets-101/

# This one has a section on Consuming WebSocket Services
# https://www.igvita.com/2009/12/22/ruby-websockets-tcp-for-the-browser/

require 'eventmachine'
require 'em-http-request'

EventMachine.run do
  http = EventMachine::HttpRequest.new("wss://rtm.zopim.com/stream").get :timeout => 0
end

  http.errback { puts "oops" }
  http.callback {
    puts "WebSocket connected!"
  }

  http.stream { |msg|
    puts "Recieved: #{msg}"
    http.send "Pong: #{msg}"
  }

  ws.close(1000)


# if waiting_time_avg <= 45
# 	puts "Light the pegacorn!"
# else
# 	puts "The time has not yet come. \n"
# end