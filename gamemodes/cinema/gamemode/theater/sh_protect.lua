-- This file is subject to copyright - contact swampservers@gmail.com for more information.
protectedTheaterTable = protectedTheaterTable or {}

timer.Create("iteratePTs", 1, 0, function()
    for k, v in pairs(protectedTheaterTable) do
        protectedTheaterTable[k]["time"] = math.max(protectedTheaterTable[k]["time"] - 1, 0)

        if SERVER then
            local l = theater.GetByLocation(k)

            if protectedTheaterTable[k]["time"] > 0 and protectedTheaterTable[k]["owner"] ~= l:GetOwner() then
                protectedTheaterTable[k]["time"] = 0
                net.Start("protectPTdata")
                net.WriteTable(protectedTheaterTable)
                net.Broadcast()
            elseif protectedTheaterTable[k]["time"] == 60 then
                l:GetOwner():Notify("Protection expires in 1 minute. Say /protect to extend it.")
            elseif protectedTheaterTable[k]["time"] == 10 then
                l:GetOwner():Notify("Protection expires in 10 seconds. Say /protect to extend it.")
            end
        end
    end
end)

hook.Add("InitPostEntity", "setupPTprotectTable", function()
    protectedTheaterTable = {}

    for k, v in pairs(theater.GetTheaters()) do
        if v:IsPrivate() then
            protectedTheaterTable[v.Id] = {
                owner = nil,
                time = 0
            }
        end
    end
end)

function getPTProtectionTime(loc)
    -- local th = theater.GetByLocation(loc)
    -- if th then
    -- 	if th:IsPlaying() then
    -- 		if th:VideoDuration()==0 then
    -- 			return 1800
    -- 		end
    -- 		return math.floor(math.min(th:VideoDuration()-th:VideoCurrentTime(true),3600*3)) 
    -- 	end
    -- end
    -- return 0
    return (Locations[loc].Theater or {}).ProtectionTime or 1200
end

function getPTProtectionCost(time)
    -- if time==0 then return 0 end
    -- time = math.max(time,10*60)
    -- return math.floor(time/60)*200
    return (time / 1200) * 5000
end

