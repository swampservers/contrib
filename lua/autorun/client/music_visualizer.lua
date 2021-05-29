-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
-- override this if you want to make new visualizations and look at them locally
function UsingMusicVis(name)
    return GetG("musicvis") == name
end 

MVIS_DATA = {} -- MVIS_DATA or {}
MVIS_REQUESTS = {} -- MVIS_REQUESTS or {} 
BYTES_PER_FRAME = 43 + 19

function MvisGetFrame(data, fn)
    local m = math.floor(fn / 3600)
    data = data[m]
    fn = fn - (3600 * m)
    local t

    if not data or fn < 0 or fn * BYTES_PER_FRAME + BYTES_PER_FRAME > data:len() then
        t = {}

        for i = 1, BYTES_PER_FRAME do
            table.insert(t, 0)
        end
    else
        t = {string.byte(data, fn * BYTES_PER_FRAME + 1, fn * BYTES_PER_FRAME + BYTES_PER_FRAME)}

        for i = 1, BYTES_PER_FRAME do
            t[i] = t[i] / 255
        end
    end

    return Vector(t[1], t[2], t[3]), Vector(t[4], t[5], t[6]), t[7], table.sub(t, 8, 18), table.sub(t, 19, 37), table.sub(t, 19 + 19, 43 + 19)
end

MVIS_TRACKERS = {}
MVIS_LOOKAHEAD_FRAMES = 30

function MvisDecayingMean(k, val, blend, initial)
    if MVIS_TRACKERS[k] == nil then
        MVIS_TRACKERS[k] = initial or val
    end

    MVIS_TRACKERS[k] = MVIS_TRACKERS[k] * blend + val * (1 - blend)
    MVISTAB_NEXT[k] = MVIS_TRACKERS[k]

    return MVISTAB_NEXT[k]
end

function MvisDelay(k, val, frames)
    if MVIS_TRACKERS[k] == nil then
        MVIS_TRACKERS[k] = {}
    end

    local tab = MVIS_TRACKERS[k]

    while #tab <= frames do
        table.insert(tab, val)
    end

    MVISTAB_NEXT[k] = table.remove(tab, 1)

    return MVISTAB_NEXT[k]
end

