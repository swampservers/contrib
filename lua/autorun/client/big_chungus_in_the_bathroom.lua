-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
BIG_CHUNGUS_LOCATION = Vector(0, 1598, 64)
BIG_CHUNGUS_NORMAL = Vector(1, 0, 0)
if (game.GetMap() ~= "cinema_swamp_v3") then return end
if (engine.ActiveGamemode() ~= "cinema") then return end

-- i don't know how badly i want to have to uninstall this every time i do something else
-- i would put this in the map's location file but i don't have it. it should probably go there.
function MAKE_CHUNGUS()
    if (not IsValid(CHUNGUS_ENTITY)) then
        CHUNGUS_ENTITY = ClientsideModel("models/hunter/blocks/cube025x025x025.mdl")
    end

    CHUNGUS_ENTITY:SetPos(BIG_CHUNGUS_LOCATION)
    CHUNGUS_ENTITY:SetAngles(BIG_CHUNGUS_NORMAL:Angle())
    CHUNGUS_ENTITY:SetMaterial("pyroteknik/bigchungus")
    CHUNGUS_ENTITY:ManipulateBoneScale(0, Vector(0.02, 1, 1.2))
end

hook.Add("InitPostEntity", "make_chungus_in_bathroom", function()
    MAKE_CHUNGUS()
end)

local function Chungus_Function(ply, key)
    if (key == IN_USE and ply:EyePos():Distance(CHUNGUS_ENTITY:GetPos()) < 64 and ply:GetEyeTrace().HitPos:Distance(CHUNGUS_ENTITY:GetPos()) < 25) then
        RunConsoleCommand("say_team", "lol big chungus")
        surface.PlaySound("weapon_funnybanana/hahaha.ogg")
    end
end

timer.Create("Chungus_Checker", 1, 0, function()
    if (LocalPlayer():GetLocationName() == "Bathroom") then
        hook.Add("KeyPress", "ChungusBathroomKey", Chungus_Function)
    else
        hook.Remove("KeyPress", "ChungusBathroomKey")
    end
end)