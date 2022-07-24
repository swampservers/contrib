﻿-- This file is subject to copyright - contact swampservers@gmail.com for more information.
--- Return player's actual Steam name without any filters (eg removing swamp.sv). All default name functions have filters.
--- function Player:TrueName()
Player.TrueName = Player.TrueName or Player.Nick
local decor_pattern = "[%[%]%{%}%(%)%<%>%-%|%=% ]+"

-- todo: create memo() which is like this but uses call interface and takes multiple args (memoization)
local advertpattern = memo(function(advert)
    local pat = {decor_pattern}

    for i = 1, #advert do
        local ch = advert[i]

        if ch == "." then
            table.insert(pat, "%.")
        else
            table.insert(pat, "[" .. ch:upper() .. ch .. "]")
        end
    end

    table.insert(pat, decor_pattern)

    return table.concat(pat, "")
end)

function StripNameAdvert(name, advert)
    local n2, replaces = (" " .. name .. " "):gsub(advertpattern[advert], "")
    n2 = n2:Trim()

    if replaces > 0 and advert == "DADG" then
        n2 = "🐾" .. n2 .. "🐾"
    end

    if #n2 < 2 then return name end

    return n2
end

function Player:ComputeName()
    if self:IsBot() then return "Kleiner" end
    local tn = self:TrueName()
    tn = StripNameAdvert(tn, "swamp.sv")
    tn = StripNameAdvert(tn, "sups.gg")
    tn = StripNameAdvert(tn, "moat.gg") --lol rip
    tn = StripNameAdvert(tn, "velk.ca")

    if tn:find("DADG") then
        tn = tn:gsub("DADG", "FURRY")
    end

    return tn
end

function Player:Name()
    if self:TrueName() ~= self.LastTrueName then
        self.NameCache = self:ComputeName()
        self.LastTrueName = self:TrueName()
    end

    return self.NameCache
end

Player.Nick = Player.Name
Player.GetName = Player.Name
