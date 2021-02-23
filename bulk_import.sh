#!/bin/bash
# Constants
START_PATH=$1
DB_NAME=passwords
DB_USER=root
DB_PASS=
DB_IDCOLUMN=id
DB_TIMESTAMPCOLUMN=ts
DB_FILECOLUMN=file_name
DB_USERCOLUMN=user_name
DB_PASSCOLUMN=pass_word
DB_TABLE=userdata
fullpath=/
term_string=:
error_string=""
char_set="ascii"
mysql -u$DB_USER --execute="CREATE DATABASE IF NOT EXISTS $DB_NAME;"

test="use $DB_NAME;create table if not exists $DB_TABLE ($DB_IDCOLUMN BIGINT NOT NULL AUTO_INCREMENT, $DB_FILECOLUMN varchar(255), $DB_USERCOLUMN varchar(255), $DB_PASSCOLUMN varchar(255), $DB_TIMESTAMPCOLUMN TIMESTAMP, PRIMARY KEY($DB_IDCOLUMN), fulltext($DB_USERCOLUMN) );"
mysql -u$DB_USER --execute "USE $DB_NAME; DROP TABLE IF EXISTS $DB_TABLE"
mysql -u$DB_USER --execute "$test"

find "$START_PATH" -iname '*.txt' | while read line; do
#	echo "$line"
	fullpath=`readlink -f "$line"`
	first_line=$(head -n 1 "$fullpath")
	if [[ ${first_line} =~ ^.*:.* ]] ; then
		term_string=":"
	else
		term_string=";"
	fi

	mysql_command="use $DB_NAME;load data infile \"$fullpath\" into table userdata character set \"$char_set\"  fields terminated by '$term_string' lines terminated  by '\r\n' ($DB_USERCOLUMN, $DB_PASSCOLUMN) SET $DB_FILECOLUMN=\"$line\";" 

	error_string=$(mysql -u$DB_USER --execute "$mysql_command")   
	if [ $? != "0" ] ; then
		echo $? >>"import_error.txt"
		echo $error_string >>"import_error.txt"
	fi
done

