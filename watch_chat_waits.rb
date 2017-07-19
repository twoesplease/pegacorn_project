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
require "/Users/user/Desktop/Pegacorn_Project/.gitignore/pegacorn_secrets"

EventMachine.run {
	http = EventMachine::HttpRequest.new(wss://rtm.zopim.com/stream).get

	options = {
          :connect_timeout => 5,        # default connection setup timeout
          :inactivity_timeout => 10,    # default connection inactivity (post-setup) timeout

 		request_options = {
 			:head => {
 				'authorization' => [ZendeskSecrets::ZOPIM_USERNAME, ZendeskSecrets::ZOPIM_PASSWORD] 
 			}
 		}

 	# Next, I need to find out how to Convert this to Ruby and send it as a message
 	# to the server:
 	#{
    #	topic: "chats.waiting_time_avg",
    #	action: "subscribe",
    #	window: 30
	#}

	# I will then also need a method for parsing the response.

 	
 		EventMachine.stop
 	}

# if waiting_time_avg <= 45
# 	puts "Light the pegacorn!"
# else
# 	puts "The time has not yet come. \n"
# end