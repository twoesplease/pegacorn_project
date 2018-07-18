## Trigger once day crew reaches 300 good ratings for the day & continue lighting once per hour for the remainder of the day ##

	# Zendesk API Documentation on Satisfaction Ratings: 
	# https://developer.zendesk.com/rest_api/docs/core/satisfaction_ratings

require 'net/http'
require 'json'
require 'date'
require 'pi_piper'
# Have to hardcode this file path bc cron can't see the relative path
require '/Users/tyoung/workspace/Pegacorn_Project/.gitignore/pegacorn_secrets.rb'

class GoodRatingsCount
  START_COUNT_AT_5AM_EST = 32_400

  def fetchratings_writelog_managepi
    http_response = fetch_ratings_from_zendesk
    write_to_log_file(http_response)
    manage_light_on_rasp_pi(http_response)
  end

  def fetch_ratings_from_zendesk
    uri = compose_uri
    req = compose_request(uri)
    set_auth_creds(req)

    res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) do |http|
      http.request(req)
    end
    res
  end

  def write_to_log_file(http_response)
    puts "\nI'm checking the count of good ratings."
    puts "It's currently: #{DateTime.now}"
    puts "Response code: #{http_response.code}"
    puts "Response message: #{http_response.message} \n"
    puts "Number of satisfaction ratings: #{json_response_body(http_response)['satisfaction_ratings'].count}"
  end

  def manage_light_on_rasp_pi(http_response)
    if satisfaction_goal_reached?(http_response) 
      light_the_pegacorn
    else
      puts "The time has not yet come.\n"
    end
  end

  private
  def compose_uri
    uri = URI(ZendeskSecrets::SATISFACTION_RATINGS_ENDPOINT)
    # Satisfaction ratings endpoint format: https://{subdomain}.zendesk.com/api/v2/satisfaction_ratings.json
    uri.query = URI.encode_www_form(api_call_params)
    uri
  end

  def compose_request(uri)
    Net::HTTP::Get.new(uri)
  end

  def set_auth_creds(req)
    req.basic_auth ZendeskSecrets::ZENDESK_USERNAME, ZendeskSecrets::ZENDESK_PASSWORD
  end

  def satisfaction_goal_reached?(http_response)
    if json_response_body(http_response)['satisfaction_ratings'].count >= 300
      return true
    end
  end

  def light_the_pegacorn
    puts 'Light the pegacorn!'
    pin.off
    pin.on
    sleep 15 # seconds
    pin.off
  end

   def api_call_params
    {
      'start_time' => today_at_5am_in_seconds,
      'score' => 'good',
      'sort_by' => 'created_at',
      'sort_order' => 'asc',
      'limit' => 1000 # change this count if you need to inspect the body
    } 
  end

   def today_at_5am_in_seconds
    DateTime.now.to_date.strftime('%s').to_i + START_COUNT_AT_5AM_EST
   end

   def pin
    PiPiper::Pin.new(:pin => 17, :direction => :out)
   end

   def json_response_body(http_response)
    JSON.parse(http_response.body)
   end
end

new_good_ratings_count = GoodRatingsCount.new
new_good_ratings_count.fetchratings_writelog_managepi
