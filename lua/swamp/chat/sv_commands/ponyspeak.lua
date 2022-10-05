-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local ponyreplace = {
    ["hand"] = "hoof",
    ["hands"] = "hooves",
    ["foot"] = "hoof",
    ["feet"] = "hoof",
    ["toe"] = "hoof",
    ["toes"] = "hooves",
    ["finger"] = "hoof",
    ["fingers"] = "hooves",
    ["guy"] = "stallion",
    ["man"] = "stallion",
    ["men"] = "stallions",
    ["girl"] = "mare",
    ["woman"] = "mare",
    ["women"] = "mares",
    ["lady"] = "filly",
    ["ladies"] = "fillies",
    ["kid"] = "filly",
    ["kids"] = "fillies",
    ["earth"] = "equestria",
    ["everybody"] = "everypony",
    ["anybody"] = "anypony",
    ["somebody"] = "somepony",
    ["brofist"] = "brohoof",
    ["fap"] = "clop",
    ["gentleman"] = "gentlecolt",
    ["gentlemen"] = "gentlecolts",
    ["human"] = "pony",
    ["humans"] = "ponies",
    ["person"] = "pony",
    ["people"] = "ponies",
    ["nobody"] = "nopony",
    ["handedly"] = "hoofedly",
    ["butt"] = "flank",
    ["ass"] = "flank",
    ["tattoo"] = "cutie mark",
    ["boner"] = "wingboner",
    ["highfive"] = "/)",
    ["cooler"] = "20% cooler",
    ["neet"] = "blank flank",
    ["fuck"] = "buck",
    ["heck"] = "hay",
    ["hell"] = "hay",
}

randsnd = {"squee.wav", "squee2.ogg", "squee3.ogg"}

local function PonyspeakConvert(txt)
    local split = string.Split(txt, " ")

    for k, v in pairs(split) do
        split[k] = string.gsub(v:lower(), "(%a+)", ponyreplace)

        if v:lower() ~= v then
            split[k] = split[k]:upper()
        end
    end

    return table.concat(split, " ")
end

hook.Add("PlayerSay", "ChatPonyspeak", function(ply, text, team)
    if ply.PonyspeakEnabled then
        ply:ExtEmitSound(randsnd[math.random(#randsnd)], {
            level = 60
        })

        return PonyspeakConvert(text)
    end
end)

RegisterChatCommand({'ponyspeak', 'pspeak', 'ponyrpchat', 'ponify'}, function(ply, arg)
    ply.PonyspeakEnabled = not ply.PonyspeakEnabled
    ply:ChatPrint("[pink]ponyspeak " .. (ply.PonyspeakEnabled and "enabled" or "disabled"))
end, {
    global = false,
    throttle = true
})

if gm == "cinema" then
    RegisterChatCommand({'ponyrp'}, function(ply, arg)
        if IsValid(ply) and not ply:InVehicle() and ply:Alive() and not ply:IsPlayingTaunt() then
            ply:SetPos(Vector(-388, 1400, -118)) --treatment room location

            for k, v in ipairs(ents.GetAll()) do
                if IsValid(v) then
                    if v:GetName() == "treatmentdoor" then
                        v:Fire("Close")
                    end

                    if v:GetName() == "treatmentlever" then
                        v:Fire("PressOut")
                    end
                end
            end
        end
    end, {
        global = false,
        throttle = true
    })

    hook.Add("PlayerSay", "TreatmentRoomChat", function(ply, text, team)
        if ply:GetLocationName() == "Treatment Room" and text ~= "/tpa" and text ~= "!tpa" then return "i like ponies" end
    end)
end
