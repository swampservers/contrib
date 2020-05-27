CoinFlips = CoinFlips or {}

RegisterChatCommand({'coin','coinflip'},function(ply,arg)
	local t = string.Explode(" ",arg)
	local p = tonumber(table.remove(t))
	if #t == 1 and t[1]:lower() == "accept" then checkCoinFlipRequest(ply, p) return end

	if p == nil then
		if #t == 1 and t[1]:lower() == "accept" then
			ply:ChatPrint("[orange]!coinflip accept points")
		else
			ply:ChatPrint("[orange]!coinflip player points")
		end
	else
		local to,c = PlyCount(string.Implode(" ",t))
		if c == 1 then
			if ply == to then
				ply:ChatPrint("[red]You can't coinflip yourself!")
			elseif hasCoinflipRequest(to) then
				ply:ChatPrint("[red]That player currently has a coinflip request active!")
			elseif p >= 1000 then -- minimum 1000 point coinflip
				initCoinFlip(ply,to,p)
			else
				ply:ChatPrint("[red]A coin flip must be a minimum of 1000 points. No pussy bets!")
			end
		else
			ply:ChatPrint("[red]Player "..string.Implode(" ",t).." not found")
		end
	end
end,{global=true,throttle=true})

timer.Create( "CoinFlip", 1, 0,
function()
	local usedID = nil
	for fromID,coinflip in pairs(CoinFlips) do
		if((coinFlip[3] + 60) <= CurTime()) then -- If 60 seconds have elapsed
			usedID = fromID -- Grab only 1 per timer itteration, prevents from having to table.remove inside of a loop.
			break
		end
	end
	if(usedID ~= nil) then
		local coinflipData = CoinFlips[usedID]
		local fromPlayer = player.GetBySteamID(usedID)
		local toPlayer = player.GetBySteamID(coinflipData[1])
		if(fromPlayer ~= nil and toPlayer ~= nil) then
			fromPlayer:ChatPrint("[edgy]" .. toPlayer:Nick() .. "[fbc] don't want to play. Try again lates.")
			toPlayer:ChatPrint("[fbc]You missed out on a coinflip from [edgy]" .. fromPlayer:Nick() .. "[fbc].")
		elseif(fromPlayer == nil and toPlayer ~= nil) then
			toPlayer:ChatPrint("[fbc]You missed out on a coinflip.")
		elseif(fromPlayer ~= nil and toPlayer == nil) then
			fromPlayer:ChatPrint("[fbc]The player you requested a coinflip to has left. Try again lates.")
		end
		table.remove(CoinFlips, usedID)
	end
end)

function initCoinFlip(ply,target,amount)
	if ply:PS_HasPoints(amount) and target:PS_HasPoints(amount) and CoinFlips[ply:SteamID()] == nil then
		-- Both players have enough points AND an existing coinflip doesn't exist.
		ply:ChatPrint("[orange]"..to:Nick().." is receiving your coinflip request.")
		CoinFlips[ply:SteamID()] = {target:SteamID(), amount, CurTime()}
	elseif CoinFlips[ply:SteamID()] ~= nil then
		ply:ChatPrint("[red]What the hell r yeh doing bruv? yeh already hae a filp goin!")
	elseif not ply:PS_HasPoints(amount) then
		ply:ChatPrint("[red]What the hell r yeh doing bruv? yeh don't hae dooze points!")
	elseif not target:PS_HasPoints(amount) then
		-- Target doesn't have the required funds. Nothing happens, CoinFlipRequestTimeout will be called and timeout the roll.
	end
end

function CoinFlipRemove(id)
	timer.Destroy("CoinFlip" .. id)
	table.remove(CoinFlips, id)
end

function checkCoinFlipRequest(toPlayer, points)
	local coinflipFound = false
	for fromID,j in pairs(CoinFlips) do
		if j[1] == toPlayer:SteamID() and j[2] == points then
			-- Coinflip Request Found
			coinflipFound = true
			finishCoinFlip(fromID, toPlayer)
			break -- Only do the first request found.
		end
	end
	if not coinflipFound then
		ply:ChatPrint("[red]Yeh don't hae a coinflip request for tha amount!")
		ply:ChatPrint("[orange]COINFLIPS:")
		local index = 1
		for fromID,j in pairs(CoinFlips) do
			if j[1] == toPlayer:SteamID() then
				local fromPlayer =  player.GetBySteamID(fromID)
				local points = j[2]
				if fromPlayer ~= nil then
					ply:ChatPrint("[orange]" .. index .. ") [rainbow]" .. points .. "[fbc] from [gold]" .. fromPlayer:Nick())
				end
				index = index + 1
			end
		end
	end
end

function hasCoinflipRequest(ply)
	for fromID,data in pairs(CoinFlips) do
		if data[1] == ply:SteamID() then
			return true
		end
	end
	return false
end

function finishCoinFlip(fromID, to)
	-- Self explanatory, 'from' is the initiator player who's ID is the key in the table, 'to' is the other player.
	local from = nil
	local amount = CoinFlips[fromID][2]
	-- Get Player from ID
	for _,ply in ipairs( player.GetAll() ) do
		if(ply:SteamID() == fromID) then from = ply end
	end
	if(from == nil) then
		CoinFlipRemove(fromID) -- Remove request from CoinFlip because initiator left the server
		to:ChatPrint("[red]The other bruv left, gotta cancel this coinflip!")
	elseif from:PS_HasPoints(amount) and to:PS_HasPoints(amount) then -- Final Check, make sure they have funds still
		CoinFlipRemove(fromID) -- Remove request because roll is starting
		local heads = math.random() < 0.5 -- the "request from" player is always Heads.
		BotSayGlobal("[edgy]" .. from:Nick() .. "[fbc] flipped a coin worth [rainbow]" .. (amount * 2) .. "[fbc] against [gold]".. to:Nick().. "[fbc] and...... [rainbow]" .. (heads and "Won" or "Lost") .."!")
		from:ChatPrint("[fbc]You " .. (heads and "Won" or "Lost") .. " " .. amount .. ".")
		to:ChatPrint("[fbc]You " .. (heads and "Won" or "Lost") .. " " .. amount .. ".")
		-- Instead of taking the amount away from both and then giving the winner the amount x 2, simply remove/add here
		if heads then
			to:PS_TakePoints(amount)
			from:PS_GivePoints(amount)
		else
			from:PS_TakePoints(amount)
			to:PS_GivePoints(amount)
		end
	elseif not from:PS_HasPoints(amount) then
		-- Initiator suddenly doesn't have the required funds. Nothing happens, show it off as an error.
		-- Alternativly, we can show no messages, and don't remove the coinflip from table and have it timeout through CoinFlipRequestTimeout
		CoinFlipRemove(fromID)
		from:ChatPrint("[red]What the hell r yeh doing bruv? yeh don't hae dooze points!")
		-- Make it look like an error for both players.
		to:ChatPrint("[red]ERROR: No points have been taken. Coinflip cancelled.")
		from:ChatPrint("[red]ERROR: No points have been taken. Coinflip cancelled.")
	elseif not to:PS_HasPoints(amount) then
		-- Target suddenly doesn't have the required funds. Nothing happens, show it off as an error.
		CoinFlipRemove(fromID)
		to:ChatPrint("[red]What the hell r yeh doing bruv? yeh don't hae dooze points!")
		-- Make it look like an error for both players.
		to:ChatPrint("[red]ERROR: No points have been taken. Coinflip cancelled.")
		from:ChatPrint("[red]ERROR: No points have been taken. Coinflip cancelled.")
	end
end
