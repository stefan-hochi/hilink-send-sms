#!/bin/sh
OUT=$(/usr/bin/perl /root/getAlarm.pl)

test -f /root/latest || touch /root/latest

if [ `stat -c %Y /root/latest` -lt `date +%s -d '30 minutes ago'` ]; then
        echo $OUT
        if [ ! -z "$OUT" ]; then
                touch /root/latest
                /usr/bin/perl /root/send-sms.pl 123456789 "$OUT"
                #echo $OUT
        fi
fi
