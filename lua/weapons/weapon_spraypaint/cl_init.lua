-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
include("shared.lua")
CreateClientConVar("spraypaint_decal", "spraypaint_decal17", true, true, "decal to spray from the can")


SPRAYPAINTMATS = {}

local function GetPaintMaterial(color)
    color = Color(255, 255, 255, 255)
    SPRAYPAINTMATS = SPRAYPAINTMATS or {}

    return SPRAYPAINTMATS[color][1]
end

local wepicon = Material("spraypaint/spraypaint_icon.png", "smooth")

function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
    self.SelNeeded = 5

    if (not IsValid(self.TempModel)) then
        self.TempModel = ClientsideModel(self.WorldModel)
        self.TempModel:SetNoDraw(true)
    else
        local pan = Angle(0, 0, 0)
        pan:RotateAroundAxis(Vector(0, 1, 0), -25)
        pan:RotateAroundAxis(Vector(0, 0, 1), CurTime() * 270)
        self.TempModel:SetAngles(pan)
    end

    if (IsValid(self.TempModel)) then
        cam.Start2D()
        cam.Start3D(Vector(0, -37, 1), Angle(0, 90, 0), 32, x, y, wide, tall)
        render.SuppressEngineLighting(true)

        for i = 0, 5 do
            render.SetModelLighting(i, 0.5, 0.5, 0.5)
        end

        render.SetModelLighting(4, 1, 1, 1)
        render.SetModelLighting(5, 0, 0, 0)
        local cl = self:GetDecalColor() or Vector(1, 0, 1)
        render.SetColorModulation(cl.x, cl.y, cl.z)
        self.TempModel:DrawModel()
        render.SuppressEngineLighting(false)
        cam.End3D()
        cam.End2D()
        local shit = self.TempModel
        timer.Remove("WEPSEL_SPRAYPAINT_" .. self.TempModel:EntIndex())

        timer.Create("WEPSEL_SPRAYPAINT_" .. self.TempModel:EntIndex(), 0.2, 1, function()
            if (IsValid(shit)) then
                shit:Remove()
            end
        end)
    end
end

function SWEP:PreDrawViewModel(vm, weapon, ply)
    self:SetBodygroup(2, 1)
    local cl = self:GetDecalColor()
    render.SetColorModulation(cl.x, cl.y, cl.z)
    local down = ply:KeyDown(IN_ATTACK)
    self.FingerLerp = self.FingerLerp or 0

    if (down) then
        self.FingerLerp = math.min(self.FingerLerp + FrameTime() * 12, 1)
    end

    if (not down) then
        self.FingerLerp = math.max(self.FingerLerp - FrameTime() * 8, 0)
    end

    vm:SetPoseParameter("press", self.FingerLerp)
end

hook.Add("PostDrawViewModel", "paint_handsfix", function(vm, ply, weapon)
    render.SetColorModulation(1, 1, 1)
end)

function SWEP:PostDrawViewModel(vm, weapon, ply)
    render.SetColorModulation(1, 1, 1)
end

function SWEP:DrawWorldModel(flags)
    local ply = self:GetOwner()
    self:SetModelScale(1, 0)
    self:SetSubMaterial()
    local matrix
    local horn = false
    local opos = self:GetPos()
    local oang = self:GetAngles()

    if IsValid(ply) then
        local isPony = ply:IsPony()
        local bn = isPony and "LrigScull" or "ValveBiped.Bip01_R_Hand"
        local bon = ply:LookupBone(bn) or 0
        local bp, ba = ply:GetBonePosition(bon)
        bp = bp or self:GetPos()
        ba = ba or self:GetAngles()
        if bp then
            opos = bp
        end

        if ba then
            oang = ba
        end

        if isPony then
            opos = opos + (oang:Forward() * 6.4) + (oang:Right() * -1.8) + (oang:Up() * 0)
            oang:RotateAroundAxis(oang:Right(), 80)
            oang:RotateAroundAxis(oang:Forward(), 12)
            oang:RotateAroundAxis(oang:Up(), 20)
        else
            if (bn ~= 0) then
                oang:RotateAroundAxis(oang:Forward(), 90)
                oang:RotateAroundAxis(oang:Right(), 90)
                oang:RotateAroundAxis(oang:Forward(), 90)
                opos = opos + oang:Right() * 3.5
                opos = opos + oang:Forward() * 2
                opos = opos + oang:Up() * 0
                oang:RotateAroundAxis(oang:Up(), -90)
            end
        end

        if (isPony) then
            if (horn) then
                opos = opos - oang:Up() * 5
            else
                opos = opos + oang:Up() * 3
            end
        end

        self:SetupBones()
        matrix = self:GetBoneMatrix(0)

        if matrix then
            matrix:SetTranslation(opos)
            matrix:SetAngles(oang)

           
                self:SetBoneMatrix(0, matrix)

        end
    end

        render.MaterialOverride()
        draw.NoTexture()
        local cl = self:GetDecalColor()
        render.SetColorModulation(cl.x, cl.y, cl.z)
        render.SetBlend(1)
        self:SetBodygroup(1, 1)
        self:DrawModel()

        render.SetColorModulation(1, 1, 1)
