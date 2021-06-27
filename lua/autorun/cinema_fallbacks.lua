AddCSLuaFile()

local function LoadOverrides()
    if (engine.ActiveGamemode() == "sandbox") then
        local meta = FindMetaTable("Player")
        meta.GetLocationName = meta.GetLocationName or function(self) return "Nowhere" end
        meta.GetLocation = meta.GetLocation or function(self) return 0 end
        meta.InTheater = function(self) return false end
        meta.GetTheater = function() return nil end 
    end 
   
    SetPlayerBounty = SetPlayerBounty or function(self, bounty)
        self:ChatPrint("Bounty Not Set: " .. bounty)

        return nil
    end 

    meta.PS_GivePoints = meta.PS_GivePoints or function(self) return nil end
    GetPlayerBounty = GetPlayerBounty or function(self, bounty) return 0 end

    meta.SS_GivePoints = meta.SS_GivePoints or function(self, money)
        self:ChatPrint("Fake money received: " .. money)
    end

    timer.Create("LocationOverrideMessage", 60 * 60 * 2, 0, function()
        print("Reminder! Location functions are being overridden currently. See lua/autorun/cinema_fallbacks.lua for more information.")
    end)

    function BotSayGlobal(text)
        BroadcastLua("FakeChatFunction(\"" .. text .. "\")")
        print(text)
    end

    local colors = {
        fbc = Color(128, 0, 255),
        white = Color(255, 255, 255),
        red = Color(255, 0, 0),
        rainbow2 = Color(255, 255, 0),
        yellow = Color(255, 255, 0),
    }

    function FakeChatFunction(text)
        local vars = {colors.fbc}

        local strings = string.Explode("[", text)

        for k, v in pairs(strings) do
            local command = string.Explode("]", v)[1]
            local word = string.Explode("]", v)[2]

            if (colors[command]) then
                table.insert(vars, colors[command])
            end

            table.insert(vars, word)
        end

        chat.AddText(unpack(vars))
    end
end

hook.Add("OnReloaded","updatecinemaoverrides",function()
    LoadOverrides()
end) 
hook.Add("Initialize","updatecinemaoverrides",function()
    LoadOverrides()
end) 
hook.Add("InitPostEntity","updatecinemaoverrides",function()
    LoadOverrides()
end) 
LoadOverrides()
timer.Simple(1,function()
    LoadOverrides()
end)