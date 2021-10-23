-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
local SERVICE = {}
SERVICE.Name = "LookMovie"
--SERVICE.Mature = true
SERVICE.NeedsCodecs = true
SERVICE.CacheLife = 0

function SERVICE:GetKey(url)
    if (util.JSONToTable(url.encoded)) then return false end
    if string.match(url.encoded, "lookmovie.io/movies/view/(.+)") or string.match(url.encoded, "lookmovie.io/shows/view/(.+)#") then return url.encoded end

    return false
end

if CLIENT then
    function SERVICE:GetVideoInfoClientside(key, callback)
        vpanel = vgui.Create("DHTML")
        vpanel:SetSize(1920, 1800)
        vpanel:SetAlpha(0)
        vpanel:SetMouseInputEnabled(false)
        vpanel.response = ""
        local info = {}
        local isTV = string.find(key, "lookmovie.io/shows/view")

        local function onFetchReceive(body)
            local t = util.JSONToTable(body)

            if (t == nil) then
                callback()
            else
                local url = t["streams"]["1080p"] or t["streams"]["720p"] or t["streams"]["480p"] or t["streams"]["360p"]
                if (isTV) then
                    url = t["streams"][1080] or t["streams"][720] or t["streams"][480] or t["streams"][360]
                end
                local subs = ""

                --find a good way to implement subtitle track choosing? lookmovie can have dozens of tracks and over a dozen tracks just for english with varying quality
                --[[for k,v in pairs(t["subtitles"]) do
                    if v["language"] == "English" then
                        subs = "https://lookmovie.io"..v["file"]
                        break
                    end
                end]]
                --change to t["streams"] and load based on quality setting?
                info.data = util.TableToJSON({
                    url = url,
                    subs = subs
                })

                theater.Services.base:Fetch(url, function(sbody)
                    local duration = 0

                    for k, v in ipairs(string.Split(sbody, "\n")) do
                        if (v:StartWith("#EXTINF:")) then
                            duration = duration + tonumber(string.Split(string.sub(v, 9), ",")[1])
                        end
                    end

                    info.duration = math.ceil(duration)

                    if (LocalPlayer().videoDebug) then
                        PrintTable(info)
                    end

                    callback(info)
                end, callback)
            end
        end

        timer.Simple(10, function()
            if IsValid(vpanel) then
                vpanel:Remove()
                print("Failed")
                callback()
            end
        end)

        timer.Create("lookmovieupdate" .. tostring(math.random(1, 100000)), 1, 10, function()
            if IsValid(vpanel) then
                vpanel:RunJavascript("console.log('CAPTCHA:'+document.title);")
                vpanel:RunJavascript("var stor = window['" .. (isTV and "show" or "movie") .. "_storage" .. "'];")

                if (not info.title or not info.thumb) then
                    vpanel:RunJavascript("if(stor){console.log('TITLE:'+stor.title+' ('+stor.year+')');console.log('THUMB:'+stor." .. (isTV and "poster_medium" or "movie_poster") .. ");}")
                end

                if (vpanel.response == "") then
                    vpanel:RunJavascript("if(stor){xmlHttp=new XMLHttpRequest();xmlHttp.open('GET','https://lookmovie.io/api/v1/security/" .. (isTV and "episode" or "movie") .. "-access?id_" .. (isTV and "episode" or "movie") .. "=" .. (isTV and string.match(key, "#.+%-(%d+)$") .. "'" or "'+stor.id_movie") .. ",false);xmlHttp.send(null);console.log('JSON:'+xmlHttp.responseText);}")
                end
            end
        end)

        function vpanel:ConsoleMessage(msg)
            if msg then
                msg = tostring(msg)

                if (LocalPlayer().videoDebug) then
                    print(msg)
                end

                if string.StartWith(msg, "CAPTCHA:") then
                    if (msg:sub(9, -1) == 'Thread Defence') then
                        self:Remove()
                        LocalPlayer():PrintMessage(HUD_PRINTTALK, "[red]Visit lookmovie.io, fill out the captcha, and then request the " .. (isTV and "show" or "movie") .. " again.")
                        callback()
                    end
                end

                if string.StartWith(msg, "TITLE:") and not info.title then
                    info.title = string.Replace(msg:sub(7, -1), "\\'", "'") .. (isTV and (" " .. string.match(key, "#(.+)%-.+%-%d+$") .. " " .. string.match(key, "#.+%-(.+)%-%d+$")) or "")
                end

                if string.StartWith(msg, "THUMB:") and not info.thumb then
                    info.thumb = msg:sub(7, -1)
                end

                if string.StartWith(msg, "JSON:") and self.response == "" then
                    self.response = msg:sub(6, -1)
                end

                if (self.response ~= "" and info.title and info.thumb) then
                    print("success")
                    self:Remove()
                    onFetchReceive(self.response)
                end
            end
        end

        vpanel:OpenURL(key)
    end

    function SERVICE:LoadVideo(Video, panel)
        local t = util.JSONToTable(Video:Data())
        local url = "http://swamp.sv/s/cinema/file.html"
        panel:EnsureURL(url)

        HTTP({
            method = "HEAD",
            url = t.url,
            headers = {
                ["Cache-Control"] = "no-cache"
            },
            success = function(code, body, headers) end,
            failed = function(err)
                LocalPlayer():PrintMessage(HUD_PRINTTALK, "[red]The " .. (string.find(t.url, "lookmovie.io/shows/view") and "tv show" or "movie") .. " link is expired, try requesting it again.")
            end
        })

        if IsValid(panel) then
            local str = string.format("th_video('%s','%s');", string.JavascriptSafe(t.url), t.subs or "")
            panel:QueueJavascript(str)
        end
    end
end

theater.RegisterService('lookmovie', SERVICE)
