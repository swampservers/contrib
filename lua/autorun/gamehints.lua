AddCSLuaFile()
--hints play randomly but you can set them to play deliberately whenever.
if(CLIENT)then
SwampHints = {}
SwampHints["playvideos"] = "Hold Q to view video controls and to play videos."
SwampHints["shop"] = "Press F3 to access the pointshop"
SwampHints["disablehints"] = "To disable hints, open the scoreboard using tab and check the Display section"

function SwampHint_InitVar()
SWAMP_HINTVAR = GetConVar("swamp_showhints") or CreateClientConVar( "swamp_showhints", "1", true,false, "show me those pesky hints on how to play cinema" )
end
SwampHint_InitVar()

function RandomSwampHint()
	SwampHint(table.Random(SwampHints),0)
end 

function SwampHint(message,delay)
	SwampHint_InitVar()
	local showmessage = SWAMP_HINTVAR and SWAMP_HINTVAR:GetBool()
	if(!showmessage)then return end
	if(SwampHints[message])then message = SwampHints[message] end
	timer.Create("delayswamphint"..message,delay,1,function()
		if(showmessage)then
			notification.AddLegacy( message, NOTIFY_GENERIC, 5 )
		end
	end)
end

timer.Create("SwampHint_Random",60,0,function()
	if(math.random() <= 0.1)then
		local showmessage = SWAMP_HINTVAR and SWAMP_HINTVAR:GetBool()
		if(RandomSwampHint and showmessage)then
			RandomSwampHint()
		end
	end
end)


end

if(SERVER)then
	local meta = FindMetaTable("Player")
	function meta:SwampHint(message,delay)
		if(type(message) != "string" or type(delay) != "number")then return end
		self:SendLua("SwampHint(\""..message.."\","..delay..")")
	end
	
--some scripted hints	
hook.Add("PlayerChangeLocation", "EnterTheater",function(ply,loc,oldloc)
	if(ply:InTheater() and ply.SwampHint)then
		ply:SwampHint("playvideos",4)
	end
end)
end