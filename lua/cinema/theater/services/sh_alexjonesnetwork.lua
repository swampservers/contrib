-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local AJNSERVICE = {}
AJNSERVICE.Name = "AlexJonesNetwork"
AJNSERVICE.NeedsCodecs = true
AJNSERVICE.NeedsChromium = true

local rumble_service = theater.GetServiceByClass("rumble")

function AJNSERVICE:GetKey(url)
    if string.match(url.encoded, "https://alexjones.network/watch$") then return url.encoded end

    return false
end

if CLIENT then
    function AJNSERVICE:GetVideoInfoClientside(key, callback)
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
                    rumble_service:GetVideoInfoClientside(rumbleURL, callback)
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

    function AJNSERVICE:LoadVideo(Video, panel)
        rumble_service:LoadVideo(Video, panel)
    end
end

theater.RegisterService('alexjonesnetwork', AJNSERVICE)
