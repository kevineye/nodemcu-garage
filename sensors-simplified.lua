local MODULE = 'sensors'
local config = require 'config'
local log = require 'log'
local m = require 'mqtt-connect'

local sensors = {}
sensors.SAMPLE_FREQ         = 60000
sensors.DHT_PIN             = nil
sensors.LIGHT_PIN           = nil

sensors.zone                = config.data['zone']
sensors.temp_offset         = config.data['temp_offset']

sensors.temp               = 0
sensors.humi               = 0
sensors.light              = 0

tmr.create():alarm(sensors.SAMPLE_FREQ, tmr.ALARM_AUTO, function()
    local status, temp, humi = dht.read(sensors.DHT_PIN)
    if status ~= dht.OK then
        log.log(4, MODULE, 'error reading from DHT')
        temp = sensors.temp
        humi = sensors.humi
    else
        temp = temp * 9 / 5 + 32;
        temp = temp + sensors.temp_offset;
        sensors.temp = temp;
        sensors.humi = humi;
    end

    sensors.light = adc.read(sensors.LIGHT_PIN) / 10.24

    local msg = string.format('{"temperature":%0.1f,"humidity":%d,"light":%d', sensors.temp, sensors.humi, sensors.light)
    if sensors.zone ~= nil then
        msg = msg .. ',"zone":"' .. sensors.zone .. '"'
    end
    msg = msg .. '}'
    log.log(7, MODULE, 'logging ' .. msg)
    m.client:publish(m.prefix .. "/sensors", msg, 0, 0)
end)

return sensors
