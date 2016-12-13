fake_temp = 22.0
fake_humi = 50.0

dht = {}

dht.OK = 1

dht.read = function()
    fake_temp = fake_temp + 0.1
    fake_humi = fake_humi + 0.1
    return dht.OK, fake_temp, fake_humi
end
