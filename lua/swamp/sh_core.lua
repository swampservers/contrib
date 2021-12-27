-- This file is subject to copyright - contact swampservers@gmail.com for more information.
--- Shorthand for empty function
function noop()
end

--- Just calls the function with the args
function call(func, ...)
    func(...)
end

--- Shorthand timer.Simple(0, callback) and also passes args
function call_async(callback, ...)
    local arg = {...}

    timer.Simple(0, function()
        callback(unpack(arg))
    end)
end

--- Calls the function and if it fails, calls catch (default: ErrorNoHaltWithStack) with the error. Doesn't return anything
function try(func, catch)
    local succ, err = pcall(func)

    if not succ then
        (catch or ErrorNoHaltWithStack)(err)
    end
end

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

--- Returns next power of 2 >= n
function math.nextpow2(n)
    return math.pow(2, math.ceil(math.log(n) / math.log(2)))
end

math.power2 = math.power2

--- Convert an ordered table {a,b,c} into a set {[a]=true,[b]=true,[c]=true}
function table.Set(tab)
    local s = {}

    for i, v in ipairs(tab) do
        s[v] = true
    end

    return s
end

--- Convert a table of {k=v} to {v=k}
function table.Inverse(tab)
    local s = {}

    for k, v in pairs(tab) do
        s[v] = k
    end

    return s
end

--- Copy table at the first layer only
function table.ShallowCopy(tab)
    local s = {}

    for k, v in pairs(tab) do
        s[k] = v
    end

    return s
end

--- Selects a range of an ordered table similar to string.sub
function table.sub(tab, startpos, endpos)
    local out = {}

    for i = startpos, endpos do
        table.insert(out, tab[i])
    end

    return out
end

function table.ireduce(tab, func)
    local out = nil

    for i, v in ipairs(tab) do
        if out == nil then
            out = v
        else
            out = func(out, v)
        end
    end

    return out
end

--- Sums an ordered table.
function table.isum(tab)
    return table.ireduce(tab, function(a, b) return a + b end)
end

--- Selects the maximum value of an ordered table. See also: table.imin
function table.imax(tab)
    return table.ireduce(tab, math.max)
end

function table.imin(tab)
    return table.ireduce(tab, math.min)
end

local function sortedindex(tab, val, a, b)
    if a >= b then
        assert(a == 0 or tab[a] <= val)
        assert(a == #tab or tab[a + 1] > val)

        return a
    end

    local mid = math.floor((a + b + 1) / 2)

    if tab[mid] <= val then
        return sortedindex(tab, val, mid, b)
    else
        return sortedindex(tab, val, a, mid - 1)
    end
end

--- Returns the largest index such that tab[index] > val (or is the end)
function table.SortedInsertIndex(tab, val)
    return sortedindex(tab, val, 0, #tab) + 1
end

-- function table.repeated(val,n)
--     local out = {}
--     for i=1,n do
--         table.insert(out, val)
--     end
--     return out  
-- end
local vector = FindMetaTable("Vector")
local vec__baseadd = vec__baseadd or vector.__add
local vec__basesub = vec__basesub or vector.__sub
local vec__basediv = vec__basediv or vector.__div
local vec__baseNormalize = vec__baseNormalize or vector.Normalize

vector.__add = function(a, b)
    if isnumber(b) then
        return Vector(a.x + b, a.y + b, a.z + b)
    else
        return vec__baseadd(a, b)
    end
end

vector.__sub = function(a, b)
    if isnumber(b) then
        return Vector(a.x - b, a.y - b, a.z - b)
    else
        return vec__basesub(a, b)
    end
end

vector.__div = function(a, b)
    if isvector(b) then
        return Vector(a.x / b.x, a.y / b.y, a.z / b.z)
    else
        return vec__basediv(a, b)
    end
end

function vector:Normalize()
    vec__baseNormalize(self)

    return self
end

function vector:Mean()
    return (self.x + self.y + self.z) / 3
end

function vector:Pow(y)
    return Vector(math.pow(self.x, y), math.pow(self.y, y), math.pow(self.z, y))
end

function vector:Max(o)
    if isnumber(o) then return Vector(math.max(self.x, o), math.max(self.y, o), math.max(self.z, o)) end
    return Vector(math.max(self.x, o.x), math.max(self.y, o.y), math.max(self.z, o.z))
end

function vector:Min(o)
    if isnumber(o) then return Vector(math.min(self.x, o), math.min(self.y, o), math.min(self.z, o)) end
    return Vector(math.min(self.x, o.x), math.min(self.y, o.y), math.min(self.z, o.z))
end

function vector:Clamp(min, max)
    if isnumber(min) then return Vector(math.Clamp(self.x, min, max), math.Clamp(self.y, min, max), math.Clamp(self.z, min, max)) end
    return Vector(math.Clamp(self.x, min.x, max.x), math.Clamp(self.y, min.y, max.y), math.Clamp(self.z, min.z, max.z))
end

function vector:InBox(vec1, vec2)
    return self.x >= vec1.x and self.x <= vec2.x and self.y >= vec1.y and self.y <= vec2.y and self.z >= vec1.z and self.z <= vec2.z
end

function vector:Print(round)
    round = round or 1
    local txt = ("Vector(%s, %s, %s)"):format(math.Round(self.x / round) * round, math.Round(self.y / round) * round, math.Round(self.z / round) * round)
    SetClipboardText(txt)
    print(txt)
end

-- COLOR
BLACK = Color(0, 0, 0, 255)
WHITE = Color(255, 255, 255, 255)

--- Returns a table such that when indexing the table, if the value doesn't exist, the constructor will be called with the key to initialize it.
function defaultdict(constructor)
    return setmetatable({}, {
        __index = function(tab, key)
            local d = constructor(key)
            tab[key] = d

            return d
        end
    })
end

function bit.packu32(i)
    return string.char(bit.band(bit.rshift(i, 24), 255), bit.band(bit.rshift(i, 16), 255), bit.band(bit.rshift(i, 8), 255), bit.band(i, 255))
end
