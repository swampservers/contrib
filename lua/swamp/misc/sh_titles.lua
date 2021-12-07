-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local Player = FindMetaTable("Player")

function Player:GetTitle()
    return self:GetNWString("title", "")
end

--NOMINIFY

Titles = {}
TitleRefreshDir = defaultdict(function() return {} end)


if SERVER then for k,v in pairs(player.GetAll()) do v.TitleCache=nil end end


local function num(p)
    if not isnumber(p) then p= p and 1 or 0 end
    return p
end

function AddTitle(thresholds, description, nwp_vars, progress_fn)

    local title = {}

    if isstring(thresholds) then
        thresholds = {[1]=thresholds}
    end
    local sorted_thresholds = {}
    for k,v in pairs(thresholds) do
        table.insert(sorted_thresholds, {k,v})
    end
    table.SortByMember(sorted_thresholds, 1, true)

    function title:Thresholds()
        local i,n = 0,#sorted_thresholds
        return function()
            i=i+1
            if i<=n then local v=sorted_thresholds[i] return v[1],v[2] end
        end
    end

    function title:Description(min)
        return description:format(min)
    end


    if isstring(nwp_vars) then
        nwp_vars = {nwp_vars}
    end

    progress_fn = progress_fn or function(ply)
        local p = 0
        for i,var in ipairs(nwp_vars) do
            p = p + num(ply.NWPrivate[var])
        end
        return p
    end

    function title:Progress(ply)
        return num(progress_fn(ply))
    end

    table.insert(Titles, title)
    
    for i,v in ipairs(nwp_vars) do
        table.insert(TitleRefreshDir[v], #Titles)
    end
end


AddTitle("Newfriend", "Test title", {}, function() return true end)

-- TODO add point rewards for reaching some?
AddTitle({[100]="Gift Giver",[1000]="Santa"}, "Give %s gifts (mystery boxes) to other players (NOT WORKING YET DONT COMPLAIN)", "s_giftgiver")

--todo: print who currently has the title?
AddTitle("Platinum Patriot", "Be the top donor to Donald Trump", "trump_patriot", function(ply) return ply.NWPrivate.trump_patriot==1 end)
AddTitle("Golden Patriot", "Be on Donald Trump's donation leaderboard", "trump_patriot", function(ply) return ply.NWPrivate.trump_patriot~=nil end)
AddTitle("Greatest Ally", "Be the top donor to Joe Biden", "biden_patriot", function(ply) return ply.NWPrivate.biden_patriot==1 end)
AddTitle("Ally", "Be on Joe Biden's donation leaderboard", "biden_patriot", function(ply) return ply.NWPrivate.biden_patriot~=nil end)
