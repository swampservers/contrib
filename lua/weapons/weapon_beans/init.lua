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
		
		for k,v in pairs(FunnyFart) do
			if(v.BeansEaten != nil and v.BeansEaten > 0 and math.random(0,25) < v.BeansEaten)then
					
				local pit = math.random(90,105)
	
				self:EmitSound("fart/shitpants.wav",350,math.random(90,110),1)
				local point = self:GetOwner():GetPos()
				if(IsValid(self) and SERVER)then BeanFart(ply) end
					
				v.BeansEaten = math.Clamp(v.BeansEaten - math.random(0,25),0,100000)
			end
		end
		FunnyFart = nil
	end)
end

function BeanFart(ply)
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
	self:Remove()
end
