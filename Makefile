SRC_FILES := \
    lib/config.lua \
    lib/init.lua \
    lib/log.lua \
    lib/mqtt-connect.lua \
    lib/ready.lua \
    lib/telnet.lua \
    sensors-simplified.lua \
    lib/wifi-connect.lua \
    app.lua \
    garage.lua \
    config.json

include lib/Makefile.mk
