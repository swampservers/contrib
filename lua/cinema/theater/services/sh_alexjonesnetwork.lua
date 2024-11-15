-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local SERVICE = {}
SERVICE.Name = "AlexJonesNetwork"
SERVICE.NeedsCodecs = true
SERVICE.NeedsChromium = true
local rumbleService = theater.GetServiceByClass("rumble")

function SERVICE:GetKey(url)
    if string.match(url.encoded, "https://alexjones.network/watch$") then return url.encoded end

    return false
end

if CLIENT then
    function SERVICE:GetVideoInfoClientside(key, callback)
        local videoInfo = {}

        EmbeddedCheckCodecs(function()
            if vpanel then
                vpanel:Remove()
            end

            vpanel = vgui.Create("DHTML", nil, "AlexJonesNetworkVPanel")
            vpanel:SetSize(100, 100)
            vpanel:SetAlpha(0)
            vpanel:SetMouseInputEnabled(false)
            vpanel:SetKeyboardInputEnabled(false)

            timer.Simple(20, function()
                if IsValid(vpanel) then
                    vpanel:Remove()
                    print("Failed")
                    callback()
                end
            end)

            function vpanel:OnDocumentReady(url)
                self:AddFunction("gmod", "onRumbleURL", function(rumbleURL)
                    rumbleService:GetVideoInfoClientside(rumbleURL, callback)
                end)

                self:QueueJavascript([[
                    const rumbleURL = document.querySelector(".bigPlayUI a").href;
                    if (rumbleURL) {
                        gmod.onRumbleURL(rumbleURL);
                    }
                ]])
            end

            vpanel:OpenURL(key)
        end, function()
            chat.AddText("You need codecs to request this. Press F2.")

            return callback()
        end)
    end

    function SERVICE:LoadVideo(Video, panel)
        rumbleService:LoadVideo(Video, panel)
    end
end

theater.RegisterService('alexjonesnetwork', SERVICE)
