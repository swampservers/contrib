-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local ponyreplace = {
    ["hand"] = "hoof",
    ["hands"] = "hooves",
    ["foot"] = "hoof",
    ["feet"] = "hooves",
    ["toe"] = "hoof",
    ["toes"] = "hooves",
    ["finger"] = "hoof",
    ["fingers"] = "hooves",
    ["arm"] = "hoof",
    ["arms"] = "hooves",
    ["boy"] = "colt",
    ["boys"] = "colts",
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
    ["fapping"] = "clopping",
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
    ["asshole"] = "ponut",
    ["tattoo"] = "cutie mark",
    ["boner"] = "wingboner",
    ["pussy"] = "marehood",
    ["highfive"] = "/)",
    ["cooler"] = "20% cooler",
    ["neet"] = "blank flank",
    ["fuck"] = "buck",
    ["fucking"] = "bucking",
    ["heck"] = "hay",
    ["hell"] = "hay",
    ["mayonnaise"] = "[redacted]",
    ["halloween"] = "nightmare night",
    ["christmas"] = "hearth's warming",
    ["valentines"] = "hearts and hooves",
    ["cowboy"] = "cowpony",
    ["cowgirl"] = "cowpony",
    ["naysayer"] = "neighsayer",
    ["snowman"] = "snowpony",
    ["walk"] = "trot",
    ["walking"] = "trotting",
    ["run"] = "gallop",
    ["running"] = "galloping",
    ["wingman"] = "wingpony",
    ["god"] = "celestia",
    ["gamer"] = "luna",
}

randsnd = {"squee.wav", "squee2.ogg", "squee3.ogg"}

local function PonyspeakConvert(txt)
    local split = string.Split(txt, " ")

    for k, v in pairs(split) do
        split[k] = string.gsub(v:lower(), "(%a+)", ponyreplace)

        if split[k] == v:lower() then
            split[k] = v
        elseif v:lower() ~= v then
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

RegisterChatCommand({"ponyspeak", "pspeak", "ponyrpchat", "ponify"}, function(ply, arg)
    ply.PonyspeakEnabled = not ply.PonyspeakEnabled
    ply:ChatPrint("[pink]ponyspeak " .. (ply.PonyspeakEnabled and "enabled" or "disabled"))
end, {
    global = false,
    throttle = true
})

if gm == "cinema" then
    RegisterChatCommand({"ponyrp"}, function(ply, arg)
        if IsValid(ply) and not ply:InVehicle() and ply:Alive() then
            ply:SetPos(GetLocationCenterByName("Treatment Room") + Vector(0, 0, -64))

            for _, ent in ents.Iterator() do
                if IsValid(ent) then
                    if ent:GetName() == "treatmentdoor" then
                        ent:Fire("Close")
                    end

                    if ent:GetName() == "treatmentlever" then
                        ent:Fire("PressOut")
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
