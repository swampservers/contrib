-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local SERVICE = {}
SERVICE.Name = "Oligopoly"
SERVICE.NeedsCodecs = true
SERVICE.CacheLife = 0

function SERVICE:GetKey(url)
    if util.JSONToTable(url.encoded) then return false end
    if string.match(url.encoded, "olgply.com/movie/%d+") or string.match(url.encoded, "olgply.com/tv/%d+/%d+/%d+") then return url.encoded end

    return false
end

if CLIENT then
    function SERVICE:GetVideoInfoClientside(key, callback)
        if vpanel then
            vpanel:Remove()
        end

        vpanel = vgui.Create("DHTML")
        vpanel:SetSize(ScrW(), ScrH())
        vpanel:SetAlpha(0)
        vpanel:SetMouseInputEnabled(false)
        local info = {}
        local isTV = string.match(key, "/tv/%d+/%d+/%d+")
        local season = string.match(key, "/tv/%d+/(%d+)/%d+")
        local episode = string.match(key, "/tv/%d+/%d+/(%d+)")

        timer.Simple(30, function()
            if IsValid(vpanel) then
                vpanel:Remove()
                print("Failed")
                callback()
            end
        end)

        self:Fetch("https://api.themoviedb.org/3/" .. (isTV and "tv" or "movie") .. "/" .. string.match(key, "olgply.com/.-/(%d+)") .. "?api_key=29b951a1229cc0c9dc81df66d6f81ec7&language=en-US&append_to_response=external_ids", function(body)
            local t = util.JSONToTable(body)

            if t == nil then
                callback()
            else
                info.title = (t["original_title"] or t["original_name"]) .. (isTV and " S" .. season .. " E" .. episode or " (" .. string.match(t["release_date"], '(%d%d%d%d)') .. ")")
                info.thumb = "https://image.tmdb.org/t/p/w370_and_h556_bestv2" .. t["poster_path"]

                function vpanel:ConsoleMessage(msg)
                    if Me.videoDebug then
                        print(msg)
                    end

                    if msg:StartWith("DURATION:") and msg ~= "DURATION:NaN" then
                        local duration = math.ceil(tonumber(string.sub(msg, 10)))
                        info.duration = duration
                    end

                    if msg:StartWith("FILE:") then
                        local data = string.sub(msg, 6)
                        info.data = data
                    end

                    if info.duration ~= nil and info.data ~= nil then
                        self:Remove()
                        print("Success!")
                        callback(info)
                    end
                end

                vpanel:OpenURL(key)
                vpanel:QueueJavascript("window.location='https://olgply.xyz/" .. (isTV and string.match(key, "olgply.com/.-/(%d+/%d+/%d+)") or string.match(key, "olgply.com/.-/(%d+)")) .. "'")

                timer.Create("oligopolyupdate" .. tostring(math.random(1, 100000)), 1, 20, function()
                    if IsValid(vpanel) then
                        vpanel:RunJavascript("console.log('FILE:'+hls.url);")
                        vpanel:RunJavascript("console.log('DURATION:'+player.duration);")
                    end
                end)
            end
        end)
    end

    function SERVICE:LoadVideo(Video, panel)
        panel:EnsureURL("https://swamp.sv/s/cinema/file.html")

        panel:AddFunction("gmod", "loaded", function()
            self:SeekTo(CurTime() - Video:StartTime(), panel)
            self:SetVolume(theater.GetVolume(), panel)
        end)

        local str = string.format("th_video('%s');", string.JavascriptSafe(Video:Data()))
        panel:QueueJavascript(str)
    end
end

theater.RegisterService('oligopoly', SERVICE)
