 -- mqtt ------------------------------------------------------------------

m:on("connect", function(m)
    mqtt_cb.connect(m)
    m:subscribe(config.mqtt_prefix .. "/door/toggle", 0)
    publishopen()
end)

m:on("message", function(m, t, pl)
    mqtt_cb.message(m, t, pl)
    if (t == config.mqtt_prefix .. "/door/toggle") then
        toggleopen()
    end
end)

function publishopen()
    local msg = '{"state":"' .. (is_open and "open" or "closed") .. '"}'
    m:publish(config.mqtt_prefix .. "/door", msg, 0, 1)
end


-- relay/opener ----------------------------------------------------------

gpio.mode(PIN_OPENER, gpio.OUTPUT)
gpio.write(PIN_OPENER, gpio.LOW)

function toggleopen()
    print("Opening/closing")
    gpio.serout(PIN_OPENER, gpio.HIGH, {400000,400000}, 1, function()
        gpio.serout(PIN_LED, gpio.LOW, { 200000, 200000 }, 2, 1)
    end)
end


 -- state/open sensor -----------------------------------------------------

function debounce(func)
    local last = 0
    local delay = 50000 -- 50ms * 1000 as tmr.now() has μs resolution

    return function(...)
        local now = tmr.now()
        local delta = now - last
        if delta < 0 then delta = delta + 2147483647 end; -- proposed because of delta rolling over, https://github.com/hackhitchin/esp8266-co-uk/issues/2
        if delta < delay then return end;

        last = now
        return func(...)
    end
end

function buttonpress()
    is_open = gpio.read(PIN_STATE) == gpio.HIGH
    print("Door is " .. (is_open and "open" or "closed"))
    publishopen()
end

gpio.mode(PIN_STATE, gpio.INT, gpio.PULLUP) -- see https://github.com/hackhitchin/esp8266-co-uk/pull/1
gpio.trig(PIN_STATE, 'both', debounce(buttonpress))
