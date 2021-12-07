-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- GLOBAL
local Player = FindMetaTable("Player")

-- Titles = {
--     patriot1 = "Platinum Patriot",
--     patriot = "Golden Patriot",
--     ally1 = "Greatest Ally",
--     ally = "Ally"
-- }
function Player:GetTitle()
    return self:GetNWString("title", "")
end

-- todo dont network globally
function Player:GetTitles()
    return string.Explode(",", self:GetNWString("titles", ""))
end


Titles = {}

function AddTitle(thresholds, description, progress_fn)

    local t_sorted = {}
    for k,v in pairs(thresholds) do
        table.insert(t_sorted, {k,v})
    end
    table.SortByMember(t_sorted, 1, true)

    if isstring(progress_fn) then
        local name = progress_fn
        if name:StartWith("st_") then
            name = name:sub(4)
        
            progress_fn = function(ply)
                return ply:GetStat(name)
            end
        else
            assert(false)
        end
    end

    table.insert(Titles, {thresholds=t_sorted,description=description,progress_fn=progress_fn})
end

AddTitle({[100]="Gift Giver"}, "Give %s gifts (mystery boxes) to other players", "st_giftgiver")
