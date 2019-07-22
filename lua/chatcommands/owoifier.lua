local OwOemotes = {"OwO", "owo", "UwU", "uwu", "TwT", ">w<", ">wO", "Ow<", ":3c", ":3", ":33", ":333", "nya", "(> owo )>",
					"(> owo <)", "*pounces on you*", "*glomps u*", "mrowww", "~", ":owo:", ":uwu:", ":awoo:", ":blush:", 
					":catgirl:", ":pat:", ":snug:", ":thinkerfelix:", ":weebblush1:", ":weebears:", ":widetrap:"} --Add more emotes here

local function OwOifier(text)
	local splitstring = string.Split(text, "")
	local isemoteenabled = false

	if string.find(splitstring[1], "[!/]") then
		isemoteenabled = true
	end
	
	for k, v in pairs(splitstring) do
		if string.find(v, "[:;%[%]]") then --Keep emotes and chat colors the same
			isemoteenabled = !isemoteenabled
		elseif v == " " then
			isemoteenabled = false
		end
		if !isemoteenabled then
			if splitstring[k+1] then
				for nyaaa in string.gmatch(splitstring[k]..splitstring[k+1], "[Nn][aeiouAEIOU]") do --n(vowel) to ny(vowel)
					if v == v:lower() then
						splitstring[k] = "ny"
					else 
						splitstring[k] = "NY"
					end
				end
			end

			if string.find(v, "[RrLl]") then --R and L to W
				if v == v:lower() then
					splitstring[k] = "w"
				else
					splitstring[k] = "W"
				end
			end		
		end
	end

	local owotext = table.concat(splitstring)
	local owotext = string.gsub(owotext, "this", "dis")
	local owotext = owotext.." "..OwOemotes[math.random(#OwOemotes)] --add a random emote at the end

	return owotext
end

hook.Add("PlayerSay", "ChatOwOifier",function(ply, text, team)
	if ply.OwOEnabled then
		return OwOifier(text)
	end
end)

RegisterChatCommand({'owo', 'uwu', 'toggleowo', 'toggleuwu'}, function(ply, arg)
	ply.OwOEnabled = ply.OwOEnabled or false
	if ply.OwOEnabled == false then --Enable OwO
		ply.OwOEnabled = true
		ply:ChatPrint("[pink]owo enabled")
	elseif ply.OwOEnabled == true then --Disable OwO
		ply.OwOEnabled = false
		ply:ChatPrint("[pink]owo disabled")
	else end
end, {global=true, throttle=true})
