RegisterChatCommand({'ponyrp'}, function(ply, arg)
	if !Safe(ply) and !ply:InVehicle() then
		if !IsValid(ply) then return end
		ply:SetPos(Vector(-388, 1400, -118)) --treatment room location

		for k, v in pairs(ents.GetAll()) do
			if IsValid(v) then
				if v:GetName() == "treatmentdoor" then v:Fire("Close") end
				if v:GetName() == "treatmentlever" then v:Fire("PressOut") end
			end
		end
	end
end, {global=false, throttle=true})

hook.Add("PlayerSay", "TreatmentRoomChat", function(ply, text, team)
	if ply:GetLocationName() == "Treatment Room" then
		return "i like ponies"
	end
end)