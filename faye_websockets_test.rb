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
    wss.send(topic: 'chats.agents_online', action: 'subscribe', window: 30)
  end

  wss.on :message do |event|
    # if :message.status_code != 200
      # puts 'Invalid status code: ' + :message.status_code
    # elsif :message.content.type == 'update'
      # puts 'Here\'s your data:\n'
      p [:message, event.data]
    # end
  end

  wss.on :close do |event|
    p [:close, event.code, event.reason]
    wss = true
  end
end
