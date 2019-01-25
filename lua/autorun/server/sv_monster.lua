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
	if ply.monsterCount >= 10 then
		ply.cantStartmonster = true
		ReleaseMonster(ply)
	end
end

hook.Add("KeyRelease","DoMonsterHook",function(ply, key)
	if key == IN_ATTACK and !ply.cantStartmonster and ply:GetActiveWeapon():GetClass() == "weapon_monster" then
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
		ply.fov = ply:GetFOV()
		ply:SetWalkSpeed(300)
		ply:SetRunSpeed(400)
		ply:SetFOV(ply.fov+10,1)
		timer.Simple(5,function()
			ply.cantStartmonster=false
			ply:SetWalkSpeed(200)
			ply:SetRunSpeed(300)
			ply:SetFOV(ply.fov,1)
		end)
	end
	ply.monsterCount=0
end