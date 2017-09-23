require 'faye/websocket'
require 'eventmachine'
require '/Users/tyoung/Pegacorn_Project/.gitignore/pegacorn_secrets'

EM.run do
  wss = Faye::WebSocket::Client.new('wss://rtm.zopim.com/stream',
                                    nil,
                                    :headers =>
        { 'Authorization' => "Bearer #{ZendeskSecrets::ZENDESK_OAUTH_ACCESS_TOKEN}" })

  wss.on :open do
    p [:open]
    wss.send('Hello, world!')
  end

  wss.on :message do |event|
    p [:message, event.data]
  end

  wss.on :close do |event|
    p [:close, event.code, event.reason]
    wss = true
  end
end
