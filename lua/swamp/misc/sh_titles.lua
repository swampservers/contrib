-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local Player = FindMetaTable("Player")

function Player:GetTitle()
    return self:GetNWString("title", "")
end

--NOMINIFY

Titles = {}
TitleRefreshDir = defaultdict(function() return {} end)


if SERVER then for k,v in pairs(player.GetAll()) do v.TitleCache=nil end end


function AddTitle(reward_id, thresholds, description, nwp_vars, progress_fn)

    local title = {}

    if isstring(thresholds) then
        thresholds = {{1, thresholds}}
    end

    function title:Thresholds()
        local i,n = 0,#thresholds
        return function()
            i=i+1
            if i<=n then local v=thresholds[i] return i,v[1],v[2],(v[3] or 0) end
        end
    end

    function title:Description(min)
        return description:format(min)
    end

    if isstring(nwp_vars) then
        nwp_vars = {nwp_vars}
    end

    local function num(p)
        if not isnumber(p) then p= p and 1 or 0 end
        return p
    end

    progress_fn = progress_fn or function(ply)
        local p = 0
        for i,var in ipairs(nwp_vars) do
            p = p + num(ply.NWPrivate[var])
        end
        return p
    end

    function title:Progress(ply)
        local p = num(progress_fn(ply))

        if SERVER and reward_id~="" then
            local r = 0
            local t = nil
            for i,min,name,reward in self:Thresholds() do
                if min>p then break end
                t = name
                r = r + reward
            end
            ply:PointsReward(reward_id, r, "unlocking the title: "..t)
        end

        return p
    end

    table.insert(Titles, title)
    
    for i,v in ipairs(nwp_vars) do
        table.insert(TitleRefreshDir[v], #Titles)
    end
end

--AddTitle(reward_id, thresholds, description, nwpvars, progressfn)
--reward_id: string to identify points given for this sequence, use empty string if there are no rewards
--thresholds: {{progress1, title1, reward1}, {progress2, title2, reward2}} rewards are optional
--description: string which can be formatted with the threshold for the next target
--nwp_vars: var or list of vars that are used to calculate progress, so when they change the server can strip the title if necessary
--progress_fn: optional function to compute progess, defaults to summing nwp vars

AddTitle("", "Newfriend", "Welcome to the Swamp", {}, function() return true end)

AddTitle("", {{100, "Gift Giver"},{1000, "Santa"}}, "Give %s gifts (mystery boxes) to other players", "s_giftgiver")

AddTitle("garfield", {{200, "Chonkers", 10000}, {1000, "Fat Cat", 100000}, {10000, "I Eat, Jon.", 1000000}}, "Become Garfield and grow to weigh at least %s pounds", "s_garfield")

--todo: print who currently has the title?
AddTitle("", "Platinum Patriot", "Be the top donor to Donald Trump", "trump_patriot", function(ply) return ply.NWPrivate.trump_patriot==1 end)
AddTitle("", "Golden Patriot", "Be on Donald Trump's donation leaderboard", "trump_patriot", function(ply) return ply.NWPrivate.trump_patriot~=nil end)
AddTitle("", "Greatest Ally", "Be the top donor to Joe Biden", "biden_patriot", function(ply) return ply.NWPrivate.biden_patriot==1 end)
AddTitle("", "Ally", "Be on Joe Biden's donation leaderboard", "biden_patriot", function(ply) return ply.NWPrivate.biden_patriot~=nil end)
