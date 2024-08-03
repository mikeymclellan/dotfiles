#!/bin/sh

TEMPFOO=`basename $0`
TMPFILE=`mktemp /tmp/${TEMPFOO}.XXXXXX` || exit 1

#echo $TEXT >> $TMPFILE
#vim -c ":Align =" -c ":wq" $TMPFILE 2> /dev/null

echo $TEXT | vim -b -c ":Align =" -c ":w! $TMPFILE" -c ":q" - 2>/dev/null

cat $TMPFILE
