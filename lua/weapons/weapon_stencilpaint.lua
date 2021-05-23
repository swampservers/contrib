-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
AddCSLuaFile()
SWEP.Base = "weapon_spraypaint"
SWEP.PrintName = "Stencil Paint"
SWEP.Spawnable = true
SWEP.Category = "PYROTEKNIK"
SWEP.Primary.Automatic = false
SWEP.Instructions = "Left Click to Draw, Right click to change stencil"
SWEP.PaintDelay = 0.25
SWEP.SlotPos = 101
SWEP.WindowTitle = "Pick a Stencil (You can use your keyboard to choose)"

if (CLIENT) then
    CreateClientConVar("spraypaint_stencil", "stencil_decal27", true, true, "decal to spray from the can")
end

local function CreateDecals()
    SPRAYPAINT_STENCILS = {}

    for i = 1, 40 do
        local dname = "stencil_decal" .. i
        local matname = "spray/" .. dname
        SPRAYPAINT_STENCILS[i] = dname
        game.AddDecal(dname, matname)
        list.Set("SprayPaintStencils", i, dname)

        if (10 + i <= 36) then
            list.Set("SprayPaintStencils_keycodes", i, 10 + i)
        end
    end

    list.Set("SprayPaintStencils", 41, "Noughtsncrosses")
    list.Set("SprayPaintStencils", 42, "Nought")
    list.Set("SprayPaintStencils", 43, "Cross")
    list.Set("SprayPaintStencils", 44, "Eye")
    list.Set("SprayPaintStencils", 45, "Smile")
end

CreateDecals()
SWEP.DecalSet = "SprayPaintStencils"
SWEP.MenuColumns = 8
SWEP.ConVar = "spraypaint_stencil"

function SWEP:GetDecalColor()
    return Vector(0, 0, 0)
end

function SWEP:GetDecalMat()
    self.PREVIEWMAT = self.PREVIEWMAT or {}
    local ply = self:GetOwner()
    local decal = ply:GetInfo(self.ConVar)
    local mat = Material(util.DecalMaterial(decal))
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

    if (self.PREVIEWMAT[decal] == nil) then
        local params = {}
        params["$basetexture"] = t
        params["$frame"] = f
        params["$color2"] = c
        params["$vertexcolor"] = 1
        params["$vertexalpha"] = 1
        params["$decalscale"] = sc
        self.PREVIEWMAT[decal] = CreateMaterial(decal .. "stencilpreviewmat1", shader, params)
    end

    return self.PREVIEWMAT[decal]
end

function SWEP:DoSound(delay)
    self:EmitSound("spraypaint/spraypaint.wav", 100, 230, 0.5)
end

hook.Add("PreDrawEffects", "DrawSprayPaintHUD", function()
    local wep = LocalPlayer():GetActiveWeapon()
    if (not IsValid(wep) or wep:GetClass() ~= "weapon_stencilpaint") then return end
    if (CurTime() < wep:GetNextPrimaryFire()) then return end
    local trace = wep:GetTrace()
    if (not trace.Hit or trace.HitPos:Distance(EyePos()) > wep:GetPaintDistance()) then return end
    if (trace.HitSky) then return end
    local pos = trace.HitPos + trace.HitNormal * 0.1
    local ang = trace.HitNormal:Angle()
    local mat = wep:GetDecalMat()

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
            surface.SetDrawColor(255, 255, 255, 64)
            render.SetBlend(0.5)
            surface.SetMaterial(mat)
            surface.DrawTexturedRect(-size / 2, -size / 2, size, size)
            render.SetBlend(1)
            cam.End3D2D()
        end
    end
end)