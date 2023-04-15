-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local SERVICE = {}
SERVICE.Name = "DLive"
SERVICE.NeedsCodecs = true

function SERVICE:GetKey(url)
    if url.host and string.match(url.host, "dlive.tv") and string.match(url.path, "^/([%w_]+)[/]?$") then return url.encoded end

    return false
end

if CLIENT then
    function SERVICE:LoadVideo(Video, panel)
        panel:EnsureURL("https://swamp.sv/s/cinema/file.html")

        panel:AddFunction("gmod", "loaded", function()
            self:SeekTo(CurTime() - Video:StartTime(), panel)
            self:SetVolume(theater.GetVolume(), panel)
        end)

        panel:QueueJavascript(string.format("th_video('%s');", string.JavascriptSafe(Video:Data())))
    end
end

theater.RegisterService('dlive', SERVICE)
