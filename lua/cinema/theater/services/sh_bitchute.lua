-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local SERVICE = {}
SERVICE.Name = "Bitchute"
SERVICE.NeedsCodecs = true

function SERVICE:GetKey(url)
    local match = string.match(url.path, "/.+/(.+[^/])")
    if match ~= nil and string.find(url.encoded, "bitchute.com/video/(.+)") and not string.find(url.path, "%.") then return match end

    return false
end

if CLIENT then
    function SERVICE:GetVideoInfoClientside(key, callback)
        EmbeddedCheckCodecs(function()
            if vpanel then
                vpanel:Remove()
            end

            vpanel = vgui.Create("DHTML", nil, "BitChuteVPanel")
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
                if msg:StartWith("DURATION:") then
                    local duration = math.ceil(tonumber(string.sub(msg, 10)))
                    print("Duration: " .. duration)
                    self:Remove()
                    print("Success!")

                    callback({
                        duration = duration
                    })
                end
            end

            vpanel:OpenURL("https://swamp.sv/s/cinema/filedata.php?file=" .. key)
        end, function()
            chat.AddText("You need codecs to request this. Press F2.")

            return callback()
        end)
    end

    function SERVICE:LoadVideo(Video, panel)
        panel:EnsureURL("https://swamp.sv/s/cinema/file.html")

        panel:AddFunction("gmod", "loaded", function()
            self:SeekTo(CurTime() - Video:StartTime(), panel)
            self:SetVolume(theater.GetVolume(), panel)
        end)

        panel:QueueJavascript(string.format("th_video('%s');", string.JavascriptSafe(Video:Data())))
    end
end

theater.RegisterService('bitchute', SERVICE)
