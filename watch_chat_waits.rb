require 'faye/websocket'
require 'eventmachine'
require '/Users/tyoung/workspace/Pegacorn_Project/.gitignore/pegacorn_secrets'
require 'json'
require 'pi_piper'

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
    wss.send msg.to_json
  end

  wss.on :message do |event|
  h = JSON.parse(event.data).to_hash
  wait_time_avg = [h.dig('content', 'data', 'waiting_time_avg')][0]
  tries ||= 3
  if wait_time_avg.to_i.zero? && !(tries -= 1).zero?
    tries -= 1
    sleep 15
    redo
  elsif !wait_time_avg.to_i.zero? &&
    wait_time_avg.to_i < 45
    puts "It's currently #{DateTime.now}."
    puts "Chat wait time average is #{wait_time_avg} seconds"
    puts "\nLight the pegacorn!\n"
    pin = PiPiper::Pin.new( :pin => 17, :direction => :out )
    pin.off
    1.times do
      pin.on
      sleep 15 #seconds
      pin.off
    end
  else
    puts 'Chat wait time average is not available.'
    puts "\nPegacorn time has not yet come.\n"
  end
  wss = true
  EM.stop
  end

  wss.on :close do |event|
    puts "Something's gronked up." if event.code != 1006
    p [:close, event.code, event.reason]
    EM.stop
  end
end
