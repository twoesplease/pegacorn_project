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

# EventMachine-HttpRequest documentation: 
# https://github.com/igrigorik/em-http-request/wiki/Issuing-Requests

require 'eventmachine'
require 'em-http-request'
require 'pp'
require '/Users/user/Desktop/Pegacorn_Project/.gitignore/pegacorn_secrets'

# May needto move OAuth token to its own hash, as well as the last three key/value
# pairs, since they're the metric I want to subscribe to.  
# The http item only takes 1-2 args tho, so I can't pass in three hash vars.
EventMachine.run do
	options = {
        :connect_timeout => 5,        # default connection setup timeout
        :inactivity_timeout => 10,    # default connection inactivity (post-setup) timeout
        :Authorization => 'Bearer ' + ZendeskSecrets::OAUTH_SECRET,
        :topic => "chats.waiting_time_avg",
    	:action =>"subscribe",
    	:window => 30
      }

 	http = EventMachine::HttpRequest.new('wss://rtm.zopim.com/stream', options).get

	http.callback do
		pp http.response_header.status
		pp http.response_header
	end

	# Getting 0 for error code and nothing in the header, so it seems 
	# like I'm not connecting at all
	http.errback do
		print "Uh oh, there was an error. \n"
		pp http.response_header.status
		pp http.response_header
	end
 	
 		EventMachine.stop
 	end

 	puts "\nOk, done."
  
# if waiting_time_avg <= 45
# 	puts "Light the pegacorn!"
# else
# 	puts "The time has not yet come. \n"
# end