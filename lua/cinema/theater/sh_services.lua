-- This file is subject to copyright - contact swampservers@gmail.com for more information.
module("theater", package.seeall)
Services = Services or {}

function RegisterService(class, object, base)
    if not class or not object then return end

    if not base then
        base = "base"
    end

    Services[class] = object
    Services[class].ClassName = class

    if not Services[base] then
        ErrorNoHalt("theater.RegisterService: Base class '" .. tostring(base) .. "' not found!")
    else
        if class == "base" then return end

        setmetatable(Services[class], {
            __index = Services[base]
        })
    end
end

function GetServiceByClass(class)
    return Services[class]
end

-- base service
local SERVICE = {}
SERVICE.Name = "Base"
SERVICE.CacheLife = 7 * 24 * 3600
SERVICE.LivestreamCacheLife = 300
SERVICE.Mature = false

function SERVICE:GetName()
    return self.Name
end

function SERVICE:GetClass()
    return self.ClassName
end

function SERVICE:GetKey(url)
    return false
end

function SERVICE:IsMature(video)
    return self.Mature
end

CinemaHttpHeaders = {
    ["Cache-Control"] = "no-cache",
    ["Connection"] = "keep-alive",
    ["Referer"] = "https://swamp.sv/"
}

-- Required for Google API requests; uses browser API key.
--["Referer"] = "http://cinema.pixeltailgames.com/"--,
-- Don't use improperly formatted GMod user agent in case anything actually
-- checks the user agent.
--["User-Agent"] = "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.114 Safari/537.36"
function SERVICE:Fetch(url, onReceive, onFailure, useragent)
    CinemaHttpHeaders["User-Agent"] = useragent or "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.132 Safari/537.36"

    --"Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.114 Safari/537.36"
    local request = {
        url = url,
        method = "GET",
        headers = CinemaHttpHeaders,
        success = function(code, body, headers)
            code = tonumber(code) or 0

            if code == 200 or code == 0 then
                onReceive(body, body:len(), headers, code)
            else
                print("HTTP FAIL CODE: " .. code .. " URL " .. url)
                pcall(onFailure, code)
            end
        end,
        failed = function(err)
            print("HTTP FAILED: " .. err .. " URL " .. url)

            if isfunction(onFailure) then
                pcall(onFailure, err)
            end
        end
    }

    HTTP(request)
end

function SERVICE:GetVideoInfo(key, ply, onSuccess, onFailure)
    sv_GetVideoInfo[self:GetClass()](self, key, ply, onSuccess, onFailure)
end

if CLIENT then
    function SERVICE:GetVideoInfoClientside(key, callback)
        error("Can't get video info for " .. self:GetClass())
    end

    function SERVICE:GetHost(Video)
        return nil
    end

    function SERVICE:LoadVideo(Video, panel)
        panel:EnsureURL("http://swamp.sv/s/cinema/" .. self:GetClass() .. ".html")
        -- Let the webpage handle loading a video
        local str = string.format("th_video('%s');", string.JavascriptSafe(Video:Key()))
        panel:QueueJavascript(str)
    end

    function SERVICE:SetVolume(vol, panel)
        local str = string.format("th_volume(%s);", vol)
        panel:QueueJavascript(str)
    end

    function SERVICE:SeekTo(time, panel)
        local str = string.format("th_seek(%s);", time)
        panel:QueueJavascript(str)
    end
end

RegisterService("base", SERVICE)
