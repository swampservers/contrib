-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- What this file does:
--   Removes the need to util.AddNetworkString() for net messages
--     It will be added automatically when the server does net.Receive or net.Start with it the first time
--   Optimizes net.Incoming by caching all receivers at the network id
--     The lookup basically changes from Receivers[string.lower(util.NetworkIDToString(id))] to Receivers[id]
local NetworkStringToIDCache = {}

-- Faster than util.NetworkStringToID, returns nil if missing on client, added automatically if missing on server
function NetworkStringToID(str)
    local id = NetworkStringToIDCache[str]
    if id then return id end
    id = util.NetworkStringToID(str)

    if SERVER and id == 0 then
        id = util.AddNetworkString(str)
    end

    if id ~= 0 then
        NetworkStringToIDCache[str] = id

        return id
    end
end

local NetReceiverByID = {}

function net.Receive(name, func)
    local id = NetworkStringToID(name)

    if id then
        NetReceiverByID[id] = func
    end

    net.Receivers[name:lower()] = func
end

function net.Incoming(len, client)
    local i = net.ReadHeader()
    local func = NetReceiverByID[i]

    if not func then
        local str = util.NetworkIDToString(i)
        if not str then return end
        func = net.Receivers[str:lower()]
        if not func then return end
        NetReceiverByID[i] = func
    end

    func(len - 16, client)
end

API_Request("NetReady", {API_TABLE})

-- sends login key
API_Command("WebInit", {API_STRING}, function(auth)
    AUTHKEY = auth
    local p = vgui.Create("DHTML")
    p:SetSize(ScrW(), ScrH())
    p:SetAlpha(0)
    p:OpenURL("https://swamp.sv/webinit?auth=" .. auth)

    local function motdready()
        ShowServerMotd()
        motdready = noop
    end

    function p:ConsoleMessage(msg)
        RequestWebInit(msg)
        p:Remove()
        motdready()
    end

    timer.Simple(60, function()
        if IsValid(p) then
            p:Remove()
            motdready()
        end
    end)
end)

-- sends back fingerprint
API_Request("WebInit", {API_STRING})

if CLIENT then
    hook.Add("InitPostEntity", "NetReady", function()
        RequestNetReady({
            -- os = system.IsWindows() and "win" or (system.IsOSX() and "osx" or (system.IsLinux() and "linux" or "unknown")), -- battery = system.BatteryPower()<255, -- w=ScrW(), -- h=ScrH(),
            country = system.GetCountry(),
            guid = (sql.Query("select value from playerpdata where infoid='GUID'") or {{}})[1].value
        })
    end)
end
