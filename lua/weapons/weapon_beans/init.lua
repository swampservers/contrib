-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

AddCSLuaFile ("cl_init.lua")
AddCSLuaFile ("shared.lua")
include ("shared.lua")

util.AddNetworkString("Beans_Eat")
util.AddNetworkString("Beans_Eat_Start")

if SERVER then 
	timer.Create("BeansFart",1.7,0,function()
		FunnyFart = player.GetHumans()
		
		for k,ply in pairs(FunnyFart) do
			if(ply.BeansEaten != nil and ply.BeansEaten > 0 and math.random(0,25) < ply.BeansEaten)then			
				if(IsValid(ply) and SERVER)then BeanFart(ply) end	
				ply.BeansEaten = math.Clamp(ply.BeansEaten - math.random(0,25),0,100000)
			end
		end
		FunnyFart = nil
	end)
end

function BeanFart(ply)
	if(!IsValid(ply))then return end
	ply:ExtEmitSound("fart/shitpants.wav")
	
	local pos = ply:GetPos()
	for _,v in pairs(player.GetAll())do

		if isfunction(Safe) and Safe(v) then continue end
		if v == ply then continue end
		if v:GetNWBool("spacehat") then continue end
		if v:GetPos():Distance(pos) < 140 then
				local d = DamageInfo()
				d:SetDamage( 3 ) 
				d:SetAttacker( ply or ent )
				d:SetDamageType( DMG_POISON ) 
				v:TakeDamageInfo( d )
		end	
	end
end
