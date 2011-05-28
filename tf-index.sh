#!/bin/bash
# Copyright © 2011 Bart Massey
# [This program is licensed under the "MIT License"]
# Please see the file COPYING in the source
# distribution of this software for license terms.
# 
# Rebuild the forge index pages

PGM="`basename $0`"
CONF="/usr/local/etc/tinyforge.conf"

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

function db {
    sqlite3 -list -separator "$1" "forge.db" "$2"
}

function onebullet {
    NAME="$1"
    VISNAME="$2"
    ATTRIB="$3"
    LANGDETAIL="$4"
    if [ "$NAME" = "$VISNAME" ]
    then
	echo -n "[[$NAME]]"
    else
	echo -n "[[$VISNAME|$NAME]]"
    fi
    if [ "$LANGDETAIL" != "" ]
    then
	echo -n " ($LANGDETAIL)"
    fi
    if [ "$ATTRIB" != "" ]
    then
	echo -n " &mdash; $ATTRIB"
    fi
    echo ""
}


function bullet {
    while read INFO
    do
	echo "$INFO" |
	( IFS='@' read NAME VISNAME ATTRIB
	  echo -n "  * "
	  onebullet "$NAME" "$VISNAME" "$ATTRIB" )
    done
}

function langbullet {
    while read INFO
    do
	echo "$INFO" |
	( IFS='@' read NAME VISNAME ATTRIB LANGDETAIL
	  echo -n "  * "
	  onebullet "$NAME" "$VISNAME" "$ATTRIB" "$LANGDETAIL" )
    done
}

function datebullet {
    while read INFO
    do
	echo "$INFO" |
	( IFS='@' read NAME VISNAME ATTRIB DATE
	  echo -n "  * $DATE "
	  onebullet "$NAME" "$VISNAME" "$ATTRIB" "" )
    done
}

# generate language index
( echo "# $FORGENAME Index by Programming Language"
  echo ""
  db ' ' "SELECT name, desc FROM languages ORDER BY num;" |
  while read LANG DESC
  do
      COUNT="`db '@' \"SELECT COUNT(*) FROM master WHERE language = '$LANG';\"`"
      if [ "$COUNT" -eq 0 ]
      then
	  continue
      fi
      echo "$DESC"
      echo ""
      db '@' "SELECT intname, visname, attrib, langdetail FROM master WHERE language = '$LANG' ORDER BY intname;" |
      langbullet
      echo ""
  done ) >language_index.mdwn

# generate alpha index
( echo "# $FORGENAME Alphabetical Index"
  echo ""
  db '@' "SELECT intname, visname, attrib FROM master ORDER BY intname;" |
  bullet ) >alpha_index.mdwn

# generate date index
( echo "# $FORGENAME Date Index"
  echo ""
  db '@' "SELECT intname, visname, attrib, adddate FROM master ORDER BY adddate DESC;" |
  datebullet ) >date_index.mdwn

# generate master index
( cat index-top.mdwn
  echo ""
  db ' ' "SELECT name, desc FROM categories ORDER BY num;" |
  while read CAT DESC
  do
      COUNT="`db '@' \"SELECT COUNT(*) FROM master WHERE category = '$CAT';\"`"
      if [ "$COUNT" -eq 0 ]
      then
	  continue
      fi
      echo "$DESC"
      echo ""
      db '@' "SELECT intname, visname, attrib FROM master WHERE category = '$CAT' ORDER BY intname;" |
      bullet
      echo ""
  done ) >index.mdwn
