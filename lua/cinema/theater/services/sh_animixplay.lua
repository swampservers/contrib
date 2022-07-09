-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local SERVICE = {}
SERVICE.Name = "AniMixPlay"
SERVICE.NeedsCodecs = true
SERVICE.CacheLife = 0

function SERVICE:GetKey(url)
    if string.match(url.encoded, "animixplay.to/v11?/(.+)") then return url.encoded end

    return false
end

if CLIENT then
    function SERVICE:GetVideoInfoClientside(key, callback)
        http.Fetch(key, function(body)
            local ep = string.match(key, "animixplay.to/v11?/.+/ep(%d+)") or 1
            local k = string.match(body, "\"" .. ep - 1 .. "\":\".-php%?id=(.-)&title")

            if not k then
                chat.AddText(string.match(body, "\"eptotal\":0") and "[red]There are no episodes of this yet." or "[red]Use a different stream server.")
                callback()
            end

            EmbeddedCheckCodecs(function()
                if vpanel then
                    vpanel:Remove()
                end

                vpanel = vgui.Create("TheaterHTML")
                vpanel:SetSize(0, 0)
                vpanel:SetAlpha(0)
                vpanel:SetMouseInputEnabled(false)
                local title, thumb, duration = string.match(body, "<span class=\"animetitle\">(.-)</span>") .. (string.match(body, "\"eptotal\":1,") and "" or " - Episode " .. ep)

                timer.Simple(15, function()
                    if IsValid(vpanel) then
                        vpanel:Remove()
                        print("Failed")
                        callback()
                    end
                end)

                timer.Create("animixplayupdate" .. tostring(math.random(1, 100000)), 1, 10, function()
                    if IsValid(vpanel) then
                        vpanel:RunJavascript("console.log('DURATION:'+Math.ceil(player1.duration))")
                    end
                end)

                function vpanel:ConsoleMessage(msg) --required because the http functions fail to get the location response header
                    if msg:StartWith("DURATION:") and not msg:StartWith("DURATION:0") then
                        duration = tonumber(string.sub(msg, 10))
                    elseif msg:StartWith("HREF:") and thumb and duration then
                        local url = msg:sub(6)

                        if url ~= "about:blank" then
                            self:Remove()

                            callback({
                                title = title,
                                data = util.Base64Decode(string.Explode("#",url)[2]), --sometimes a mp4, can't rely on hls duration code
                                duration = duration,
                                thumb = thumb
                            })
                        end
                    end
                end

                self:Fetch(key, function(body)
                    self:Fetch("https://animixplay.to/assets/mal/" .. string.match(body, "var malid = '(%d+)';") .. ".json", function(body)
                        local url = util.JSONToTable(body)['image_url']
                        thumb = string.StripExtension(url) .. "l" .. string.Right(url,4) --get large image
                    end, callback)
                end, callback)

                vpanel:OpenURL("https://animixplay.to/api/live" .. util.Base64Encode(k .. "LTXs3GrU8we9O" .. util.Base64Encode(k))) --redirects to player page
            end)
        end)
    end

    function SERVICE:LoadVideo(Video, panel)
        panel:EnsureURL("http://swamp.sv/s/cinema/file.html")
        panel:QueueJavascript(string.format("th_video('%s');", string.JavascriptSafe(Video:Data())))
    end
end

theater.RegisterService('animixplay', SERVICE)
