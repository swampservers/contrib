
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
	
	hook.Add("PlayerDeath","DeathInPit",function(ply)
		if IsValid(ply) then
			local loc = ply:IsPlayer() and ply:GetLocation() or Location.Find(ply)
			local name = Location.GetLocationNameByIndex(loc)
			if name == "The Pit" then
				ply.PitDeath = true
			end
		end
	end)

	hook.Add("PlayerSpawn","SpawnNextToPit",function(ply)
		if IsValid(ply) then
			if ply.PitDeath then
				ply:SetPos(Vector(0,-157,1))
				ply:SetEyeAngles(Angle(0,270,0))
				ply.PitDeath = false
			end
		end
	end)
end