end

function SWEP:GetViewModelPosition(epos, eang)
    --[[
	epos = epos + eang:Forward() * 15
	epos = epos + eang:Right() * 8
	epos = epos + eang:Up() * -10
	eang:RotateAroundAxis(eang:Up(),90)
	return epos, eang
	]]
    self.ViewmodelFwd = self.ViewmodelFwd or 0
    local tgt = 0

    if (self.SensToggle) then
        tgt = 1
    end

    self.ViewmodelFwd = math.Approach(self.ViewmodelFwd, tgt, FrameTime())
    epos = epos + eang:Forward() * self.ViewmodelFwd * 10
    self.ViewmodelDown = self.ViewmodelDown or 0

    if (IsValid(SpraypaintMenu)) then
        self.ViewmodelDown = math.Approach(self.ViewmodelDown, 1, FrameTime())
    else
        self.ViewmodelDown = math.Approach(self.ViewmodelDown, 0, FrameTime())
    end

    eang:RotateAroundAxis(eang:Right(), self.ViewmodelDown * -45)

    return epos, eang
end

function SWEP:AdjustMouseSensitivity()
    if (self.SensToggle) then return 0.2 end
end

function SWEP:DrawHUD()
end

if not SpraypaintParticleEmitter then
    SpraypaintParticleEmitter = ParticleEmitter(Vector(0, 0, 0))
end

function SWEP:DoParticle(pos, color, size)
    for i = 1, 5 do
        self.SprayEmitter = self.SprayEmitter or ParticleEmitter(pos)
        if (not SpraypaintParticleEmitter) then return end
        self.SprayEmitter:SetPos(pos)
        local particle = self.SprayEmitter:Add(string.format("particle/smokesprites_00%02d", math.random(7, 16)), pos)
        particle:SetColor(color.r, color.g, color.b, color.a)
        particle:SetStartAlpha(color.a)
        particle:SetVelocity(VectorRand()*6)
        particle:SetGravity(Vector(0, 0, 0))
        particle:SetLifeTime(0)
        particle:SetLighting(false)
        particle:SetDieTime(math.Rand(0.1, 0.3))
        particle:SetStartSize(1)
        particle:SetEndSize(16)
        particle:SetEndAlpha(0)
        particle:SetCollide(true)
        particle:SetBounce(0)
        particle:SetRoll(math.Rand(0, 360))
        particle:SetRollDelta(0.01 * math.Rand(-40, 40))
        particle:SetAirResistance(100)
    end
end

