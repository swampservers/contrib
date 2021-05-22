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


if(CLIENT)then
    CreateClientConVar("spraypaint_stencil", "stencil_decal27", true,true,"decal to spray from the can")
end

local function CreateDecals()
    SPRAYPAINT_STENCILS = {}
        for i=1,32 do
            local dname = "stencil_decal"..i
            local matname = "spray/"..dname
            SPRAYPAINT_STENCILS[i] = dname

            game.AddDecal( dname, matname )
            list.Set( "SprayPaintStencils",i, dname )
            if( 10+i <= 36)then
            list.Set( "SprayPaintStencils_keycodes",i, 10+i )
            end
        end
end
CreateDecals()

SWEP.DecalSet = "SprayPaintStencils"
SWEP.MenuColumns = 8
SWEP.ConVar = "spraypaint_stencil"



function SWEP:GetDecalMat()
    self.PREVIEWMAT = self.PREVIEWMAT or {}
    local ply = self:GetOwner()
    local decal = ply:GetInfo(self.ConVar)
    local mat = Material(util.DecalMaterial( decal ))



    local t = mat:GetString( "$basetexture" )
    local f = mat:GetFloat( "$frame" )
    local c = mat:GetVector( "$color2" )

    if ( self.PREVIEWMAT[decal] == nil ) then
        local params = {}
        params[ "$basetexture" ] = t
        params[ "$frame" ] = f
        params[ "$color2"] = c
        params[ "$vertexcolor" ] = 1
        params[ "$vertexalpha" ] = 1
        self.PREVIEWMAT[decal] = CreateMaterial( decal.."stencilpreviewmat", "UnlitGeneric", params )
    end

    
    return self.PREVIEWMAT[decal]
end

hook.Add("PreDrawEffects","DrawSprayPaintHUD",function()
	local wep = LocalPlayer():GetActiveWeapon()
	if(!IsValid(wep) or wep:GetClass() != "weapon_stencilpaint")then return end
	
	local trace = wep:GetTrace()
	if(!trace.Hit or trace.HitPos:Distance(EyePos()) > wep:GetPaintDistance())then return end
	if(trace.HitSky)then return end
	local pos = trace.HitPos + trace.HitNormal*0.1

	local ang = trace.HitNormal:Angle()
    ang:RotateAroundAxis(ang:Up(),90)
	ang:RotateAroundAxis(ang:Forward(),90)
	if(math.abs(trace.HitNormal.z) >= 1)then
        ang:RotateAroundAxis(ang:Up(),-90*trace.HitNormal.z)
    end

	local cc = Vector(1,1,1)

		cam.Start3D2D(pos,ang,1)	
            surface.SetDrawColor(255,255,255,64)
            surface.SetMaterial(wep:GetDecalMat())
            surface.DrawTexturedRect(-8,-8,16,16)
		cam.End3D2D()

	
end)
