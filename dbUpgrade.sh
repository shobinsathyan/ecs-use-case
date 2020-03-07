#!/bin/sh

# Database Upgrade script
# Usage : ./dbUpgrade.sh scripts username password dbhost

if [ "$#" -ne 4 ]; then
    echo "Invalid arguments\n"
    echo "Usage: $0 <scriptsdirectory> <username> <dbhostname> <password>"
    exit 1
fi

SCRIPTS_DIRECTORY=$1
USERNAME=$2
DBHOST=$3
PASSWORD=$4
MAX_DB_VERSION=0
#Harcoding the number to run the script in test mode
LATEST_DB_VERSION=50
#LATEST_DB_VERSION=`mysql -u ${USERNAME} -p ${PASSWORD} -h ${DBHOST} -e "select version from versionTable"`

# Loop to get list of numbers higher than DB version
scripts_to_update=()
SORTED_FILES_NUMBERS=`ls -1 ./${SCRIPTS_DIRECTORY} | sort -n -k1.1| cut -c 1-3`
for i in $SORTED_FILES_NUMBERS
do
  ROUNDED_NUMBER=`echo $i|bc`
   if [[ $ROUNDED_NUMBER -gt $LATEST_DB_VERSION ]]; then
      IFS=$'\n'
      scripts_to_update+=($(ls ./${SCRIPTS_DIRECTORY} | grep $i))
      MAX_DB_VERSION=$ROUNDED_NUMBER
      unset IFS
  fi
done


#Apply the updates to the Database
if [[ ${scripts_to_update[@]} ]]; then
 for i in "${scripts_to_update[@]}"
 do
   echo "Applying update script ${i} ..."
   echo "mysql -u $USERNAME -p ${PASSWORD} -h ${DBHOST} -e \"INSERT INTO testTable VALUES('${i}')\"\n"
   #mysql -u $USERNAME -p ${PASSWORD} -h ${DBHOST} -e "INSERT INTO testTable VALUES('${i}')"
 done

#Increment DB Version on Table
 echo "mysql -u $USERNAME -p ${PASSWORD} -h ${DBHOST} -e \"UPDATE versionTable SET version='${MAX_DB_VERSION}' where version='$LATEST_DB_VERSION'\""
# mysql -u $USERNAME -p ${PASSWORD} -h ${DBHOST} -e "UPDATE versionTable SET version='${MAX_DB_VERSION}' where version="$LATEST_DB_VERSION'"
else
    echo "No update to Database..."
fi
