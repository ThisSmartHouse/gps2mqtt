#!/bin/bash

# http://www.github.com/ThisSmartHouse/gps2mqtt
# Apache 2.0 license, please see above URL for more information
# (c) 2019 Internet Technology Solutions, LLC

GPIO=`which gpio`
ATINOUT=`which atinout`
MOSQUITTO_PUB=`which mosquitto_pub`
STTY=`which stty`

baud=115200
tty=/dev/ttyS0
host=mitch.smart.rv
topic=/rv/gps

IS_ALIVE="echo \"AT\" | ${ATINOUT} --timeout 5 - ${tty} /dev/null"
POWER_ON="echo \"AT+CGNSPWR=1\" | ${ATINOUT} --timeout 5 - ${tty} -"
GPS_DATA="echo \"AT+CGNSINF\" | ${ATINOUT} --timeout 5 - ${tty} -"

${STTY} -F ${tty} ${baud} -parenb -parodd -cmspar cs8 -hupcl -cstopb cread clocal crtscts ignbrk -brkint -ignpar -parmrk -inpck -istrip -inlcr -igncr -icrnl -ixon -ixoff -iuclc -ixany -imaxbel -iutf8 -opost -olcuc -ocrnl -onlcr -onocr -onlret -ofill -ofdel nl0 cr0 tab0 bs0 vt0 ff0 -isig -icanon -iexten -echo -echoe -echok -echonl -noflsh -xcase -tostop -echoprt -echoctl -echoke -flusho -extproc

echo "Setting up serial port and baud rate";

echo "Checking to see if modem is alive...";
eval ${IS_ALIVE}

if [ $? -eq 0 ]
then
	echo "Modem is Alive!"
else
	echo "Modem did not respond to command, attempting to power on"
	$GPIO mode 7 out
	$GPIO write 7 low
	sleep 4
	$GPIO mode 7 in

	eval ${IS_ALIVE}
	if [ $? -ne 0 ]
	then
		echo "Modem failed to respond and won't turn on. Exiting."
		exit 1;
	fi
	echo "Waiting 10 seconds for GPS to attempt to acquire signal."
	sleep 10
fi

OUTPUT=`eval ${POWER_ON}`

if [ $? -ne 0 ]
then
	echo "Failed to turn GPS on";
	exit 1
fi


OUTPUT=`eval ${GPS_DATA}`

if [ $? -ne 0 ]
then
	echo "Failed to receive GPS data";
	exit 1
fi

HAVE_FIX=`echo ${OUTPUT} | awk -F "\"*,\"*" '{print $2}'`

if [ "$HAVE_FIX" != "1" ]
then
	echo "GPS does not have a satalite fix.";
	exit 0
fi

JSON=`echo ${OUTPUT} | awk -F "\"*,\"*" '{printf "{ \"lat\": %s, \"lon\": %s, \"el\" : %s, \"speed\" : %s, \"sat_found\" : %s, \"sat_used\" : %s }\n", (length($4) == 0) ? "0" : $4, (length($5) == 0) ? "0" : $5, (length($6) == 0) ? "0" : $6, (length($7) == 0) ? "0" : $7, (length($15) == 0) ? "0" : $15, (length($16)) == 0 ? "0" : $16}'`

echo ${JSON} | ${MOSQUITTO_PUB} -r -h ${host} -t ${topic} -s

if [ $? -ne 0 ]
then
	echo "Error publishing to MQTT server/topic";
	exit 1
fi

echo "Update complete."
