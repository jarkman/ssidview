wifi.setmode(wifi.SOFTAP)
cfg={}
cfg.ssid="ESP_STATION"
cfg.pwd="the_ESP8266_WIFI_password"
wifi.ap.config(cfg)
ap_mac = wifi.ap.getmac()

newmac=ap_mac
print(newmac)
wifi.ap.setmac(newmac) -- always fails with 'wrong arg type'


