-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA


-- override this if you want to make new visualizations and look at them locally
function UsingMusicVis(name)
    return GetG("musicvis") == name
end

MVIS_DATA = {} -- MVIS_DATA or {}
MVIS_REQUESTS = {} -- MVIS_REQUESTS or {} 


BYTES_PER_FRAME = 33
function MvisGetFrame(data, fn)
    local m = math.floor(fn/3600)
    data = data[m]
    fn = fn - (3600*m)

    local t
    if not data or fn<0 or fn*BYTES_PER_FRAME+BYTES_PER_FRAME > data:len() then 
        t = {}
        for i=1,BYTES_PER_FRAME do table.insert(tab, 0) end
    else
        t = {string.byte(data,fn*BYTES_PER_FRAME+1,fn*BYTES_PER_FRAME+BYTES_PER_FRAME)}
        for i=1,BYTES_PER_FRAME do t[i]=t[i]/255 end
    end
    
    return {Vector(t[1],t[2],t[3]), t[7]}, table.sub(t,8,18), table.sub(t,19,33), Vector(t[4],t[5],t[6])
end

function MvisAddTables(a,b)
    for k,v in pairs(a) do
        a[k] = v + b[k]
    end
    return a
end

function MvisMulTable(a,b)
    for k,v in pairs(a) do
        a[k] = v * b
    end
    return a
end

function MvisResetTrackers()
    MVIS_TRACKERS = {}
    MVIS_SUMS = {}
    MVIS_LASTVFRAME = -1
end
MvisResetTrackers() 


function MvisDecayingMean(k, val, blend, initial)
    if MVIS_TRACKERS[k]==nil then
        MVIS_TRACKERS[k] = initial or val
    end
    MVIS_TRACKERS[k] = MVIS_TRACKERS[k] * (1-blend) + val*blend
    MVISTAB[k] = MVIS_TRACKERS[k]
    return MVISTAB[k]
end

