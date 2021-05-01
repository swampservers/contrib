-- This file is subject to copyright - contact swampservers@gmail.com for more information.
net.Receive("PonyCfg", function(len)
    local ply = net.ReadEntity()
    local cfg = net.ReadTable()
    PPM_SetPonyCfg(ply, cfg)
end)

net.Receive("PonyInvalidate", function(len)
    local ply = net.ReadEntity()
    ply.OutdatedPony = true
end)

function PPM.Load(filename)
    local str = file.Read("data/ppm/" .. filename, "GAME")
    local lines = string.Split(str, "\n")
    local ponydata = {}

    for k, v in pairs(lines) do
        local args = string.Split(string.Trim(v), " ")
        local name = string.Replace(args[1], "pny_", "")

        if (table.Count(args) == 2) then
            ponydata[name] = tonumber(args[2])
        elseif (table.Count(args) == 4) then
            ponydata[name] = Vector(tonumber(args[2]), tonumber(args[3]), tonumber(args[4]))
        elseif (table.Count(args) == 3) then
            if args[2] == "b" then
                ponydata[name] = tobool(args[3])
            elseif args[2] == "s" then
                ponydata[name] = args[3]
            end
        end
    end

    return ponydata
end

function PPM.Save(filename, ponydata)
    local saveframe = {}

    for k, v in SortedPairs(ponydata) do
        if type(v) == "number" then
            table.insert(saveframe, "\n " .. k .. " " .. tostring(v))
        elseif type(v) == "Vector" then
            table.insert(saveframe, "\n " .. k .. " " .. tostring(v))
        elseif type(v) == "boolean" then
            table.insert(saveframe, "\n " .. k .. " b " .. tostring(v))
        elseif type(v) == "string" then
            table.insert(saveframe, "\n " .. k .. " s " .. string.Replace(v, " ", ""))
        end
    end

    saveframe = table.concat(saveframe)

    if not string.EndsWith(filename, ".txt") then
        filename = filename .. ".txt"
    end

    if not file.Exists("ppm", "DATA") then
        file.CreateDir("ppm")
    end

    MsgN("saving .... " .. "ppm/" .. filename)
    file.Write("ppm/" .. filename, saveframe)
end

hook.Add("Think", "PPM_Loader", function()
    if IsValid(LocalPlayer()) then
        if (file.Exists("ppm/_current.txt", "DATA")) then
            PPM_SetPonyCfg(LocalPlayer(), PPM.Load("_current.txt"))
        else
            PPM.randomizePony(LocalPlayer())
        end

        SendLocalPonyCfg()
        hook.Remove("Think", "PPM_Loader")
    end
end)

function SendLocalPonyCfg()
    local tab = LocalPlayer().ponydata
    assert(istable(tab))
    -- if not istable(tbl) then return end
    -- if (delays > CurTime()) then return end
    -- delays = CurTime() + 3
    -- local json = util.TableToJSON(tbl)
    -- local comp = util.Compress(json)
    -- PPM.SentPonyData = comp
    -- local length = #comp
    net.Start("PonyCfg")
    -- net.WriteData(comp, length)
    net.WriteTable(tab)
    net.SendToServer()
end