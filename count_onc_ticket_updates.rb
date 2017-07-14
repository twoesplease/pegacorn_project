# Count ONC ticket updates #
# Zendesk search API documentation: https://developer.zendesk.com/rest_api/docs/core/search #

require "net/http"
require "json"
require "date"
require "./.gitignore/pegacorn_secrets"

# Adding 86_400 seconds starts the count at 8pm (in EST, not GMT) for the ONC crew
today_at_8pm_in_seconds = DateTime.now.to_date.strftime('%s').to_i + 86_400
# puts today_at_8pm_in_seconds

# first attempt:
# today_at_8pm_iso = DateTime.now.to_date.strftime('%FT%R-04:00')

#second attempt:
today_at_8pm_iso = DateTime.parse(today_at_8pm_in_seconds.to_s).iso8601
puts today_at_8pm_iso
tomorrow_at_6am_iso = "this is a placeholder string"

#uri = URI("https://mailchimp.zendesk.com/api/v2/search.json?query=")
#params = {
#	"start_time": today_at_8pm_in_seconds ,
#	"score" => "good",
#	"sort_by" => "created_at",
#	"sort_order" => "asc",
#	"limit" => 1,
#	"query" => "type:ticket status:open solved>#{today_at_8pm_iso} + solved< #{tomorrow_at_6am_iso}"
#}
#uri.query = URI.encode_www_form(params)
#
#req = Net::HTTP::Get.new(uri)
#req.basic_auth 'ZendeskSecrets::ZENDESK_USERNAME', 'ZendeskSecrets::ZENDESK_PASSWORD'
#	
#	res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) {|http|
#		http.request(req)
#	}
#	
#puts "Response code: #{res.code}"
#puts "Response message: #{res.message}"
#
## We need hashed_body in order to output a hash to get the count.  
#	# Can use the prettified_body variable if we need to see the ratings in the call.  
#	# To view results, we'll need to change or remove the limit filter in params above.
#	hashed_body = JSON.parse(res.body)
#	
#	# If we need to look at the body:
#	# prettified_body = JSON.pretty_generate(hashed_body)
#
#	puts hashed_body["count"]
# end