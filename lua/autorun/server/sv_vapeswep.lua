-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

-- autorun/server/sv_vapeswep.lua
-- Defines serverside globals for Vape SWEP

-- Vape SWEP by Swamp Onions - http://steamcommunity.com/id/swamponions/

util.AddNetworkString("Vape")
util.AddNetworkString("VapeArm")
util.AddNetworkString("VapeTalking")

--spawns all the vapes to your inventory
concommand.Add("spawn_vapes", function(ply)
	if ply:IsSuperAdmin() or ply:SteamID()=="STEAM_0:0:38422842" then
		for k,v in next,weapons.GetList() do
			if v.ClassName:sub(1,11):lower()=="weapon_vape" then
				ply:Give(v.ClassName)
			end
		end
	else
		ply:PrintMessage(HUD_PRINTCONSOLE, "Superadmin only!")
	end
end)

function VapeUpdate(ply, vapeID)
	if not ply.vapeCount then ply.vapeCount = 0 end
	if not ply.cantStartVape then ply.cantStartVape=false end
	if ply.vapeCount == 0 and ply.cantStartVape then return end

	if ply.vapeCount > 3 then
		if vapeID == 3 then --medicinal vape healing
			if ply.medVapeTimer then ply:SetHealth(math.min(ply:Health() + 1, ply:GetMaxHealth())) end
			ply.medVapeTimer = !ply.medVapeTimer
		end

		if vapeID == 4 then --helium vape
			SetVapeHelium(ply, math.min(100, (ply.vapeHelium or 0)+1.5))
		end

		if vapeID == 5 then --hallucinogenic vape
			ply:SendLua("vapeHallucinogen=(vapeHallucinogen or 0)+3")
		end
	end
	
	ply.vapeID = vapeID
	ply.vapeCount = ply.vapeCount + 1
	if ply.vapeCount == 1 then
		ply.vapeArm = true
		net.Start("VapeArm")
		net.WriteEntity(ply)
		net.WriteBool(true)
		net.Broadcast()
	end
	if ply.vapeCount >= 50 then
		ply.cantStartVape = true
		ReleaseVape(ply)
	end
end

hook.Add("KeyRelease","DoVapeHook",function(ply, key)
	if key == IN_ATTACK then
		ReleaseVape(ply)
		ply.cantStartVape=false
	end
end)

function ReleaseVape(ply)
	if not ply.vapeCount then ply.vapeCount = 0 end
	if IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass():sub(1,11) == "weapon_vape" then
		if ply.vapeCount >= 5 then
			local loc=Location.GetLocationNameByIndex(Location.Find(ply)):lower()
			if (ply:InTheater() and not (ply:GetTheater()._AllowItems)) or loc=="trump lobby" or loc=="golf" then
				ply:PrintMessage( HUD_PRINTTALK, "[red] Take it outside, degenerate filth. ;authority;" )
			else 
				if(math.random(1,1000)==1)then
					local exp = ents.Create( "env_explosion" )
					exp:SetPos( ply:EyePos() )
					exp:Spawn()
					exp:SetKeyValue( "iMagnitude", "60" )
					exp:Fire( "Explode", 0, 0 )
				else
					net.Start("Vape")
					net.WriteEntity(ply)
					net.WriteInt(ply.vapeCount, 8)
					net.WriteInt(ply.vapeID + (ply:GetActiveWeapon().juiceID or 0), 8)
					net.Broadcast()
				end
				
			end
		end
	end
	if ply.vapeArm then
		ply.vapeArm = false
		net.Start("VapeArm")
		net.WriteEntity(ply)
		net.WriteBool(false)
		net.Broadcast()
	end
	ply.vapeCount=0 
end

timer.Create("VapeHeliumUpdater",0.2,0,function()
	for k,v in next,player.GetAll() do
		if not (IsValid(v:GetActiveWeapon()) and v:GetActiveWeapon():GetClass() == "weapon_vape_helium" and v.vapeArm) then
			SetVapeHelium(v, math.max(0, (v.vapeHelium or 0) - 2))
		end
	end
end)

function SetVapeHelium(ply, helium)
	if ply.vapeHelium ~= helium then
		local grav = Lerp(helium/100, 1, -0.15)
		if grav < 0 and ply:OnGround() then
			ply:SetPos(ply:GetPos()+Vector(0,0,1))
		end
		ply:SetGravity(grav)
		ply.vapeHelium = helium
		ply:SendLua("vapeHelium="..tostring(helium))

		if IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "weapon_vape_helium" then
			ply:GetActiveWeapon().SoundPitchMod=helium
			ply:SendLua("Entity("..tostring(ply:GetActiveWeapon():EntIndex())..").SoundPitchMod="..tostring(helium))
		end
	end
end

util.AddNetworkString("DragonVapeIgnite")

net.Receive("DragonVapeIgnite", function(len, ply)
	local ent = net:ReadEntity()
	if !IsValid(ent) then return end
	if !ply:HasWeapon("weapon_vape_dragon") then return end
	if !ent:IsSolid() then return end
	if ent:GetPos():Distance(ply:GetPos()) > 500 then return end
	--I hope there's no exploits
	ent:Ignite(9,0)
end)
