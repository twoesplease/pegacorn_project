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

require "websocket"

@handshake = WebSocket::Handshake::Client.new(url: 'wss://rtm.zopim.com/stream')

# Create request
@handshake.to_s 

# Parse server response
@handshake << <<EOF
HTTP/1.1 101 Switching Protocols\r
Upgrade: websocket\r
Connection: Upgrade\r
Sec-WebSocket-Accept: \r
\r
EOF

# All data received?
@handshake.finished?

# No parsing errors?
@handshake.valid?




if waiting_time_avg <= 45
	puts "Light the pegacorn!"
else
	puts "The time has not yet come. \n"
end