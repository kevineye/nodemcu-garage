SAMPLE_FREQ         = 10000  -- how often to sample sensors (ms)
REPORT_PERIOD       = 6      -- report every N samples
AVG_PERIOD          = 6      -- moving average of N samples

countdown_to_report = 0      -- number of samples until next report
sample_count        = 0      -- how many sampless in the average
avg_temp            = 0      -- current average temp
avg_humi            = 0      -- current average humidity
avg_light           = 0      -- current average light level

function readsensors()
    if sample_count < AVG_PERIOD then
        sample_count = sample_count + 1
    end

    local status, temp, humi = dht.read(PIN_DHT)
    if status ~= dht.OK then
        print("Error reading from DHT.")
        return
    end

    temp = temp * 9 / 5 + 32; -- convert to fahrenheit
    local light = adc.read(PIN_PHOTO) / 3.5
    avg_temp  = avg_temp  + (temp  - avg_temp ) / sample_count
    avg_humi  = avg_humi  + (humi  - avg_humi ) / sample_count
    avg_light = avg_light + (light - avg_light) / sample_count

    -- print("raw temperature:"..temp.." humidity:"..humi.." light:"..light)

    if countdown_to_report == 0 then
        countdown_to_report = REPORT_PERIOD
        local msg = string.format('{"temperature":%0.1f,"humidity":%d,"light":%d,"zone":%d}', avg_temp, avg_humi, avg_light, config.zone)
        print(msg)
        m:publish(config.mqtt_prefix .. "/sensors", msg, 0, 0)
    end

    countdown_to_report = countdown_to_report - 1
end

tmr.alarm(TIMER_SENSORS, SAMPLE_FREQ, tmr.ALARM_AUTO, readsensors)
