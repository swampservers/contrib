if SERVER then
	hook.Add("OnPlayerAFK","afkwepstrip",function(v)
		--Strip freebie weapons to improve performance
		v:StripWeapon("weapon_spraypaint")
		v:StripWeapon("weapon_beans")
		v:StripWeapon("weapon_switch")
		v:StripWeapon("weapon_encyclopedia")
		v:StripWeapon("weapon_fidget")
		v:StripWeapon("weapon_monster")
		v:StripWeapon("weapon_popcorn")
		v:StripWeapon("weapon_kleiner")
		v:StripWeapon("weapon_flappy")
		v:StripWeapon("weapon_autism")
		v:StripWeapon("weapon_trashtape")
		v:StripWeapon("weapon_vape")
		v:StripWeapon("weapon_pickaxe")
		--v:StripWeapon("weapon_squee")
		v:StripWeapon("weapon_anonymous")
		v:StripWeapon("gmod_camera")
	end)

	timer.Create("PrivateTheaterUnlocker", 60, 0, function()
		for k,v in pairs(player.GetAll()) do
			if (not Safe(v)) and (v.AFKTimeSeconds or 0) > 900 and isLockingPT(v) then
				v:GetTheater():ResetOwner()
			end
		end
	end)

else
	--[[
	afk_start_time = 0
	hook.Add("HUDPaint", "DrawPTAFKwarning", function()
		if LocalPlayer():GetNWBool("afk",false) then
			if afk_start_time == 0 then
				afk_start_time = CurTime()
			end
		else
			afk_start_time = 0
		end

		if isLockingPT(LocalPlayer()) and afk_start_time > 0 and CurTime()-afk_start_time > 360 then
			draw.WordBox( 8, ScrW() / 2 - 80, ScrH() / 2, "Looks like you're AFK!", "Trebuchet24", Color(0,0,0,100), Color(255,255,255,255) )
			draw.WordBox( 8, ScrW() / 2 - 160, ScrH() / 2 + 50, "Please move your mouse or your theater ownership will be removed.", "Trebuchet18", Color(0,0,0,100), Color(255,255,255,255) )
		end
	end) ]]
end


function isLockingPT(v)
	if v:GetTheater() and v:GetTheater():IsPrivate() and v:GetTheater():GetOwner()==v then return true else return false end
end