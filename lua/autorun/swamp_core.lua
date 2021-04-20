-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- function For(tab, callback)
--     local out = {}
--     for k,v in pairs(tab) do
--         k,v = callback(k,v)
--         if k~=nil then
--             if v~=nil then
--                 out[k]=v
--             else
--                 table.insert(out,k)
--             end
--         end
--     end
--     return out
-- end
function For(tab, callback)
    local out = {}

    for _, v in ipairs(tab) do
        v = callback(v)

        if v ~= nil then
            table.insert(out, v)
        end
    end

    return out
end

local vec = FindMetaTable("Vector")
vec__baseadd = vec__baseadd or vec.__add
vec__basesub = vec__basesub or vec.__sub
vec__basediv = vec.__basediv or vec.__div

vec.__add = function(a, b)
    if isnumber(b) then
        return Vector(a.x + b, a.y + b, a.z + b)
    else
        return vec__baseadd(a, b)
    end
end

vec.__sub = function(a, b)
    if isnumber(b) then
        return Vector(a.x - b, a.y - b, a.z - b)
    else
        return vec__basesub(a, b)
    end
end

vec.__div = function(a, b)
    if isvector(b) then
        return Vector(a.x / b.x, a.y / b.y, a.z / b.z)
    else
        return vec__basediv(a, b)
    end
end

function vec:Mean()
    return (self.x + self.y + self.z) / 3
end

function vec:Pow(y)
    return Vector(math.pow(self.x, y), math.pow(self.y, y), math.pow(self.z, y))
end

-- WORKING SETGLOBAL* BECAUSE GARRYS VERSION UNSETS ITSELF RANDOMLY THANKS A LOT GARRY
glbls = glbls or {}

function GetG(k)
    return glbls[k]
end

if SERVER then
    util.AddNetworkString("Glbl")

    hook.Add("PlayerInitialSpawn", "globalsync", function(ply)
        net.Start("Glbl")
        net.WriteTable(glbls)
        net.Send(ply)
    end)

    timer.Create("KEEP IT REAL", 2, 0, function()
        local glblents = {}

        for k, v in pairs(glbls) do
            if isentity(v) then
                glblents[k] = v
            end
        end

        net.Start("Glbl", true)
        net.WriteTable(glblents)
        net.Broadcast()
    end)

    function SetG(k, v)
        net.Start("Glbl")

        net.WriteTable({
            [k] = v
        })

        net.Broadcast()
        glbls[k] = v
    end
else
    net.Receive("Glbl", function()
        local t = net.ReadTable()

        for k, v in pairs(t) do
            glbls[k] = v
        end
    end)
end