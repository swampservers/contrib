-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
include("shared.lua")
CreateClientConVar("spraypaint_decal", "spraypaint_decal17", true, true, "decal to spray from the can")

function SWEP:PreDrawViewModel(vm, weapon, ply)
    self:SetBodygroup(2, 1)
    local cl = self:GetDecalColor()
    render.SetColorModulation(cl.x, cl.y, cl.z)
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

        if (bon) then
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
                oang:RotateAroundAxis(oang:Forward(), 90)
                oang:RotateAroundAxis(oang:Right(), 90)
                oang:RotateAroundAxis(oang:Forward(), 90)
                opos = opos + oang:Right() * 3.5
                opos = opos + oang:Forward() * 2
                opos = opos + oang:Up() * 0
                oang:RotateAroundAxis(oang:Up(), -90)
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
    self.ViewmodelDown = self.ViewmodelDown or 0
    self.ViewmodelDown = math.Approach(self.ViewmodelDown, IsValid(SpraypaintMenu) and 1 or 0, FrameTime() * 2)
    eang:RotateAroundAxis(eang:Right(), self.ViewmodelDown * -45)

    return epos, eang
end

function SWEP:AdjustMouseSensitivity()
end

function SWEP:DrawHUD()
end

if not SpraypaintParticleEmitter then
    SpraypaintParticleEmitter = ParticleEmitter(Vector(0, 0, 0))
end

function SWEP:DoParticle(pos)
    local color, size = self:GetDecalColor()

    for i = 1, 5 do
        self.SprayEmitter = self.SprayEmitter or ParticleEmitter(pos)
        if (not SpraypaintParticleEmitter) then return end
        self.SprayEmitter:SetPos(pos)
        local particle = self.SprayEmitter:Add(string.format("particle/smokesprites_00%02d", math.random(7, 16)), pos)
        particle:SetColor(color.x * 255, color.y * 255, color.z * 255, 255)
        particle:SetStartAlpha(32)
        particle:SetVelocity(VectorRand() * 6)
        particle:SetGravity(Vector(0, 0, 0))
        particle:SetLifeTime(0)
        particle:SetLighting(false)
        particle:SetDieTime(math.Rand(0.1, 0.3))
        particle:SetStartSize(1)
        particle:SetEndSize((size or 1) / 1.5)
        particle:SetEndAlpha(0)
        particle:SetCollide(true)
        particle:SetBounce(0)
        particle:SetRoll(math.Rand(0, 360))
        particle:SetRollDelta(0.01 * math.Rand(-40, 40))
        particle:SetAirResistance(100)
    end
end

SpraypaintMenu = nil

function SWEP:GetPreviewMat()
    SPRAYPAINT_DECALPREVIEW_CACHE = SPRAYPAINT_DECALPREVIEW_CACHE or {}
    local ply = self:GetOwner()
    local decal = ply:GetInfo(self.ConVar)
    local mat = Material(util.DecalMaterial(decal) or util.DecalMaterial("Cross"))
    local t = mat:GetString("$basetexture")
    local f = mat:GetFloat("$frame")
    local sc = mat:GetFloat("$decalscale")
    local c = mat:GetVector("$color2")
    local shader = mat:GetShader() or "VertexLitGeneric"

    if (shader == "VertexLitGeneric") then
        shader = "UnlitGeneric"
    end

    if (shader == "LightmappedGeneric") then
        shader = "UnlitGeneric"
    end

    if (SPRAYPAINT_DECALPREVIEW_CACHE[decal] == nil) then
        local params = {}
        params["$basetexture"] = t
        params["$frame"] = f
        params["$color2"] = c
        params["$vertexcolor"] = 1
        params["$vertexalpha"] = 1
        params["$decalscale"] = sc
        SPRAYPAINT_DECALPREVIEW_CACHE[decal] = CreateMaterial(decal .. "stencilpreviewmat", shader, params)
    end

    return SPRAYPAINT_DECALPREVIEW_CACHE[decal]
end

hook.Add("PreDrawEffects", "DrawSprayPaintHUD", function()
    local wep = LocalPlayer():GetActiveWeapon()

    --baseclass friendly
    if (IsValid(wep) and wep.DrawSpraypaintReticle) then
        wep:DrawSpraypaintReticle()
    end
end)

