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

math.power2 = math.nextpow2

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

--- Check if tables contain the same data, even if they are different tables (deep copy OK)
function table.Equal(a, b, epsilon)
    if istable(a) and istable(b) then
        if table.Count(a) ~= table.Count(b) then return false end

        for k, v in pairs(a) do
            if not table.Equal(v, rawget(b, k), epsilon) then return false end
        end

        return true
    elseif epsilon and isnumber(a) and isnumber(b) then
        return math.abs(a - b) < epsilon
    else
        return a == b
    end
end

--- Selects a range of an ordered table similar to string.sub
function table.sub(tab, startpos, endpos)
    local out = {}

    for i = startpos, endpos do
        table.insert(out, tab[i])
    end

    return out
end

function table.map(tab, func)
    local out = {}

    for k, v in pairs(tab) do
        out[k] = func(v)
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

-- remove if this is added to gmod
function table.GetValues(tab)
    local values = {}
    local id = 1

    for k, v in pairs(tab) do
        values[id] = v
        id = id + 1
    end

    return values
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
-- note: v[1] is a teeny bit faster than v.x
local vector = FindMetaTable("Vector")
local vec__baseadd = vec__baseadd or vector.__add
local vec__basesub = vec__basesub or vector.__sub
local vec__basediv = vec__basediv or vector.__div
local vec__baseNormalize = vec__baseNormalize or vector.Normalize

vector.__add = function(a, b)
    if isnumber(b) then
        return Vector(a[1] + b, a[2] + b, a[3] + b)
    else
        return vec__baseadd(a, b)
    end
end

vector.__sub = function(a, b)
    if isnumber(b) then
        return Vector(a[1] - b, a[2] - b, a[3] - b)
    else
        return vec__basesub(a, b)
    end
end

vector.__div = function(a, b)
    if isvector(b) then
        return Vector(a[1] / b[1], a[2] / b[2], a[3] / b[3])
    else
        return vec__basediv(a, b)
    end
end

function vector:Normalize()
    vec__baseNormalize(self)

    return self
end

function vector:Mean()
    return (self[1] + self[2] + self[3]) / 3
end

vector.MeanVal = vector.Mean

function vector:Pow(y)
    return Vector(math.pow(self[1], y), math.pow(self[2], y), math.pow(self[3], y))
end

function vector:Max(o)
    if isnumber(o) then return Vector(math.max(self[1], o), math.max(self[2], o), math.max(self[3], o)) end

    return Vector(math.max(self[1], o[1]), math.max(self[2], o[2]), math.max(self[3], o[3]))
end

function vector:Min(o)
    if isnumber(o) then return Vector(math.min(self[1], o), math.min(self[2], o), math.min(self[3], o)) end

    return Vector(math.min(self[1], o[1]), math.min(self[2], o[2]), math.min(self[3], o[3]))
end

function vector:Clamp(min, max)
    if isnumber(min) then return Vector(math.Clamp(self[1], min, max), math.Clamp(self[2], min, max), math.Clamp(self[3], min, max)) end

    return Vector(math.Clamp(self[1], min[1], max[1]), math.Clamp(self[2], min[2], max[2]), math.Clamp(self[3], min[3], max[3]))
end

function vector:MaxWith(o)
    if o[1] > self[1] then
        self[1] = o[1]
    end

    if o[2] > self[2] then
        self[2] = o[2]
    end

    if o[3] > self[3] then
        self[3] = o[3]
    end
end

function vector:MinWith(o)
    if o[1] < self[1] then
        self[1] = o[1]
    end

    if o[2] < self[2] then
        self[2] = o[2]
    end

    if o[3] < self[3] then
        self[3] = o[3]
    end
end

function vector:ClampWith(a, b)
    self:MaxWith(a)
    self:MinWith(b)
end

function vector:MaxVal()
    return math.max(self[1], self[2], self[3])
end

function vector:MinVal()
    return math.min(self[1], self[2], self[3])
end

function vector:InBox(vec1, vec2)
    return self[1] >= vec1[1] and self[1] <= vec2[1] and self[2] >= vec1[2] and self[2] <= vec2[2] and self[3] >= vec1[3] and self[3] <= vec2[3]
end

function vector:Print(round)
    round = round or 1
    local txt = ("Vector(%s, %s, %s)"):format(math.Round(self[1] / round) * round, math.Round(self[2] / round) * round, math.Round(self[3] / round) * round)
    SetClipboardText(txt)
    print(txt)
end

function vector:Approach(target, change)
    local delta = target - self
    local r2 = delta:LengthSqr()

    if r2 > change * change then
        self:Add((delta / math.sqrt(r2)) * change)
    else
        self:Set(target)
    end
end

local angle = FindMetaTable("Angle")

function angle:GetInverse()
    local m = Matrix()
    m:Rotate(self)
    m:Invert()

    return m:GetAngles()
end

local matrixscale = FindMetaTable("VMatrix").Scale

function ScaleMatrix(scale)
    local m = Matrix()
    matrixscale(m, isnumber(scale) and Vector(scale, scale, scale) or scale)

    return m
end

