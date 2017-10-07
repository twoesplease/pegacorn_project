require 'faye/websocket'
require 'eventmachine'
require '/Users/tyoung/Pegacorn_Project/.gitignore/pegacorn_secrets'
require 'json'
require 'awesome_print'

EM.run do
  wss = Faye::WebSocket::Client.new('wss://rtm.zopim.com/stream',
                                    nil,
                                    :headers =>
        { 'Authorization' => "Bearer #{ZendeskSecrets::ZENDESK_OAUTH_ACCESS_TOKEN}" })

  wss.on :open do
    p [:start]
    msg = {}
    msg[:topic] = 'chats.waiting_time_avg'
    msg[:action] = 'subscribe'
    msg[:window] = 30
    wss.send msg.to_json
  end

  wss.on :message do |event|
    h = JSON.parse(event.data).to_hash
    # ap [:message, h["content"]["data"]["waiting_time_avg"]]
    puts 'Chat wait time average is currently'
    if ![h.dig('content', 'data', 'waiting_time_avg')][0].to_i.zero? &&
       [h.dig('content', 'data', 'waiting_time_avg')][0].to_i < 45
    puts ": #{[h.dig('content', 'data', 'waiting_time_avg')][0]} seconds"
      puts "\nLight the pegacorn!\======================================"
    else
    puts " not available."
      puts "\nPegacorn time has not yet come.\n======================================"
    end
    # if int > 5
      # 'winner winner chicken dinner!'
    # else
      # 'not a winner'
    # end
    wss = true
  end

  wss.on :close do |event|
    p [:close, event.code, event.reason]
    # Make bell sound
    # tput bel
  end
end