if CLIENT then
    surface.CreateFont("spraypaint_ammocounter", {
        font = "Coolvetica", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
        extended = false,
        size = 128,
        weight = 500,
        blursize = 2,
        scanlines = 0,
        antialias = true,
        underline = false,
        italic = false,
        strikeout = false,
        symbol = false,
        rotary = false,
        shadow = false,
        additive = false,
        outline = false,
    })

    SPRAYPAINT_DECALCOLOR_CACHE = SPRAYPAINT_DECALCOLOR_CACHE or {}
    SpraypaintMenu = nil

    function SWEP:GetDecalColor()
        local ply = self:GetOwner()
        if (not IsValid(ply)) then return Vector(1, 1, 1) end
        local decal = ply:GetInfo(self.ConVar)
        if (SPRAYPAINT_DECALCOLOR_CACHE[decal]) then return SPRAYPAINT_DECALCOLOR_CACHE[decal] end
        local mat = Material(util.DecalMaterial(decal))

        if (mat) then
            SPRAYPAINT_DECALCOLOR_CACHE[decal] = mat:GetVector("$color2")

            return mat:GetVector("$color2") or Vector(1, 1, 1)
        end

        return Vector(1, 1, 1)
    end

    function SWEP:SpraypaintOpenPanel()
        if IsValid(SpraypaintMenu) then return end
        local Frame = vgui.Create("DFrame")
        Frame:SetSize((48 + 4) * self.MenuColumns + 4 + 2, 280) --good size for example
        Frame:SetTitle(self.WindowTitle)
        Frame:Center()
        Frame:MakePopup()
        Frame.KeyCodeBinding = {}

        --auto-pressed buttons if associated with a specific key
        function Frame:OnKeyCodePressed(keycode)
            if (self.KeyCodeBinding[keycode]) then
                self.KeyCodeBinding[keycode]:DoClick()
            end
        end 

        surface.PlaySound(self.ShakeSound)
        local List = vgui.Create("DIconLayout", Frame)
        List:Center()
        List:SetSpaceY(4) -- Sets the space in between the panels on the Y Axis by 5
        List:SetSpaceX(4) -- Sets the space in between the panels on the X Axis by 5
        local columncounter = 1
        local rows = 1

        for k, v in pairs(list.Get(self.DecalSet)) do
           

            local DButton = List:Add("DButton")
            DButton:SetPos(128, 240)
            DButton:SetText("")
            DButton:SetSize(48, 48)
            local keycode = list.Get(self.DecalSet .. "_keycodes")[k]

            if (keycode) then
                Frame.KeyCodeBinding[keycode] = DButton
            end

            DButton.PerformLayout = function() end
            local mat = Material(util.DecalMaterial(v))
            local dispmat = mat:GetName() --mat:GetString("$modelmaterial")
            local color = mat:GetVector("$color2"):ToColor() or Color(255, 255, 255)
            local size = mat:Width() * tonumber(mat:GetFloat("$decalscale"))

            DButton.Paint = function(self)
                local w, h = self:GetSize()
                draw.RoundedBox(4, 0, 0, w, h, Color(48, 48, 48, 255))
            end

            DButton:SetMaterial("models/shiny")
            DButton.FixVertexLitMaterial = function() end

            function DButton.m_Image:FixImage()
                --
                -- If it's a vertexlitgeneric material we need to change it to be
                -- UnlitGeneric so it doesn't go dark when we enter a dark room
                -- and flicker all about
                --
                local Mat = self:GetMaterial()
                local strImage = Mat:GetName()
                local t = Mat:GetString("$basetexture")
                local f = Mat:GetFloat("$frame")
                local c = Mat:GetVector("$color2")

                if (t) then
                    local params = {}
                    params["$basetexture"] = t
                    params["$frame"] = f
                    params["$color2"] = c
                    params["$vertexcolor"] = 1
                    params["$vertexalpha"] = 1
                    Mat = CreateMaterial(strImage .. "_DImage_1", "UnlitGeneric", params)
                end

                self:SetMaterial(Mat)
            end

            DButton.m_Image:SetMaterial(dispmat)
            DButton.m_Image:FixImage()
            DButton.m_Image:SetImageColor(color)
            DButton.m_Image:Dock(NODOCK)
            local isize = math.Clamp(size * 3, 0, 48)
            DButton.m_Image:SetSize(isize, isize)
            DButton.m_Image:Center()

            DButton.DoClick = function()
                RunConsoleCommand(self.ConVar, v)
                Frame:Remove()
            end
            columncounter = columncounter + 1

            if (columncounter > self.MenuColumns) then
                columncounter = 0
                rows = rows + 1
            end
        end

        List:Dock(FILL)
        Frame:SizeToContents()
        Frame:SetTall((rows ) * (48 + 4) + 30)
        Frame:Center()
        SpraypaintMenu = Frame
    end
end
