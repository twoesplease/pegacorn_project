## Trigger once ONC hits 45 solves for the day ##
	# Zendesk search API documentation: https://developer.zendesk.com/rest_api/docs/core/search 

require "net/http"
require "json"
require "date"
# Have to hardcode this file path bc cron can't see the relative path
require "/Users/user/Desktop/Pegacorn_Project/.gitignore/pegacorn_secrets"

# Get the year, month, date for today and then add the timestamp for 8pm
def today_at_8pm_iso 
	DateTime.parse(DateTime.now.strftime('%Y%m%d') + "T20:00:00-04:00").iso8601
end

def tomorrow_at_6am_iso
	today = DateTime.now.strftime('%Y-%m-%d').split("-").to_a
	# Add 1 to today's date to make it tomorrow!
	add_one_for_tomorrow = (today[2].to_i) + 1
	# Swap out today's date in the array to get tomorrow
	tomorrow = today.map do |x| 
		if x==today[2] 
			add_one_for_tomorrow
		else 
			x
		end
	end
	# Add the timestamp of 6am to the end of the array
	today.push("T06:00:00-04:00")
	tmw_at_6am = today.join("-")
	DateTime.parse(tmw_at_6am).iso8601
end

uri = URI("https://mailchimp.zendesk.com/api/v2/search.json")
params = {
	'sort_by' => 'created_at',
	'sort_order' => 'asc',
	'limit' => 1,
	#Using this query on 7/15/17 at 10:09 pm got me 1672 in the hashed_body["count"]
	# but using the interpolated query "solved>#{today_at_8pm_iso} solved<#{tomorrow_at_6am_iso}" 
		#got me 0 results.  Why?  Is it because it's a string?
	#'query' => "solved>2017-07-15T06:00:00-04:00 solved<2017-07-15T20:00:00-04:00"
	'query' => "solved>#{today_at_8pm_iso} solved<#{tomorrow_at_6am_iso}"
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

if hashed_body["count"] >= 45
	puts "Light the pegacorn!"
else
	puts "The time has not yet come. \n"
end