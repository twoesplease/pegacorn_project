require 'faye/websocket'
require 'eventmachine'
require '/Users/tyoung/Pegacorn_Project/.gitignore/pegacorn_secrets'
require 'json'
require 'PrettyPrint'

EM.run do
  wss = Faye::WebSocket::Client.new('wss://rtm.zopim.com/stream',
                                    nil,
                                    :headers =>
        { 'Authorization' => "Bearer #{ZendeskSecrets::ZENDESK_OAUTH_ACCESS_TOKEN}" })

  wss.on :open do
    p [:open]
    msg = {}
    msg[:topic] = 'chats.waiting_time_avg'
    msg[:action] = 'subscribe'
    msg[:window] = 30
    wss.send msg.to_json
  end

  wss.on :message do |event|
    p [:message, event.data]
    wss = true
  end

  wss.on :close do |event|
    p [:close, event.code, event.reason]
    # Make bell sound
    tput bel
  end
end
