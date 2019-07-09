local OwOemotes = {"OwO", "owo", "UwU", "uwu", "TwT", ">w<", ">wO", "Ow<", ":3c", ":3", ":33", ":333", "nya", "(> owo )>",
					"(> owo <)", "*pounces on you*", "*glomps u*", "mrowww", "~", ":owo:", ":uwu:", ":awoo:", ":blush:", 
					":catgirl:", ":pat:", ":snug:", ":thinkerfelix:", ":weebblush1:", ":weebears:", ":widetrap:"} --Add more emotes here

local function OwOifier(text)
	local splitstring = string.Split(text, "")
	local isemoteenabled = false

	for k, v in pairs(splitstring) do
		if v == ":" or v == ";" or v == "[" or v == "]" then --Keep emotes and chat colors the same
			isemoteenabled = !isemoteenabled
		elseif v == " " then
			isemoteenabled = false
		end
		if !isemoteenabled then
			if splitstring[k+1] then
				local dtext = table.concat(splitstring, "", k, k+1)

				for nyaaa in string.gmatch(dtext, "n[aeiou]+") do --n(vowel) to ny(vowel)
					local ny = "ny"..string.TrimLeft(nyaaa, "n")
					local jointext = string.gsub(dtext, nyaaa, ny)
					table.remove(splitstring, k+1)
					table.remove(splitstring, k)
					table.insert(splitstring, k, jointext)
				end
			end

			if string.find(v, "[RrLl]") then --R and L to W
				local stext = string.Replace(string.Replace(v, "R", "W"), "r", "w")
				local stext = string.Replace(string.Replace(stext, "L", "W"), "l", "w")
				table.remove(splitstring, k)
				table.insert(splitstring, k, stext)
			end		
		end
	end

	local owotext = table.concat(splitstring)

	local owotext = string.gsub(owotext, "this", "dis")

	if string.StartWith(owotext, "!") then
		owotext = string.gsub(owotext, "!woww", "!roll") --revert some commands
		owotext = string.gsub(owotext, "!pwaytime", "!playtime")
		owotext = string.gsub(owotext, "!kiwws", "!kills")
	end

	local owotext = string.format(owotext.." %s", OwOemotes[math.random(#OwOemotes)]) --add a random emote at the end

	return owotext
end

if SERVER then
	hook.Add("PlayerSay", "ChatOwOifier",function(ply, text, team)
		if ply:GetNWBool("OwOEnabled", false) then
			return OwOifier(text)
		end
	end)

	hook.Add("PlayerSay", "ClientOwOToggle", function(ply, text, team)
		if string.lower(text) == "!owo" then
			if ply:GetNWBool("OwOEnabled", false) == false then --Enable OwO
				ply:SetNWBool("OwOEnabled", true)
				ply:ChatPrint("[pink]owo enabled")
				return ""
			elseif ply:GetNWBool("OwOEnabled", false) == true then --Disable OwO
				ply:SetNWBool("OwOEnabled", false)
				ply:ChatPrint("[pink]owo disabled")
				return ""
			else end
		end
	end)
end
