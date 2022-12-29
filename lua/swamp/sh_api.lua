-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local string_len = string.len
local ReadBool, WriteBool = net.ReadBool, net.WriteBool
local ReadData, WriteData = net.ReadData, net.WriteData
local ReadInt, WriteInt = net.ReadInt, net.WriteInt
local ReadUInt, WriteUInt = net.ReadUInt, net.WriteUInt

function net.ReadLength()
    local l = ReadUInt(8)

    return l < 254 and l or ReadUInt(l == 254 and 16 or 32)
end

function net.WriteLength(v)
    if v >= 254 then
        if v <= 65535 then
            WriteUInt(254, 8)
            WriteUInt(v, 16)
        else
            WriteUInt(255, 8)
            WriteUInt(v, 32)
        end
    else
        WriteUInt(v, 8)
    end
end

local ReadLength, WriteLength = net.ReadLength, net.WriteLength
local ReadFloat, WriteFloat = net.ReadFloat, net.WriteFloat
local ReadDouble, WriteDouble = net.ReadDouble, net.WriteDouble
local ReadString, WriteString = net.ReadString, net.WriteString

--NOMINIFY
-- TODO: check if having non byte aligned stuff matters for performance
-- will be uints from 0 to numvals-1
local function bitsneeded(numvals)
    return math.ceil(math.log(numvals) / math.log(2))
end

-- bidirectional mapping for NetworkStrings and IDs
API_NetworkStringCache = setmetatable({}, {
    __index = function(tab, key)
        local d

        if isnumber(key) then
            d = util.NetworkIDToString(key)
        else
            d = util.NetworkStringToID(key)

            if d == 0 then
                d = nil
            end
        end

        tab[key] = d

        return d
    end
})

API_UnfinishedNetworkStrings = {}

function API_Int(bits)
    return {
        function() return ReadInt(bits) end, function(v)
            WriteInt(v, bits)
        end
    }
end

function API_UInt(bits)
    return {
        function() return ReadUInt(bits) end, function(v)
            WriteUInt(v, bits)
        end
    }
end

function API_Constant(value)
    return {isfunction(value) and value or function() return value end, function(v) end}
end

API_NIL = API_Constant(nil)
API_FALSE = API_Constant(false)
API_TRUE = API_Constant(true)
API_ZERO = API_Constant(0)
API_ONE = API_Constant(1)
API_EMPTYTABLE = API_Constant(function() return {} end)

API_BOOL = {net.ReadBool, net.WriteBool}

API_FLOAT = {net.ReadFloat, net.WriteFloat}

API_DOUBLE = {net.ReadDouble, net.WriteDouble}

API_INT8, API_INT16, API_INT32 = API_Int(8), API_Int(16), API_Int(32)
API_UINT8, API_UINT16, API_UINT32 = API_UInt(8), API_UInt(16), API_UInt(32)

API_LENGTH = {net.ReadLength, net.WriteLength}

API_NT_STRING = {net.ReadString, net.WriteString}

function net.ReadBinaryString()
    return net.ReadData(net.ReadLength())
end

function net.WriteBinaryString(v)
    local l = string_len(v)
    net.WriteLength(l)
    net.WriteData(v, l)
end

API_BINARY_STRING = {net.ReadBinaryString, net.WriteBinaryString}

API_STRING = API_BINARY_STRING

function net.ReadNetworkString()
    local id = ReadUInt(12)

    if id == 0 then
        return nil
    elseif id == 4095 then
        return ReadString()
    else
        local st = API_NetworkStringCache[id]

        if st == nil then
            ErrorNoHaltWithStack("Unknown network string! " .. id)

            return "UNKNOWN"
        end

        return st
    end
end

function net.WriteNetworkString(v)
    if v == nil then
        WriteUInt(0, 12)

        return
    end

    assert(isstring(v))
    local id = API_NetworkStringCache[v]

    if SERVER then
        if not id then
            util.AddNetworkString(v)
            id = API_NetworkStringCache[v]
            assert(id)
            -- send the full string for 10 sec until the id gets pooled (1 sec wasnt enough at loading time!)
            -- print("POOLING", id)
            API_UnfinishedNetworkStrings[id] = true

            timer.Simple(10, function()
                API_UnfinishedNetworkStrings[id] = nil
            end)
        end

        if API_UnfinishedNetworkStrings[id] then
            WriteUInt(4095, 12)
            WriteString(v)
        else
            WriteUInt(id, 12)
        end
    else
        if not id then
            ErrorNoHaltWithStack("No Network String ID! " .. v)
            id = 0
        end

        WriteUInt(id, 12)
    end
end

API_NETWORK_STRING = {net.ReadNetworkString, net.WriteNetworkString}

API_VECTOR = {
    function() return Vector(ReadFloat(), ReadFloat(), ReadFloat()) end, function(v)
        WriteFloat(v[1])
        WriteFloat(v[2])
        WriteFloat(v[3])
    end
}

API_COMP_VECTOR = {net.ReadVector, net.WriteVector}

API_ANGLE = {
    function() return Angle(ReadFloat(), ReadFloat(), ReadFloat()) end, function(v)
        WriteFloat(v[1])
        WriteFloat(v[2])
        WriteFloat(v[3])
    end
}

API_COMP_ANGLE = {net.ReadAngle, net.WriteAngle}

API_ENTITY = {net.ReadEntity, net.WriteEntity}

API_COLOR = {net.ReadColor, net.WriteColor}

local any_id_bits = 4

local any_id_reader = {
    [0] = API_NIL[1],
    API_TRUE[1], API_FALSE[1], API_UINT8[1], API_DOUBLE[1], API_STRING[1], API_NETWORK_STRING[1], API_VECTOR[1], API_ANGLE[1], API_ENTITY[1], API_COLOR[1]
}