if CLIENT then
    net.Receive("protectPTdata", function(len, ply)
        protectedTheaterTable = net.ReadTable()
    end)

    local notifyWeapons = {
        weapon_357 = true,
        weapon_sniper = true,
        weapon_crossbow = true,
        weapon_smg1 = true,
        weapon_ar2 = true,
        weapon_frag = true,
        weapon_crowbar = true,
        weapon_pistol = true,
        weapon_doom3_bfg = true,
        weapon_jihad = true,
        weapon_bigbomb = true,
        weapon_slam = true,
        weapon_physgun = true,
        weapon_slitter = true,
        weapon_gauntlet = true,
        weapon_peacekeeper = true,
        weapon_magicmissile = true,
        weapon_garand = true,
        weapon_pickaxe = true,
        weapon_pickaxe_diamond = true,
        weapon_fists = true,
        weapon_crusadersword = true,
        gun_44magnum = true,
        gun_ak47 = true,
        gun_aug = true,
        gun_awp = true,
        gun_deagle = true,
        gun_elite = true,
        gun_famas = true,
        gun_fiveseven = true,
        gun_g3sg1 = true,
        gun_galil = true,
        gun_garand = true,
        gun_glock = true,
        gun_m3 = true,
        gun_m4a1 = true,
        gun_m4a1s = true,
        gun_m249 = true,
        gun_mac10 = true,
        gun_mg42 = true,
        gun_mp5navy = true,
        gun_mp7 = true,
        gun_p90 = true,
        gun_p228 = true,
        gun_scout = true,
        gun_sg550 = true,
        gun_sg552 = true,
        gun_spas12 = true,
        gun_tmp = true,
        gun_ump45 = true,
        gun_usp = true,
        gun_uspmatch = true,
        gun_usps = true,
        gun_xm1014 = true
    }

    hook.Add("HUDPaint", "drawSAFENOTIFY", function()
        if not Me:InVehicle() and Me:IsProtected() then
            if IsValid(Me:GetActiveWeapon()) then
                if notifyWeapons[Me:GetActiveWeapon():GetClass()] then
                    local col = Color(255, 255, 255, 255)
                    local cy = ScrH() * 0.7
                    local pt = protectedTheaterTable and protectedTheaterTable[Me:GetLocation()]
                    local protected = pt ~= nil and pt["time"] > 1
                    local owner = Me:InTheater() and protected and Me:GetTheater():GetOwner() == Me
                    local m0 = "This is " .. (owner and "your" or "a") .. " Safe Space"
                    local m1 = owner and "You can defend this area from players you don't want inside" or "You can't harm anyone here."
                    draw.WordBox(8, ScrW() / 2, cy, m0, "Trebuchet24", Color(0, 0, 0, 100), col, TEXT_ALIGN_CENTER)
                    draw.WordBox(8, ScrW() / 2, cy + 42, m1, "HudHintTextLarge", Color(0, 0, 0, 100), col, TEXT_ALIGN_CENTER)
                    draw.WordBox(8, ScrW() / 2, cy + 74, "Holster your weapon to hide this.", "HudHintTextLarge", Color(0, 0, 0, 100), col, TEXT_ALIGN_CENTER)
                end
            end
        end
    end)

    function CreateRentWindow()
        local window = vgui.Create("CinemaRentalsWindow")
        window:SetSize(450, 125)
        window:SetTitle("Protect Theater")
        local desc = vgui.Create("DLabel", window)
        desc:SetWrap(true)
        desc:SetText("Protect your theater to prevent weapons from being used inside it. Lasts for " .. tostring(math.floor(getPTProtectionTime(Me:GetLocation()) / 60)) .. " minutes.")
        desc:SetFont("Trebuchet24")
        desc:SetContentAlignment(5)
        desc:SetSize(window:GetWide() - 16, 60)
        desc:SetPos(8, window:GetTall() - 90)
        desc:CenterHorizontal()
        local rentButton = vgui.Create("TheaterButton", window)
        rentButton:SetText("Purchase")
        rentButton:SetSize(window:GetWide() - 8, 25)
        rentButton:SetPos(0, window:GetTall() - rentButton:GetTall() - 4)
        rentButton:CenterHorizontal()

        rentButton.DoClick = function(btn)
            -- net.Start("protectPT")
            -- net.SendToServer()
            RunConsoleCommand("say", "/protect")
            window:Remove()
        end

        window.Think = function(pnl)
            local t = getPTProtectionCost(getPTProtectionTime(Me:GetLocation()))

            if t > 0 then
                rentButton:SetText("Purchase for " .. tostring(t) .. " Points")
            else
                rentButton:SetText("Play a video to buy protection")
            end
        end

        window:Center()
        window:MakePopup()
    end

    local PANEL = {}
    local CloseTexture = Material("theater/close.png")

    --local TitleBackground = Material("theater/bannernew2.png")
    function PANEL:Init()
        self:SetFocusTopLevel(true)
        self.titleHeight = 36
        self.title = vgui.Create("DLabel", self)
        self.title:SetFont("ScoreboardTitleSmall")
        self.title:SetColor(Color(255, 255, 255))
        self.title:SetText("Window")
        self.closeButton = vgui.Create("DButton", self)
        self.closeButton:SetZPos(5)
        self.closeButton:NoClipping(true)
        self.closeButton:SetText("")

        self.closeButton.DoClick = function(btn)
            self:Remove()
        end

        self.closeButton.Paint = function(btn, w, h)
            DisableClipping(true)
            surface.SetDrawColor(48, 55, 71)
            surface.DrawRect(2, 2, w - 4, h - 4)
            surface.SetDrawColor(26, 30, 38)
            surface.SetMaterial(CloseTexture)
            surface.DrawTexturedRect(0, 0, w, h)
            DisableClipping(false)
        end
    end

    function PANEL:SetTitle(title)
        self.title:SetText(title)
    end

    function PANEL:PerformLayout()
        self.title:SizeToContents()
        self.title:SetTall(self.titleHeight)
        self.title:SetPos(1, 1)
        self.title:CenterHorizontal()
        self.closeButton:SetSize(32, 32)
        self.closeButton:SetPos(self:GetWide() - 34, 2)
    end

    function PANEL:Paint(w, h)
        surface.SetDrawColor(26, 30, 38, 255)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(141, 38, 33, 255)
        surface.DrawRect(0, 0, w, self.title:GetTall())
        surface.SetDrawColor(141, 38, 33, 255)
        --surface.SetMaterial(TitleBackground)
        surface.DrawRect(0, -1, 512, self.title:GetTall() + 1)

        if w > 512 then
            surface.DrawRect(460, -1, 512, self.title:GetTall() + 1)
        end
    end

    vgui.Register("CinemaRentalsWindow", PANEL, "Panel")
else
    hook.Add("PlayerInitialSpawn", "SendPTProtection", function(ply)
        net.Start("protectPTdata")
        net.WriteTable(protectedTheaterTable)
        net.Send(ply)
    end)
end

local function divideUpSeconds(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local seconds = math.floor(seconds % 60)

    return hours, minutes, seconds
end

function SecondsToString(seconds)
    local hours, minutes, seconds = divideUpSeconds(seconds)
    local str = ""

    if hours == 1 then
        str = str .. tostring(hours) .. " hour "
    elseif hours > 1 then
        str = str .. tostring(hours) .. " hours "
    end

    if minutes == 1 then
        str = str .. tostring(minutes) .. " minute "
    elseif minutes > 1 then
        str = str .. tostring(minutes) .. " minutes "
    end

    if seconds == 1 then
        str = str .. tostring(seconds) .. " second"
    elseif seconds > 1 or minutes == 0 and hours == 0 then
        str = str .. tostring(seconds) .. " seconds"
    end

    return str:gsub("^%s*(.-)%s*$", "%1")
end

function SecondsToTimer(seconds)
    local hours, minutes, seconds = divideUpSeconds(seconds)

    return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end
