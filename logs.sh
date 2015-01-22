#! /bin/bash

#######################
# Date: 22 January, 2015
# Author: Rajiv Sharma
# License: GPL

# .subjectfile1 and .idfile1 are queue for Subjects and Message IDs of emails received by the server.
# .tmp1 file stores the Message ID of last executed log's email.
# Add the names of package and location in file "path.txt" (One package-name in one line without any space in the beginning). 

# format:
# mail  /var/log/maillog
# webserver /var/log/nginx/error.log

# If you want to exclude any package from the list then comment out that package line in path.txt. 
# Add the email addresses of authenticated users in file "validsenders1.txt" to whom you want to give priviledge for reading logs.

# .count1 file stores difference to setup queue of emails received by the server in 1 minute.

# Set a cron for this script under /etc/crontab in the following format:

#  */1 * * * * root bash -l -c 'sh logs_email.sh'

#Once done with the setup send email to your server like:

#From: your_email_address
#Subject: log webserver 
#        Or
#Subject:  log mail

#######################

countCheck=1
function initialization()
{
    location=`pwd`

    if [[ ! -f $location/.count1 ]];
        then
        sed -n '/To:/,/Content-Type/p' $MAIL | grep  "^Message-ID" | wc -l > $location/.count1
    fi

    if [[ ! -f $location/.tmp1 ]]; 
        then
        touch $location/.tmp1
    fi

    if [[ ! -f $location/path.txt ]];
        then
        touch $location/path.txt
    fi

    value_for_script          # Executing the function for script values 

}

function value_for_script()
{
    N=0
    count=`cat .count1`
    newcount=`sed -n '/To:/,/Content-Type/p' $MAIL | grep  "^Message-ID" | wc -l`
    lastid=`cat .tmp1 | cut -d ',' -f1`

    if [ "$newcount" != "$count" ];
        then
        number=`expr $newcount - $count`
        sed -n '/To:/,/Content-Type/p' $MAIL | grep  "^Subject" | tail -$number | sed 's/^Subject: \(.*\)/\1/' > .subjectfile1
        sed -n '/To:/,/Content-Type/p' $MAIL | grep  "^Message-ID" | tail -$number | sed 's/^Message-ID: \(.*\)/\1/' | sed 's/^<\(.*\)/\1/' | sed 's/.$// ' > .idfile1
        sed -n '/To:/,/Content-Type/p' $MAIL | grep  "^From" | tail -$number |sed 's/^From: \(.*\)/\1/' > .temp_sender1.txt
cat .temp_sender1.txt | while read w;
do
acceptEmail             # Executes the function for every sender in the list and checks the format of email address.
countCheck=1
done 
  
    else
        echo "up-to-date"
    fi
}

function acceptEmail() {
  
    if [[ "$countCheck" > 2 ]]; then
        echo "exit" 
        exit 1
    else

        if [[ ! "$w" =~ ^[-0-9a-zA-Z.+_]+@[-0-9a-zA-Z.+_]+\.[a-zA-Z]{2,4} ]];
            then
                countCheck=$((countCheck+1))
                w=`echo "$w" | sed 's/.*<\(.*\)/\1/' | sed 's/.$// '`
                acceptEmail
            else
                                 
		echo "$w" > .senderfile1
		subjectFetcher    # Calling function to fetch subject, messageid and email sender address from the queues.

        fi
    fi
}

function subjectFetcher()
{

            N=$((N+1))
            SUBJECT=`sed -n ''$N'p' .subjectfile1`                    
            messageid=`sed -n ''$N'p' .idfile1`
            fromaddr=`sed -n ''1'p' .senderfile1`
            #echo "$fromaddr"
            valid_users_check        # Calling function for valid users present in the file "validsenders1.txt"
}

function valid_users_check()
{
        for k in $(cat validsenders1.txt | grep -v "^#")
        do
                if [[ "$k" == "$fromaddr" ]];
                    then
                        messageid_check             # Executing function to check message ID's (any recent email)
                fi
        done
}

function messageid_check()
{
        if [ "$messageid" != "$lastid" ];
                then
           
     log_Executer     # Executing the main path execution function.
        fi
}


function log_Executer()
{
      for (( i =1; i<= `cat $location/path.txt | grep -v "^#" | wc -l`; i++ ))
do
        var=`cat $location/path.txt | grep -v "^#" | sed -n ''$i'p' | sed -e 's/[ \t].*//'`


        if [[ "log $var" == "$SUBJECT" ]];
        then
               log_path=`cat $location/path.txt | grep -v "^#" | sed -n ''$i'p' | sed -e 's/^.*[ \t]//'`
               tail -10 $log_path | mail -a'$log_path' -s "IMP: REQUESTED LOG" $(cat validsender.txt | grep -v "^#")
               break
        fi

done
echo $?
}

initialization  # Main Execution 
