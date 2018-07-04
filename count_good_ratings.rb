## Trigger once day crew reaches 300 good ratings for the day & continue lighting once per hour for the remainder of the day ##

	# Zendesk API Documentation on Satisfaction Ratings: 
	# https://developer.zendesk.com/rest_api/docs/core/satisfaction_ratings

require 'net/http'
require 'json'
require 'date'
require 'pi_piper'
# Have to hardcode this file path bc cron can't see the relative path
require '/Users/tyoung/workspace/Pegacorn_Project/.gitignore/pegacorn_secrets.rb'
require 'pry'

def fetch_ratings_from_zendesk(start_time)
  uri = URI(ZendeskSecrets::SATISFACTION_RATINGS_ENDPOINT)
  params = {
    'start_time' => start_time,
    'score' => 'good',
    'sort_by' => 'created_at',
    'sort_order' => 'asc',
    'limit' => 1 # change this count if you need to inspect the body
  }

  uri.query = URI.encode_www_form(params)

  req = Net::HTTP::Get.new(uri)
  req.basic_auth ZendeskSecrets::ZENDESK_USERNAME, ZendeskSecrets::ZENDESK_PASSWORD

  @res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) do |http|
    http.request(req)
  end
end

def write_to_log_file
  puts "\nI'm checking the count of good ratings."
  puts "It's currently: #{DateTime.now}"
  puts "Response code: #{@res.code}"
  puts "Response message: #{@res.message} \n"

  @hashed_body = JSON.parse(@res.body)
  puts "Number of satisfaction ratings: #{@hashed_body['satisfaction_ratings'].count}"
end

def manage_light_on_rasp_pi
  if satisfaction_goal_reached? 
    light_the_pegacorn
  else
    puts "The time has not yet come.\n"
  end
end

START_COUNT_AT_5AM_EST = 32_400

def todays_date_to_integer
  today_at_5am_in_seconds = DateTime.now.to_date.strftime('%s').to_i + START_COUNT_AT_5AM_EST
end

def satisfaction_goal_reached?
  if @hashed_body['satisfaction_ratings'].count >= 300
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

fetch_ratings_from_zendesk(todays_date_to_integer)
write_to_log_file
manage_light_on_rasp_pi
