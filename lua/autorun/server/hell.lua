util.AddNetworkString("HellTeleport")
util.AddNetworkString("HellTeleportEffect")

net.Receive("HellTeleport",function(len,ply)
	
	if !ply:GetPos():WithinAABox(Vector(3456,3440,-1089),Vector(3540,3471,-975)) then return end
	
	ply:SetPos(Vector(-50,4608,0))
	ply:SetEyeAngles(Angle(0,180,0))
	if ply:IsPony() then ply:Ignite(3) end
	ply:EmitSound("hell/DSTELEPT.wav")
	net.Start("HellTeleportEffect")
		net.WriteEntity(ply)
		net.WriteBool(false)
	net.Broadcast()
	
end)

hook.Add("InitPostEntity","CreateHellPortal",function()
	
	local hellportalprop = ents.Create("hellportalprop")
	hellportalprop:SetPos(Vector(3498,3470,-1020))
	hellportalprop:SetAngles(Angle(0,270,0))
	hellportalprop:Spawn()
	
	local hellportal = ents.Create("hellportal")
	hellportal:SetPos(Vector(3498,3470,-1020))
	hellportal:SetAngles(Angle(0,270,0))
	hellportal:Spawn()
	
	local hellgate = ents.Create("hellgate")
	hellgate:SetPos(Vector(-49,5073,0))
	hellgate:Spawn()
	
end)