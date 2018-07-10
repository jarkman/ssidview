wifi.setmode(wifi.SOFTAP)
cfg={}
cfg.ssid="SSIDVIEW"
cfg.pwd="the_ESP8266_WIFI_password" 
wifi.ap.config(cfg)
ap_mac = wifi.ap.getmac()

 
led1 = 3
led2 = 4
gpio.mode(led1, gpio.OUTPUT)
gpio.mode(led2, gpio.OUTPUT)
 
n = 1

-- change SSID on probe:
-- wifi.eventmon.register(wifi.eventmon.AP_PROBEREQRECVED, function(T) 
 -- print("\n\tAP - PROBE".."\n\tMAC: ".. T.MAC.."\n\tRSSI: "..T.RSSI)
-- handleProbe(T.MAC)
-- end)

-- Change SSID periodically: 
-- mac and ios both poll every 10s for 1 minute, and show a list of aps in alpha order
--   but entries time out, maybe only get 6 ?
-- android only shows the most recent ap name for each ap, identified by mac
tmr.alarm(0,10000,1,function() handleTimer() end)


function ssidHeader(line)
header="."..string.char(string.byte("0")+line).."." -- eg .a.
return header
end

-- UTF text decorator:  http://qaz.wtf/u/convert.cgi?text=goth
-- emoji picker: http://emojikeyboard.org/

pacman={

"  🎬", -- 0
"  🌞",
"  🐒🐒🐒",
"  ▮",
"  ▮   🐒",
"  ▮   🐒🐒", --5
"  ▮   🐒🐒🐒", 
"  🐵🍖🐒",
"  🐵🍖☠",
"  🐵🍖",
"        🍖",  --10
"           🍖", -- 11
"                🚀",  -- 12
"                   🚀", -- 13
"                        🚀",  --14 
"   🚀          🛰",  -- 15
"    🚀        🛰",
"     🚀      🛰",
"         🖊💁",
"      🚀    🛰",
"       🚀 🛰", -- 20
"         🛰",
"         🍲",
"         🌒",
"         🌒▮",
"         🌒▮⚡", -- 25
"         🌒▮⚡⚡",
"         🌒▮⚡⚡⚡",
"  🌍",
"  🌍  🚀",
"  🌍          🚀", -- 30
"  🌍                  🚀",
"   🚀",
"           🚀",
"                      🚀",
"  🔴📻 ",
"  📻      🏃         🚶",
"  📻🏃               🚶",
"  🔴☠🏃            🚶",
"  🚶☠🔴",
"  🔴🎶", -- 40
"  🎆",
"  👽",
"  🚼"

}

function ssidBody(line) 
return pacman[line]
end

probes={}

-- This is an attempt to show the correct next frame to each client by 
-- spotting their probes and remembering which frame they saw last
-- It runs, but does not create the desired result, becuase (I think)
-- the SSID change doesn't take effect until after the probe has ben completed.


function handleProbe(mac)  -- if this never gets called, reboot your ESP
    -- print("\nProbe from "..mac)
    now=tmr.now()/1000000 -- convert uS to S
    newFrame=false
    
    if(probes[mac]==nil) then
        print("\nNew probe from "..mac)
        probes[mac]={}
        probes[mac].frame=0 
        probes[mac].time=0
        newFrame=true
    else
       age=now-probes[mac].time
       if age>1 then                -- many clients probe several times in a row, ignore repeats
        print("\nOld Probe from "..mac.." age : "..age)
        newFrame=true
       end
    end
    
    if newFrame then 
        showFrame(probes[mac].frame) 
        probes[mac].time=now
        probes[mac].frame=probes[mac].frame+1
    end
end

function showFrame(frame)
    frame=((frame-1)%44)+1

    print("\nshowing frame "..frame) 
    
    cfg={}
    newSsid=ssidHeader(frame)..ssidBody(frame)
    print(newSsid) 
    cfg.ssid=newSsid
    cfg.pwd="the_ESP8266_WIFI_password"  
    -- This is working code to change our MAC address on each frame change
    -- It has the effect of deduplicating our entries in the Android wifi AP
    -- picker.
    -- Some might argue that picking MAC addresses that aren't ours is a bad thing. 
    -- Though I think the real-world risk is small.
    if false then          
        newmac=string.sub(ap_mac,0,15)..(16+n) -- make a new mac with n for last 2 digits
    -- newmac="1A-FE-34-15-40-5B"
        print("Changed MAC address to "..newmac)
        wifi.ap.setmac(newmac) -- if this always fails with 'wrong arg type', update your ESP to new firmware
    end
    
    wifi.ap.config(cfg)

end

function handleTimer()

    showFrame(n)

    n=n+1
    if( n > 44 ) then
        n = 1
    end
end
