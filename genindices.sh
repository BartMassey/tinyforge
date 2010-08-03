#!/bin/bash
function db {
    sqlite3 -list -separator "$1" bartforge.db "$2"
}

function onebullet {
    NAME="$1"
    VISNAME="$2"
    ATTRIB="$3"
    LANGDETAIL="$4"
    if [ "$NAME" = "$VISNAME" ]
    then
	echo -n "  * [[$NAME]]"
    else
	echo -n "  * [[$VISNAME|$NAME]]"
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
	  onebullet "$NAME" "$VISNAME" "$ATTRIB" )
    done
}

function langbullet {
    while read INFO
    do
	echo "$INFO" |
	( IFS='@' read NAME VISNAME ATTRIB LANGDETAIL
	  onebullet "$NAME" "$VISNAME" "$ATTRIB" "$LANGDETAIL" )
    done
}

# generate language index
( echo "# Bartforge Index by Programming Language"
  echo ""
  db ' ' "select name, desc from languages order by num;" |
  while read LANG DESC
  do
      echo "$DESC"
      echo ""
      db '@' "select intname, visname, attrib, langdetail from master where language = '$LANG' order by intname;" |
      langbullet
      echo ""
  done ) >language_index.mdwn

# generate alpha index
( echo "# Bartforge Alphabetical Index"
  echo ""
  db '@' "select intname, visname, attrib from master order by intname;" |
  bullet ) >alpha_index.mdwn

# generate master index
( cat index-top.mdwn
  echo ""
  db ' ' "select name, desc from categories order by num;" |
  while read CAT DESC
  do
      echo "$DESC"
      echo ""
      db '@' "select intname, visname, attrib from master where category = '$CAT' order by intname;" |
      bullet
      echo ""
  done ) >index.mdwn
