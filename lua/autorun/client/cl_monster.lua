-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

net.Receive("MonsterZero",function()
	local ply = net.ReadEntity()
	if not IsValid(ply) then return end
	local z = net.ReadBool()
	if ply.monsterArm != z then
		if z then
			timer.Simple(0.1, function() 
				if !IsValid(ply) then return end 
				if ply.monsterArm then ply:EmitSound("boomer/sip.wav") end
			end)
		else
			ply:StopSound("boomer/sip.wav")
		end
	end
	ply.monsterArm = z
	ply.monsterArmTime = os.clock()
	local m = 0
	if z then m = 1 end

	for i=0,19 do
		timer.Simple(i/60,function()
			if IsValid(ply) and ply:Alive() then
				monster_interpolate_arm(ply, math.abs(m-((19-i)/20)))
			end
		end)
	end
end)

function monster_interpolate_arm(ply, mult)
	if not IsValid(ply) then return end
	local b1 = ply:LookupBone("ValveBiped.Bip01_R_Upperarm")
	local b2 = ply:LookupBone("ValveBiped.Bip01_R_Forearm")
	if (not b1) or (not b2) then return end
	ply:ManipulateBoneAngles(b1,Angle(20*mult,-62*mult,10*mult))
	ply:ManipulateBoneAngles(b2,Angle(-5*mult,-16*mult,-50*mult))
	if mult==1 then ply.monsterArmFullyUp=true else ply.monsterArmFullyUp=false end
end
