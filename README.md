# NodeMCU Garage Door Controller

MQTT garage door controller. Also includes temperature and light level logger.

Overall NodeMCU docs:

 * https://nodemcu.readthedocs.io/en/dev/

## Lua firmware setup

#### Build firmware

The lua-based NodeMCU firmware must be built and flashed to the ESP8266. Then the code is uploaded to the firmware's filesystem.

### Build NodeMCU firmware

Build the firmware using the [NodeMCU cloud build service](https://nodemcu-build.com/). Select at least the following modules:

  * CJSON
  * file (default)
  * GPIO (default)
  * MQTT
  * net (default)
  * node (default)
  * timer (default)
  * UART (default)
  * WiFi (default)

Download the "float" version of the build.

### Upload firmware (serial)

Download [esptool,py](https://github.com/themadinventor/esptool) to flash firmware.

    export NODEMCU_DEV=/dev/tty.usbserial*
    alias esptool='esptool.py --port $NODEMCU_DEV --baud 115200'
    
    # upgrade esp SDK
    esptool erase_flash
    esptool write_flash -fm dio -fs 32m 0x00000 nodemcu-master-....bin 0x3fc000 esp_init_data_default.bin
    
    # or just flash
    esptool write_flash -fm dio -fs 32m 0x00000 nodemcu-master-....bin

Programming some modules requires a jumper or button to be set while the device is powered on to enter reprogramming mode.

### Terminal monitor/REPL (serial)

    miniterm.py $NODEMCU_DEV 115200

### Local upload all files (serial)

Download [nodemcu-uploader.py](https://github.com/kmpm/nodemcu-uploader) for local (USB/serial) management.

    export NODEMCU_DEV=/dev/tty.usbserial*
    alias nodemcu-uploader='nodemcu-uploader --port $NODEMCU_DEV'

    nodemcu-uploader upload --restart *.lua *.json && \
    nodemcu-uploader terminal

### Remote management (wifi)

Download [loatool.py](https://github.com/4refr0nt/luatool) for remote (telnet) management.

    export NODEMCU_HOST=<device-ip>
    export NODEMCU_PORT=2323
    alias luatool='luatool --ip $NODEMCU_HOST:$NODEMCU_PORT'

    luatool --restart --src <file.lua>
  
    telnet $NODEMCU_HOST $NODEMCU_PORT
    nc $NODEMCU_HOST $NODEMCU_PORT

These commands only work if a telnet server is running on the device. If the device is otherwise inaccessible, be very
careful not to upload code (such as a broken init.lua) that will fail to connect to wifi, have an error before running 
the telnet server or reboot without allowing time to send some commands.


## Operation

The device will connect to WiFi and MQTT with the settings in config.json. Make sure these are correct before transferring to the device.

### Feedback

When powered on, the LED will give three quick flashes every three seconds until it is successfully connected to WiFi and MQTT. The LED will give two slower flashes when the garage door is opened or closed.

### MQTT

The device will subscribe and publish with a configurable root path, called "home/garage" below, for basic status and configuration.

| Topic                     | Pub/Sub   | Payload   | Description |
|---------------------------|-----------|-----------|-------------|
| `home/garage/ping`        | subscribe | *any*     | Triggers publishing status message. |
| `home/garage/status`      | publish   | *JSON*    | Status info is published at connect and retained. Contains IP address and other info. Marked offline when device is not connected. Retained. |
| `home/garage/config`      | subscribe | key=value | Persistently sets a configuration value in config.json. |
| `home/garage/config`      | subscribe | ping      | Triggers publishing config JSON dump. |
| `home/garage/config`      | subscribe | restart   | Restarts the device. |
| `home/garage/config/json` | publish   | *JSON*    | Configuration values (initially from config.json) are dumped in response to config ping. |
| `home/garage/door/toggle` | subscribe | *any*     | Push the door opener button, i.e. start up or down, or stop if already moving. |
| `home/garage/door`        | publish   | *JSON*    | State of door in json, i.e. {"state":"closed"} or {"state":"open"} |
| `home/garage/sensors`     | publish   | *JSON*    | Sensor data, like {"temperature":72.5,"humidity":65,"light":99}, published every minute. |
