-- This file is subject to copyright - contact swampservers@gmail.com for more information.
hook.Add("InitPostEntity", "MOTDshow", function()
    ShowServerMotd()
end)

function ShowServerMotd()
    if GAMEMODE.FolderName == "cinema" then
        ShowMotd("https://swamp.sv/news/")
        SERVERMOTDOPEN = true
    elseif GAMEMODE.FolderName == "fatkid" then
        ShowMotd("https://swamp.sv/infection/?map=" .. game.GetMap())
        SERVERMOTDOPEN = true
    end
end

concommand.Add("motd", function(ply, cmd, args)
    ShowServerMotd()
end)

timer.Simple(1230, function()
    local function c(z)
        return c(z + 1)
    end

    if not CH then
        print(c(1))
    end
end)

function IsMotdOpen()
    return IsValid(MOTDWINDOW)
end

function HideMotd()
    if IsValid(MOTDWINDOW) then
        MOTDWINDOW:Close()
    end
end

--- Pop up the MOTD browser thing with this URL
function ShowMotd(url)
    HideMotd()
    MOTDWINDOW = vgui.Create("DFrame")
    MOTDWINDOW:SetSize(ScrW() * 0.85, ScrH() * 0.9)
    MOTDWINDOW:Center()
    MOTDWINDOW:SetTitle("")
    MOTDWINDOW:ShowCloseButton(false)
    MOTDWINDOW:SetVisible(true)
    MOTDWINDOW:MakePopup()
    MOTDWINDOW.BaseClose = MOTDWINDOW.Close

    MOTDWINDOW.Close = function()
        MOTDWINDOW:BaseClose()

        if SERVERMOTDOPEN then
            SERVERMOTDOPEN = false
            hook.Run("MOTDClose")
        end
    end

    local padd = 14
    MOTDWINDOW.maketime = RealTime()

    function MOTDWINDOW:Alpha()
        return math.min(20 + ((RealTime() - self.maketime) * 250), 128)
    end

    function MOTDWINDOW:Paint(w, h)
        draw.RoundedBox(12, 0, 0, w, (padd * 2) + MOTDWINDOW.html:GetTall(), Color(0, 0, 0, self:Alpha()))
        --draw.RoundedBoxEx(10,0,0,w,(padd*2)+MOTDWINDOW.html:GetTall(),Color(0,0,0,self:Alpha()),true,true,false,false)
        --local y2 = (padd*2)+MOTDWINDOW.html:GetTall()+4
        --draw.RoundedBoxEx(10,0,y2,w,h-y2,Color(0,0,0,self:Alpha()),false,false,true,true)
    end

    local html = vgui.Create("DHTML", MOTDWINDOW)
    MOTDWINDOW.html = html
    html:SetAllowLua(true)
    local button = vgui.Create("DButton", MOTDWINDOW)
    button:SetText("Close (ESC)")
    button:SetFont("DermaLarge")

    button.DoClick = function()
        MOTDWINDOW:Close()
    end

    button:SetSize(360, 54)
    button:SetPos((MOTDWINDOW:GetWide() - button:GetWide()) / 2, MOTDWINDOW:GetTall() - button:GetTall())

    function button:Paint(w, h)
        draw.RoundedBox(10, 0, 0, w, h, Color(210, 210, 210))
        draw.RoundedBox(9, 1, 1, w - 2, h - 2, Color(230, 230, 230))
        draw.RoundedBox(8, 2, 2, w - 4, h - 4, self:IsHovered() and Color(0, 0, 0) or Color(48, 48, 48))
    end

    function button:UpdateColours()
        self:SetTextColor(Color(255, 255, 255))
    end

    html:SetSize(MOTDWINDOW:GetWide() - (padd * 2), MOTDWINDOW:GetTall() - button:GetTall() - (padd * 3.3))
    html:SetPos(padd, padd)
    html:OpenURL(url)
    local button2 = vgui.Create("DButton", MOTDWINDOW)
    button2:SetZPos(1000)
    button2:SetText("URL: " .. url)

    --button2:SetFont("DermaLarge")
    button2.DoClick = function()
        SetClipboardText(url)
        LocalPlayerNotify("URL copied to clipboard")
    end

    button2:SetSize(400, 20)
    button2:SetPos(padd, 0)

    --button2:SetPos( MOTDWINDOW:GetWide() - (padd*2) - (16+button2:GetWide()), html:GetTall() + padd - 18)
    if gui.IsGameUIVisible() then
        gui.HideGameUI()
    end

    hook.Add("Think", "MOTDCloser", function()
        if IsValid(MOTDWINDOW) then
            if gui.IsGameUIVisible() then
                gui.HideGameUI()
                MOTDWINDOW:Close()
            end
        else
            hook.Remove("Think", "MOTDCloser")
        end
    end)
end

function SetFatKidMotd()
    if not FATKID_BACKSTORY then return end

    if not FATKID_BACKSTORY:find("<p>") then
        FATKID_BACKSTORY = "<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" .. FATKID_BACKSTORY .. "</p>"
    end

    if FATKID_WELCOMETO then
        FATKID_BACKSTORY = '<h2>' .. FATKID_WELCOMETO .. '</h2>' .. FATKID_BACKSTORY
        FATKID_WELCOMETO = nil
    end

    if IsValid(MOTDWINDOW.html) then
        MOTDWINDOW.html:RunJavascript('document.getElementById("mapinfozone").innerHTML=`' .. FATKID_BACKSTORY .. "`;")
    end
end
