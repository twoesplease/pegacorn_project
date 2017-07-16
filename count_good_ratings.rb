## Trigger once day crew reaches 300 good ratings for the day ##
	# Zendesk API Documentation on Satisfaction Ratings: 
	# https://developer.zendesk.com/rest_api/docs/core/satisfaction_ratings

require "net/http"
require "json"
require "date"
# Have to hardcode this file path bc cron can't see the relative path
require "/Users/user/Desktop/Pegacorn_Project/.gitignore/pegacorn_secrets"
	
# Today's date has to be converted to seconds bc the Zendesk API requires an integer 
# for the start_time filter
#def convert_today_to_seconds
	# Adding 32_400 seconds starts the count at 5am (in EST, tnot GMT) for the daytime crew
	today_at_5am_in_seconds = DateTime.now.to_date.strftime('%s').to_i + 32_400
#end

uri = URI("https://mailchimp.zendesk.com/api/v2/satisfaction_ratings.json")
params = { 
	'start_time' => today_at_5am_in_seconds,
	'score' => 'good',
	'sort_by' => 'created_at',
	'sort_order' => 'asc',
	'limit' => 1
 }

uri.query = URI.encode_www_form(params)

req = Net::HTTP::Get.new(uri)
req.basic_auth ZendeskSecrets::ZENDESK_USERNAME, ZendeskSecrets::ZENDESK_PASSWORD

res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) {|http|
	http.request(req)
}

puts "It's currently: #{DateTime.now}"
puts "Response code: #{res.code}"
puts "Response message: #{res.message} \n"

# We need hashed_body in order to output a hash to get the count.  
hashed_body = JSON.parse(res.body)
# If we need to look at the body (we'll need to change limit filter in params above):
# prettified_body = JSON.pretty_generate(hashed_body)
puts hashed_body["count"]
if hashed_body["count"] >= 300
	puts "Light the pegacorn!"
else
	puts "The time has not yet come. \n"
end