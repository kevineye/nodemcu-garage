PIN_LED         = 4

local log = require 'log'
log.level = 7

require 'config'
require 'ready'

local app = {}

function app.run()
    require 'telnet'
    require 'mqtt-connect'
    local sensors = require 'sensors'
    sensors.DHT_PIN             = 2
    sensors.LIGHT_PIN           = 0
    require 'garage'
    ready = ready - 1
end

return app
