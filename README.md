# Pegacorn Project #

![Neon pegacorn sign](https://d1nvcfeljt87mm.cloudfront.net/items/271C0r422B013L1z0T0P/Image%202018-07-09%20at%2010.01.59%20PM.png?X-CloudApp-Visitor-Id=d596462286e4c525c1c75b475db911c0&v=de49e146)

## Overview ##
Each file in this project checks the Zendesk API to see if your Tech Support team has reached certain goals, and sends a signal to a connected Raspberry Pi when those goals are met.
In this case, that Raspberry Pi is intended to be connected to a neon pegacorn sign to cheer our Support team on for their amazing work!

`count_good_ratings.rb` and `count_onc_ticket_updates.rb` use Zendesk's Core API ([documentation here](https://developer.zendesk.com/rest_api/docs/core/introduction)) 
while `watch_chat_waits.rb` uses Zendesk's Real-Time-Chat API ([documentation here](https://developer.zendesk.com/rest_api/docs/chat/apis)).

## Requirements ##
In order to use this project, you'll need a Zendesk account with access to their API. The login information has been obfuscated in the code you can see, so in order to use this code
you'll need to create a file that stores your account-specific information and change the path to that file in the `require` statements (this is my recommendation since it's more secure), or you'll need to
replace your account-specific information in the variables namespaced `ZendeskSecrets`.  

Endpoints in the Zendesk API change based on the subdomain for the account you're accessing, so here is a list of the account-specific information you'll need to obtain:

* Zendesk username & password (for basic auth in `count_good_ratings.rb` and `count_onc_ticket_updates.rb`)
* Subdomain for your Zendesk account (this is used in the endpoint URLs for `count_good_ratings.rb` and `count_onc_ticket_updates.rb`) 
* OAuth access token (for use in `watch_chat_waits.rb`)

In order to use this code with a Raspberry Pi, you'll also need one of those along with a bread board (or appropriate alternative) & the appropriate wiring to link to your light source of choice.
These files use pin 17 as the output for the light source, so you'll need to be sure that your wiring connects your light source to that pin (or change the pin number in the `pin` function).  

To delve more into using a Raspberry Pi to light things up, I recommend checking out [this tutorial](https://thepihut.com/blogs/raspberry-pi-tutorials/27968772-turning-on-an-led-with-your-raspberry-pis-gpio-pins).
In order to use Ruby code instead of Python code like the tutorial does, this code uses the [Pi Piper gem](https://github.com/jwhitehorn/pi_piper).

## Use ##
After enabling the code to use the correct authentication and access the correct endpoints, you can use the files in this project to achieve the following goals:

**`count_good_ratings.rb`**: Checks the number of good satisfaction ratings for the day, starting the count at 5am EST.  Sends a signal to the Pi to trigger the light once that count hits 300 good ratings.
**`count_onc_ticket_updates.rb`**: This file is designed to check stats for our overnight crew, so it looks at the number  of ticket updates for the day, starting at 8pm EST and ending at 6am EST.  Sends a signal to the Pi to trigger the light once that count hits 45 ticket updates.
**`watch_chat_waits.rb`**: Uses websockets to check the current chat wait time on the Zendesk Real-Time Chat API.  Sends a signal to the Pi to trigger the light if that wait time is under 45 seconds.

### Triggering Automatically ###
In order to trigger these scripts automatically, you can leave your Pi connected to your light source and set up a cron job on the Pi to run each file automatically at chosen intervals throughout the day.
I recommend having your cron job set up to write the files' output to a log file so that you can keep an eye on things if any unexpected behavior pops up. Here's an example cron job setup that writes to a log file called 
`pegacorn.log`: 

`0,10,20,30,40,50 5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21 * * 1,2,3,4,5 ruby ~/Pegacorn_Project/count_good_ratings.rb >> ~/Pegacorn_Project/pegacorn.log 2>&1`

To check out a reference for how to set up a cron job on LINUX and UNIX systems from Linode, [click here](https://www.linode.com/docs/tools-reference/tools/schedule-tasks-with-cron/). 

As for the `2>&1` notation after the path to the log file, that indicates that errors should be output to the same file as standard output.  You can find more on writing to a log file from a cron
job [here](https://www.thegeekstuff.com/2012/07/crontab-log/).





