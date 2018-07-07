## Trigger once ONC hits 45 solves for the day & continue lighting once per hour for the remainder of the shift ##

#	# Zendesk search API documentation: https://developer.zendesk.com/rest_api/docs/core/search # # 

require 'net/http'
require 'json'
require 'date'
require 'pi_piper'
# Have to hardcode this file path bc cron can't see the relative path
require '/Users/tyoung/workspace/Pegacorn_Project/.gitignore/pegacorn_secrets.rb'

class CountOncUpdates
  attr_accessor :http_response, :response_body

  # Get the year, month, date for today and then add the timestamp for 8pm
  def today_at_8pm_iso 
    @glommer = DateTime.parse(DateTime.now.strftime('%Y%m%d') + "T20:00:00-04:00").iso8601
  end

  def tomorrow_at_6am_iso
    today = DateTime.now.strftime('%Y-%m-%d').split("-").to_a
    # Add 1 to today's date to make it tomorrow!
    add_one_for_tomorrow = (today[2].to_i) + 1
    # Swap out today's date in the array to get tomorrow
    today.map do |x| 
      if x==today[2] 
        add_one_for_tomorrow
      else 
        x
      end
    end
    tmw_at_6am = today.join("-") 	# Add the timestamp of 6am to the end of the array
    tmw_at_6am = tmw_at_6am + "T06:00:00-04:00"
    @blommer = DateTime.parse(tmw_at_6am).iso8601
  end

  API_CALL_PARAMS = { 
      'sort_by' => 'created_at',
      'sort_order' => 'asc',
      'limit' => 1, # Change this to inspect the body
      'query' => "solved>=#{@glommer} solved<=#{@blommer}"
      }


  def fetch_solved_tickets_from_zendesk
    uri = URI(ZendeskSecrets::SEARCH_ENDPOINT)
    uri.query = URI.encode_www_form(API_CALL_PARAMS)

    req = Net::HTTP::Get.new(uri)
    req.basic_auth ZendeskSecrets::ZENDESK_USERNAME, ZendeskSecrets::ZENDESK_PASSWORD
      
    res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) do 
      |http| http.request(req)
    end
    @http_response = res

    # res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) {|http|
      # http.request(req)
    # }
  end
    
  def write_to_log_file
    puts "I'm checking the number of ONC ticket updates."
    puts "It's currently: #{DateTime.now}"
    puts "Response code: #{@http_response.code}"
    puts "Response message: #{@http_response.message} \n"

    hashed_body = JSON.parse(@htp_response.body)
    @response_body = hashed_body
    puts "Number of ONC ticket updates: #{@response_body['count']}"
  end

  def manage_light_on_rasp_pi
    if ticket_count_goal_reached?
      light_the_pegacorn
    else
      puts "The time has not yet come. \n"
    end
  end

    private
    def ticket_count_goal_reached?
      if @response_body["count"] >= 45
        return true
      else
        return false
      end
    end

    def light_the_pegacorn
      puts "Light the pegacorn!"
      pin = PiPiper::Pin.new( :pin => 17, :direction => :out )
      pin.off
      1.times do
        pin.on
        sleep 15 #seconds
        pin.off
      end
    end
end

new_updates_count = CountOncUpdates.new
new_updates_count.fetch_solved_tickets_from_zendesk
new_updates_count.write_to_log_file
new_updates_count.manage_light_on_rasp_pi