local any_type_writers = {
    ["nil"] = function(v)
        WriteUInt(0, any_id_bits)
    end,
    boolean = function(v)
        WriteUInt(v and 1 or 2, any_id_bits)
    end,
    number = function(v)
        if math.floor(v) == v and v >= 0 and v <= 255 then
            WriteUInt(3, any_id_bits)
            WriteUInt(v, 8)
        else
            WriteUInt(4, any_id_bits)
            WriteDouble(v, 8)
        end
    end,
    string = function(v)
        -- capitalization issue with network strings
        WriteUInt(5, any_id_bits)
        API_STRING[2](v)
    end,
    Vector = function(v)
        WriteUInt(7, any_id_bits)
        API_VECTOR[2](v)
    end,
    Angle = function(v)
        WriteUInt(8, any_id_bits)
        API_ANGLE[2](v)
    end,
    Entity = function(v)
        WriteUInt(9, any_id_bits)
        API_ENTITY[2](v)
    end,
}

any_type_writers.Player = any_type_writers.Entity

function net.ReadAny()
    return any_id_reader[ReadUInt(any_id_bits)]()
end

function net.WriteAny(v)
    return any_type_writers[type(v)](v)
end

API_ANY = {net.ReadAny, net.WriteAny}

function API_Dict(key_type, value_type)
    read_key, write_key = unpack(key_type or API_ANY)
    read_value, write_value = unpack(value_type or API_ANY)

    return {
        function()
            local out, nvals = {}, ReadLength()

            for i = 1, nvals do
                local k = read_key()
                out[k] = read_value()
            end

            return out
        end,
        function(val)
            WriteLength(table.Count(val))

            for k, v in pairs(val) do
                write_key(k)
                write_value(v)
            end
        end
    }
end

API_TABLE = API_Dict()
any_id_reader[11] = API_TABLE[1]

any_type_writers.table = function(v)
    if IsColor(v) then
        WriteUInt(10, any_id_bits)
        API_COLOR[2](v)
    else
        WriteUInt(11, any_id_bits)
        API_TABLE[2](v)
    end
end

function API_Struct(...)
    local readers, writers = {}, {}

    for i, v in ipairs({...}) do
        readers[i], writers[i] = v[1], v[2]
    end

    return {
        function()
            local out = {}

            for i, reader in ipairs(readers) do
                out[i] = reader()
            end

            return out
        end,
        function(v)
            for i, writer in ipairs(writers) do
                writer(v[i])
            end
        end,
    }
end

function API_List(value_type)
    local read_value, write_value = unpack(value_type or API_ANY)

    return {
        function()
            local out, nvals = {}, ReadLength()

            for i = 1, nvals do
                out[i] = read_value()
            end

            return out
        end,
        function(v)
            local nvals = #v
            WriteLength(nvals)

            for i = 1, nvals do
                write_value(v[i])
            end
        end
    }
end

API_LIST = API_List()

function API_Set(key_type)
    return API_Dict(key_type or API_ANY, API_TRUE)
end

API_PLAYER = {
    function()
        local ply = net.ReadEntity()
        assert(IsValid(ply) and ply:IsPlayer())

        return ply
    end,
    net.WriteEntity
}

-- NOTE: args will be a table: 
-- {argtype1, argtype2, unreliable=bool, ???}
-- if there are zero positional arguments, it is vararg. if you really want an empty command just make 1 arg API_NIL
-- parse argtypes and align parameters (argtypes is table, handler is function, unreliable is bool)
function API_HandlerArgs(args, handler)
    if not istable(args) then
        args, handler = {}, args
    end

    local function rw_vararg(r, w)
        return function() return unpack(r()) end, function(...)
            w({...})
        end
    end

    if not args[1] then
        args[1], args[2] = rw_vararg(unpack(API_List(API_ANY)))
    elseif istable(args[1]) then
        args[1], args[2] = rw_vararg(unpack(API_Struct(unpack(args))))
    else
        assert(isfunction(args[1]) and isfunction(args[2]))
    end

    args.unreliable = args.unreliable or false

    return args, handler
end

if CLIENT then
    --- Register a function which is called on the server and executed on the client. See this file for details.
    function API_Command(name, args, handler)
        args, handler = API_HandlerArgs(args, handler)
        local reader = args[1]

        net.Receive(name, function()
            handler(reader())
        end)
    end

    local net_Start, net_SendToServer = net.Start, net.SendToServer

    function API_Request(name, args, handler)
        args, handler = API_HandlerArgs(args, handler)
        local writer, unreliable, on_request = args[2], args.unreliable, args.OnRequest

        _G["Request" .. name] = function(...)
            if on_request then
                on_request(...)
            end

            net_Start(name, unreliable)
            writer(...)
            net_SendToServer()
        end
    end
end
-- -- TODO: union containing inner union within types could be collapsed
-- function API_Union(types, selector)
--     assert(istable(types) and isfunction(selector))
--     local readers, writers = {},{}
--     for i,v in ipairs(types) do readers[i-1],writers[i-1] = v[1],v[2] end
--     local readtype,writetype = unpack( API_UInt(bitsneeded(#types)) )
--     return {
--         function()
--             return readers[readtype()]()
--         end,
--         function(v)
--             local sel = selector(v)-1
--             writetype(sel)
--             writers[sel](v)
--         end
--     }    
-- end
-- function API_Optional(typ)
--     return API_Union({API_NIL, typ}, function(v) return v==nil and 1 or 2 end)
-- end
