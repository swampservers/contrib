
hook.Add("PlayerDeath","BountyDeath",function(ply,infl,atk)
	local bounty = GetPlayerBounty(ply)
	if bounty > 0 and ply != atk and atk:IsPlayer() then
		SetPlayerBounty(ply,0)
		atk:PS_GivePoints(bounty)
		BotSayGlobal("[edgy]"..atk:Nick().." [fbc]has claimed [gold]"..ply:Nick().."'s [fbc]bounty of [rainbow]"..bounty.." [fbc]points!")
	end
end)

function GetPlayerBounty(ply)
	if ply.bounty == nil then
		ply.bounty = tonumber(ply:GetPData("bounty",0))
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
	if ply:PS_HasPoints(amount) then
		SetPlayerBounty(target,GetPlayerBounty(target) + amount)
		ply:PS_TakePoints(amount)
		BotSayGlobal("[fbc]"..target:Nick().."'s bounty is now [rainbow]"..GetPlayerBounty(target) + amount.." [fbc]points")
	else
		ply:ChatPrint("[red]You don't have enough points")
	end
end

RegisterChatCommand({'bounty'},function(ply,arg)
	local t = string.Explode(" ",arg)
	local to = PlyCount(t[1])
	if to[1]:IsPlayer() and not to[2]>1 then
		local bounty = GetPlayerBounty(to)
		local p = tonumber(t[2])
		if type(p) == "number" then
			if p > 1000 then
				AddBounty(ply,to,p)
			else
				ply:ChatPrint("[red]You must add a minimum of 1000 points to the bounty")
			end
		elseif bounty > 0 then
			BotSayGlobal(to:Nick().."'s bounty is [rainbow]"..bounty.." [fbc]points")
		elseif bounty == 0 then
			ply:ChatPrint("[fbc]"..to:Nick().." has no bounty")
		end
	elseif
		ply:ChatPrint("[fbc]More than one person found with that string in their name")
	else
		ply:ChatPrint("[fbc]!bounty player points")
	end
end,{global=true,throttle=true})

RegisterChatCommand({'bounties'},function(ply,arg)
	local t = {}
	for k,v in pairs(player.GetHumans()) do
		local bounty = GetPlayerBounty(v)
		if bounty > 0 then
			table.insert(t,{v,bounty})
		end
	end
	table.sort(t,function(a,b) return a[2] > b[2] end)
	ply:ChatPrint("[fbc]--- [gold]Bounties [fbc]---")
	for k,v in pairs(t) do
		ply:ChatPrint(v[1]:Nick()..": "..v[2])
	end
end,{global=false,throttle=false})