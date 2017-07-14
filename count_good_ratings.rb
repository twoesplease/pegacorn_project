# Trigger once we reach 300 good ratings for the day #
# Zendesk API Documentation on Satisfaction Ratings: 
 #https://developer.zendesk.com/rest_api/docs/core/satisfaction_ratings
#class GetGoodRatings 

	require "net/http"
	require "json"
	require "date"
	require "./.gitignore/pegacorn_secrets"
		
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
	
	puts "The current time is: #{DateTime.now}"
	puts "Response code: #{res.code}"
	puts "Response message: #{res.message}"
	
	# We need hashed_body in order to output a hash to get the count.  
	# Can use the prettified_body variable if we need to see the ratings in the call.  
	# To view results, we'll need to change or remove the limit filter in params above.
	hashed_body = JSON.parse(res.body)
	# prettified_body = JSON.pretty_generate(hashed_body)

	puts hashed_body["count"]

	if hashed_body["count"] >= 400
		puts "Light the pegacorn!"
	else
		puts "The time has not yet come. \n"
	end

#end