--NOMINIFY
-- COLOR
BLACK = Color(0, 0, 0, 255)
WHITE = Color(255, 255, 255, 255)

--- Returns a table such that when indexing the table, if the value doesn't exist, the constructor will be called with the key to initialize it.
-- function defaultdict(constructor, args)
--     assert(args==nil)
--     return setmetatable(args or {}, {
--         __index = function(tab, key)
--             local d = constructor(key)
--             tab[key] = d
--             return d
--         end,
--         __mode = mode
--     })
-- end
-- -- __mode = weak and "v" or nil
-- local memofunc = {
--     function(func)
--         return setmetatable({}, {
--             __index = function(tab, key)
--                 local d = func(key)
--                 tab[key] = d
--                 return d
--             end
--         })
--     end
-- }
-- for i=2,10 do
--     local nextmemo = memofunc[i-1]
--     memofunc[i] = function(func, weak)
--         return memo(function(arg) 
--             return nextmemo[funci(function(arg) return func(arg) end, weak)
--         end, weak)
--     end
-- end
function basememo(func, params)
    local init, meta = {}, {
        __index = function(tab, key)
            local d, out = func(key)

            if d == nil then
                return out
            else
                tab[key] = d

                return d
            end
        end
    }

    if params then
        for k, v in pairs(params) do
            if k == 1 then
                init = v
            else
                meta[k] = v
            end
        end
    end

    return setmetatable(init, meta)
end

-- note: stack will belong to callee
function multimemo(func, params, stack, limit)
    if #stack == limit - 1 then
        return basememo(function(arg)
            stack[limit] = arg

            return func(unpack(stack))
        end)
    else
        return basememo(function(arg)
            local i, childstack = 1, {}

            while stack[i] ~= nil do
                childstack[i] = stack[i]
                i = i + 1
            end

            childstack[i] = arg

            return multimemo(func, params, childstack, limit)
        end)
    end
end

--- Wraps a function with a cache to store computations when the same arguments are reused. Google: Memoization
-- The returned memo should be "called" by indexing it:
-- a = memo(function(x,y) return x*y end)
-- print(a[2][3]) --prints 6
-- If the function returns nil, nothing will be stored, and the second return value will be returned by the indexing.
-- params are extra things to put in the metatable (eg __mode), or index 1 can be a default initialization for the table
function memo(func, params)
    local limit = debug.getinfo(func, "u").nparams
    assert(params == nil or params.init == nil, "CHANGE INIT TO 1") -- TODO remove
    assert(params == nil or params[1] == nil or limit <= 1, "init only for single argument memo")
    local the_memo = limit <= 1 and basememo(func, params) or multimemo(func, params, {}, limit)
    -- getmetatable(the_memo).__call = function()

    return the_memo
end

local weakrefmeta = {
    __mode = "v",
    __call = function(t) return t[1] end
}

--- weak reference, call it to get the thing or nil if its gone
function weakref(value)
    return setmetatable({value}, weakrefmeta)
end

--- Global cache/generator for tables
-- Use to localize tables that can't be cleared on file refresh or have to sync in multiple files
-- local stuff = Table.MyWeaponStuff
Table = Table or memo(function() return {} end)
-- Table = memo(function(k) if not _G[k] then _G[k] = {} end assert(istable(_G[k])) return _G[k] end)

-- local test = memo(function(a,b,c) return a + b * c end)
-- print(test[1][2][3])
-- PrintTable(test)
function bit.packu32(i)
    return string.char(bit.band(bit.rshift(i, 24), 255), bit.band(bit.rshift(i, 16), 255), bit.band(bit.rshift(i, 8), 255), bit.band(i, 255))
end

function list2(tab)
    local list2meta = {
        Push = function(self, obj)
            local len = self.len + 1
            self[len] = obj
            self.len = len
        end,
        Pop = function(self)
            local len = self.len
            if self.len == 0 then return nil end
            local v = self[len]
            self[len] = nil
            self.len = len - 1

            return v
        end,
        Top = function(self)
            if self.len == 0 then return nil end

            return self[self.len]
        end
    }

    list2meta.__index = list2meta

    return setmetatable({
        len = 0
    }, list2meta)
end

function list3(tab)
    local len = 0

    local list3meta = {
        Push = function(self, obj)
            self[len] = obj
            len = len + 1
        end,
        Pop = function(self)
            local v = self[len]
            self[len] = nil

            if len > 0 then
                len = len - 1
            end

            return v
        end,
        Top = function(self) return self[len] end
    }

    list3meta.__index = list3meta

    return setmetatable({}, list3meta)
end

-- self[0] is faster than self.len ... TODO: try self[true]
local listmeta = {
    Append = function(self, obj)
        if obj == nil then return end
        local len = self[0] + 1
        self[len] = obj
        self[0] = len
    end,
    Push = function(self, obj)
        if obj == nil then return end
        local len = self[0] + 1
        self[len] = obj
        self[0] = len
    end,
    Pop = function(self)
        local len = self[0]
        if len == 0 then return nil end
        local v = self[len]
        self[len] = nil
        self[0] = len - 1

        return v
    end,
    Top = function(self)
        local len = self[0]
        if len == 0 then return nil end

        return self[len]
    end,
    Size = function(self) return self[0] end,
    Length = function(self) return self[0] end,
    Sort = function(self, comparator)
        table.sort(self, comparator)

        return self
    end,
    Extend = function(self, other)
        local len = self[0]

        for i, v in ipairs(other) do
            len = len + 1
            self[len] = v
        end

        self[0] = len

        return self
    end,
    Map = function(self, callback)
        local loss, len = 0, self[0]

        for i, v in ipairs(self) do
            v = callback(v)

            if v == nil then
                loss = loss + 1
            else
                self[i - loss] = v
            end
        end

        self[0] = len - loss
        len = self[0] + 1

        while self[len] ~= nil do
            self[len] = nil
            len = len + 1
        end

        return self
    end
}

listmeta.__index = listmeta

-- makes list() callable, its basically util stack but a little faster (and i wanted to make my own)
setmetatable(list, {
    __call = function(_list, tab)
        if tab then
            tab[0] = #tab
        else
            tab = {
                [0] = 0
            }
        end

        return setmetatable(tab, listmeta)
    end
})

-- calling sub(x, ...) instead of x:sub(...) is much faster (on windows at least). localizing is ideal but too much code pollution
sub = string.sub
local sub = sub

function startswith(x, prefix)
    return sub(x, 1, #prefix) == prefix
end

function endswith(x, suffix)
    return suffix == "" or sub(x, -#suffix) == suffix
end

-- if CLIENT then
-- for k,maker in pairs({
--     list=list,
--     -- list2=list2,
--     -- list3=list3,
--     -- stack=util.Stack
-- }) do
--     print(k, maker)
--     bench(function()
--         for i=1,1000 do
--             local stack = list()
--             for j=1,1000 do
--                 -- stack:Push(j)
--                 listmeta.Push(stack,j) 
--             end
--             stack:Filter(function(x) return x%2==0 end)
--         end
--     end)
-- end
-- end
-- local meta = getmetatable( "" )
-- function meta:__index( key )
-- 	local val = string[ key ]
-- 	if  val ~= nil  then
-- 		return val
-- 	elseif ( tonumber( key ) ) then
-- 		return self:sub( key, key )
-- 	end
-- end
-- local sub=string.sub 
-- SUB=string.sub
-- local function thing()
-- T=list() for i=1,5 do local x="" for i=1,1000 do x=x..(math.random()>0.5 and "." or "a") end T:Push(x) end
-- a,b,c,d,e = unpack(T)
-- print(table.concat(T, "/"))
-- -- return T
-- -- end
-- -- local t = {{{{{{{{{{{{}}}}}}}}}}}}
-- local sw = string.StartWith
-- local ss = string.sub
-- local sl = string.len
-- function sw3( String, Start )
-- 	return ss( String, 1, #Start ) == Start
-- end
-- bench({
-- --     metasub=  function() x=0 for i=1,1000000 do if T[i]:sub(1,1)=="." then x=x+1 end  end end ,
-- --     metaindex=  function() x=0 for i=1,1000000 do if T[i][1]=="." then x=x+1 end  end  end ,
-- -- --     -- ( function() x=0 T:Filter(function(v) if v[1]=="." then x=x+1 end return v end) end ),
-- -- --     glo=( function() x=0 thing():Filter(function(v) if SUB(v,1,1)=="." then x=x+1 end return v end) end ),
-- -- --     loc=( function() x=0 thing():Filter(function(v) if sub(v,1,1)=="." then x=x+1 end return v end) end ),
-- --     SUB =  function() x=0 for i=1,1000000 do if SUB(T[i],1,1)=="." then x=x+1 end  end  end ,
--     -- sw1 =  function() x=0 for i=1,1000000 do if T[i]:StartWith(".") then x=x+1 end  end end ,
--     sw2 =  function() x=0 for i=1,1000 do if a.."/"..b.."/"..c.."/"..d.."/"..e then x=x+1 end  end end ,
--     s =  function() x=0 for i=1,1000 do if table.concat(T, "/") then x=x+1 end  end end ,
-- -- --     -- ( function() x=0 T:Filter(function(v) if string.StartWith(v,".") then x=x+1 end return v end) end ),
-- -- --     -- ( function() x=0 T:Filter(function(v) if v:StartWith(".") then x=x+1 end return v end) end ),    
--     -- function() x=0 for i=1,1000000 do if t[1][1][1][1][1] then x=x+1 end end end,
--     -- function() x=0 local s=t[1][1][1][1][1] for i=1,1000000 do if s then x=x+1 end end end 
-- })
-- bench(function() x=0 T:Filter(function(v) if v[1]=="." then x=x+1 end return v end) end)
-- bench(function() x=0 T:Filter(function(v) if v[1]=="." then x=x+1 end return v end) end)
function GenerateKey()
    local c = {}

    for i = 1, 16 do
        c[i] = ("0123456789abcdefghijklmnopqrstuvwxyz")[math.random(36)]
    end

    c = table.concat(c, "")
    -- regenerate it if there aren't any letters

    return tonumber(c) and GenerateKey() or c
end
