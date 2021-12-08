-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local function CreateLayeredProperty(getter, setter, id_argument, additive, default)
    local basedgetter, basedsetter = "Based" .. getter, "Based" .. setter
    -- currently unused, getter just uses the accumulated value
    Player[basedgetter] = Player[basedgetter] or Player[getter]
    Player[basedsetter] = Player[basedsetter] or Player[setter]
    local settable = setter .. "Tab"

    local accumulate = additive and (function(t)
        local v
        local k, accum = next(t)

        while true do
            k, v = next(t, k)
            if not k then break end
            accum = accum + v
        end

        return accum
    end) or (function(t)
        local v
        local k, accum = next(t)

        while true do
            k, v = next(t, k)
            if not k then break end
            accum = accum * v
        end

        return accum
    end)

    Player[setter] = id_argument and (function(self, id, val, key)
        local s = self[settable]

        if not s then
            s = {}
            self[settable] = s
        end

        local t = s[id]

        if not t then
            t = {}
            s[id] = t
        end

        key = key or ""

        if key ~= "" then
            if not t[""] then
                t[""] = self[basedgetter](self, id)
            end

            if val == default then
                val = nil
            end
        end

        t[key] = val
        self[basedsetter](self, id, accumulate(t))
    end) or (function(self, val, key)
        local t = self[settable]

        if not t then
            t = {}
            self[settable] = t
        end

        key = key or ""

        if key ~= "" then
            if not t[""] then
                t[""] = self[basedgetter](self)
            end

            if val == default then
                val = nil
            end
        end

        t[key] = val
        self[basedsetter](self, accumulate(t))
    end)
end

Player.GetManipulateBonePosition = Entity.GetManipulateBonePosition
Player.ManipulateBonePosition = Entity.ManipulateBonePosition
Player.GetManipulateBoneAngles = Entity.GetManipulateBoneAngles
Player.ManipulateBoneAngles = Entity.ManipulateBoneAngles
Player.GetManipulateBoneScale = Entity.GetManipulateBoneScale
Player.ManipulateBoneScale = Entity.ManipulateBoneScale
CreateLayeredProperty("GetSlowWalkSpeed", "SetSlowWalkSpeed", false, false, 1)
CreateLayeredProperty("GetWalkSpeed", "SetWalkSpeed", false, false, 1)
CreateLayeredProperty("GetRunSpeed", "SetRunSpeed", false, false, 1)
CreateLayeredProperty("GetManipulateBonePosition", "ManipulateBonePosition", true, true, Vector(0, 0, 0))
CreateLayeredProperty("GetManipulateBoneAngles", "ManipulateBoneAngles", true, true, Angle(0, 0, 0))
CreateLayeredProperty("GetManipulateBoneScale", "ManipulateBoneScale", true, false, Vector(1, 1, 1))
