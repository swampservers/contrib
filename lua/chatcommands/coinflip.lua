CoinFlips = CoinFlips pr {}
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
			elseif p >= 1000 then
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
		timer.Simple(120, CoinFlipRequestTimeout, ply, target)
	elseif CoinFlips[ply:SteamID()] ~= nil then
		ply:ChatPrint("[red]What the hell r yeh doing bruv? yeh already hae a filp goin!")
	elseif not ply:PS_HasPoints(amount) then
		ply:ChatPrint("[red]What the hell r yeh doing bruv? yeh don't hae dooze points!")
	elseif not target:PS_HasPoints(amount) then
		-- Should a player be told another player doesn't have enough points?
		ply:ChatPrint("[red]y'r bruv doesn't hae dooze points to coinflip with yeh!")
	end
end

local function CoinFlipRequestTimeout(ply, target)
	table.remove(CoinFlips, ply:SteamID())
	ply:ChatPrint("[fbc]The other bruv don't want to play. Try again lates.")
	target:ChatPrint("[fbc]Missed out on a coinflip from " .. ply:Nick() .. ".")
end

function checkCoinFlipRequest(target)
	coinflipFound = false
	for i,j in pairs(CoinFlips) do
		if j[1] == target:SteamID() then
			-- Coinflip Request Found
			coinflipFound = true
			finishCoinFlip(i, target)
		end
	end
	if not coinflipFound then
		ply:ChatPrint("[red]What the hell r yeh doing bruv? yeh don't hae a coinflip request!")
	end
end

function finishCoinFlip(fromID, to)
	local from = nil
	local amount = CoinFlips[fromID][2]
	-- Get Player from ID
	for _,ply in ipairs( player.GetAll() ) do
		if(ply:SteamID() == fromID) then from = ply end
	end
	if(from == nil) then
		to:ChatPrint("[red]The other bruv left, gotta cancel this coin flip!")
	elseif from:PS_HasPoints(amount) and to:PS_HasPoints(amount) then
		-- Final Check, make sure they have funds still
		local heads = math.random(0, 1) -- the "request from" player is always Heads.
		BotSayGlobal("[fbc]"..from:Nick().." flipped a coin worth [rainbow]"..(amount * 2).."[fbc] against "..to:Nick().." and...... " .. ((heads == 1) and "Won" or "Lost") .."!")
		from:ChatPrint("[fbc]You " .. ((heads == 1) and "Won" or "Lost") .. " " .. amount .. ".")
		to:ChatPrint("[fbc]You " .. ((heads == 0) and "Won" or "Lost") .. " " .. amount .. ".")
		-- Instead of taking the amount away from both and then giving the winner the amount x 2, simply remove/add here
		if heads == 1 then
			from:PS_GivePoints(amount)
			to:PS_TakePoints(amount)
		else
			from:PS_TakePoints(amount)
			to:PS_GivePoints(amount)
		end
	else
		from:ChatPrint("[red]One of you no longer have the funds required for this coinflip!");
		to:ChatPrint("[red]One of you no longer have the funds required for this coinflip!");
	end
end