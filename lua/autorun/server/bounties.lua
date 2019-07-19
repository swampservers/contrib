
BountyLimit = BountyLimit or {}

hook.Add("PlayerDeath","BountyDeath",function(ply,infl,atk)
	local bounty = GetPlayerBounty(ply)
	if bounty > 0 and ply != atk and atk:IsPlayer() then
		SetPlayerBounty(ply,0)
		BountyLimit[ply:SteamID()] = math.max((BountyLimit[ply:SteamID()] or 0) - bounty,0)
		atk:PS_GivePoints(bounty)
		BotSayGlobal("[edgy]"..atk:Nick().." [fbc]has claimed [gold]"..ply:Nick().."'s [fbc]bounty of [rainbow]"..bounty.." [fbc]points!")
	end
end)

function GetPlayerBounty(ply)
	if ply.bounty == nil then
		ply.bounty = tonumber(ply:GetPData("bounty",0)) or 0
	end
	return ply.bounty
end

function SetPlayerBounty(ply,bounty)
	ply:SetPData("bounty",bounty)
	ply.bounty = bounty
end

function AddBounty(ply,target,amount)
	if !ply:IsPlayer() or !target:IsPlayer() or type(amount) != "number" then return end
	amount = amount > 0 and amount or 0
	local total = (BountyLimit[ply:SteamID()] or 0) + amount
	if ply:PS_HasPoints(amount) and total <= 10000000 then
		local add = GetPlayerBounty(target) + amount
		BountyLimit[ply:SteamID()] = (BountyLimit[ply:SteamID()] or 0) + amount
		SetPlayerBounty(target,add)
		ply:PS_TakePoints(amount)
		BotSayGlobal("[fbc]"..target:Nick().."'s bounty is now [rainbow]"..add.." [fbc]points")
	elseif ply:PS_HasPoints(amount) then
		ply:ChatPrint("[red]You have reached your limit for today")
	else
		ply:ChatPrint("[red]You don't have enough points")
	end
end

RegisterChatCommand({'bounty','setbounty'},function(ply,arg)
	local t = string.Explode(" ",arg)
	local p = tonumber(table.remove(t))
	if p == nil then
		ply:ChatPrint("[orange]!bounty player points")
	else
		local to,c = PlyCount(string.Implode(" ",t))
		if c == 1 then
			if p >= 1000 then
				AddBounty(ply,to,p)
			else
				ply:ChatPrint("[red]You must add a minimum of 1000 points to the bounty")
			end
		else
			ply:ChatPrint("[red]Player "..string.Implode(" ",t).." not found")
		end
	end
end,{global=true,throttle=true})

RegisterChatCommand({'showbounty'},function(ply,arg)
	local to,c = PlyCount(arg)
	if c == 1 then
		local bounty = GetPlayerBounty(to)
		if bounty > 0 then
			ply:ChatPrint("[orange]"..to:Nick().."'s bounty is [edgy]"..bounty.." [orange]points")
		else
			ply:ChatPrint("[orange]"..to:Nick().." has no bounty")
		end
	else
		ply:ChatPrint("[orange]!showbounty player")
	end
end,{global=false,throttle=false})

RegisterChatCommand({'bounties','showbounties'},function(ply,arg)
	local t = {}
	for k,v in pairs(player.GetHumans()) do
		local bounty = GetPlayerBounty(v)
		if bounty > 0 then
			table.insert(t,{v,bounty})
		end
	end
	table.sort(t,function(a,b) return a[2] > b[2] end)
	ply:ChatPrint("[fbc]--- [gold]Bounties [fbc]---")
	for k,v in ipairs(t) do
		if k <= 10 then
			ply:ChatPrint(v[1]:Nick()..": "..v[2])
		end
	end
end,{global=false,throttle=false})