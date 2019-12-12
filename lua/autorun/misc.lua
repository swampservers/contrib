
function Safe(ent) 
	local loc = ent:IsPlayer() and ent:GetLocation() or Location.Find(ent)
	local name = Location.GetLocationNameByIndex(loc)

	if HumanTeamName~=nil and name~="Movie Theater" then
		return false
	end

	if (name=="Movie Theater" and ent:GetPos().x < -1648) or (name=="Arcade") or (name=="Bomb Shelter") then
		return true
	end
	if name=="Golf" or name=="Upper Caverns" or name=="Lower Caverns" then
		if ent:IsPlayer() then
			local w = ent:GetActiveWeapon()
			if IsValid(w) and w:GetClass()=="weapon_golfclub" then
				if IsValid(w:GetBallToShoot()) then
					return true
				end
			end
		end
	end
	local pt = protectedTheaterTable[loc]
	if pt~=nil and pt["time"]>1 then return true end
	if ent:IsPlayer() then
		if IsValid(ent:GetVehicle()) then
		    if ent:GetVehicle():GetNWBool("IsChessSeat", false) then
		    	local e = ent:GetVehicle():GetNWEntity("ChessBoard",nil)
		    	if IsValid(e) and e:GetPlaying() then
		    		return true
		    	end
		    end
		    local v = ent:GetVehicle()
		    if (v.SeatData~=nil) and (v.SeatData.Ent~=nil) and IsValid(v.SeatData.Ent) and v.SeatData.Ent:GetName()=="rocketseat" then
		    	return true
		    end
		end
	end
	return false
end

util.PrecacheModel("models/ppm/pony_anims.mdl")

SkyboxPortalEnabled = SkyboxPortalEnabled or false
SkyboxPortalCenter = Vector(0,-256,0)

if SERVER then
	util.AddNetworkString("bounce")
	net.Receive("bounce", function()
		local t = net.ReadTable()
		local p = Ply("Swamp")
		if IsValid(p) then
			net.Start("bounce")
			net.WriteTable(t)
			net.Send(p)
		end
	end)
	
	hook.Add("PlayerDeath","DeathInPitGym",function(ply)
		if ply:GetLocationName() == "The Pit" then
			ply.PitDeath = true
		end
		if ply:GetLocationName() == "Gym" then
			ply.DodgeballDeath = true
		end
	end)

	hook.Add("PlayerSpawn","SpawnNextToPitGym",function(ply)
		if ply.PitDeath then
			ply.PitDeath = false
			timer.Simple(0,function()
				ply:SetPos(Vector(math.random(-256,256),-256,0))
				ply:SetEyeAngles(Angle(0,-90,0))
			end)
		end
		if ply.DodgeballDeath then
			ply.DodgeballDeath = false
			timer.Simple(0,function()
				ply:SetPos(Vector(math.random(2160, 1903), -1185, -32))
				ply:SetEyeAngles(Angle(0,-90,0))
			end)
		end
	end)
else
	net.Receive("bounce", function()
		local t = net.ReadTable()
		PrintTable(t)
	end)
	function bounce(t)
		if IsValid(LocalPlayer()) and LocalPlayer():Name()~="Swamp" then
			net.Start("bounce")
			net.WriteTable(t)
			net.SendToServer()
		end
	end
end