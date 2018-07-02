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

def convert_todays_date_to_integer
  start_count_at_5AMEST = 32_400
  @today_at_5am_in_seconds = DateTime.now.to_date.strftime('%s').to_i + start_count_at_5AMEST
end

def request_ratings_count_from_Zendesk
  uri = URI('https://mailchimp.zendesk.com/api/v2/satisfaction_ratings.json')
  params = {
    'start_time' => @today_at_5am_in_seconds,
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

def log_output
  puts "I'm checking the count of good ratings."
  puts "It's currently: #{DateTime.now}"
  puts "Response code: #{@res.code}"
  puts "Response message: #{@res.message} \n"

  @hashed_body = JSON.parse(@res.body)
  puts "Number of satisfaction ratings: #{@hashed_body['satisfaction_ratings'].count}"
end

def trigger_light_on_RaspPi
  if @hashed_body['satisfaction_ratings'].count >= 300
    puts 'Light the pegacorn!'
    pin = PiPiper::Pin.new(:pin => 17, :direction => :out)
    pin.off
    1.times do
      pin.on
      sleep 15 # seconds
      pin.off
    end
  else
    puts "The time has not yet come. \n"
  end
end

request_ratings_count_from_Zendesk
log_output
trigger_light_on_RaspPi
