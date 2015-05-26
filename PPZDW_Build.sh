#!/bin/bash
# 
# 
#  Poor Person's Zuora Data Warehouse - PPZDW
#
#  Using this script pull out from Zuora all the data sources needed
#  for the data warehouse - we'll use the AQuA api interface, in non-synchronous mode,
#  meaning multiple serial queries that may partially capture new incoming txns.
#  All the data gets stuck into a SQLite relational database, this is an open source,
#  and as the name implies, light, relational database, this isn't Oracle and isn't
#  even MYSql but it comes bundled with Macs and most Linux's and does the job.
#
#  The AQuA queries may take minutes, half hour or longer to complete if you have a
#  a lot of data. Be patient.
#
#  What you actually do with all this data in a relational database is up to you, but
#  this script makes a couple of suggestions you might want to follow, skip to the end.
#
#
#  Have to feed in the tenant identifier (www or apisandbox), login and password,
#  start and end date - pick something like 01/01/2000 and 12/31/2100 to get everything.
#
#  richard.sawey@zuora.com
#
#  Written in bash, but only tested on a Mac running Mavericks, 10.9.5, your
#  mileage may vary.
#
#  Why bash? Because Ruby and Python are for wimps
#
# Not sure this is the right place for date filtering, let's grab everything and later
# use AQuA itself for incrementals.
#
if [ ! $# == 5 ]; then
  echo "Usage: Tenant Type (www or apisandbox) Zuora_Login Zuora_Password Start_Date End_Date"
  echo "Usage example: ./PPDZW_Build.sh apisandbox user@whatever.com mysecret 10/1/2014 10/31/2014"
  exit
fi


TENANT=$1
USER_NAME=$2
PASSWORD=$3
STARTDATE=$4
ENDDATE=$5


# Redirect stdout ( > ) to a log file
exec > >(tee PPZDW_Build.log)
exec 2>&1


BASE_URL="https://$TENANT.zuora.com/apps"
echo $BASE_URL
JOB_STATUS="pending"
SLEEP_PERIOD="15s"

#
#  Before we do anything useful let's define a function we'll use to check if the
#  aqua job is complete
#
job_ready() {
  JOBID=$1
  echo "============= Checking Job Id: $JOBID ===========" 
  echo "TRYING: curl -i -k -u $USER_NAME:$PASSWORD -H" "Content-Type:application/json" "-H Accept:application/json" "-X GET https://$TENANT.zuora.com/apps/api/batch-query/jobs/$JOBID > file_ready_check.txt"
  curl -i -k -u $USER_NAME:$PASSWORD -H "Content-Type:application/json" -H "Accept:application/json" -X GET https://$TENANT.zuora.com/apps/api/batch-query/jobs/$JOBID > file_ready_check.txt
  if grep 'HTTP/1.1 200 OK' file_ready_check.txt && ! grep 'errorCode' file_ready_check.txt 
  then
    #
    #  And what is going on below? we grep the results file looking for the id line that has the job id,
    #  then we have cut out the bit between the ':' and the ',' which has the job id surrounded
    #  by some white space (the first sed gets rid of all white space), and then by double quotes,
    #  so the second sed -e gets rid of the leading " and the last one the last ".
    #
    JOB_STATUS=`grep '"status" :' file_ready_check.txt | head -1 | cut -d : -f2 | cut -d , -f1 | sed -e 's/[[:space:]]//g' -e 's/^"//'  -e 's/"$//' `
    echo "Job Id: $JOBID has status $JOB_STATUS"
    if [ "$JOB_STATUS" == "aborted" ]
    then
      echo "File status of aborted reported! Review contents of file_ready_check.txt for clues"
    fi
  else
    echo "File ready check failed! review contents of file_ready_check.txt for clues"
    JOB_STATUS="fail"
  fi
}

#
#  And here is a function to go pull down one of the result files, this will be
#  called over and over file id by file id to retrieve all the csv result files
#  of our Aqua queries
#
#  GET https://www.zuora.com/apps/api/file/{fileId}
#
get_aqua_result_file() {
  FID=$1
  RFOLDER=$2
  echo "============= Getting Aqua Results File Id: $FID ===========" 
  curl -i -k -u $USER_NAME:$PASSWORD -H "Content-Type:application/json" -H "Accept:application/json" -X GET https://$TENANT.zuora.com/apps/api/file/$FID > $RFOLDER/file_$FID.txt
  if grep 'HTTP/1.1 200 OK' $RFOLDER/file_$FID.txt && ! grep 'errorCode' $RFOLDER/file_$FID.txt 
  then
    echo "Got good stuff: $RFOLDER/file_$FID.txt"
    #
    #  And now it's time to post process the results file, they have a bunch of HTTP 
    #  header info in them that has to be stripped out, the tail -n+12 tails the entire
    #  file but starting at line 12 and the sed strips out any blank lines
    #
    tail -n+12 $RFOLDER/file_$FID.txt  | sed -e '/^[[:space:]]*$/d' > $RFOLDER/$FID.csv
  else
    mv $RFOLDER/file_$FID.txt $RFOLDER/file_$FID.fail
    echo "Aqua Results File $FID pull failed! Review contents of $RFOLDER/file_$FID.fail for clues"
  fi
}

#
#  ====================================================================================
#
#
#  ====================================================================================
#
#
#  ====================================================================================
#
#  Time to rumble, enough with the functions, let's do some work. First we will
#  fire up the aqua queries, check they worked and if they did pull the job id
#  that we need to test to see if the results are ready
#
#  ====================================================================================
#
#
#  ====================================================================================
#
#
#  ====================================================================================
#
echo "============= File up queries against $BASE_URL ===========" 

echo "PPZDW_Queries.sh $TENANT $USER_NAME $PASSWORD $STARTDATE $ENDDATE > PPZDW_Queries_Results.txt"
source PPZDW_Queries.sh $TENANT $USER_NAME $PASSWORD $STARTDATE $ENDDATE > PPZDW_Queries_Results.txt
if grep 'HTTP/1.1 200 OK' PPZDW_Queries_Results.txt && ! grep 'errorCode' PPZDW_Queries_Results.txt 
then
  echo "Queries seemed to have been posted successfully"
  #
  #  And what is going on below? we grep the results file looking for the id line that has the job id,
  #  then we have cut out the bit between the ':' and the ',' which has the job id surrounded
  #  by some white space (the first sed -e gets rid of all white space), and then by double quotes,
  #  so the second sed -e gets rid of the leading " and the last one the last ".
  #
  JOBID=`grep '"id" :' PPZDW_Queries_Results.txt | tail -1 | cut -d : -f2 | cut -d , -f1 | sed -e 's/[[:space:]]//g' -e 's/^"//'  -e 's/"$//' `
  echo "Aqua Job Id: $JOBID"  
else
  echo "Problem found in PPZDW_Queries_Results.txt - check HTTP return code and errorCode"
  exit 1
fi

while [ "$JOB_STATUS" == "pending" ] || [ "$JOB_STATUS" == "executing"  ] || [ "$JOB_STATUS" == "submitted"  ]; do
  sleep $SLEEP_PERIOD
  job_ready $JOBID
done

if [ "$JOB_STATUS" != "completed" ]
then
  echo "Houston, we have problem, aqua job status: $JOB_STATUS, was expecting 'completed' "
  exit 1
fi
#
#  Make a directory for the results files
#
echo "============= Make a sub directory for the results: $JOBID ===========" 
mkdir "$JOBID"
mv PPZDW_Queries_Results.txt $JOBID/PPZDW_Queries_Results.txt
mv file_ready_check.txt $JOBID/file_ready_check.txt

#
#  Time to grab the file ids and then the files, the grep parses out and grabs the 
#  file ids and sticks them in file_ids.txt
#  
grep fileId $JOBID/file_ready_check.txt | cut -d : -f2 | cut -d , -f1 | sed -e 's/[[:space:]]//g' -e 's/^"//'  -e 's/"$//' > $JOBID/file_ids.txt
#
#
#  This while loop grabs a file each time round from file_ids.txt and sticks the results in a folder
#  named after the Aqua JOB ID - ergo there will always be a unique folder name
#
while read RFILEID; do get_aqua_result_file $RFILEID $JOBID; done < $JOBID/file_ids.txt

#
#  Time to actually build the data warehouse, the first column is used to determine the table
#  name (which will be the data source name with no spaces)
#  Everything is going to be built in the sub-directory where we placed the 
#  downloaded result files. This includes the actual database file itself, PPZDW.sqlite
#
#  So each time you run this file you'll get a new Job Id, a new sub directory and a
#  a new database - so this will soak up all your disk space if you ignore this and
#  never clean up.
#

/bin/rm -f $JOBID/load_files.txt
ls $JOBID/*.csv > $JOBID/load_files.txt

#
#  The sql file created here is going to contain the sqlite commands to import the csv files. We'll
#  take advantage of the sqlite .import feature, we just have to make sure the column headers in the
#  first line of the csv file are what we want, this means changing the 'Contact:
#  First Name' crap to just 'FirstName'
#
#  And if you are wondering why I build the table first and I don't take advantage of
#  the documented feature where you can both create and load the table from a csv file?
#  That SQLite feature simply doesn't work as far as I can see. 
#
# 
#  Let's open and start building our new database build file
DBBUILDFILE=$JOBID/PPZDW_Data.sql
echo ".mode csv" > $DBBUILDFILE

#
#  For each csv file, edit first line so the column names are correct and write the 
#  rest of the file to an appropriately named csv file,
#  'appropriately named' means a file that contains the table name
#
#  Change separator to a comma so we can parse out the columns headers
IFS=','
#
#  Now loop through each csv file
#
while read RFNAME; do 
  echo "found $RFNAME"
  # delete all leading blank lines at top of file
  cat $RFNAME | sed '/./,$!d' > $RFNAME.tmp
  /bin/rm -f $RFNAME
  /bin/mv $RFNAME.tmp $RFNAME
  
  TABLENAME=`head -1 $RFNAME | cut -d : -f1 | sed -e 's/[[:space:]]//g' -e 's/^"//' -e 's/"$//'`
  echo "Table $TABLENAME with columns "

  TARGET=`head -1 $RFNAME | cut -d : -f1`  
  COLNAMES=`head -1 $RFNAME | sed -e "s/$TARGET://g" -e 's/[[:space:]]//g' -e 's/\///' -e 's/^"//' -e 's/"$//'`
  echo "create table $TABLENAME($COLNAMES);"
  echo "create table $TABLENAME($COLNAMES);" >> $DBBUILDFILE
  echo ".import $JOBID/$TABLENAME.sql $TABLENAME"  >> $DBBUILDFILE

  /bin/rm -f $JOBID/$TABLENAME.sql
  tail -n+2 $RFNAME > $JOBID/$TABLENAME.sql

done < $JOBID/load_files.txt
unset IFS

# Load up on more SQL to build out the database, specifically build a
# ProductRatePlan table EVEN though there is no ProductRatePlan data source.
#
cat <<EOT >> $DBBUILDFILE
create table PRPTemp as select distinct CreatedByID,CreatedDate,Description,EffectiveEndDate,EffectiveStartDate,ID,Name,UpdatedByID,UpdatedDate,ProductRatePlanId,ProductId,ProductSKU from ProductRatePlan;
drop table ProductRatePlan;
create table ProductRatePlan as select CreatedByID,CreatedDate,Description,EffectiveEndDate,EffectiveStartDate,ID,Name,UpdatedByID,UpdatedDate,ProductRatePlanId,ProductId,ProductSKU from PRPTemp;
EOT

sqlite3 $JOBID/PPZDW_Data.sqlite < $DBBUILDFILE
mv $JOBID/PPZDW_Data.sqlite PPZDW_Data.sqlite

echo
echo
echo "You have optional follow up items:"
echo 
echo " 1. Create a Txn Fact table that will all you to list txns for"
echo "    any account in chronological order."
echo " 2. Load user table so you know who created or changed objects"
echo
echo 
echo "If you want to build the txn table run:"
echo "AR_PIT_Build.sh"
echo "If you've changed the name of the database file, use that as the first optional"
echo "parameter for this script."
echo
echo
echo "If you have the tenant user export in a file, name the file"
echo "AllUsersList.csv and leave it in this directory and then run:"
echo "sqlite3 PPZDW_Data.sqlite < PPZDW_AddZUsers.sql"
echo "   - you don't have to do this now, but until you do you won't know who made changes"
echo
echo
echo "Either way just run sqlite3 PPZDW_Data.sqlite when ready to work with the database "
echo
echo 

