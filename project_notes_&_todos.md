	# count_onc_ticket_updates.rb TODOS
	1. fix today_at_8pm_iso method + tomorrow_at_6am_iso
	2. check that those dates work in params and are returning accurate values
	3. create logic placeholder to light pegacorn
	4. create cron job
	5. see if I can combine pieces of the files

	# count_good_ratings.rb TODOS
	DONE 1. See todo above convert_start_of_today_to_integer method
	2. Read this: https://ruby-doc.org/stdlib-2.4.1/libdoc/net/http/rdoc/Net/HTTP.html#method-c-https_default_port
	DONE 3. Figure out how to count the number of ratings appropriately.
	DONE 4. Write logic to trigger another action when the number of ratings is 200 or above.
	DONE 5. Figure out why changing the limit to 0 breaks the '>=' method with error:
		 zendesk_api_test.rb:46:in `<main>': undefined method `>=' for nil:NilClass (NoMethodError) 
		#=> It's because if you don't return any results, there's nothing in the response body to parse.
	 DONE 6. Figure out how to schedule this task to run at a specified interval.
		 Add to crontab: 
		 0,10,20,30,40,50  5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21  *  *  1,2,3,4,5  ruby ~/Desktop/pegacorn_project/zendesk_api_test.rb > ~/Desktop/pegacorn_project/pegacorn.log 2>&1

		I used these resources: http://jameshuynh.com/2016/02/16/using-cron-job-and-whenever-gem-to-run-scheduled-task-in-rails/ + https://www.computerhope.com/unix/ucrontab.htm

		Info on the ZD search API: https://help.zendesk.com/hc/en-us/articles/229136927-Zendesk-REST-API-tutorial-Searching-with-the-Zendesk-API
	
	# PROJECT TODOs
	 1. Start on logic for other triggers.
	 2. Set up RaspbPi.
	 3. Figure out how to trigger a light connected to RaspbPi.
	 4. Hook logic for an individual trigger to light on RaspbPi.
	 5. Hook all four scripts to RaspbPi.  How to bundle them together?