function MvisMedian(k, val, frames, bilateral_maxdiff)
    if MVIS_TRACKERS[k] == nil then
        MVIS_TRACKERS[k] = {}
    end

    assert(isnumber(val))
    local tab = MVIS_TRACKERS[k]

    while #tab <= frames do
        table.insert(tab, val)
    end

    table.remove(tab, 1)
    tab = table.Copy(tab)

    if bilateral_maxdiff then
        local i = 1

        while i <= #tab do
            if math.abs(tab[i] - val) > bilateral_maxdiff then
                table.remove(tab, i)
            else
                i = i + 1
            end
        end
    end

    table.sort(tab)
    MVISTAB_NEXT[k] = tab[math.ceil((#tab) / 2)]

    return MVISTAB_NEXT[k]
end

function MvisBilateral(k, val, frames, maxdiff)
    if MVIS_TRACKERS[k] == nil then
        MVIS_TRACKERS[k] = {}
    end

    assert(isnumber(val))
    local tab = MVIS_TRACKERS[k]

    while #tab <= frames do
        table.insert(tab, val)
    end

    table.remove(tab, 1)
    local total, count = 0, 0

    for i, v in ipairs(tab) do
        if math.abs(v - val) < maxdiff then
            total = total + v
            count = count + 1
        end
    end

    MVISTAB_NEXT[k] = total / count

    return MVISTAB_NEXT[k]
end

function MvisMean(k, val, framecount, initial)
    if MVIS_TRACKERS[k] == nil then
        MVIS_TRACKERS[k] = {{}, isvector(val) and Vector() or 0}

        local tab = MVIS_TRACKERS[k][1]

        if initial then
            while #tab < framecount do
                table.insert(tab, initial)
            end

            MVIS_TRACKERS[k][2] = initial * framecount
        end
    end

    local tab, sum = unpack(MVIS_TRACKERS[k])

    while #tab >= framecount do
        sum = sum - table.remove(tab, 1)
    end

    table.insert(tab, val)
    sum = sum + val
    MVIS_TRACKERS[k][2] = sum
    MVISTAB_NEXT[k] = sum / (#tab)

    return MVISTAB_NEXT[k]
end

function MvisMeanStd(k, val, framecount)
    MvisMean(k, val, framecount)
    local k2 = k .. "_sqr"
    MvisMean(k2, val * val, framecount)
    local var = MVISTAB_NEXT[k2] - MVISTAB_NEXT[k] * MVISTAB_NEXT[k]
    MVISTAB_NEXT[k .. "_std"] = (isnumber(var) and math.sqrt(var) or var:Max(Vector(0, 0, 0)):Pow(0.5))

    return MVISTAB_NEXT[k], MVISTAB_NEXT[k .. "_std"]
end

function MvisDecayingMax(k, val, decay, subtract)
    if MVIS_TRACKERS[k] == nil then
        MVIS_TRACKERS[k] = val
    else
        MVIS_TRACKERS[k] = subtract and math.max(val, MVIS_TRACKERS[k] - decay) or math.max(val, MVIS_TRACKERS[k] * decay)
    end

    MVISTAB_NEXT[k] = MVIS_TRACKERS[k]

    return MVISTAB_NEXT[k]
end

function MvisInterpolating(k, inc, gen)
    if MVIS_TRACKERS[k] == nil then
        MVIS_TRACKERS[k] = {0, gen(0), gen(1)}
    end

    local lastid = math.floor(MVIS_TRACKERS[k][1])
    MVIS_TRACKERS[k][1] = MVIS_TRACKERS[k][1] + inc
    local t = MVIS_TRACKERS[k][1]
    local frameid = math.floor(t)

    if lastid ~= frameid then
        MVIS_TRACKERS[k][2] = MVIS_TRACKERS[k][3]
        MVIS_TRACKERS[k][3] = gen(frameid + 1)
    end

    v0 = MVIS_TRACKERS[k][2]
    v1 = MVIS_TRACKERS[k][3]

    if isfunction(v0) then
        v0 = v0()
    end

    if isfunction(v1) then
        v1 = v1()
    end

    MVISTAB_NEXT[k] = (isvector(v0) and LerpVector or Lerp)(t - frameid, v0, v1)

    return MVISTAB_NEXT[k]
end

-- keeps track of last frame's params
MVISTAB_LAST = {}
MVISTAB_NEXT = {}
MVIS_PLOTS = {} --make sure to clear this every file reload

function MvisNextFrame(...)
    MVISTAB_LAST = MVISTAB_NEXT or {}
    MVISTAB_NEXT = {}
    local l, t = MVISTAB_LAST, MVISTAB_NEXT

    -- the inputs are MVIS_LOOKAHEAD_FRAMES ahead of time, just correct it for now, but it could be useful
    col, colchange, amplitude, fft1, fft2, harmonics = unpack(MvisDelay("lookahead_delay", {...}, MVIS_LOOKAHEAD_FRAMES))

    t.avgfft1 = table.isum(fft1) / (#fft1)
    t.maxharmonic = table.imax(harmonics)
    t.avgharmonic = table.isum(harmonics) / (#harmonics)
    t.harmonicpower = t.maxharmonic - t.avgharmonic
    local fftdelta = {}

    for i = 1, #fft1 do
        table.insert(fftdelta, fft1[i] - ((l.fft1 or {})[i] or 0))
    end

    local fftds, fftdsa = 0, 0

    for i = 1, #fft1 do
        fftds = fftds + fftdelta[i]
        fftdsa = fftdsa + math.abs(fftdelta[i])
    end

    t.fftds = fftds
    t.fftdsa = fftdsa
    t.fftdso = math.abs(fftds) / (fftdsa + 0.1)
    MvisDecayingMax("snare", math.max(fft1[8], fft1[9]) - t.avgfft1, 0.9, false)
    MvisDecayingMax("instrument", m, 0.9, false)
    MvisMean("mc05", col:Mean(), 30)
    MvisMeanStd("v05", amplitude, 30)
    MvisMeanStd("col1", col, 60)
    MvisMeanStd("col2", col, 120)
    MvisMeanStd("col4", col, 240)
    -- MvisMean("fft1d", fft1[1], 10)
    t.fft1d = fft1[1]
    t.fft2d = math.max(fft1[2], fft1[3])
    -- MvisDecayingMax("fft1d", fft[1], 0.9, false)
    -- MvisDecayingMax("fft2d", math.max(fft1[2],fft1[3]), 0.9, false)
    a, b = t.fft1d, t.fft2d
    wa, wb = math.pow(a, 3), math.pow(b, 3) * 0.75
    t.dualbass1 = (b * wb - a * wa) / (wa + wb + 0.001)
    -- t.dualbass1 = t.fft2d*0.75>t.fft1d and t.fft2d or -t.fft1d
    MvisDecayingMax("dualbass_factor", math.abs((l.dualbass2 or 0) - t.dualbass1), 0.2, true)
    -- print(math.max(1, 1-math.pow((last["dualbass"]or 0)-tab["dualbass1"],4)))
    MvisDecayingMean("dualbass2", t.dualbass1, math.max(0, 1 - t.dualbass_factor))
    MvisDecayingMax("dualbass", t.dualbass2, 0.15, true)

    -- REMOVED: when harmonic power is strong, the color stops shifting: math.max(0,1.5-t.harmonicpower*2)
    MvisInterpolating("wanderinghsv", 1 / 60, function(i)
        local hsv = VectorRand(0, 1)

        if i % 2 == 1 then
            local sc_h, sc_s, sc_v = ColorToHSV(t.col1:ToColor())
            hsv.x = ((sc_h / 360) + hsv.x * 0.1 - 0.05) % 1
        end

        return hsv
    end)

    --harmonic power increases saturation
    MvisDecayingMax("minsaturation", t.harmonicpower, 0.98)
    local antiflickerframes = UsingMusicVis("dynamic") and 40 or 4
    local mean, meanvol = MvisMean("col", col, antiflickerframes), MvisMean("vol", amplitude, antiflickerframes)
    local normvol = (t.vol - t.v05) --not actual std
    -- TODO: use long color mean for extra darkness, short color mean for extra flash
    t.normalized_color = (mean - t.col4) --mean1:Max(mean1)) -- / (std1+0.006)  --max of 2 running means to prefer a lower normalized value
    -- local finalpower = 1 - t.fft2d*2  -- 0.85- (norm_avg * 1 + mean:Mean() * 0.8 + (meanvol-0.5) * 5) --math.sin(SysTime()*10)*0.5+0.5
    -- 1 = default light, 0 = squared light with color. it can go above 1 but not below 0 (it should have dark non-flickery parts.. maybe bright nonflicker when the image is bright? )
    t.drive = -0.4 + t.dualbass + t.v05 * 1.5 + t.normalized_color:Mean() * 2

    if UsingMusicVis("flash") then
        t.drive = t.drive + 0.8
    end

    if UsingMusicVis("dark") or UsingMusicVis("colorful") then
        t.drive = 0
    end

    local maxextradarkness = math.max(0.4 - t.col4:Mean(), 0) * 0.6
    local extradarkness = (math.max(0.3 - t.drive, 0) / 0.3) * maxextradarkness
    local c = HSVToColor(t.wanderinghsv.x * 360, math.max(t.wanderinghsv.y, t.minsaturation), 1 - extradarkness) --math.max((finalpower-1)*0.1, 0))
    t.color = Vector(c.r / 255, c.g / 255, c.b / 255)

    if UsingMusicVis("dark") then
        t.color = Vector(0.5, 0.5, 0.5)
        t.drive = t.drive * 0.3
    end

    if UsingMusicVis("red") then
        --local other = math.max(0, 0.5 - drive
        t.color = Vector(math.min(0.7, t.drive) + 0.4, 0.1, 0.1)
        t.drive = 0 --drive*0.1
    end

    if UsingMusicVis("blue") then
        --local other = math.max(0, 0.5 - drive
        t.color = Vector(0.1, 0.1, math.min(0.7, t.drive) + 0.4)
        t.drive = 0 --drive*0.1
    end

    t.flash = 0

    if FORCEDRIVE then
        t.drive = FORCEDRIVE
    end

    -- flashing increases when the screen is bright... TODO make it adjust drive directly but make it balance with sound
    t.flash = t.drive > 1 and math.min((t.drive - 1) / (2 - t.col:Mean() * 1.5), 0.5 + t.col:Mean()) or 0

    if UsingMusicVis("flash") then
        t.flash = t.flash * 1.5
    end

    -- these are used for the bars on the podium
    VAPOR_LAST_DRIVE = t.drive
    VAPOR_LAST_FFT = fft1
    t.fft1 = fft1
    t.fft2 = fft2
    t.harmonics = harmonics
    MvisPlot("drive")
    MvisPlot("color")
    MvisPlot("flash")
    t.fft1_2 = fft1[2]
    MvisPlot("fft1_2")
    -- MvisMedian("fft2m",fft1[2],60)
    -- MvisPlot("fft2m")
    -- t.fft2m2 = Lerp(math.min(1, (1.5*math.abs(t.fft22-t.fft2m))^2 ),t.fft2m,t.fft22)
    -- MvisPlot("fft2m2")
    MvisMedian("fft1_2_bilateral_median", t.fft1_2, 60, 0.2)
    MvisPlot("fft1_2_bilateral_median")
    MvisPlot("vol")
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

        if th:VideoType() ~= "youtube" then
            draw.DrawText("FX only work with YouTube videos", "DermaLarge", ScrW() * 0.5, ScrH() * 0.1, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)

            return
        end

        if UsingMusicVis("none") then return end
        local thekey = th:VideoKey()

        if not MVIS_REQUESTS[thekey] then
            MVIS_REQUESTS[thekey] = {}
            MVIS_DATA[thekey] = {}
        end

        local ts = (YoutubeActualTimestamp() or 0) + 0.02
        local fts = ts * 60
        local vframe = (math.floor(fts) + 1) + MVIS_LOOKAHEAD_FRAMES
        local vminute = math.max(0, math.floor(vframe / 3600))

        for _, look in ipairs({vminute - 1, vminute, vminute + 1}) do
            local theminute = look

            if theminute > -1 and not MVIS_REQUESTS[thekey][theminute] then
                MVIS_REQUESTS[thekey][theminute] = true

                http.Fetch("http://swamp.sv/fft/data/" .. thekey .. "/" .. tostring(theminute) .. "?" .. tostring(os.time()), function(b, l, h, c)
                    if c == 200 then
                        print("DATASIZE", b:len())
                        MVIS_DATA[thekey][theminute] = b
                    else
                        timer.Simple(3, function()
                            MVIS_REQUESTS[thekey][theminute] = false
                        end)
                    end
                end, function(msg)
                    timer.Simple(3, function()
                        MVIS_REQUESTS[thekey][theminute] = false
                    end)
                end)
            end
        end

        local data = MVIS_DATA[thekey]

        if not data[vminute] then
            draw.DrawText("Generating FX...", "DermaLarge", ScrW() * 0.5, ScrH() * 0.1, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)

            return
        end

        if MVIS_LASTVFRAME == nil or vframe < MVIS_LASTVFRAME or vframe > MVIS_LASTVFRAME + 100 then
            MVIS_TRACKERS = {} -- reset all trackers
            MVIS_LASTVFRAME = vframe - (2 + MVIS_LOOKAHEAD_FRAMES)
        end

        for frame2add = MVIS_LASTVFRAME + 1, vframe do
            MvisNextFrame(MvisGetFrame(data, frame2add))
        end

        MVIS_LASTVFRAME = vframe
        local drive = Lerp(fts % 1, MVISTAB_LAST.drive, MVISTAB_NEXT.drive)
        local color = Lerp(fts % 1, MVISTAB_LAST.color, MVISTAB_NEXT.color)
        local flash = Lerp(fts % 1, MVISTAB_LAST.flash, MVISTAB_NEXT.flash)

        if drive > 1 then
            DrawColorModify({
                ["$pp_colour_addr"] = 0, --ADD TO ONE
                ["$pp_colour_addg"] = 0,
                ["$pp_colour_addb"] = 0,
                ["$pp_colour_brightness"] = flash * 0.15, --ADD TO ALL
                ["$pp_colour_colour"] = 1 + flash * 0.15, --SATURATION
                ["$pp_colour_mulr"] = 0, -- MULTIPLY ONE...?
                ["$pp_colour_mulg"] = 0,
                ["$pp_colour_mulb"] = 0,
                ["$pp_colour_contrast"] = 1 + flash, --MULTIPLY ALL
                
            })
        else
            DrawSquareColor(1 - drive, color, false)
        end

        if GetConVar("musicvis_debug"):GetBool() then
            MvisDrawDebug()
        end
    end
end)

function MvisPlot(name, mean0, t0)
    local val = MVISTAB_NEXT[name] or 0
    local lookback = 300
    local chart = nil
    local i = nil

    for ii, v in ipairs(MVIS_PLOTS) do
        if v.name == name then
            chart = v.chart
            i = ii
        end
    end

    if not chart then
        table.insert(MVIS_PLOTS, {
            name = name,
            mean0 = mean0,
            lookback = lookback,
            chart = {},
            t0 = t0
        })

        chart = MVIS_PLOTS[#MVIS_PLOTS].chart
        i = #MVIS_PLOTS
    end

    i = i - 1

    while #chart >= lookback do
        table.remove(chart, 1)
    end

    while #chart < lookback do
        table.insert(chart, val)
    end
end

function MvisDrawDebug()
    local t = MVISTAB_NEXT
    if not t then return end
    draw.DrawText("Setting: " .. tostring(GetG("musicvis")), "DermaDefault", 410, 1)

    for j, tab in ipairs(MVIS_PLOTS) do
        local chart, name, mean0, lookback = tab.chart, tab.name, tab.mean0, tab.lookback
        local y1 = j * 60 - 50
        local y2 = y1 + 50
        local x1 = 10
        local x2 = 400
        draw.DrawText(name, "DermaDefault", x1 + 5, y1 + 5)
        surface.SetDrawColor(200, 200, 200)
        surface.DrawLine(x1, y1, x2, y1)

        if mean0 then
            surface.DrawLine(x1, (y1 + y2) / 2, x2, (y1 + y2) / 2)
        end

        surface.DrawLine(x1, y2, x2, y2)
        local it = 0
        local mean = mean0 and 0.5 or 0
        local scale = mean0 and 0.5 or 1

        for i = 2, #chart do
            local a, b = chart[i - 1], chart[i]
            local ax = Lerp((i - 1) / lookback, x1, x2)
            local bx = Lerp(i / lookback, x1, x2)
            local f, g = a, b

            if isvector(a) then
                surface.SetDrawColor(255, 0, 0)
                surface.DrawLine(ax, Lerp(a.x * scale + mean, y2, y1), bx, Lerp(b.x * scale + mean, y2, y1))
                surface.SetDrawColor(0, 255, 0)
                surface.DrawLine(ax, Lerp(a.y * scale + mean, y2, y1), bx, Lerp(b.y * scale + mean, y2, y1))
                surface.SetDrawColor(0, 0, 255)
                surface.DrawLine(ax, Lerp(a.z * scale + mean, y2, y1), bx, Lerp(b.z * scale + mean, y2, y1))
                f = (a.x + a.y + a.z) / 3
                g = (b.x + b.y + b.z) / 3
            end

            surface.SetDrawColor(255, 255, 255)
            surface.DrawLine(ax, Lerp(f * scale + mean, y2, y1), bx, Lerp(g * scale + mean, y2, y1))
            it = g
        end

        draw.DrawText(tostring(it), "DermaDefault", x2 - 100, y1 + 5)
    end

    for i, v in ipairs(t.fft1) do
        surface.SetDrawColor(255, 255, i % 2 == 0 and 128 or 255, 255)
        surface.DrawRect(500 + i * 20, 0, 15, v * 500)
        draw.DrawText(tostring(i), "DermaDefault", 502 + i * 20, 2, Color(0, 0, 0, 255))
    end

    for i, v in ipairs(t.fft2) do
        surface.SetDrawColor(i % 2 == 0 and 128 or 255, 255, 255, 255)
        surface.DrawRect(800 + i * 20, 0, 15, v * 500)
        draw.DrawText(tostring(i), "DermaDefault", 802 + i * 20, 2, Color(0, 0, 0, 255))
    end

    for i, v in ipairs(t.harmonics) do
        surface.SetDrawColor(255, i % 2 == 0 and 128 or 255, 255, 255)
        surface.DrawRect(1300 + i * 20, 0, 15, v * 500)
        draw.DrawText(tostring(i), "DermaDefault", 1302 + i * 20, 2, Color(0, 0, 0, 255))
    end

    surface.SetDrawColor(255, 255, 255, 255)
    surface.DrawRect(400, 500, 200, 2)
end