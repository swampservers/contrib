-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
AddCSLuaFile()
SWEP.Base = "weapon_spraypaint"
SWEP.PrintName = "Stencil Paint"
SWEP.Spawnable = true
SWEP.Category = "PYROTEKNIK"
SWEP.Instructions = "Left Click to Draw, Right click to change stencil"
SWEP.UseHands = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.ViewModel = Model("models/pyroteknik/v_spraypaint.mdl")
SWEP.WorldModel = Model("models/pyroteknik/w_spraypaint.mdl")
SWEP.PaintDelay = 0.25
SWEP.SlotPos = 101
SWEP.WindowTitle = "Pick a Stencil (You can use your keyboard to choose)"



if (CLIENT) then
    CreateClientConVar("spraypaint_stencil", "stencil_decal27", true, true, "decal to spray from the can")
end

SPRAYPAINT_STENCILS = {}
SPRAYPAINT_STENCILS_WHITELIST = {}
SPRAYPAINT_MATLOOKUP = SPRAYPAINT_MATLOOKUP or {}

for i = 1, 40 do
    local dname = "stencil_decal" .. i
    local matname = "spray/" .. dname
    SPRAYPAINT_STENCILS[i] = dname
    SPRAYPAINT_STENCILS_WHITELIST[dname] = true
    SPRAYPAINT_MATLOOKUP[dname] = matname
    game.AddDecal(dname, matname)
    --Material(matname)
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
SPRAYPAINT_STENCILS_WHITELIST["Noughtsncrosses"] = true
SPRAYPAINT_STENCILS_WHITELIST["Nought"] = true
SPRAYPAINT_STENCILS_WHITELIST["Cross"] = true
SPRAYPAINT_STENCILS_WHITELIST["Eye"] = true
SPRAYPAINT_STENCILS_WHITELIST["Smile"] = true

SPRAYPAINT_MATLOOKUP["Noughtsncrosses"] = "decals/noughtsncrosses"
SPRAYPAINT_MATLOOKUP["Nought"] = "decals/nought"
SPRAYPAINT_MATLOOKUP["Cross"] = "decals/cross"
SPRAYPAINT_MATLOOKUP["Eye"] = "decals/eye"
SPRAYPAINT_MATLOOKUP["Smile"] = "decals/smile"


SWEP.DecalSet = "SprayPaintStencils"
SWEP.MenuColumns = 8
SWEP.ConVar = "spraypaint_stencil"

function SWEP:GetCurrentDecal()
    local ply = self:GetOwner()
    local decal = ply:GetInfo(self.ConVar)
    if (SPRAYPAINT_STENCILS_WHITELIST[decal]) then return decal end
    -- if decal~="" and ply==LocalPlayer() then
    --     net.Start("BanMe")
    --     net.SendToServer()
    -- end

    return "stencil_decal27"
end

function SWEP:DoSound(delay)
    self:EmitSound("spraypaint/spraypaint.wav", 100, 230, 0.5)
end
