## Trigger when chat wait times are below 40s ##
# Zendesk streaming chat API documentation here:
# https://developer.zendesk.com/rest_api/docs/chat/apis

# EventMachine-HttpRequest documentation:
# https://github.com/igrigorik/em-http-request/wiki/Issuing-Requests

require 'eventmachine'
require 'em-http-request'
require 'pp'
require '/Users/tyoung/Pegacorn_Project/.gitignore/pegacorn_secrets'

EventMachine.run do 

  connection_options = {
    :connect_timeout => 5, # default connection setup timeout
    :inactivity_timeout => 10, # default connection inactivity (post-setup) timeout}
  }    

 	request_options = {
 		:topic => 'chats.waiting_time_avg',
  	:action =>'subscribe',
  	:window => 30,
  	:head => {
  	'authorization' => 'Bearer' + ZendeskSecrets::ZOPIM_OAUTH_ACCESS_TOKEN
    }
  }

  options = {
  :authorization => ['Bearer', ZendeskSecrets::ZOPIM_OAUTH_ACCESS_TOKEN]
  }

  http = EventMachine::HttpRequest.new('wss://rtm.zopim.com/stream',options).get 

	http.callback {
		pp http.response_header.status
		pp http.response_header
		EventMachine.stop
 	  puts "\nOk, done."
	}

	http.errback {
		print "Uh oh, there was an error. \n"
		pp http.response_header.status
		pp http.response_header
    pp http.response
		EventMachine.stop
 	  puts "\nOk, done."
	}

  http.headers { |hash|  p [:headers, hash] }
  http.stream  { |chunk| p [:data, chunk] }

end

# if waiting_time_avg <= 45
# 	puts "Light the pegacorn!"
# else
# 	puts "The time has not yet come. \n"
# end
