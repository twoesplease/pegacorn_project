## Trigger once ONC hits 45 solves for the day & continue lighting once per hour for the remainder of the shift ##

#	# Zendesk search API documentation: https://developer.zendesk.com/rest_api/docs/core/search # # 

require 'net/http'
require 'json'
require 'date'
require 'pi_piper'
# Have to hardcode this file path bc cron can't see the relative path
require '/Users/tyoung/workspace/Pegacorn_Project/.gitignore/pegacorn_secrets.rb'j

class CountOncUpdates
  ADD_ONE_FOR_TOMORROW = 1
  SIX_AM_TIMESTAMP = "T06:00:00-04:00" 

  def fetchsolved_writelog_managelight
    http_response = fetch_solved_tickets_from_zendesk
    write_to_log_file(http_response)
    manage_light_on_rasp_pi(http_response)
  end
  
  def fetch_solved_tickets_from_zendesk
    uri = compose_uri
    req = compose_request(uri)
    set_auth_creds(req)
      
    res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) do |http| 
      http.request(req)
    end
    res
  end
    
  def write_to_log_file(http_response)
    puts "I'm checking the number of ONC ticket updates."
    puts "It's currently: #{DateTime.now}"
    puts "Response code: #{http_response.code}"
    puts "Response message: #{http_response.message} \n"
    puts "Number of ONC ticket updates: #{parsed_json_body(http_response)['count']}"
  end

  def manage_light_on_rasp_pi(http_response)
    if ticket_count_goal_reached?(http_response)
      light_the_pegacorn
    else
      puts "The time has not yet come. \n"
    end
  end

  private
  def compose_uri
    uri = URI(ZendeskSecrets::SEARCH_ENDPOINT)
    # Search endpoint format: "https://{subdomain}.zendesk.com/api/v2/search.json"
    uri.query = URI.encode_www_form(api_call_params)
    uri
  end

  def compose_request(uri)
    req = Net::HTTP::Get.new(uri)
  end

  def set_auth_creds(req)
    req.basic_auth ZendeskSecrets::ZENDESK_USERNAME, ZendeskSecrets::ZENDESK_PASSWORD
  end

  def ticket_count_goal_reached?(http_response)
    if parsed_json_body(http_response)["count"] >= 45
      return true
    end
  end

  def light_the_pegacorn
    puts "Light the pegacorn!"
    pin.off
    pin.on
    sleep 15 # seconds
    pin.off
  end

  def api_call_params
  { 
    'sort_by' => 'created_at',
    'sort_order' => 'asc',
    'limit' => 1, # Change this to inspect the body
    'query' => "solved>=#{today_at_8pm_iso} solved<=#{tomorrow_at_6am_iso}"
  }
  end

  def pin
    pin = PiPiper::Pin.new( :pin => 17, :direction => :out )
  end

  def parsed_json_body(http_response)
    JSON.parse(http_response.body)
  end
  
  # Get the year, month, date for today and then add the timestamp for 8pm
  def today_at_8pm_iso 
    DateTime.parse(DateTime.now.strftime('%Y%m%d') + "T20:00:00-04:00").iso8601
  end

  def tomorrow_at_6am_iso
    today = DateTime.now.strftime('%Y-%m-%d').split("-").to_a
    tomorrow = (today[2].to_i) + ADD_ONE_FOR_TOMORROW
    replace_todays_date_with_tomorrow(today, tomorrow) 
    tomorrow_at_6am = today.join("-") + SIX_AM_TIMESTAMP
    DateTime.parse(tomorrow_at_6am).iso8601
  end

  def replace_todays_date_with_tomorrow(today, tomorrow)
    today.map do |x| 
      if x == today[2] 
        tomorrow
      end
    end
  end
end

new_updates_count = CountOncUpdates.new
new_updates_count.fetchsolved_writelog_managelight
