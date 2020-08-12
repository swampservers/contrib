CoinFlips = CoinFlips or {}

RegisterChatCommand({'coin','coinflip'},function(ply,arg)
	local t = string.Explode(" ",arg)
	local p = tonumber(t[#t])
	if #t == 1 and t[1]:lower() == "accept" and p != nil then checkCoinFlipRequest(ply, p) return end

	if p == nil then
		if #t == 1 and t[1]:lower() == "accept" then
			ply:ChatPrint("[orange]!coinflip accept [confirm number of points]")
		else
			ply:ChatPrint("[orange]!coinflip player points")
		end
	else
		table.remove(t)
		local to,c = PlyCount(string.Implode(" ",t))
		if c == 1 then
			if ply == to then
				ply:ChatPrint("[red]You can't coinflip yourself!")
			elseif p >= 1000 then -- minimum 1000 point coinflip
				initCoinFlip(ply,to,p)
			else
				ply:ChatPrint("[red]A coinflip must be a minimum of 1000 points.")
			end
		else
			ply:ChatPrint("[red]Player "..string.Implode(" ",t).." not found.")
		end
	end
end,{global=true,throttle=true})

timer.Create( "CoinFlip", 1, 0,
function()
	local NewCoinFlips = {}
	for fromID,j in pairs(CoinFlips) do
		if((j[3] + 20) <= CurTime()) then
			local fromPlayer = player.GetBySteamID(fromID)
			local toPlayer = player.GetBySteamID(j[1])
			if(fromPlayer != nil and toPlayer != nil) then -- This whole nonsense is because I want to show the from/to's name if possible, but otherwise show a different message.
				fromPlayer:ChatPrint("[edgy]" .. toPlayer:Nick() .. "[fbc] doesn't want to play. Try again later.")
				toPlayer:ChatPrint("[fbc]You missed out on a coinflip from [edgy]" .. fromPlayer:Nick() .. "[fbc].")
			elseif(fromPlayer == nil and toPlayer != nil) then
				toPlayer:ChatPrint("[fbc]You missed out on a coinflip.")
			elseif(fromPlayer != nil and toPlayer == nil) then
				fromPlayer:ChatPrint("[fbc]The player you requested a coinflip to has left. Try again later.")
			end
			CoinFlips[fromID] = nil
		else
			NewCoinFlips[fromID] = j
		end
	end
	CoinFlips = NewCoinFlips
end)

function initCoinFlip(ply,target,amount)
	if ply:PS_HasPoints(amount) and CoinFlips[ply:SteamID()] == nil then
		ply:ChatPrint("[orange]"..target:Nick().." is receiving your coinflip request.")
		target:ChatPrint("[orange]"..ply:Nick().." is sending you a coinflip request for [rainbow]"..amount.."[orange]. Say !coinflip accept [confirm number of points] to accept.")
		CoinFlips[ply:SteamID()] = {target:SteamID(), amount, CurTime()}
	elseif CoinFlips[ply:SteamID()] != nil then
		ply:ChatPrint("[red]You already have a coinflip in progress.")
	elseif not ply:PS_HasPoints(amount) then
		ply:ChatPrint("[red]You don't have enough points.")
	end
end

function checkCoinFlipRequest(toPlayer, points)
	for fromID,j in pairs(CoinFlips) do
		if j[1] == toPlayer:SteamID() and j[2] == points then
			-- Coinflip Request Found
			finishCoinFlip(fromID, toPlayer)
			return
		end
	end
	toPlayer:ChatPrint("[red]You don't have a coinflip request for that amount!")
	toPlayer:ChatPrint("[orange]COINFLIPS:")
	local index = 1
	for fromID,j in pairs(CoinFlips) do
		if j[1] == toPlayer:SteamID() then
			local fromPlayer = player.GetBySteamID(fromID)
			if fromPlayer != nil then
				toPlayer:ChatPrint("[orange](" .. index .. ") [gold]" .. j[2] .. "[orange] from [edgy]" .. fromPlayer:Nick())
			end
			index = index + 1
		end
	end
end

function finishCoinFlip(fromID, toPlayer)
	local fromPlayer = player.GetBySteamID(fromID)
	local amount = CoinFlips[fromID][2]
	if(fromPlayer == nil) then
		CoinFlips[fromID] = nil -- Remove request from CoinFlip because initiator left the server
		toPlayer:ChatPrint("[red]The initiator left, coinflip cancelled.")
	elseif fromPlayer:PS_HasPoints(amount) and toPlayer:PS_HasPoints(amount) then -- Final Check, make sure they have funds still
		CoinFlips[fromID] = nil
		local heads = math.random() < 0.5 -- the "request from" player is always Heads.
		BotSayGlobal("[edgy]" .. fromPlayer:Nick() .. "[fbc] flipped a coin worth [rainbow]" .. (amount * 2) .. "[fbc] against [gold]".. toPlayer:Nick().. "[fbc] and [rainbow]" .. (heads and "Won" or "Lost") .."[fbc]!")
		fromPlayer:ChatPrint("[fbc]You " .. (heads and "Won" or "Lost") .. " [gold]" .. amount .. "[fbc] points.")
		toPlayer:ChatPrint("[fbc]You " .. (heads and "Lost" or "Won") .. " [gold]" .. amount .. "[fbc] points.")
		-- Instead of taking the amount away from both and then giving the winner the amount x 2, simply remove/add here
		if heads then
			toPlayer:PS_TakePoints(amount)
			fromPlayer:PS_GivePoints(amount)
		else
			fromPlayer:PS_TakePoints(amount)
			toPlayer:PS_GivePoints(amount)
		end
	else
		CoinFlips[fromID] = nil
		toPlayer:ChatPrint("[red]ERROR: No points have been taken. Coinflip cancelled.")
		fromPlayer:ChatPrint("[red]ERROR: No points have been taken. Coinflip cancelled.")
	end
end