function MvisMean(k, val, framecount, initial)
    if MVIS_TRACKERS[k]==nil then
        MVIS_TRACKERS[k] = {}
        MVIS_SUMS[k] = 0
        if initial then
            while #tab < framecount do
                table.insert(tab, initial)
            end
            MVIS_SUMS[k] = initial * framecount
        end
    end
    local tab = MVIS_TRACKERS[k]
    local sum = MVIS_SUMS[k]
    while #tab >= framecount do
        sum = sum-table.remove(tab, 1)
    end

    table.insert(tab, val)
    MVIS_SUMS[k] = val+sum
    
    MVISTAB[k] = MVIS_SUMS[k] / (#(MVIS_TRACKERS[k]))
    return MVISTAB[k]
end

function MvisMeanStd(k,val,framecount)
    MvisMean(k,val,framecount)
    local k2 = k.."_sqr"
    MvisMean(k2,val*val,framecount)
    local var = MVISTAB[k2] - MVISTAB[k]*MVISTAB[k]
    MVISTAB[k.."_std"] = (isnumber(var) and math.sqrt(var) or var:Max(Vector(0,0,0)):Pow(0.5))
    return MVISTAB[k], MVISTAB[k.."_std"]
end

function MvisDecayingMax(k,val,decay,subtract)
    if MVIS_TRACKERS[k]==nil then
        MVIS_TRACKERS[k]=val
    else
        MVIS_TRACKERS[k]=subtract and math.max(val,MVIS_TRACKERS[k]-decay) or math.max(val,MVIS_TRACKERS[k]*decay)
    end
    MVISTAB[k] = MVIS_TRACKERS[k]
    return MVISTAB[k]
end

function MvisInterpolating(k,inc,gen)
    if MVIS_TRACKERS[k]==nil then
        MVIS_TRACKERS[k] = {0, gen(0), gen(1)}
    end
    local lastid = math.floor(MVIS_TRACKERS[k][1])
    MVIS_TRACKERS[k][1] = MVIS_TRACKERS[k][1] + inc
    local t = MVIS_TRACKERS[k][1]
    local frameid = math.floor(t)

    if lastid ~= frameid then
        MVIS_TRACKERS[k][2] = MVIS_TRACKERS[k][3]
        MVIS_TRACKERS[k][3] = gen(frameid+1)
    end

    v0 = MVIS_TRACKERS[k][2]
    v1 = MVIS_TRACKERS[k][3]
    if isfunction(v0) then v0=v0() end
    if isfunction(v1) then v1=v1() end

    MVISTAB[k] = (isvector(v0) and LerpVector or Lerp)(t-frameid,v0,v1)
    return MVISTAB[k]
end

-- keeps track of last frame's params
MVISTAB={} 
function MvisNextFrame(f,fft, resp)
    local col,vol = unpack(f)
    local last = MVISTAB or {}
    MVISTAB={}
    local tab = MVISTAB

    local m = resp[2]
    for i = 3,#resp do m = math.max(m, resp[i]) end

    MvisDecayingMax("instrument", m, 0.9, false)

    MvisMean("mc05", col:Mean(), 30)
    MvisMeanStd("v05", vol, 30)


    MvisMeanStd("c1", col, 60)
    MvisMeanStd("c2", col, 120)
    MvisMeanStd("c4", col, 240)
    MvisMeanStd("v05", vol, 30)
    MvisMean("fft1d", fft[1], 10)
    -- MvisDecayingMax("fft1d", fft[1], 0.9, false)
    MvisDecayingMax("fft2d", math.max(fft[2],fft[3]), 0.9, false)

    -- a,b = tab["fft1d"], tab["fft2d"]
    -- wa,wb = math.pow(a,2),math.pow(b*0.7,2)
    -- (b*wb - a*wa ) / (wa+wb + 0.001)

    MvisDecayingMax("dualbass1",tab["fft2d"]*0.7>tab["fft1d"] and tab["fft2d"] or -tab["fft1d"], 0.25, true)

    -- print(math.max(1, 1-math.pow((last["dualbass"]or 0)-tab["dualbass1"],4)))
    MvisDecayingMean("dualbass",tab["dualbass1"],math.min(1, math.abs((last["dualbass"]or 0)-tab["dualbass1"])^0.5  ))

    MvisInterpolating("alternating_color", 1/60, function(i) 
        local hsv = VectorRand(0, 1)
        -- print("Cb1", hsv, i)
        if i%2==1 then
            -- local genx = hsv.x
            -- return function()
                local sc_h, sc_s, sc_v = ColorToHSV(tab["c1"]:ToColor() )
                hsv.x = ((sc_h / 360) + hsv.x * 0.1 - 0.05) % 1
            --     return hsv
            -- end
        end
        return hsv
    end)

    -- tab["lead"] = math.max(fft[4],fft[5],fft[6]) - math.min(fft[4],fft[5],fft[6]) --math.max(fft[7],fft[8],fft[9])
    -- tab["lead"] = math.max(fft[5],fft[6],fft[7]) - math.min(fft[5],fft[6],fft[7])
end




hook.Add("RenderScreenspaceEffects", "MusicVis", function()
    local th = (IsValid(LocalPlayer()) and LocalPlayer():GetLocationName() == "Vapor Lounge") and LocalPlayer():GetTheater()
    if th and th:IsPlaying() then
        if not GetConVar("musicvis_flashing"):GetBool() then
            if not MVIS_ASKEDFLASHING then
               MVIS_ASKEDFLASHING = true
                Derma_Query("Enable effects? Do not accept if you are prone to epilepsy.", "Epilepsy warning", "No", function() end, "Enable", function()
                    GetConVar("musicvis_flashing"):SetBool(true)
                end)
            end
            return
        end

        if th:VideoType()~="youtube" then
            draw.DrawText("FX only work with YouTube videos", "DermaLarge", ScrW() * 0.5, ScrH() * 0.1, Color(255,255,255,255), TEXT_ALIGN_CENTER)
            return
        end

        if UsingMusicVis("none") then return end

        local thekey = th:VideoKey()
        if not MVIS_REQUESTS[thekey] then
            MVIS_REQUESTS[thekey] = {}
            MVIS_DATA[thekey] = {}
        end

        local ts = (YoutubeActualTimestamp() or 0) + 0.02 --remove latency
        local vframe = math.max(0, math.floor(ts*60))
        local vminute = math.max(0, math.floor(ts/60))

        for _,look in ipairs({vminute,vminute+1}) do
            local theminute = look
            if not MVIS_REQUESTS[thekey][theminute] then
                MVIS_REQUESTS[thekey][theminute]=true
                http.Fetch("http://swampservers.net/fft/data/"..thekey.."/"..tostring(theminute).."?"..tostring(os.time()),function(b,l,h,c) if c==200 then print("DATASIZE", b:len()) MVIS_DATA[thekey][theminute]=b else timer.Simple(3,function() MVIS_REQUESTS[thekey][theminute]=false end) end end, function(msg) timer.Simple(3,function() MVIS_REQUESTS[thekey][theminute]=false end) end)
            end
        end

        local data = MVIS_DATA[thekey]
        if not data[vminute] then
            draw.DrawText("Generating FX...", "DermaLarge", ScrW() * 0.5, ScrH() * 0.1, Color(255,255,255,255), TEXT_ALIGN_CENTER)
            return
        end

        --reset the tracker thing
        if vframe < MVIS_LASTVFRAME or vframe > MVIS_LASTVFRAME+100 then
            MvisResetTrackers()
            MVIS_LASTVFRAME = vframe-1
        end

        local avg,fft

        local frame2add = MVIS_LASTVFRAME+1
        MVIS_LASTVFRAME = vframe
        while frame2add <= vframe do
            avg, fft, resp = MvisGetFrame(data, frame2add)
            MvisNextFrame(avg, fft, resp)
            frame2add = frame2add +1
        end
    

        avg, fft, resp, diff = MvisGetFrame(data, vframe)
        local avgc = 1

        local countback = vframe-1
        --antiflicker
        local antiflickerframes = UsingMusicVis("dynamic") and 40 or 4
        while countback>vframe-antiflickerframes do
            f2,fft2 = MvisGetFrame(data, countback)
            avg = MvisAddTables(avg, f2)
            avgc = avgc+1
            countback = countback-1
        end
        
        avg = MvisMulTable(avg,1/avgc)

        local tab = MVISTAB --args from MvisNextFrame

        local mean, meanvol = unpack(avg)        

        local mean1, std1 = tab["c1"], tab["c1_std"]
        local mean4, std4 = tab["c4"], tab["c4_std"]
        local mv5,std5 = tab["v05"], tab["v05_std"]

        local normvol = (meanvol-mv5) --not actual std

        -- TODO: use long color mean for extra darkness, short color mean for extra flash

        local normalized = (mean - tab["c4"]) --mean1:Max(mean1)) -- / (std1+0.006)  --max of 2 running means to prefer a lower normalized value
        local norm_avg = normalized:Mean()
        local mean_avg = mean:Mean() --VAPOR_RUNNINGMEAN)
        -- local transition_avg = vecavg(VAPOR_RUNNINGMEAN - VAPOR_RUNNINGMEAN_LONG)
        -- local finalpower = 1 - tab["fft2d"]*2  -- 0.85- (norm_avg * 1 + mean_avg * 0.8 + (meanvol-0.5) * 5) --math.sin(SysTime()*10)*0.5+0.5

        -- 1 = default light, 0 = squared light with color. it can go above 1 but not below 0 (it should have dark non-flickery parts.. maybe bright nonflicker when the image is bright? )
        local drive = -0.35 + tab["dualbass"]+tab["v05"]*1.5 + normalized:Mean()*2

        -- drive = math.pow(math.max(0,drive), 2)

        if UsingMusicVis("flash") then drive=drive+1 end
        if UsingMusicVis("dark") or UsingMusicVis("colorful") then drive=0 end

        local hsv = tab["alternating_color"]

        local maxextradarkness = math.max(0.4-mean4:Mean(), 0) * 0.6
        local extradarkness = (math.max(0.3-drive, 0)/0.3) * maxextradarkness
        -- VaporChart("med", maxextradarkness) 
        local colormod = HSVToColor(hsv.x * 360, math.sqrt(hsv.y), 1-extradarkness) --math.max((finalpower-1)*0.1, 0))
        colormod = Vector(colormod.r / 255, colormod.g / 255, colormod.b / 255)


        if UsingMusicVis("dark") then
            colormod = Vector(0.5,0.5,0.5)
            drive = drive*0.3
        end

        if UsingMusicVis("red") then
            --local other = math.max(0, 0.5 - drive
            colormod = Vector(math.min(0.7,drive)+0.3,0.1,0.1)
            drive = 0 --drive*0.1
        end

        local extraflash = 0
        if FORCEDRIVE then drive=FORCEDRIVE end
        if drive>1 then
            -- flashing increases when the screen is bright... TODO make it adjust drive directly but make it balance with sound
            extraflash = math.min((drive-1)/(2 - mean:Mean()*1.5), 0.5+mean:Mean())

            if UsingMusicVis("flash") then extraflash=extraflash*1.5 end

            DrawColorModify({
                ["$pp_colour_addr"] = 0, --ADD TO ONE
                ["$pp_colour_addg"] = 0,
                ["$pp_colour_addb"] = 0,
                ["$pp_colour_brightness"] = extraflash * 0.15, --ADD TO ALL
                ["$pp_colour_colour"] = 1 + extraflash*0.15, --SATURATION
                ["$pp_colour_mulr"] = 0, -- MULTIPLY ONE...?
                ["$pp_colour_mulg"] = 0,
                ["$pp_colour_mulb"] = 0,
                ["$pp_colour_contrast"] = 1 + extraflash, --MULTIPLY ALL
            })
        else
            DrawSquareColor(1-drive, colormod, false)
        end

        if GetConVar("musicvis_debug"):GetBool() then
            draw.DrawText("Setting: "..tostring(GetG("musicvis")), "DermaDefault", 310,1)
            VaporChart("drive") 
            VaporChart("colormod")
            VaporChart("extraflash")
        
        
            VaporChart("instrument",tab["instrument"])
        
            VaporChart("framediff") 
            --band notes
            -- 1 very low
            -- 2 is kick
            -- 3 is like low humming or higher kick
        
            VaporChart("volume", meanvol)
            -- VaporChart("fft1", fft[1])
            VaporChart("fft1d", tab["fft1d"])
            -- VaporChart("fft1m", tab["fft1m"])
            -- VaporChart("fft2", fft[2])
            VaporChart("fft2d", tab["fft2d"])
            VaporChart("dualbass", tab["dualbass"]+0.5)
            VaporChart("dualbass1", tab["dualbass1"]+0.5)
            -- VaporChart("fftub", fft[3])
            -- VaporChart("fft5", fft[5])
            -- VaporChart("fft9", fft[9])
            -- VaporChart("nvolume", normvol+0.5)
            -- VaporChart("mvolume", mv5)
            VaporChart("normalized", (normalized) + 0.5)
        
            VaporChart("mean", mean)
            VaporChart("rmean1", mean1)
            VaporChart("rmean4",mean4)
            -- VaporChart("mean-running_mean", mean-VAPOR_RUNNINGMEAN + Vector(0.5,0.5,0.5))
            VaporChart("std1", std1)
        
            -- local h, s, v = ColorToHSV(mean1:ToColor())
            -- VaporChart("hue", h / 360)
            -- VaporChart("extradarkness", extradarkness)
            -- VaporChart("extraflash", extraflash)
        
            
            for i,v in ipairs(fft) do
                surface.SetDrawColor( 255,255,i%2==0 and 128 or 255, 255 )
                surface.DrawRect(400 + i*20,0,15,v*500 )
                draw.DrawText(tostring(i), "Trebuchet18", 402 + i*20, 2, Color(0,0,0,255))
            end
            for i,v in ipairs(resp) do
                surface.SetDrawColor( 255,i%2==0 and 128 or 255,255, 255 )
                surface.DrawRect(800 + i*20,0,15,v*500 )
                draw.DrawText(tostring(i), "Trebuchet18", 802 + i*20, 2, Color(0,0,0,255))
            end
            surface.SetDrawColor( 255,255,255, 255 )
            surface.DrawRect(400 ,500,200,2 )
        end

        VAPOR_LAST_DRIVE = drive
        VAPOR_LAST_FFT = fft
    end
end) 

VAPOR_CHARTS = {}