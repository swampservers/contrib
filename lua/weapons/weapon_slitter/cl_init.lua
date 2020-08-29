-- This file is subject to copyright - contact swampservers@gmail.com for more information.

include("shared.lua")

if (CLIENT) then
	killicon.AddFont("weapon_slitter", "CSKillIcons", "j", Color( 255, 80, 0, 255 ))
	surface.CreateFont("CSKillIcons", {font = "csd", size = ScreenScale(30), weight = 500, antialias = true, additive = true})
	surface.CreateFont("CSSelectIcons", {font = "csd", size = ScreenScale(60), weight = 500, antialias = true, additive = true})
end


BloodMaterials = {}
for k=1,6 do
	local m = Material("decals/blood"..tostring(k).."_subrect")
	table.insert(BloodMaterials,m)
end

net.Receive("slitThroatneck",function(len)
	local ent = net.ReadEntity()
	local ply = net.ReadEntity()
	local pos = net.ReadVector()
	local norm = net.ReadVector()

	for i=1,10 do 
		timer.Simple((i-1)*0.015, function()
			local add = VectorRand()
			add.z = (add.z - 0.5)*0.75
			add = 120*add
			local tr = util.TraceLine({ start= pos, endpos = pos+add, mask=MASK_NPCWORLDSTATIC } )
			if tr.Hit then
				util.DecalEx(BloodMaterials[math.random(#BloodMaterials)], tr.Entity, tr.HitPos, tr.HitNormal, Color(255,255,255,255),1,1)
			end
		end)
	end

	if ply ~= LocalPlayer() then
		sound.Play("Weapon_Knife.Hit",pos,80,100,1)
		local effectdata = EffectData()
		effectdata:SetOrigin(pos)
		effectdata:SetNormal(norm)
		effectdata:SetMagnitude(1)
		effectdata:SetScale(15)
		effectdata:SetColor( BLOOD_COLOR_RED )
		effectdata:SetFlags( 3 )
		util.Effect( "bloodspray", effectdata, true, true )
	end

	local scale = 14.0

	timer.Create( "UniqueNa"..tostring(math.random(0,1000)), 0.15, 15, function()

		local effectdata = EffectData()
		if ent and ent:IsValid() and ent:GetRagdollEntity() and ent:GetRagdollEntity():IsValid() then
			effectdata:SetOrigin( ent:GetRagdollEntity():GetPos())
			effectdata:SetNormal(Vector(0,0,1))
			effectdata:SetMagnitude(1)
			effectdata:SetScale(scale)
			scale = scale-0.6
			effectdata:SetColor( BLOOD_COLOR_RED )
			effectdata:SetFlags( 3 )
			util.Effect( "bloodspray", effectdata, true, true )
		end
	end)
end)
