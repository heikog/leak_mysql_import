#!/bin/bash
# Constants
START_PATH=$1
DB_NAME=collection_no1

DB_USER=root
DB_PASS=
DB_IDCOLUMN=id
DB_TIMESTAMPCOLUMN=ts
DB_FILECOLUMN=file_name
DB_USERCOLUMN=user_name
DB_PASSCOLUMN=pass_word
DB_TABLE=userda
fullpath=/
term_string=:
error_string=""
char_set="ascii"
mysql -u$DB_USER --execute="CREATE DATABASE IF NOT EXISTS $DB_NAME;"

#mysql -u$DB_USER --execute "USE $DB_NAME; DROP TABLE IF EXISTS $DB_TABLE"

find "$START_PATH" -iname '*.txt' | while read line; do
	echo "$line"
	filename=${line##*/}
	DB_TABLE=$( echo ${filename} | tr '.' '_' ) 
	DB_TABLE=$( echo ${DB_TABLE} | tr '[' '_' ) 
	DB_TABLE=$( echo ${DB_TABLE} | tr ']' '_' ) 
	create_table_sql="use $DB_NAME ;create table if not exists \`$DB_TABLE\` ($DB_IDCOLUMN BIGINT NOT NULL AUTO_INCREMENT, $DB_FILECOLUMN varchar(255), $DB_USERCOLUMN varchar(255), $DB_PASSCOLUMN varchar(255), $DB_TIMESTAMPCOLUMN TIMESTAMP, PRIMARY KEY($DB_IDCOLUMN), fulltext($DB_USERCOLUMN) );"
#	echo "$create_table_sql"
#	exit
	mysql -u$DB_USER --execute "$create_table_sql"
	fullpath=`readlink -f "$line"`
	first_line=$(head -n 1 "$fullpath")
	if [[ ${first_line} =~ ^.*:.* ]] ; then
		term_string=":"
	else
		term_string=";"
	fi

	mysql_command="use $DB_NAME;load data infile \"$fullpath\" IGNORE  into table \`$DB_TABLE\`   character set \"$char_set\"  fields terminated by '$term_string' lines terminated  by '\r\n' ($DB_USERCOLUMN, $DB_PASSCOLUMN) SET $DB_FILECOLUMN=\"$line\";" 
#echo "$mysql_command"
	error_string=$(mysql -u$DB_USER --execute "$mysql_command")   
	if [ $? != "0" ] ; then
		echo $? >>"import_error.txt"
		echo $error_string >>"import_error.txt"
	fi
	rm -r "$line"
	echo "$line deleted"
	echo "--------------------------------------------------"
done

