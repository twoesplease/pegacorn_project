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
  attr_accessor :http_response, :parsed_body

  START_COUNT_AT_5AM_EST = 32_400
  TODAY_AT_5AM_IN_SECONDS = DateTime.now.to_date.strftime('%s').to_i + START_COUNT_AT_5AM_EST
  API_CALL_PARAMS = {
      'start_time' => TODAY_AT_5AM_IN_SECONDS,
      'score' => 'good',
      'sort_by' => 'created_at',
      'sort_order' => 'asc',
      'limit' => 1 # change this count if you need to inspect the body
    } 

  def fetch_ratings_from_zendesk
    uri = URI(ZendeskSecrets::SATISFACTION_RATINGS_ENDPOINT)
    uri.query = URI.encode_www_form(API_CALL_PARAMS)

    req = Net::HTTP::Get.new(uri)
    req.basic_auth ZendeskSecrets::ZENDESK_USERNAME, ZendeskSecrets::ZENDESK_PASSWORD

    res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) do |http|
      http.request(req)
    end
    @http_response = res
  end

  def write_to_log_file
    puts "\nI'm checking the count of good ratings."
    puts "It's currently: #{DateTime.now}"
    puts "Response code: #{@http_response.code}"
    puts "Response message: #{@http_response.message} \n"

    @parsed_body = JSON.parse(@http_response.body)
    puts "Number of satisfaction ratings: #{@parsed_body['satisfaction_ratings'].count}"
  end

  def manage_light_on_rasp_pi
    if satisfaction_goal_reached? 
      light_the_pegacorn
    else
      puts "The time has not yet come.\n"
    end
  end

  private
  def satisfaction_goal_reached?
    if @parsed_body['satisfaction_ratings'].count >= 300
      return true
    else
      return false
    end
  end

  def light_the_pegacorn
    puts 'Light the pegacorn!'
    pin = PiPiper::Pin.new(:pin => 17, :direction => :out)
    pin.off
    pin.on
    sleep 15 # seconds
    pin.off
  end
end

newcount = GoodRatingsCount.new
newcount.fetch_ratings_from_zendesk
newcount.write_to_log_file
newcount.manage_light_on_rasp_pi
