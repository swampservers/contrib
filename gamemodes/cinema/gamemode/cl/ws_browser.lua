local PANEL = {}
local matUp = Material("icon16/arrow_up.png")
--NOMINIFY
local maxfilesize = 60

function PANEL:Init()
    self.HomeURL = "http://steamcommunity.com/workshop/browse/?appid=4000&searchtext=playermodel&childpublishedfileid=0&browsesort=trend&section=readytouseitems&requiredtags%5B%5D=Model"
    self.Browser:OpenURL(self.HomeURL)
    self.AddressBar:SetText(self.HomeURL)

    self.Browser:AddFunction("gmod", "wssubscribe", function()
        if self.addonsize and self.addonsize < maxfilesize then
            self:GetWSID(tostring(self.chosen_id))
            self:OnClose()
            self:Remove()
        end
    end)

    self.Browser.Think = function(self)
        if not self._nextUrlPoll or self._nextUrlPoll < RealTime() then
            self:RunJavascript('console.log("HREF:"+window.location.href);')
            self:RunJavascript([[
				function SubscribeItem(){
					gmod.wssubscribe();
				};
				
				var sub = document.getElementById("SubscribeItemOptionAdd");
				if (sub){
					sub.innerText = "Select";
				};
			]])
            self._nextUrlPoll = RealTime() + 0.25
        end
    end

    -- local prevurl = ""
    -- self.Browser.ConsoleMessage = function(panel, msg)
    --     if isstring(msg) and msg:StartWith("HREF:") and "HREF:" .. prevurl ~= msg then
    --         prevurl = msg:sub(6)
    --         self.addonsize = nil
    --         self.AddressBar:SetText(prevurl)
    --         self:LoadedURL()
    --     end
    -- end
    local b = vgui.Create('DButton', self)
    self.chooseb = b
    b:Dock(BOTTOM)
    b:SetText("Select Character")
    b:SizeToContents()
    b:SetWidth(math.min(b:GetSize(), 256) + 32)
    b:SetTall(48)
    b:SetZPos(100)
    b:SetEnabled(false)
    b:NoClipping(false)
    b:SetFont("DermaLarge")

    b.Paint = function(b, w, h)
        if self.chosen_id then
            local info = require_workshop_info(self.chosen_id)

            if info then
                self.addonsize = info.size / 1000000

                if info.size / 1000000 > 60 then
                    b:SetText("Addon is too big (>60mb)!")
                    b:SetEnabled(false)
                    surface.SetDrawColor(Color(255, 0, 0))
                    surface.DrawRect(0, 0, w, h)
                else
                    b:SetText("Use this addon")
                    b:SetEnabled(true)
                    surface.SetDrawColor(b:IsHovered() and Color(60, 255, 60) or Color(0, 255, 0))
                    surface.DrawRect(0, 0, w, h)
                end

                return
            end
        end

        b:SetColor(Color(255, 255, 255))
        b:SetText("Select a playermodel...")
        b:SetEnabled(false)
        surface.SetDrawColor(Color(16, 16, 16))
        surface.DrawRect(0, 0, w, h)
    end

    b.DoClick = function(b, mc)
        -- if self.addonsize and (self.addonsize < maxfilesize) then
        if self.chosen_id then
            self:GetWSID(tostring(self.chosen_id))
            self:OnClose()
            self:Remove()
        end
    end
end

function PANEL:OnDocumentReady(url)
    -- local url = self.AddressBar:GetValue()
    local id = url:match('://steamcommunity.com/sharedfiles/filedetails/.*[%?%&]id=(%d+)') or url:match('://steamcommunity.com/workshop/filedetails/.*[%?%&]id=(%d+)')
    -- self.chooseb:SetEnabled(id and true or false)
    self.chosen_id = id
end

function PANEL:GetWSID(data)
end

vgui.Register("workshopbrowser", PANEL, "BrowserBase")
