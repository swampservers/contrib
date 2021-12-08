-- This file is subject to copyright - contact swampservers@gmail.com for more information.
concommand.Add("dashing", function(ply, cmd, args)
    local m = Material("models/fedora_rainbowdash/fedora_rainbowdash_texture")
    m:SetFloat("$cloakpassenabled", 1)
    m:SetFloat("$cloakfactor", 0.95)
    m:SetVector("$cloakcolortint", Vector(0.5, 0.8, 1))
    m:SetFloat("$refractamount", 0)
end)

--can edit this and it shows in menu
--MATAlert = Material( "icon16/error.png" )
--before error drawing, after previous shit
--hook.Add("DrawOverlay"
--after error drawing
--hook.Add("PostRenderVGUI"
net.Receive("OnPlayerChat", function()
    local ply = net.ReadEntity()
    local txt = net.ReadString()
    local tem = net.ReadBool()

    if IsValid(ply) then
        hook.Run("OnPlayerChat", ply, txt, tem, not ply:Alive())
    end
end)

local SwampMatureContent = CreateClientConVar("swamp_mature_content", 0, true, false)
local SwampMatureChatbox = CreateClientConVar("swamp_mature_chatbox", 0, true, false)
local SwampMatureResetter = CreateClientConVar("swamp_mature_last_reset", 0, true, false)

timer.Simple(1, function()
    local MATURE_RESET_INTERVAL = 24 * 3600 * 14
    local resetter = SwampMatureResetter:GetInt()

    if resetter > -1 and resetter < (os.time() - MATURE_RESET_INTERVAL) then
        RunConsoleCommand("swamp_mature_content", "0")
        RunConsoleCommand("swamp_mature_chatbox", "0")
        RunConsoleCommand("swamp_mature_last_reset", tostring(os.time()))
    end
end)

local wasf6down = false
local wasf7down = false

hook.Add("Think", "SwampMatureToggler", function()
    local isf6down = input.IsKeyDown(KEY_F6)
    local isf7down = input.IsKeyDown(KEY_F7)

    if isf6down and not wasf6down then
        local last = SwampMatureContent:GetBool()
        RunConsoleCommand("swamp_mature_content", (last and "0" or "1"))
        LocalPlayerNotify("Mature " .. (GAMEMODE.FolderName == "cinema" and "Videos & " or "") .. "Images " .. (last and "Disabled" or "Enabled"))
    end

    if GAMEMODE.FolderName == "cinema" then
        if isf7down and not wasf7down then
            local last = SwampMatureChatbox:GetBool()
            RunConsoleCommand("swamp_mature_chatbox", (last and "0" or "1"))
            LocalPlayerNotify("Mature Chatbox Images " .. (last and "Disabled" or "Enabled"))
        end
    end

    wasf6down = isf6down
    wasf7down = isf7down
end)

net.Receive("RunLuaLong", function()
    RunString(net.ReadString())
end)

net.Receive("MergeG", function()
    table.Merge(_G, net.ReadTable())
end)
