
hook.Add("PlayerDeath","PlayerDeath",function(ply,infl,atk)
	local bounty = tonumber(ply:GetPData("bounty",0))
	if bounty > 0 and ply != atk and type(atk) == "Player" then
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

function AddBounty(ply,target,amount,global)
	if type(ply) != "Player" or type(target) != "Player" or type(amount) != "number" then return end
	amount = amount > 0 and amount or 0
	if ply:PS_HasPoints(amount) then
		ply:PS_TakePoints(amount)
		target:SetPData("bounty",tonumber(target:GetPData("bounty",0)) + amount)
		if global then
			BotSayGlobal("[fbc]"..to:Nick().."'s bounty is now [rainbow]"..bounty + p.." [fbc]points")
		else
			ply:ChatPrint("You have increased "..target:Nick().."'s bounty by "..amount.." points",ply)
		end
	else
		ply:ChatPrint("[red]You don't have enough points")
	end
end

RegisterChatCommand({'bounty'}, function(ply, arg)
	local t = string.Explode(" ",arg)
	local to = FindPlayer(t[1])
	if type(to) == "Player" then
		local bounty = tonumber(to:GetPData("bounty",0))
		if tonumber(t[2]) then
			local p = tonumber(t[2])
			AddBounty(ply,to,p,true)
		elseif bounty > 0 then
			BotSayGlobal(to:Nick().."'s bounty is [rainbow]"..bounty.." [fbc]points")
		elseif bounty == 0 then
			ply:ChatPrint("[fbc]"..to:Nick().." has no bounty")
		end
	else
		ply:ChatPrint("[fbc]!bounty player points")
	end
end, {global=true, throttle=true})

RegisterChatCommand({'bounties'}, function(ply, arg)
	local t = {}
	for k,v in pairs(player.GetHumans()) do
		local bounty = tonumber(v:GetPData("bounty",0))
		if bounty > 0 then
			table.insert(t,{v,bounty})
		end
	end
	table.sort(t,function(a,b) return a[2] > b[2] end)
	ply:ChatPrint("[fbc]--- [gold]Bounties [fbc]---")
	for k,v in pairs(t) do
		ply:ChatPrint(v[1]:Nick()..": "..v[2])
	end
end, {global=false, throttle=false})