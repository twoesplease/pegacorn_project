require 'faye/websocket'
require 'eventmachine'
require '/Users/tyoung/Pegacorn_Project/.gitignore/pegacorn_secrets'

EM.run {
  headers = {
    'Authorization' => 'Bearer' + ZendeskSecrets::ZOPIM_OAUTH_ACCESS_TOKEN
  }


  wss = Faye::WebSocket::Client.new('wss://rtm.zopim.com/stream', headers)

  wss.on :open do |event|
    p [:open]
    ws.send('Hello, world!')
  end

  wss.on :message do |event|
    p [:message, event.data]
  end

  wss.on :close do |event|
    p [:close, event.code, event.reason]
    wss = nil
  end
}
