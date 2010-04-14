#!/bin/bash
ITMP=/tmp/forge-$$.mdwn
trap "rm -f $ITMP" 0 1 2 3 15

function db {
   sqlite3 -list -separator ' ' bartforge.db "$1"
}

# generate language index
( echo "# Bartforge Index by Programming Language"
  echo ""
  db "select name, desc from languages order by num;" |
  while read LANG DESC
  do
      echo "$DESC"
      echo ""
      db "select intname, visname from master where language = '$LANG' order by intname;" |
      while read NAME VISNAME
      do
	  if [ "$NAME" = "$VISNAME" ]
	  then
	      echo "  * [[$NAME]]"
	  else
	      echo "  * [[$VISNAME|$NAME]]"
	  fi
      done
      echo ""
  done ) >language_index.mdwn

# generate alpha index
( echo "# Bartforge Alphabetical Index"
  echo ""
  db "select intname, visname from master order by intname;" |
  while read NAME VISNAME
  do
      if [ "$NAME" = "$VISNAME" ]
      then
	  echo "  * [[$NAME]]"
      else
	  echo "  * [[$VISNAME|$NAME]]"
      fi
  done ) >alpha_index.mdwn

# generate master index
( cat index-top.mdwn
  echo ""
  db "select name, desc from categories order by num;" |
  while read CAT DESC
  do
      echo "$DESC"
      echo ""
      db "select intname, visname from master where category = '$CAT' order by intname;" |
      while read NAME VISNAME
      do
	  if [ "$NAME" = "$VISNAME" ]
	  then
	      echo "  * [[$NAME]]"
	  else
	      echo "  * [[$VISNAME|$NAME]]"
	  fi
      done
      echo ""
  done ) >index.mdwn
