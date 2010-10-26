#!/bin/bash
# Copyright © 2010 Bart Massey
# Insert a new entry into the BartForge db
# and update the indices to reflect this
PGM="`basename $0`"

function usage {
  echo "$PGM: usage:">&2
  echo "  $PGM --help [language|category]" >&2
  echo "  $PGM [--langdetail <detail>] [--attrib <name>] \\" >&2
  echo "    <intname> <category> <visname> <language>" >&2
}

function db {
    sqlite3 -list -separator '	' bartforge.db "$1"
}

NARGS=0
LANGDETAIL="NULL"
ATTRIB="NULL"
INTNAME=""
CATEGORY=""
VISNAME=""
LANGUAGE=""

case "$1" in
    --help)
	if [ $# -gt 1 ]
	then
	    case "$2" in
		language)
		    db "SELECT name, desc FROM languages ORDER BY num;"
		    exit 0
		    ;;
		category)
		    db "SELECT name, desc FROM categories ORDER BY num;"
		    exit 0
		    ;;
		*)
		    usage
		    exit 1
		    ;;
	    esac
	else
	    usage
	    exit 0;
	fi
	;;
esac

while [ $# -ge 1 ]
do
    case "$1" in
	--attrib|--langdetail)
	    if [ $# -le 1 ] || [ "$2" = "" ]
	    then
		usage
		exit 1
	    fi
	    case $1 in
	      --attrib) ATTRIB="'$2'" ;;
	      --langdetail) LANGDETAIL="'$2'" ;;
	    esac
	    shift 2
	    ;;
	*)
	    case $NARGS in
		0) INTNAME="$1" ;;
		1) CATEGORY="$1" ;;
		2) VISNAME="$1" ;;
		3) LANGUAGE="$1" ;;
		*) usage; exit 1 ;;
	    esac
	    NARGS="`expr $NARGS + 1`"
	    shift
	    ;;
    esac
done
if [ $NARGS -ne 4 ]
then
    usage
    exit 1
fi
LN=`db "SELECT num FROM languages WHERE name = '$LANGUAGE';"`
if [ "$LN" = "" ]
then
    echo "$PGM: bad language" >&2
    exit 1
fi
CN=`db "SELECT num FROM categories WHERE name = '$CATEGORY';"`
if [ "$CN" = "" ]
then
    echo "$PGM: bad category" >&2
    exit 1
fi
db "INSERT INTO master VALUES ('$INTNAME', '$CATEGORY', '$VISNAME', $ATTRIB, '$LANGUAGE', $LANGDETAIL);"
sh genindices.sh