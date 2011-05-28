#!/bin/bash
# Copyright © 2011 Bart Massey
# [This program is licensed under the "MIT License"]
# Please see the file COPYING in the source
# distribution of this software for license terms.
# 
# Insert a new entry into the forge db
# and update the indices to reflect this

PGM="`basename $0`"
CONF="/usr/local/etc/tinyforge.conf"

function usage {
  echo "$PGM: usage:">&2
  echo "  $PGM --help [language|category]" >&2
  echo "  $PGM [--langdetail <detail>] [--attrib <name>] \\" >&2
  echo "    <intname> <category> <visname> <language>" >&2
}

function db {
    sqlite3 -list -separator '	' "forge.db" "$1"
}

NARGS=0
LANGDETAIL="NULL"
ATTRIB="NULL"
INTNAME=""
CATEGORY=""
VISNAME=""
LANGUAGE=""

if [ -f "$CONF" ]
then
    . "$CONF"
    if [ "$FORGEPATH" != "" ]
    then
	if cd "$FORGEPATH" >/dev/null 2>&1
	then
	    :
	else
	    echo "$PGM: Bad FORGEPATH $FORGEPATH" >&2
	    exit 1
	fi
    fi
else
    echo "$PGM: cannot find TinyForge config file $CONF" >&2
    exit 1
fi

if [ ! -f forge.db ]
then
    echo "$PGM: cannot find forge directory" >&2
    exit 1
fi

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

if git add "$INTNAME".mdwn
then
    :
else
    echo "$PGM: could not git add '$INTNAME.mdwn', giving up" >&2
    exit 1
fi

# XXX These next two should probably be enforced using foreign
# key constraints. Oh well.

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

db "INSERT INTO master (intname, category, visname, attrib, language, langdetail) VALUES ('$INTNAME', '$CATEGORY', '$VISNAME', $ATTRIB, '$LANGUAGE', $LANGDETAIL);"
tf-index
git commit -am "added $INTNAME"
