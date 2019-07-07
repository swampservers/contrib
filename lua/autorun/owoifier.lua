local OwOemotes = {"OwO", "owo", "UwU", "uwu", "TwT", ">w<", ":3c", ":3", ":33", ":333", "nya", "(> owo )>",
					"*pounces on you*", "*glomps u*", "mrowww", "~", ":owo:", ":uwu:", ":awoo:", ":blush:", 
					":catgirl:", ":pat:", ":snug:", ":thinkerfelix:", ":weebblush1:", ":weebears:", ":widetrap:"} //Add more emotes here

local function OwOifier(text)
	local text = string.Replace(string.Replace(text,"R","W"),"r","w")
	local text = string.Replace(string.Replace(text,"L","W"),"l","w")

	for emotecolon in string.gmatch(text, ":%a-:") do //replace swampchat image emotes with text ones, because I cant figure out how to prevent them from being owo-ified
		text = string.gsub(text, emotecolon, OwOemotes[math.random(#OwOemotes)])
	end
	for emotesemicolon in string.gmatch(text, ";%a-;") do
		text = string.gsub(text, emotesemicolon, OwOemotes[math.random(#OwOemotes)])
	end

	for nyaaa in string.gmatch(text, "n[aeiou]+") do //n(vowel) to ny(vowel)
		local ny = "ny"..string.TrimLeft(nyaaa, "n")
		text = string.gsub(text, nyaaa, ny)
	end

	text = string.gsub(text, "!woww", "!roll") //revert !roll

	local text = string.format(text.." %s", OwOemotes[math.random(#OwOemotes)]) //add a random emote at the end

	return text
end

if SERVER then
	util.AddNetworkString("OwOSendToggleInfo")

	hook.Add("PlayerSay", "ChatOwOifier",function(ply, text, team)
		if ply:GetNWBool("OwOEnabled", false) then
			return OwOifier(text)
		end
	end)

	hook.Add("PlayerSay", "ClientOwOToggle", function(ply, text, team)
		if string.lower(text) == "!owo" then
			if ply:GetNWBool("OwOEnabled", false) == false then //Enable OwO
				ply:SetNWBool("OwOEnabled", true)
				net.Start("OwOSendToggleInfo")
					net.WriteEntity(ply)
					net.Send(ply)
				return ""
			elseif ply:GetNWBool("OwOEnabled", false) == true then //Disable OwO
				ply:SetNWBool("OwOEnabled", false)
				net.Start("OwOSendToggleInfo")
					net.WriteEntity(ply)
					net.Send(ply)
				return ""
			else end
		end
	end)
end

if CLIENT then
	local owochatcolor = Color(202, 67, 247)
	net.Receive("OwOSendToggleInfo",function()
		local ply = net.ReadEntity()
		if ply:GetNWBool("OwOEnabled", false) == false then
			chat.AddText(owochatcolor, "owo enabled")
		elseif ply:GetNWBool("OwOEnabled", false) == true then
			chat.AddText(owochatcolor, "owo disabled")
		else end
	end)
end