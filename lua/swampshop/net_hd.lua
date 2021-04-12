-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
--sendtable with higher bit vectors/angles
AddCSLuaFile()

function net.WriteVectorHD(vec)
    net.WriteFloat(vec.x)
    net.WriteFloat(vec.y)
    net.WriteFloat(vec.z)
end

function net.ReadVectorHD()
    local x = net.ReadFloat()
    local y = net.ReadFloat()
    local z = net.ReadFloat()

    return Vector(x, y, z)
end

function net.WriteAngleHD(vec)
    net.WriteFloat(vec.p)
    net.WriteFloat(vec.y)
    net.WriteFloat(vec.r)
end

function net.ReadAngleHD()
    local x = net.ReadFloat()
    local y = net.ReadFloat()
    local z = net.ReadFloat()

    return Angle(x, y, z)
end

function net.WriteTableHD(tab)
    for k, v in pairs(tab) do
        net.WriteTypeHD(k)
        net.WriteTypeHD(v)
    end

    -- End of table
    net.WriteTypeHD(nil)
end

function net.ReadTableHD()
    local tab = {}

    while true do
        local k = net.ReadTypeHD()
        if (k == nil) then return tab end
        tab[k] = net.ReadTypeHD()
    end
end

net.WriteVarsHD = {
    [TYPE_NIL] = function(t, v)
        net.WriteUInt(t, 8)
    end,
    [TYPE_STRING] = function(t, v)
        net.WriteUInt(t, 8)
        net.WriteString(v)
    end,
    [TYPE_NUMBER] = function(t, v)
        net.WriteUInt(t, 8)
        net.WriteDouble(v)
    end,
    [TYPE_TABLE] = function(t, v)
        net.WriteUInt(t, 8)
        net.WriteTableHD(v)
    end,
    [TYPE_BOOL] = function(t, v)
        net.WriteUInt(t, 8)
        net.WriteBool(v)
    end,
    [TYPE_ENTITY] = function(t, v)
        net.WriteUInt(t, 8)
        net.WriteEntity(v)
    end,
    [TYPE_VECTOR] = function(t, v)
        net.WriteUInt(t, 8)
        net.WriteVectorHD(v)
    end,
    [TYPE_ANGLE] = function(t, v)
        net.WriteUInt(t, 8)
        net.WriteAngleHD(v)
    end,
    [TYPE_MATRIX] = function(t, v)
        net.WriteUInt(t, 8)
        net.WriteMatrix(v)
    end,
    [TYPE_COLOR] = function(t, v)
        net.WriteUInt(t, 8)
        net.WriteColor(v)
    end,
}

function net.WriteTypeHD(v)
    local typeid = nil

    if IsColor(v) then
        typeid = TYPE_COLOR
    else
        typeid = TypeID(v)
    end

    local wv = net.WriteVarsHD[typeid]
    if (wv) then return wv(typeid, v) end
    error("net.WriteType: Couldn't write " .. type(v) .. " (type " .. typeid .. ")")
end

net.ReadVarsHD = {
    [TYPE_NIL] = function() return nil end,
    [TYPE_STRING] = function() return net.ReadString() end,
    [TYPE_NUMBER] = function() return net.ReadDouble() end,
    [TYPE_TABLE] = function() return net.ReadTableHD() end,
    [TYPE_BOOL] = function() return net.ReadBool() end,
    [TYPE_ENTITY] = function() return net.ReadEntity() end,
    [TYPE_VECTOR] = function() return net.ReadVectorHD() end,
    [TYPE_ANGLE] = function() return net.ReadAngleHD() end,
    [TYPE_MATRIX] = function() return net.ReadMatrix() end,
    [TYPE_COLOR] = function() return net.ReadColor() end,
}

function net.ReadTypeHD(typeid)
    typeid = typeid or net.ReadUInt(8)
    local rv = net.ReadVarsHD[typeid]
    if (rv) then return rv() end
    error("net.ReadType: Couldn't read type " .. typeid)
end