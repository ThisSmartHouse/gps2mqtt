# gps2mqtt
A shell script based on atinout and mosquitto_pub to publish GPS coordinates from a Raspberry Pi powered WaveShare GPS/GSM modem 

# Requirements

Built for the WaveShare GSM / GPRS / GNSS HAT for Raspberry Pi (https://www.waveshare.com/wiki/GSM/GPRS/GNSS_HAT)

To use this script you'll need the `atinout` package **This Smart House Version** found here:

http://github.com/ThisSmartHouse/atinout

If you don't use the version maintained by This Smart House this script will likely not function properly as it will not time out when trying to determine if the GPS module is alive.

It is also assumed you have the `mosquitto-clients` package installed

# Setting up

Install `atinout` (forked version) and `mosquitto-clients` Edit the `baud`, `tty`, `host` and `topic` variables set at the top of the script and run!

```
$ git clone http://github.com/ThisSmartHouse/atinout
$ cd atinout
$ make
$ sudo make install
$ cd ..
$ sudo apt-get install mosquitto-clients
$ git clone http://github.com/ThisSmartHouse/gps2mqtt
$ nano gps2mqtt/gps2mqtt.sh

<edit configuration> 

$ sudo cp gps2mqtt/gps2mqtt.sh /usr/local/bin
$ sudo chmod +x /usr/local/bin/gps2mqtt.sh
$ crontab -e

<create a crontab for how frequently you want to publish GPS data>

```
