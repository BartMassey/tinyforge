#!/bin/bash
ITMP=/tmp/forge-$$.mdwn
trap "rm -f $ITMP" 0 1 2 3 15

function db {
   sqlite3 -list -separator ' ' bartforge.db "$1"
}

function bullet {
   while read NAME VISNAME ATTRIB
   do
       if [ "$NAME" = "$VISNAME" ]
       then
	   echo -n "  * [[$NAME]]"
       else
	   echo -n "  * [[$VISNAME|$NAME]]"
       fi
       if [ "$ATTRIB" != "" ]
       then
	   echo -n " &mdash; $ATTRIB"
       fi
       echo ""
   done
}

# generate language index
( echo "# Bartforge Index by Programming Language"
  echo ""
  db "select name, desc from languages order by num;" |
  while read LANG DESC
  do
      echo "$DESC"
      echo ""
      db "select intname, visname, attrib from master where language = '$LANG' order by intname;" |
      bullet
      echo ""
  done ) >language_index.mdwn

# generate alpha index
( echo "# Bartforge Alphabetical Index"
  echo ""
  db "select intname, visname, attrib from master order by intname;" |
  bullet ) >alpha_index.mdwn

# generate master index
( cat index-top.mdwn
  echo ""
  db "select name, desc from categories order by num;" |
  while read CAT DESC
  do
      echo "$DESC"
      echo ""
      db "select intname, visname, attrib from master where category = '$CAT' order by intname;" |
      bullet
      echo ""
  done ) >index.mdwn
