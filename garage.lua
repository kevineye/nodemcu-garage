local MODULE = 'garage'
local m = require 'mqtt-connect'
local log = require 'log'

local garage = {}

garage.PIN_STATE    = 1
garage.PIN_OPENER   = 5
garage.is_open      = false

m.onConnect(function(client)
    client:subscribe(m.prefix .. "/door/toggle", 0)
    client:subscribe(m.prefix .. "/door/open", 0)
    client:subscribe(m.prefix .. "/door/close", 0)
    garage.publishopen()
end)

m.onMessage(function(_, t, pl)
    if pl == nil then pl = "" end
    log.log(7, MODULE, "got " .. pl .. " " .. t)
    if (t == m.prefix .. "/door/open" and not garage.is_open)
    or (t == m.prefix .. "/door/close" and garage.is_open)
    or (t == m.prefix .. "/door/toggle") then
        garage.toggleopen()
    end
end)

function garage.publishopen()
    local msg = '{"state":"' .. (garage.is_open and "open" or "closed") .. '"}'
    m.client:publish(m.prefix .. "/door", msg, 0, 1)
end

gpio.mode(garage.PIN_OPENER, gpio.OUTPUT)
gpio.write(garage.PIN_OPENER, gpio.LOW)

function garage.toggleopen()
    log.log(5, MODULE, "opening/closing")
    gpio.serout(garage.PIN_OPENER, gpio.HIGH, {400000,400000}, 1, function()
        gpio.serout(PIN_LED, gpio.LOW, { 200000, 200000 }, 2, 1)
    end)
end

function debounce(func)
    local last = 0
    local delay = 500000 -- 500ms * 1000 as tmr.now() has μs resolution

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
    garage.is_open = gpio.read(garage.PIN_STATE) == gpio.HIGH
    log.log(5, MODULE, "door is " .. (garage.is_open and "open" or "closed"))
    garage.publishopen()
end

gpio.mode(garage.PIN_STATE, gpio.INT, gpio.PULLUP)
gpio.trig(garage.PIN_STATE, 'both', debounce(buttonpress))

return garage
