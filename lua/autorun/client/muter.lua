-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
--doesn't work because per current design AFKS cant hear micspam
--[[
timer.Create("AFK_Unmicspam",1,0,function()
	if math.random(1,20)==1 then
		if IsValid(LocalPlayer()) and LocalPlayer():IsAFK() and LocalPlayer():IsSpeaking() then
			local afkheardcount = 0
			local heardcount = 0
			for k,v in pairs(player.GetAll()) do
				if v:IsSpeaking() then
					if v:IsAFK() then
						afkheardcount = afkheardcount+1
					end
					heardcount = heardcount+1
				end
			end
			if afkheardcount > 2 or heardcount>4 then
				RunConsoleCommand("-voicerecord")
			end
		end
	end
end) ]]
hook.Add("HUDShouldDraw", "HideHUsddfD", function(name)
    if GetConVarNumber("cinema_hideinterface") <= 0 then return end
    if name == "CHudDeathNotice" then return false end
end)

hook.Add("PlayerStartVoice", "Hidevoiceasd", function(name)
    if GetConVarNumber("cinema_hideinterface") > 0 then return false end
end)
