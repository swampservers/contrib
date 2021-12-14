-- This file is subject to copyright - contact swampservers@gmail.com for more information.

-- What this file does:
--   Removes the need to util.AddNetworkString() for net messages
--     It will be added automatically when the server does net.Receive or net.Start with it the first time
--   Optimizes net.Incoming by caching all receivers at the network id
--     The lookup basically changes from Receivers[string.lower(util.NetworkIDToString(id))] to Receivers[id]

local NetworkStringToIDCache = {}

-- Faster than util.NetworkStringToID, returns nil if missing on client, added automatically if missing on server
local function NetworkStringToID(str)
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

if SERVER then
    local BaseNetStart = net.Start

    function net.Start(messageName, unreliable)
        NetworkStringToID(messageName)

        return BaseNetStart(messageName, unreliable)
    end


    -- Reload network strings we created in previous server runs
    SavedNetworkStrings = util.JSONToTable(file.Read("networkstringcache.txt", "DATA") or "[]")

    local BaseAddNetworkString = util.AddNetworkString

    function util.AddNetworkString(str)
        SavedNetworkStrings[str] = 10
        if not StartedSaveNetworkStrings then
            StartedSaveNetworkStrings = true
            timer.Simple(5, function()
                StartedSaveNetworkStrings = nil
                file.Write("networkstringcache.txt", util.TableToJSON(SavedNetworkStrings))
            end)
        end
        return BaseAddNetworkString(str)
    end
    
    for k,v in pairs(SavedNetworkStrings) do
        util.AddNetworkString(k) 
        SavedNetworkStrings[k] = v>1 and v-1 or nil
    end

end

--NOMINIFY
