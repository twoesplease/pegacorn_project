## Trigger when chat wait times are below 40s ##
# Zendesk streaming chat API documentation here: 
#https://developer.zendesk.com/rest_api/docs/chat/apis 

# EventMachine-HttpRequest documentation: 
# https://github.com/igrigorik/em-http-request/wiki/Issuing-Requests

require 'eventmachine'
require 'em-http-request'
require 'pp'
require '/Users/tyoung/Pegacorn_Project/.gitignore/pegacorn_secrets'

EventMachine.run {
	request_options = {
        :connect_timeout => 5,        # default connection setup timeout
        :inactivity_timeout => 10    # default connection inactivity (post-setup) timeout
 	}

 	options = {
 		:topic => 'chats.waiting_time_avg',
    	:action =>'subscribe',
    	:window => 30,

    	:head => {
    	'authorization' => 'Bearer' + ZendeskSecrets::ZOPIM_OAUTH_ACCESS_TOKEN
    	}
 	}

 	http = EventMachine::HttpRequest.new('wss://rtm.zopim.com/stream', options).get request_options

	http.callback {
		pp http.response_header.status
		pp http.response_header
		EventMachine.stop
	}

	# Getting 0 for error code and nothing in the header, so it seems 
	# like I'm not connecting at all
	http.errback {
		print 'Uh oh, there was an error. \n'
		pp http.response_header.status
		pp http.response_header
    pp http.response
		EventMachine.stop
	}
}
 	
 	puts '\nOk, done.'
  
# if waiting_time_avg <= 45
# 	puts "Light the pegacorn!"
# else
# 	puts "The time has not yet come. \n"
# end
