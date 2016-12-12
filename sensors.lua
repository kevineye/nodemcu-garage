-- dht22 -----------------------------------------------------------------

function tofahrenheit(c)
    return c * 9 / 5 + 32
end

 function publishsensors()
    status, temp, humi = dht.read(PIN_DHT)
    if status == dht.OK then
        temp = tofahrenheit(temp)
        print("DHT Temperature:"..temp..";".."Humidity:"..humi)
        light = adc.read(PIN_PHOTO)
        print("Light:"..light)
        local msg = string.format('{"temperature":%0.1f,"humidity":%d,"light":%d}', temp, humi, light/3.5)
        m:publish(config.mqtt_prefix .. "/sensors", msg, 0, 0)
    end
end

tmr.alarm(TIMER_SENSORS, 60000, tmr.ALARM_AUTO, publishsensors)
