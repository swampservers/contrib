-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
function string.FormatSeconds(sec)
    local hours = math.floor(sec / 3600)
    local minutes = math.floor((sec % 3600) / 60)
    local seconds = sec % 60

    if minutes < 10 then
        minutes = "0" .. tostring(minutes)
    end

    if seconds < 10 then
        seconds = "0" .. tostring(seconds)
    end

    if hours > 0 then
        return string.format("%s:%s:%s", hours, minutes, seconds)
    else
        return string.format("%s:%s", minutes, seconds)
    end
end

function string.reduce(str, font, width)
    surface.SetFont(font)
    local tw, th = surface.GetTextSize(str)

    while tw > width do
        str = string.sub(str, 1, string.len(str) - 1)
        tw, th = surface.GetTextSize(str)
    end

    return str
end
