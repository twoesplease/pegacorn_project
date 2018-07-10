require 'faye/websocket'
require 'eventmachine'
require '/Users/tyoung/workspace/Pegacorn_Project/.gitignore/pegacorn_secrets.rb'
require 'json'
require 'pi_piper'
require 'date'

class WatchChatWaits
  def start_event_machine
    EM.start
  end

  def create_new_request
    Faye::WebSocket::Client.new("wss://rtm.zopim.com/stream",
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

  EM.run do
    wss = create_new_request
    wss.on :open do
      subscribe_to_chat_waits(wss)
    end

    def check_for_success_3x_on_message
      wss.on :message do |event|
      h = JSON.parse(event.data).to_hash
      wait_time_avg = ([h.dig('content', 'data', 'waiting_time_avg')][0]).to_i
      tries ||= 3
      if wait_time_avg.zero? && !(tries -= 1).zero?
        tries -= 1
        sleep 15
        redo
      elsif wait_time_avg > 0 && wait_time_avg < 45
        log_success_light_rasp_pi
      else
        log_attempt_unsuccessful
      end
        wss = true
        stop_event_machine
      end
    end

    def log_status_on_close
      wss.on :close do |event|
      puts "Something's gronked up." if event.code != 1006
      p ["Closing", "Event code: #{event.code}", "Event reason: #{event.reason}"]
      end
      stop_event_machine
    end

  def stop_event_machine
    EM.stop
  end

  def pin
    PiPiper::Pin.new( :pin => 17, :direction => :out )
  end

  private

end
end

new_wait_watch = WatchChatWaits.new
EM.run do
  new_wait_watch.start_event_machine
  wss = new_wait_watch.create_new_request
  wss.on :open do
    new_wait_watch.subscribe_to_chat_waits(wss)
    check_for_success_3x_on_message
    log_status_on_close
  end
end
