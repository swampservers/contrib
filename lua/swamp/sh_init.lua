--- Global cache/generator for tables
-- Use to localize tables that can't be cleared on file refresh or have to sync in multiple files
-- local stuff = Table.MyWeaponStuff
Table = Table or setmetatable({}, {
    __index = function(t, k)
        t[k] = {}

        return t[k]
    end
})

-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local corefiles, _ = file.Find("swamp/_core/*.lua", "LUA")

for _, f in ipairs(corefiles) do
    f = "_core/" .. f
    include(f)

    if SERVER then
        AddCSLuaFile(f)
    end
end

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
local weakrefmeta = {
    __mode = "v",
    __call = function(t) return t[1] end
}

--- weak reference, call it to get the thing or nil if its gone
function weakref(value)
    return setmetatable({value}, weakrefmeta)
end

WeakRef = weakref

-- Table = memo(function(k) if not _G[k] then _G[k] = {} end assert(istable(_G[k])) return _G[k] end)
-- local test = memo(function(a,b,c) return a + b * c end)
-- print(test[1][2][3])
-- PrintTable(test)
function bit.packu32(i)
    return string.char(bit.band(bit.rshift(i, 24), 255), bit.band(bit.rshift(i, 16), 255), bit.band(bit.rshift(i, 8), 255), bit.band(i, 255))
end

-- calling sub(x, ...) instead of x:sub(...) is much faster (on windows at least). localizing is ideal but too much code pollution
sub = string.sub
local sub = sub

function startswith(x, prefix)
    return sub(x, 1, #prefix) == prefix
end

function endswith(x, suffix)
    return suffix == "" or sub(x, -#suffix) == suffix
end
