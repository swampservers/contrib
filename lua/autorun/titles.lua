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
    return string.Explode(",",self:GetNWString("titles", ""))
end