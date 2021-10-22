-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
local SERVICE = {}
SERVICE.Name = "LookMovie"
--SERVICE.Mature = true
SERVICE.NeedsCodecs = true
SERVICE.CacheLife = 0

function SERVICE:GetKey(url)
    if (util.JSONToTable(url.encoded)) then return false end
    if string.match(url.encoded, "lookmovie.io/movies/view/(.+)") then return url.encoded end

    return false
end

if CLIENT then
    function SERVICE:GetVideoInfoClientside(key, callback)
        local vpanel = vgui.Create("DHTML")
        vpanel:SetSize(1920, 1800)
        vpanel:SetAlpha(0)
        vpanel:SetMouseInputEnabled(false)
        vpanel.response = ""
        local info = {}

        local function onFetchReceive(body)
            local t = util.JSONToTable(body)

            if (t == nil) then
                callback()
            else
                local url = t["streams"]["1080p"] or t["streams"]["720p"] or t["streams"]["480p"] or t["streams"]["360p"]
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

                if (not info.title or not info.thumb) then
                    vpanel:RunJavascript("if(window['movie_storage']){console.log('TITLE:'+window['movie_storage'].title+' ('+window['movie_storage'].year+')');console.log('THUMB:'+window['movie_storage'].movie_poster);}")
                end

                if (vpanel.response == "") then
                    vpanel:RunJavascript("if(window['movie_storage']){xmlHttp=new XMLHttpRequest();xmlHttp.open('GET','https://lookmovie.io/api/v1/security/movie-access?id_movie='+window['movie_storage'].id_movie,false);xmlHttp.send(null);console.log('JSON:'+xmlHttp.responseText);}")
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
                        LocalPlayer():PrintMessage(HUD_PRINTTALK, "[red]Visit lookmovie.io, fill out the captcha, and then request the movie again.")
                        callback()
                    end
                end

                if string.StartWith(msg, "TITLE:") and not info.title then
                    info.title = string.Replace(msg:sub(7, -1), "\\'", "'")
                    print("TITLE: " .. info.title)
                end

                if string.StartWith(msg, "THUMB:") and not info.thumb then
                    info.thumb = msg:sub(7, -1)
                    print("THUMB: " .. info.thumb)
                end

                if string.StartWith(msg, "JSON:") and self.response == "" then
                    self.response = msg:sub(6, -1)
                    print("JSON: " .. self.response)
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
                LocalPlayer():PrintMessage(HUD_PRINTTALK, "[red]The movie link is expired, try requesting it again.")
            end
        })

        if IsValid(panel) then
            local str = string.format("th_video('%s','%s');", string.JavascriptSafe(t.url), t.subs or "")
            panel:QueueJavascript(str)
        end
    end
end

theater.RegisterService('lookmovie', SERVICE)
