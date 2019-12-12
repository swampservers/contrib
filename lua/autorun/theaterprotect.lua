
protectedTheaterTable = protectedTheaterTable or {}

timer.Create("iteratePTs",1,0,function()
	for k,v in pairs(protectedTheaterTable) do
		protectedTheaterTable[k]["time"]=math.floor(math.max(protectedTheaterTable[k]["time"]-1,0))
		if SERVER then
			local l = theater.GetByLocation(k)
			if protectedTheaterTable[k]["time"]>0 and (protectedTheaterTable[k]["owner"]~=l:GetOwner() or protectedTheaterTable[k]["video"]~=l:VideoData()) then	
				protectedTheaterTable[k]["time"]=0
				net.Start("protectPTdata")
				net.WriteTable(protectedTheaterTable)
				net.Broadcast()
			end
		end
	end
end)

function setupTheaterProtectTable()
	protectedTheaterTable = {}
	for k,v in pairs(theater.GetTheaters()) do
		if v:IsPrivate() then
			protectedTheaterTable[v.Id]={owner=nil,time=0,data=nil}
		end
	end
end

hook.Add("InitPostEntity", "setupPTprotectTable", setupTheaterProtectTable)
hook.Add("PostCleanupMap", "setupPTprotectTable2", setupTheaterProtectTable)

function getPTProtectionTime(loc)
	local th = theater.GetByLocation(loc)
	if th then
		if th:IsPlaying() then
			if th:VideoDuration()==0 then
				return 1800
			end
			return math.floor(math.min(th:VideoDuration()-th:VideoCurrentTime(true),3600*3)) 
		end
	end
	return 0
end

function getPTProtectionCost(time)
	if time==0 then return 0 end
	time = math.max(time,1800)
	return math.floor(time/18)*50
end

if CLIENT then
	net.Receive("protectPTdata",function(len,ply)
		protectedTheaterTable=net.ReadTable()
	end)
	local notifyWeapons = {
		weapon_357=true,
		weapon_sniper=true,
		weapon_crossbow=true,
		weapon_smg1=true,
		weapon_ar2=true,
		weapon_frag=true,
		weapon_crowbar=true,
		weapon_pistol=true,
		weapon_doom3_bfg=true,
		weapon_jihad=true,
		weapon_bigbomb=true,
		weapon_slam=true,
		weapon_physgun=true,
		weapon_slitter=true,
		weapon_gauntlet=true,
	}

	hook.Add("HUDPaint", "drawSAFENOTIFY", function()
		if not LocalPlayer():InVehicle() and Safe(LocalPlayer()) then
			if IsValid(LocalPlayer():GetActiveWeapon()) then
				if notifyWeapons[LocalPlayer():GetActiveWeapon():GetClass()] then
					local col = Color(255,255,255,255)
					draw.WordBox( 8, ScrW() / 2 - 100, (ScrH() / 2) + 80, "This is a Safe Space", "Trebuchet24", Color(0,0,0,100), col )
					draw.WordBox( 8, ScrW() / 2 - 108, (ScrH() / 2) + 120, "You can't harm anyone here.", "HudHintTextLarge", Color(0,0,0,100), col )
					draw.WordBox( 8, ScrW() / 2 - 108, (ScrH() / 2) + 150, "Holster your weapon to hide this.", "HudHintTextLarge", Color(0,0,0,100), col )
				end
			end
		end
	end)
end

local function divideUpSeconds(seconds)
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	local seconds = math.floor(seconds % 60)
	
	return hours, minutes, seconds
end

function SecondsToString(seconds)
	local hours, minutes, seconds = divideUpSeconds(seconds)
	
	local str = ""
	
	if hours == 1 then
		str = str .. tostring(hours) .. " hour "
	elseif hours > 1 then
		str = str .. tostring(hours) .. " hours "
	end
	
	if minutes == 1 then
		str = str .. tostring(minutes) .. " minute "
	elseif minutes > 1 then
		str = str .. tostring(minutes) .. " minutes "
	end
	
	if seconds == 1 then
		str = str .. tostring(seconds) .. " second"
	elseif seconds > 1 or (minutes == 0 and hours == 0) then
		str = str .. tostring(seconds) .. " seconds"
	end
	
	return str:gsub("^%s*(.-)%s*$", "%1")
end

function SecondsToTimer(seconds)
	local hours, minutes, seconds = divideUpSeconds(seconds)
	return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end