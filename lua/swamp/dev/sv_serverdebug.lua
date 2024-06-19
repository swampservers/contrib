-- This file is subject to copyright - contact swampservers@gmail.com for more information.
util.AddNetworkString("PrintConsole")
util.AddNetworkString("ClientErrorLog")
SessionErrors = SessionErrors or {}

-- For session-only errors that can be reviewed with the serverdebug concommand
function ServerDebug(e)
    SessionErrors[tostring(e)] = CurTime()
end

-- For errors we're queueing up to store in the database for long-term review (across restarts, etc)
function StoreErrorForDB(err, realm, stack, count, client)
    if type(stack) == "table" then
        stack = FormatErrorStack(stack)
    end

    if not stack then
        stack = "no stack"
    end

    if client and type(client) ~= "string" then
        client = IsValid(client) and client:Nick() .. " (" .. client:SteamID() .. ")" or "INVALID CLIENT"
    end

    if ErrorsForDB[err] then
        if client and ErrorsForDB[err].client ~= client then
            ErrorsForDB[err].client = "Multiple Clients"
        end

        ErrorsForDB[err].count = ErrorsForDB[err].count + (count or 1)
    else
        ErrorsForDB[err] = {
            realm = realm,
            stack = stack,
            count = count or 1,
            client = client
        }
    end
end

function FlushErrorsForDB()
    local errors = table.Copy(ErrorsForDB) -- We don't want it changing while we're storing
    table.Empty(ErrorsForDB)
    -- TODO(winter): Should this be a transaction?
    local totalerrors = 0

    for err, info in pairs(errors) do
        SQL_Query("INSERT INTO log_errors (hash, string, realm, stack, count, gamemode" .. (info.client and ", client" or "") .. ") VALUES (?, ?, ?, ?, ?, ?" .. (info.client and ", ?" or "") .. ") ON DUPLICATE KEY UPDATE count = count + VALUES(count)" .. (info.client and ", client = IF(client <> 'Multiple Clients', VALUES(client), 'Multiple Clients')" or ""), {util.SHA1(err), err, info.realm, info.stack, info.count, engine.ActiveGamemode(), info.client})

        totalerrors = totalerrors + 1
    end

    if totalerrors > 0 then
        print("[ServerDebug] Storing " .. tostring(totalerrors) .. " error(s) in DB")

        for _, ply in player.Iterator() do
            if ply:GetRank() >= 5 then
                ply:ChatPrint("[red][ServerDebug][white] Storing " .. tostring(totalerrors) .. " error(s) in DB")
            end
        end
    end
end

timer.Create("ServerDebug.LogErrorsInDB", 300, 0, FlushErrorsForDB)

hook.Add("OnLuaError", "ServerDebug.CatchBaseError", function(err, realm, stack)
    ServerDebug("Error: " .. err)
    StoreErrorForDB(err, realm, stack)
end)

net.Receive("ClientErrorLog", function(_, ply)
    local errors = net.ReadTable()

    for err, info in pairs(errors) do
        StoreErrorForDB(err, "client", info.stack, info.count, ply)
    end
end)

concommand.Add("serverdebug", function(ply, cmd, args)
    if (ply.sv_errors_last or 0) + 1 > CurTime() then return end
    ply.sv_errors_last = CurTime()
    ply:SendLua([[net.Receive("PrintConsole", function() print(net.ReadString()) end)]])
    local errors_ordered = {}

    for k, v in pairs(SessionErrors) do
        table.insert(errors_ordered, {k, v})
    end

    table.sort(errors_ordered, function(a, b) return a[2] < b[2] end)
    error_str = "\n\n"

    for i = math.max(1, #errors_ordered - 10), #errors_ordered do
        error_str = error_str .. tostring(math.floor(CurTime() - errors_ordered[i][2])) .. " seconds ago: " .. errors_ordered[i][1] .. "\n\n"
    end

    net.Start("PrintConsole")
    net.WriteString(error_str)
    net.Send(ply)
end)

local clientdebugtxt = ""
local clientdebugtime = 0

local function sendclientdebug(ply)
    ply:SendLua([[net.Receive("PrintConsole", function() print(net.ReadString()) end)]])
    net.Start("PrintConsole")
    net.WriteString(clientdebugtxt)
    net.Send(ply)
end

concommand.Add("clientdebug", function(ply, cmd, args)
    if CurTime() - clientdebugtime > 60 then
        file.AsyncRead("clientside_errors.txt", "MOD", function(fn, gp, status, data)
            if status == FSASYNC_OK then
                print("READDONE", #data)
                clientdebugtxt = data:sub(#data - 1500)
                clientdebugtime = CurTime()
                sendclientdebug(ply)
            end
        end)
    else
        sendclientdebug(ply)
    end
end)
