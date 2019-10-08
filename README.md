# gps2mqtt
A shell script based on atinout and mosquitto_pub to publish GPS coordinates from a Raspberry Pi powered WaveShare GPS/GSM modem 

# Requirements

Built for the WaveShare GSM / GPRS / GNSS HAT for Raspberry Pi (https://www.waveshare.com/wiki/GSM/GPRS/GNSS_HAT)

To use this script you'll need the `atinout` package **This Smart House Version** found here:

http://github.com/ThisSmartHouse/atinout

If you don't use the version maintained by This Smart House this script will likely not function properly as it will not time out when trying to determine if the GPS module is alive.

It is also assumed you have the `mosquitto-clients` package installed
