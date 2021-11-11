local PANEL = {}
local matUp = Material("icon16/arrow_up.png")

--NOMINIFY


local maxfilesize = 60

function PANEL:Init()
    self:SetVisible(true)
    self:SetSize(ScrW() * 0.9, ScrH() * 0.8)
    self:Center()
    self:SetTitle("Workshop Browser")
    self:SetDeleteOnClose(false)
    self:ShowCloseButton(true)
    self:SetDraggable(true)
    self:SetSizable(true)
    self:MakePopup()
    self:SetKeyboardInputEnabled(true)
    self:SetMouseInputEnabled(true)
    local top = vgui.Create("EditablePanel", self)
    self.top = top
    top:Dock(TOP)
    top:SetTall(24)
    local PreviousIcon = "icon16/arrow_left.png"
    local NextIcon = "icon16/arrow_right.png"
    local btn = vgui.Create("DButton", self.top)
    btn:SetText("")
    btn:SetSize(24, 24)
    btn:SetIcon(PreviousIcon)
    btn:Dock(LEFT)

    function btn.DoClick()
        self.browser:GoBack()
    end

    local txt = vgui.Create('DLabel', self, 'msg')
    txt:Dock(TOP)
    txt:SetText("If the browser does not change URL please paste the URL yourself in the browser bar from your web browser.")
    txt:SetTextColor(Color(0, 0, 0, 255))
    local btn = vgui.Create("DButton", self.top)
    btn:SetText("")
    btn:SetSize(24, 24)
    btn:SetIcon(NextIcon)
    btn:Dock(LEFT)

    function btn.DoClick()
        self.browser:GoForward()
    end

    local entry = vgui.Create("DTextEntry", top)
    self.entry = entry
    entry:Dock(FILL)
    entry:SetTall(24)

    function entry.OnEnter(entry)
        self:OpenURL(entry:GetText())
        self.browser:RequestFocus()
    end

    local btn = vgui.Create("DButton", self.top)
    btn:SetText("")
    btn:SetSize(24, 24)
    btn:Dock(LEFT)

    function btn.DoClick()
        if self.browser:IsLoading() then
            self.browser:StopLoading()
        else
            self.browser:Refresh(true)
        end
    end

    local RefreshIcon = Material("icon16/arrow_refresh.png")
    local CancelIcon = Material("icon16/cross.png")

    btn.Paint = function(btn, w, h)
        DButton.Paint(btn, w, h)

        if not self.browser:IsLoading() then
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(RefreshIcon)
            surface.DrawTexturedRect(btn:GetWide() / 2 - 16 / 2, btn:GetTall() / 2 - 16 / 2, 16, 16)
        else
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(CancelIcon)
            surface.DrawTexturedRect(btn:GetWide() / 2 - 16 / 2, btn:GetTall() / 2 - 16 / 2, 16, 16)
        end
    end

    local btn = vgui.Create("DButton", self.top)
    btn:SetText("")
    btn:SetSize(24, 24)
    btn:SetIcon("icon16/script_gear.png")
    btn:Dock(RIGHT)

    function btn.DoClick()
        self.browser:RunJavascript([[var s = document.documentElement.outerHTML; document.write('<html><body><textarea id="dsrc" style="width: 100%; height: 100%;"></textarea></body></html>');  var ta=document.getElementById( 'dsrc'); ta.value=s; void 0;]])
    end

    local browser = vgui.Create("DHTML", self)
    self.browser = browser
    browser:Dock(FILL)
    browser.Paint = function() end
    browser:SetFocusTopLevel(true)

    browser:AddFunction("gmod", "wssubscribe", function()
        self:GetWSID(tostring(self.chosen_id))
        self:Close()
    end)

    browser:AddFunction("gmod", "addonsize", function(msg)
        if tonumber(msg) then
            self.addonsize = tonumber(msg)
        end
    end)

    browser.OnDocumentReady = function(browser, url)
        self.entry:SetText(url)
        self:LoadedURL()
    end


    browser.Think = function(self)
        if not self._nextUrlPoll or self._nextUrlPoll < RealTime() then
            self:RunJavascript('console.log("HREF:"+window.location.href);')
            self:RunJavascript([[
				var adsz = document.getElementsByClassName("detailsStatsContainerRight").length ? document.getElementsByClassName("detailsStatsContainerRight")[0].children[0].textContent.split(" ")[0] : undefined;
				if (adsz) gmod.addonsize(adsz);
				
				function SubscribeItem() {
					if (]] .. maxfilesize .. [[>adsz) gmod.wssubscribe();
				};
			
				var sub = document.getElementById("SubscribeItemOptionAdd");
				if (sub) {
					sub.innerText = "Select";
				};
			]])
            self._nextUrlPoll = RealTime() + 0.25
        end
    end

    local prevurl = ""

    browser.ConsoleMessage = function(browser, msg)
        if isstring(msg) and msg:StartWith("HREF:") and "HREF:" .. prevurl ~= msg then
            prevurl = msg:sub(6)
            self.addonsize = nil
            browser.OnDocumentReady(browser, prevurl)
        end
    end

    local b = vgui.Create('DButton', self)
    self.chooseb = b
    b:Dock(BOTTOM)
    b:SetText("Select Character")
    b:SizeToContents()
    b:SetWidth(math.min(b:GetSize(), 256) + 32)
    b:SetTall(28)
    b:SetZPos(100)
    b:SetEnabled(false)
    b:NoClipping(false)
    b:SetFont("DermaLarge")

    b.Paint = function(b, w, h)
        if self.addonsize then
            if b:IsEnabled() then
                
                if self.addonsize < maxfilesize then
                    local x, y = b:CursorPos()

                    if (x >= 0 and y >= 0 and x <= b:GetWide() and y <= b:GetTall()) then
                        b:SetColor(Color(200, 200, 200))
                        surface.SetDrawColor(30, 100, 0, 100)
                        surface.DrawRect(0, 0, w, h)

                        return
                    end

                    b:SetColor(Color(255, 255, 255))
                    surface.SetDrawColor(30, 255, 0, 75)
                    surface.DrawRect(0, 0, w, h)
                else
                    b:SetColor(Color(255, 255, 255))
                    surface.SetDrawColor(255, 30, 0, 75)
                    surface.DrawRect(0, 0, w, h)
                end
            end
        else
            surface.SetDrawColor(Color(16, 16, 16))
            surface.DrawRect(0, 0, w, h)
        end
    end

    b.DoClick = function(b, mc)
        -- if self.addonsize and (self.addonsize < maxfilesize) then
            self:GetWSID(tostring(self.chosen_id))
            self:Close()
        -- end
    end
end

function PANEL:LoadedURL()
    local url = self.entry:GetValue()
    local id = url:match('://steamcommunity.com/sharedfiles/filedetails/.*[%?%&]id=(%d+)') or url:match('://steamcommunity.com/workshop/filedetails/.*[%?%&]id=(%d+)')
    self.chooseb:SetEnabled(id and true or false)
    self.chosen_id = id and tonumber(id) or nil
end

function PANEL:OpenURL(url)
    self.browser:StopLoading()
    self.browser:OpenURL(url)
    self.entry:SetText(url)
end

function PANEL:Think(w, h)
    DFrame.Think(self, w, h)

    if input.IsKeyDown(KEY_ESCAPE) then
        self:Close()
        gui.HideGameUI()
    end
end

function PANEL:GetWSID(data)
end

function PANEL:Show()
    local url = 'http://steamcommunity.com/workshop/browse/?appid=4000&searchtext=playermodel&childpublishedfileid=0&browsesort=trend&section=readytouseitems&requiredtags%5B%5D=Model'
    self:OpenURL(url)

    if ValidPanel(self.browser) then
        self.browser:RequestFocus()
    end
end

function PANEL:Close()
    self:Remove()
end

vgui.Register("workshopbrowser", PANEL, "DFrame")
