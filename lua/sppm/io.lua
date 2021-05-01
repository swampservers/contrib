-- This file is subject to copyright - contact swampservers@gmail.com for more information.
net.Receive("PonyCfg", function(len)
    local ply = net.ReadEntity()
    local cfg = net.ReadTable()
    PPM_SetPonyCfg(ply, cfg)
end)

net.Receive("PonyInvalidate", function(len)
    local ply = net.ReadEntity()
    ply.UpdatedPony = nil
end)

function PPM_Load(filename)
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

    PPM_SetPonyCfg(LocalPlayer(), SanitizePonyCfg(ponydata))
end

function PPM_Randomize()
    local ponydata = {}
    ponydata.kind = math.Round(math.Rand(1, 4))
    ponydata.gender = math.Round(math.Rand(1, 2))
    ponydata.body_type = 1
    ponydata.mane = math.Round(math.Rand(1, 15))
    ponydata.manel = math.Round(math.Rand(1, 12))
    ponydata.tail = math.Round(math.Rand(1, 14))
    ponydata.tailsize = math.Rand(0.8, 1)
    ponydata.eye = math.Round(math.Rand(1, EYES_COUNT))
    ponydata.eyelash = math.Round(math.Rand(1, 5))
    ponydata.coatcolor = Vector(math.Rand(0, 1), math.Rand(0, 1), math.Rand(0, 1))

    for I = 1, 6 do
        ponydata["haircolor" .. I] = Vector(math.Rand(0, 1), math.Rand(0, 1), math.Rand(0, 1))
    end

    for I = 1, 8 do
        ponydata["bodydetail" .. I] = 1
        ponydata["bodydetail" .. I .. "_c"] = Vector(0, 0, 0)
    end

    ponydata.cmark = math.Round(math.Rand(1, MARK_COUNT))
    ponydata.bodyweight = math.Rand(0.8, 1.2)
    ponydata.bodyt0 = 1 --math.Round(math.Rand(1,4)) 
    ponydata.bodyt1_color = Vector(math.Rand(0, 1), math.Rand(0, 1), math.Rand(0, 1))
    local iriscolor = Vector(math.Rand(0, 1), math.Rand(0, 1), math.Rand(0, 1)) * 2
    ponydata.eyecolor_bg = Vector(1, 1, 1)
    ponydata.eyeirissize = 0.7 + math.Rand(-0.1, 0.1)
    ponydata.eyecolor_iris = iriscolor
    ponydata.eyecolor_grad = iriscolor / 3
    ponydata.eyecolor_line1 = iriscolor * 0.9
    ponydata.eyecolor_line2 = iriscolor * 0.8
    ponydata.eyeholesize = 0.7 + math.Rand(-0.1, 0.1)
    ponydata.eyecolor_hole = Vector(0, 0, 0)
    -- TODO assert(ponydata == SanitizePonyCfg(ponydata))
    PPM_SetPonyCfg(LocalPlayer(), ponydata)
end

function PPM_Save(filename)
    local saveframe = {}

    for k, v in SortedPairs(LocalPlayer().ponydata) do
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

function ReloadCurrentPony()
    if (file.Exists("ppm/_current.txt", "DATA")) then
        PPM_Load("_current.txt")
    else
        PPM_Randomize()
    end

    SendLocalPonyCfg()
end

hook.Add("Think", "PPM_Loader", function()
    -- and LocalPlayer():IsPPMPony() then --disabled so it appears in shop
    if IsValid(LocalPlayer()) then
        ReloadCurrentPony()
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