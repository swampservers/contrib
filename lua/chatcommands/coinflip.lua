CoinFlips = CoinFlips or {}
RegisterChatCommand({'coin','coinflip'},function(ply,arg)
	if arg:lower() == "accept" then checkCoinFlipRequest(ply) return end
	local t = string.Explode(" ",arg)
	local p = tonumber(table.remove(t))
	if p == nil then
		ply:ChatPrint("[orange]!coinflip player points")
	else
		local to,c = PlyCount(string.Implode(" ",t))
		if c == 1 then
			if ply == to then
				ply:ChatPrint("[red]You can't coinflip yourself!")
			elseif p >= 1000 then -- minimum 1000 point coinflip
				initCointFlip(ply,to,p)
			else
				ply:ChatPrint("[red]A coin flip must be a minimum of 1000 points. No pussy bets!")
			end
		else
			ply:ChatPrint("[red]Player "..string.Implode(" ",t).." not found")
		end
	end
end,{global=true,throttle=true})

function initCointFlip(ply,target,amount)
	if ply:PS_HasPoints(amount) and target:PS_HasPoints(amount) and CoinFlips[ply:SteamID()] == nil then
		-- Both players have enough points AND an existing coinflip doesn't exist.
		ply:ChatPrint("[orange]"..to:Nick().." is receiving your coinflip request.")
		CoinFlips[ply:SteamID()] = {target:SteamID(), amount}
		timer.Simple(120, CoinFlipRequestTimeout, ply, target) -- 2 minutes for the timeout.
	elseif CoinFlips[ply:SteamID()] ~= nil then
		ply:ChatPrint("[red]What the hell r yeh doing bruv? yeh already hae a filp goin!")
	elseif not ply:PS_HasPoints(amount) then
		ply:ChatPrint("[red]What the hell r yeh doing bruv? yeh don't hae dooze points!")
	elseif not target:PS_HasPoints(amount) then
		-- Target doesn't have the required funds. Nothing happens, CoinFlipRequestTimeout will be called and timeout the roll.
	end
end

local function CoinFlipRequestTimeout(ply, target)
	table.remove(CoinFlips, ply:SteamID())
	ply:ChatPrint("[edgy]" .. target:Nick() .. "[fbc] don't want to play. Try again lates.")
	target:ChatPrint("[fbc]You missed out on a coinflip from [edgy]" .. ply:Nick() .. "[fbc].")
end

function checkCoinFlipRequest(target)
	-- There is probably a better way to do this. I have always found this kind of coding nasty once you get a sip of Java 8.
	coinflipFound = false
	for i,j in pairs(CoinFlips) do
		if j[1] == target:SteamID() then
			-- Coinflip Request Found
			coinflipFound = true
			finishCoinFlip(i, target)
			break -- Only do the first request found.
		end
	end
	if not coinflipFound then
		ply:ChatPrint("[red]What the hell r yeh doing bruv? yeh don't hae a coinflip request!")
	end
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
		table.remove(CoinFlips, fromID) -- Remove request from CoinFlip because initiator left the server
		to:ChatPrint("[red]The other bruv left, gotta cancel this coinflip!")
	elseif from:PS_HasPoints(amount) and to:PS_HasPoints(amount) then -- Final Check, make sure they have funds still
		table.remove(CoinFlips, fromID) -- Remove request because roll is starting
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
		table.remove(CoinFlips, fromID)
		from:ChatPrint("[red]What the hell r yeh doing bruv? yeh don't hae dooze points!")
		-- Make it look like an error for both players.
		to:ChatPrint("[red]ERROR: No points have been taken. Coinflip cancelled.")
		from:ChatPrint("[red]ERROR: No points have been taken. Coinflip cancelled.")
	elseif not to:PS_HasPoints(amount) then
		-- Target suddenly doesn't have the required funds. Nothing happens, show it off as an error.
		table.remove(CoinFlips, fromID)
		to:ChatPrint("[red]What the hell r yeh doing bruv? yeh don't hae dooze points!")
		-- Make it look like an error for both players.
		to:ChatPrint("[red]ERROR: No points have been taken. Coinflip cancelled.")
		from:ChatPrint("[red]ERROR: No points have been taken. Coinflip cancelled.")
	end
end
