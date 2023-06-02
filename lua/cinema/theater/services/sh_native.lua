-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local SERVICE = {}
SERVICE.Name = "Native"
SERVICE.Mature = true

function SERVICE:GetKey(url)
    if string.sub(url.path, -5) == ".webm" or string.sub(url.path, -4) == ".mov" then return url.encoded end

    return false
end

if CLIENT then
    function SERVICE:GetVideoInfoClientside(key, callback)
        if vpanel then
            vpanel:Remove()
        end

        vpanel = vgui.Create("DHTML", nil, "NativeVPanel")
        vpanel:SetSize(100, 100)
        vpanel:SetAlpha(0)
        vpanel:SetMouseInputEnabled(false)

        timer.Simple(20, function()
            if IsValid(vpanel) then
                vpanel:Remove()
                print("Failed")
                callback()
            end
        end)

        function vpanel:ConsoleMessage(msg)
            if Me.videoDebug then
                print(msg)
            end

            if msg:StartWith("DURATION:") then
                local duration = math.ceil(tonumber(string.sub(msg, 10)))
                print("Duration: " .. duration)
                self:Remove()

                if duration > 0 then
                    print("Success!")

                    callback({
                        duration = duration
                    })
                else
                    print("Error: Duration less than or equal to 0")
                    callback()
                end
            end
        end

        local urll = "https://swamp.sv/s/cinema/filedata.php?file="
        vpanel:OpenURL(urll .. key)
    end

    function SERVICE:GetHost(Video)
        return url.parse2(Video:Key()).host
    end

    function SERVICE:LoadVideo(Video, panel)
        panel:EnsureURL("https://swamp.sv/s/cinema/file.html")

        panel:AddFunction("gmod", "loaded", function()
            self:SeekTo(CurTime() - Video:StartTime(), panel)
            self:SetVolume(theater.GetVolume(), panel)
        end)

        panel:QueueJavascript(string.format("th_video('%s');", string.JavascriptSafe(Video:Key())))
    end
end

theater.RegisterService('native', SERVICE)
