require 'faye/websocket'
require 'eventmachine'
require '/Users/tyoung/workspace/Pegacorn_Project/.gitignore/pegacorn_secrets.rb'
require 'json'
require 'pi_piper'
require 'date'

# class WatchChatWaits
  def create_new_request
    Faye::WebSocket::Client.new(ZendeskSecrets::ZOPIM_STREAM_ENDPOINT,
    nil,
    :headers =>
    authorization_credentials)
  end

  def authorization_credentials
    { 'Authorization' => "Bearer #{ZendeskSecrets::ZENDESK_OAUTH_ACCESS_TOKEN}" }
  end

  def subscribe_to_chat_waits(wss)
    p [:start]
    msg = {}
    msg[:topic] = 'chats.waiting_time_avg'
    msg[:action] = 'subscribe'
    wss.send msg.to_json
  end

  def wait_time_avg_goal_reached? (wait_time_avg)
    if wait_time_avg < 45
      return true
    end
  end

  def log_success_light_rasp_pi
    puts "It's currently #{DateTime.now}."
    puts "Chat wait time average is #{wait_time_avg} seconds"
    puts "\nLight the pegacorn!\n"
    pin.off
    pin.on
    sleep 15 # seconds
    pin.off
  end

  def log_attempt_unsuccessful
    puts "It's currently #{DateTime.now}."
    puts 'Chat wait time average is not available.'
    puts "\nPegacorn time has not yet come.\n"
  end

  # ** REDO doesn't work in either of the methods below ** #

  # def retry_3x(tries)
    # tries -= 1
    # sleep 15
    # redo
  # end

  # def manage_wait_time
  # wait_time_avg = ([h.dig('content', 'data', 'waiting_time_avg')][0]).to_i
  # tries ||= 3
    # if wait_time_avg.zero? && !(tries -= 1).zero?
      # tries -= 1
      # sleep 15
      # redo
      # # retry_3x
    # elsif wait_time_avg > 0 && wait_time_avg < 45
      # log_success_light_rasp_pi
    # else
      # log_attempt_unsuccessful
    # end
  # end


  EM.run do
    wss = create_new_request
    wss.on :open do
      subscribe_to_chat_waits(wss)
    end

    wss.on :message do |event|
      h = JSON.parse(event.data).to_hash
      # manage_wait_time
  wait_time_avg = ([h.dig('content', 'data', 'waiting_time_avg')][0]).to_i
  tries ||= 3
    if wait_time_avg.zero? && !(tries -= 1).zero?
      tries -= 1
      sleep 15
      redo
      # retry_3x
    elsif wait_time_avg > 0 && wait_time_avg < 45
      log_success_light_rasp_pi
    else
      log_attempt_unsuccessful
    end

      wss = true
      EM.stop
    end

    wss.on :close do |event|
      puts "Something's gronked up." if event.code != 1006
      p ["Closing", "Event code: #{event.code}", "Event reason: #{event.reason}"]
      EM.stop
    end
  end

  def pin
    PiPiper::Pin.new( :pin => 17, :direction => :out )
  end
# end
