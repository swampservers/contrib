util.AddNetworkString("Bounties")
util.AddNetworkString("IncreaseBounty")

hook.Add("PlayerDeath","PlayerDeath",function(ply,infl,atk)
	local bounty = tonumber(ply:GetPData("bounty",0))
	if bounty > 0 and ply != atk then
		atk:PS_GivePoints(bounty)
		BotSayGlobal("[edgy]"..atk:Nick().." [fbc]has claimed [gold]"..ply:Nick().."'s [fbc]bounty of [rainbow]"..bounty.." [fbc]points!")
		ply:SetPData("bounty",0)
	end
end)

function FindPlayer(plyname)
	if type(plyname) == "string" and plyname != "" then
		local search = {}
		for k,v in pairs(player.GetAll()) do
			local x,y,z = string.find(string.lower(v:GetName()),".*("..string.lower(plyname)..").*")
			if z then
				table.insert(search,v)
			end
		end
		if table.Count(search) == 1 then
			return search[1]
		elseif table.Count(search) > 1 then
			return "Multiple players found, be more specific."
		elseif table.Count(search) == 0 then
			return "No players found."
		end
		return "Error"
	end
end

hook.Add("PlayerSay","BountyChatCommands",function(ply,text)
	if (string.StartWith(text,"!") or string.StartWith(text,"/")) then
		local newtext = string.Trim(string.Trim(string.Trim(text,"!"),"/")," ")
		if (string.StartWith(newtext,"bounty")) then
			local t = string.Explode(" ",newtext)
			local to = FindPlayer(t[2])
			if type(to) == "Player" then
				local bounty = tonumber(to:GetPData("bounty",0))
				if tonumber(t[3]) then
					local p = tonumber(t[3])
					if ply:PS_HasPoints(p) and p > 1000 then
						ply:PS_TakePoints(p)
						to:SetPData("bounty",bounty + p)
						BotSayGlobal(to:Nick().."'s bounty is now [rainbow]"..bounty + p.." [fbc]points")
					elseif ply:PS_HasPoints(p) and p < 1000 then
						ply:ChatPrint("[red]You must add a minimum of 1000 points to the bounty")
					else
						ply:ChatPrint("[red]You don't have enough points")
					end
				elseif bounty > 0 then
					BotSayGlobal(to:Nick().."'s bounty is [rainbow]"..bounty.." [fbc]points")
				elseif bounty == 0 then
					ply:ChatPrint("[fbc]"..to:Nick().." has no bounty")
				end
			else
				ply:ChatPrint("[fbc]!bounty player points")
			end
			return text
		end
		if (newtext:lower() == "bounties") then
			local t = {}
			for _,v in pairs(player.GetHumans()) do
				local bounty = tonumber(v:GetPData("bounty",0))
				if bounty > 0 then
					table.insert(t,{v,bounty})
				end
			end
			net.Start("Bounties")
				net.WriteTable(t)
			net.Send(ply)
		end
	end
end)

net.Receive("IncreaseBounty",function(len,ply)
	local p = net.ReadUInt(32)
	local s = net.ReadString()
	local t = FindPlayer(s)
	p = p > 0 and p or 0
	if ply:PS_HasPoints(p) and type(t) == "Player" then
		ply:PS_TakePoints(p)
		t:SetPData("bounty",tonumber(t:GetPData("bounty",0)) + p)
		ply:PS_Notify("You have increased "..t:Nick().."'s bounty by "..p.." points")
	elseif !ply:PS_HasPoints(p) and type(t) == "Player" then
		ply:PS_Notify("You don't have enough points")
	end
end)