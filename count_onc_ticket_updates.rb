## Trigger once ONC hits 45 solves for the day & continue lighting once per hour for the remainder of the shift ##
#
	# Zendesk search API documentation: https://developer.zendesk.com/rest_api/docs/core/search 

require 'net/http'
require 'json'
require 'date'
require 'pi_piper'
# Have to hardcode this file path bc cron can't see the relative path
require '/Users/tyoung/workspace/Pegacorn_Project/.gitignore/pegacorn_secrets.rb'

# Get the year, month, date for today and then add the timestamp for 8pm
def today_at_8pm_iso 
	DateTime.parse(DateTime.now.strftime('%Y%m%d') + "T20:00:00-04:00").iso8601
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
    DateTime.parse(tmw_at_6am).iso8601
end

 uri = URI("https://mailchimp.zendesk.com/api/v2/search.json")
params = {
	'sort_by' => 'created_at',
	'sort_order' => 'asc',
	'limit' => 1, # Change this to inspect the body
	'query' => "solved>=#{today_at_8pm_iso} solved<=#{tomorrow_at_6am_iso}"
	}

uri.query = URI.encode_www_form(params)

req = Net::HTTP::Get.new(uri)
req.basic_auth ZendeskSecrets::ZENDESK_USERNAME, ZendeskSecrets::ZENDESK_PASSWORD
	

res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) do 
	|http| http.request(req)
end

res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) {|http|
	http.request(req)
}
	
puts "I'm checking the number of ONC ticket updates."
puts "It's currently: #{DateTime.now}"
puts "Response code: #{res.code}"
puts "Response message: #{res.message} \n"

hashed_body = JSON.parse(res.body)
puts "Number of ONC ticket updates: #{hashed_body['count']}"

if hashed_body["count"] >= 45
	puts "Light the pegacorn!"
  pin = PiPiper::Pin.new( :pin => 17, :direction => :out )
  pin.off
  1.times do
    pin.on
    sleep 15 #seconds
    pin.off
  end
else
	puts "The time has not yet come. \n"
end