function SWEP:DrawSpraypaintReticle()
    if (CurTime() < self:GetNextPrimaryFire()) then return end
    local trace = self:GetTrace()
    if (not trace.Hit or trace.HitPos:Distance(EyePos()) > self:GetPaintDistance()) then return end
    if (trace.HitSky) then return end
    local pos = trace.HitPos + trace.HitNormal * 0.1
    local ang = trace.HitNormal:Angle()
    local mat = self:GetPreviewMat()
    local color = self:GetDecalColor()

    if (mat) then
        local size = mat:Width() * tonumber(mat:GetFloat("$decalscale"))
        ang:RotateAroundAxis(ang:Up(), 90)
        ang:RotateAroundAxis(ang:Forward(), 90)

        if (math.abs(trace.HitNormal.z) >= 1) then
            ang:RotateAroundAxis(ang:Up(), -90 * trace.HitNormal.z)
        end

        local cc = Vector(1, 1, 1)

        if (mat and size) then
            cam.Start3D2D(pos, ang, 1)
            surface.SetDrawColor(color.x * 255, color.y * 255, color.z * 255, 128)
            render.SetBlend(0.5)
            surface.SetMaterial(mat)
            surface.DrawTexturedRect(-size / 2, -size / 2, size, size)
            render.SetBlend(1)
            cam.End3D2D()
        end
    end
end

function SWEP:SpraypaintOpenPanel()
    if IsValid(SpraypaintMenu) then
        SpraypaintMenu:Remove()

        return
    end

    local Frame = vgui.Create("DFrame")
    Frame:SetSize((48 + 4) * self.MenuColumns + 4 + 2, 280) --good size for example
    Frame:SetTitle(self.WindowTitle)
    Frame:Center()
    Frame:MakePopup()
    SpraypaintMenu = Frame
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

        DButton.Paint = function(self)
            local w, h = self:GetSize()
            draw.RoundedBox(4, 0, 0, w, h, Color(114, 115, 128))
        end

        --we need to create the image and then destroy some of its functions so we can use custom handling
        local decalmat = util.DecalMaterial(v)

        if (decalmat) then
            DButton.PerformLayout = function() end
            DButton:SetMaterial("models/shiny")
            DButton.m_Image.FixVertexLitMaterial = function() end
            local mat = Material(decalmat)
            local dispmat = mat and mat:GetString("$modelmaterial") or mat and mat:GetName()
            local color = mat:GetVector("$color2"):ToColor() or Color(255, 255, 255)
            local size = mat:Width() * tonumber(mat:GetFloat("$decalscale"))

            function DButton.m_Image:FixImage()
                --
                -- If it's a vertexlitgeneric material we need to change it to be
                -- UnlitGeneric so it doesn't go dark when we enter a dark room
                -- and flicker all about
                --
                local Mat = self:GetMaterial()

                if (not Mat) then
                    self:SetMaterial("models/shiny")

                    return
                end

                local strImage = Mat:GetName()
                local t = Mat:GetString("$basetexture")
                local f = Mat:GetFloat("$frame")
                local c = Mat:GetVector("$color2")
                local shader = mat:GetShader()

                if (shader == "VertexLitGeneric") then
                    shader = "UnlitGeneric"
                end

                if (shader == "LightmappedGeneric") then
                    shader = "UnlitGeneric"
                end

                if (t) then
                    local params = {}
                    params["$basetexture"] = t
                    params["$frame"] = f
                    params["$color2"] = c
                    params["$vertexcolor"] = 1
                    params["$vertexalpha"] = 1
                    Mat = CreateMaterial(strImage .. "_DecalPreview3", shader, params)
                end

                self:SetMaterial(Mat)
            end

            DButton.m_Image:SetMaterial(dispmat)
            DButton.m_Image:FixImage()
            --DButton:SetText(k)
            --DButton:SetMaterial()
            --DButton:SetTooltip(util.DecalMaterial(v))
            DButton.m_Image:SetImageColor(color)
            DButton.m_Image:Dock(NODOCK)
            local isize = math.Clamp(size * 3, 0, 48)
            DButton.m_Image:SetSize(isize, isize)
            DButton.m_Image:Center()
        else
            DButton:SetText("[missing]")
        end

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
    Frame:SetTall((rows) * (48 + 4) + 30)
    Frame:Center()
end