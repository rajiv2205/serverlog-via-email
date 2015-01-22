# serverlog-via-email
########## ##########

This is a script that helps the admin to get the logs (like mailserver or webserver) of their server without logging into the server.

You need to set the cron for this script which executes this on an interval of 1 minute. 
Follow the steps to automate this task:
1) Download the script from the link: bitdiffferent.com/logs.sh
2) Place the script where you want to place it ( Make sure the mail directory should be the directory kept in $MAIL in which emails are landing).
3) Make the entry of services and log path location in path.txt file (You can create the same file).
    mailserver /var/log/mail/maillog
    webserver /var/log/nginx/error.log
4) Make the entries of authorized users in validsenders1.txt.
5) Set a cron for this script under /etc/crontab in the following format:

   */1 * * * * root bash -l -c 'sh logs_email.sh'
   
6) Try to send the emails with subject like "log mailserver" or "log webserver"
7) No more steps. :-) Happy scripting.

If you face any issue send me email at my email-address.

Rajiv Sharma
rajivsharma@bitdiffferent.com
