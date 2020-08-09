CoinFlips = CoinFlips or {}

RegisterChatCommand({'coin','coinflip'},function(ply,arg)
	local t = string.Explode(" ",arg)
	local p = tonumber(table.remove(t))
	if #t == 1 and t[1]:lower() == "accept" then checkCoinFlipRequest(ply, p) return end

	if p == nil then
		if #t == 1 and t[1]:lower() == "accept" then
			ply:ChatPrint("[orange]!coinflip accept [confirm number of points]")
		else
			ply:ChatPrint("[orange]!coinflip player points")
		end
	else
		local to,c = PlyCount(string.Implode(" ",t))
		if c == 1 then
			if ply == to then
				ply:ChatPrint("[red]You can't coinflip yourself!")
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
	local NewCoinFlips = {}
	for fromID,coinflip in pairs(CoinFlips) do
		if((coinFlip[3] + 60) <= CurTime()) then

			local fromPlayer = player.GetBySteamID(fromID)
			local toPlayer = player.GetBySteamID(coinflip[1])
			if(fromPlayer ~= nil and toPlayer ~= nil) then -- This whole nonsense is because I want to show the from/to's name if possible, but otherwise show a different message.
				fromPlayer:ChatPrint("[edgy]" .. toPlayer:Nick() .. "[fbc] don't want to play. Try again lates.")
				toPlayer:ChatPrint("[fbc]You missed out on a coinflip from [edgy]" .. fromPlayer:Nick() .. "[fbc].")
			elseif(fromPlayer == nil and toPlayer ~= nil) then
				toPlayer:ChatPrint("[fbc]You missed out on a coinflip.")
			elseif(fromPlayer ~= nil and toPlayer == nil) then
				fromPlayer:ChatPrint("[fbc]The player you requested a coinflip to has left. Try again lates.")
			end
		else
			NewCoinFlips[fromID] = coinflip
		end
	end
	CoinFlips = NewCoinFlips
end)

function initCoinFlip(ply,target,amount)
	if ply:PS_HasPoints(amount) and CoinFlips[ply:SteamID()] == nil then
		ply:ChatPrint("[orange]"..to:Nick().." is receiving your coinflip request.")
		CoinFlips[ply:SteamID()] = {target:SteamID(), amount, CurTime()}
	elseif CoinFlips[ply:SteamID()] ~= nil then
		ply:ChatPrint("[red]What the hell r yeh doing bruv? yeh already hae a filp goin!")
	elseif not ply:PS_HasPoints(amount) then
		ply:ChatPrint("[red]What the hell r yeh doing bruv? yeh don't hae dooze points!")
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

function finishCoinFlip(fromID, toPlayer)
	local fromPlayer = nil
	local amount = CoinFlips[fromID][2]
	-- Get Player from ID
	for _,ply in ipairs( player.GetAll() ) do
		if(ply:SteamID() == fromID) then fromPlayer = ply end
	end
	if(fromPlayer == nil) then
		CoinFlipRemove(fromID) -- Remove request from CoinFlip because initiator left the server
		toPlayer:ChatPrint("[red]The other bruv left, gotta cancel this coinflip!")
	elseif fromPlayer:PS_HasPoints(amount) and toPlayer:PS_HasPoints(amount) then -- Final Check, make sure they have funds still
		CoinFlipRemove(fromID)
		local heads = math.random() < 0.5 -- the "request from" player is always Heads.
		BotSayGlobal("[edgy]" .. fromPlayer:Nick() .. "[fbc] flipped a coin worth [rainbow]" .. (amount * 2) .. "[fbc] against [gold]".. toPlayer:Nick().. "[fbc] and...... [rainbow]" .. (heads and "Won" or "Lost") .."!")
		fromPlayer:ChatPrint("[fbc]You " .. (heads and "Won" or "Lost") .. " " .. amount .. ".")
		toPlayer:ChatPrint("[fbc]You " .. (heads and "Won" or "Lost") .. " " .. amount .. ".")
		-- Instead of taking the amount away from both and then giving the winner the amount x 2, simply remove/add here
		if heads then
			toPlayer:PS_TakePoints(amount)
			fromPlayer:PS_GivePoints(amount)
		else
			fromPlayer:PS_TakePoints(amount)
			toPlayer:PS_GivePoints(amount)
		end
	else
		CoinFlipRemove(fromID)
		toPlayer:ChatPrint("[red]ERROR: No points have been taken. Coinflip cancelled.")
		fromPlayer:ChatPrint("[red]ERROR: No points have been taken. Coinflip cancelled.")
	end
end
