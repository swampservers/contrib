util.AddNetworkString("MonsterZero")

function MonsterUpdate(ply)
	if not ply.monsterCount then ply.monsterCount = 0 end
	if not ply.cantStartmonster then ply.cantStartmonster=false end
	if ply.monsterCount == 0 and ply.cantStartmonster then return end
	
	ply.monsterCount = ply.monsterCount + 1
	if ply.monsterCount == 1 then
		ply.monsterArm = true
		net.Start("MonsterZero")
		net.WriteEntity(ply)
		net.WriteBool(true)
		net.Broadcast()
	end
	if ply.monsterCount >= 12 then
		ply.cantStartmonster = true
		ReleaseMonster(ply)
	end
end

hook.Add("KeyRelease","DoMonsterHook",function(ply, key)
	if key == IN_ATTACK and !ply.cantStartmonster and IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "weapon_monster" then
		if ply.monsterCount < 10 then ply.cantStartmonster=false end
		ReleaseMonster(ply)
	end
end)

function ReleaseMonster(ply)
	if not ply.monsterCount then ply.monsterCount = 0 end
	if ply.monsterArm then
		ply.monsterArm = false
		net.Start("MonsterZero")
		net.WriteEntity(ply)
		net.WriteBool(false)
		net.Broadcast()
	end
	if ply.cantStartmonster then
		ply.realFov = ply:GetFOV()
		ply.realWalkSpeed = ply:GetWalkSpeed()
		ply.realRunSpeed = ply:GetRunSpeed()
		ply:SetWalkSpeed(280)
		ply:SetRunSpeed(420)
		ply:SetFOV(ply.realFov+10,1)
		timer.Simple(10,function()
			if IsValid(ply) then
				ply.cantStartmonster=false
				ply:SetWalkSpeed(ply.realWalkSpeed)
				ply:SetRunSpeed(ply.realRunSpeed)
				ply:SetFOV(ply.realFov,1)
			end
		end)
	end
	ply.monsterCount=0
end