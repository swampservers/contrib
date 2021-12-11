-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local Player = FindMetaTable("Player")

--- Get current title string or ""
function Player:GetTitle()
    return self:GetNWString("title", "")
end

--NOMINIFY
Titles = {}
TitleRefreshDir = defaultdict(function() return {} end)

if SERVER then
    for k, v in pairs(player.GetAll()) do
        v.TitleCache = nil
    end
end

--TODO: should we combine all title reward_ids into one? or maybe just some simpler ones like the kleinertp one?
function AddTitle(reward_id, thresholds, description, nwp_vars, progress_fn, pset_verb)
    local title = {}
    table.insert(Titles, title)

    if isstring(thresholds) then
        thresholds = {
            {1, thresholds}
        }
    end

    function title:Thresholds()
        local i, n = 0, #thresholds

        return function()
            i = i + 1

            if i <= n then
                local v = thresholds[i]

                return i, v[1], v[2], (v[3] or 0)
            end
        end
    end

    if isstring(description) then
        function title:Description(i, min)
            return description:format(min)
        end
    else
        function title:Description(i, min)
            return description[i]
        end
    end

    if isstring(nwp_vars) then
        nwp_vars = {nwp_vars}
    end

    title.nwp_vars = nwp_vars

    local function num(p)
        if not isnumber(p) then
            p = p and 1 or 0
        end

        return p
    end

    progress_fn = progress_fn or function(ply)
        local p = 0

        for i, var in ipairs(nwp_vars) do
            p = p + num(ply.NWP[var])
        end

        return p
    end

    local titleindex = #Titles
    local maxkey = "lasttitlemax" .. titleindex

    function title:Progress(ply)
        local p = num(progress_fn(ply))

        if SERVER and reward_id ~= "" then
            local r = 0
            local t = nil
            local im = 0

            for i, min, name, reward in self:Thresholds() do
                if min > p then break end
                t = name
                r = r + reward
                im = i
            end

            if (ply[maxkey] or 0) < im and not ply.SUPPRESSTITLEUNLOCK then
                ply:Notify("Unlocked a new title: " .. t .. "")
            end

            ply[maxkey] = im
            ply:PointsReward(reward_id, r, "unlocking a title")
        end

        return p
    end

    title.pset_verb = pset_verb

    for i, v in ipairs(nwp_vars) do
        table.insert(TitleRefreshDir[v], titleindex)
    end
end

--AddTitle(reward_id, thresholds, description, nwpvars, progressfn)
--reward_id: string to identify points given for this sequence, use empty string if there are no rewards
--thresholds: {{progress1, title1, reward1}, {progress2, title2, reward2}} rewards are optional
--description: string which can be formatted with the threshold for the next target, or list of strings corresponding to each level
--nwp_vars: var or list of vars that are used to calculate progress, so when they change the server can strip the title if necessary
--progress_fn: optional function to compute progess, defaults to summing nwp vars
--pset_verb: optional, verb to use if nwpvar1 is a pset and should be trackable
AddTitle("", "Newfriend", "Welcome to the Swamp", {}, function() return true end)

-- TODO: make income max at 500k due to new ways to get points, make leaderboards network the threshold to get to a certain level
--jolly
AddTitle("christmas", {
    {1, "Festive", 25000},
}, "During December, give a present (from shop) to another player", "s_christmas")

-- {1000, "Saint Nick", 1000000}
AddTitle("giftgiver", {
    {100, "Gift Giver", 1000000}
}, "Give a present (from shop) to %s different players", "s_giftgiver", function(ply) return PartnerSetSize(ply.NWP.s_giftgiver or "") end, "gifted")

AddTitle("popcornhit", {
    {10, "Goofball", 2000},
    {200, "Troll", 10000},
    {1000, "Minge", 50000},
    {100000, "Retard", 0}
}, "Throw popcorn in someone's face %s times", "s_popcornhit")

AddTitle("mined", {
    {20, "Digger", 10000},
    {100, "Spelunker", 20000},
    {500, "Excavator", 30000},
    {2000, "Earth Mover", 40000},
    {10000, "Minecraft Steve", 50000}
}, "Dig up %s pieces of ore (In Minecraft)", "s_mined")

AddTitle("garfield", {
    {200, "Chonkers", 10000},
    {1000, "Fat Cat", 100000},
    {10000, "I Eat, Jon.", 1000000}
}, "Become Garfield and grow to weigh at least %s pounds", "s_garfield")

AddTitle("megavape", {
    {1, "Vapist", 50000}
}, "Find the mega vape and hit it", "s_megavape")

AddTitle("kleinertp", {
    {1, "Test Subject", 10000}
}, "Be subjected to one of Dr. Isaac Kleiner's teleportation experiments", "s_kleinertp")

AddTitle("buttonsearch", {
    { 1, "Button Rookie", 0},
    { 10, "Button Hunter", 0},
    { 100, "Button Master", 0}
}, "Find and press %s buttons.", "s_magicbutton")

AddTitle("bountykill", {
    {10, "Bounty Hunter", 0},
    {100, "The Cleaner", 0},
    {1000, "Hitman", 0}
}, "Collect %s bounties.", "s_bounties")

AddTitle("headshotkill", {
    {50, "Boom Headshot!", 2500},
    {250, "American Sniper", 10000},
    {1000, "Lee Harvey Oswald", 50000}
}, "Kill %s non-afk players with headshots.", "s_headshotkill")

AddTitle("kleinerkiller", {
    {100, "Kleiner Killer", 5000},
    {1000, "Anti Kleiner", 10000},
    {10000, "Kleiner Exterminator", 25000}
}, "Kill %s Kleiners.", "s_kleinerkiller")

AddTitle("knifekill", {
    {25, "Edgelord", 0},
    {100, "Stab Enthusiast", 0},
    {1000, "American Psycho", 0}
}, "Kill %s non-afk players with the throatneck slitter.", "s_knifekill")

AddTitle("theaterkill", {
    {100, "Peacekeeper", 0}
}, "Defend your theater %s amount of times.", "s_theaterkill")

AddTitle("fistkill", {
    {25, "Fightclub Member", 5000},
    {100, "Chad", 10000},
    {500, "Giga Chad", 25000},
    {1000, "Billy's Disciple", 100000}
}, "Get %s kills with the fists.", "s_fistkill")

AddTitle("dodgeballkill", {
    {25, "FatKid", 2500},
    {100, "Underdog", 10000},
    {500, "Strongarm", 50000},
    {1000, "Dodgeball Warrior", 100000}
}, "Get %s kills with the dodgeball.", "s_dodgeballkill")

AddTitle("snaps", {
    {10, "Snap", 0},
    {50, "Perfectly Balanced", 0}
}, "Snap and kill %s players with the Thanos Gauntlet.", "s_snaps")

-- Jihadi, Fundamentalist, Islamist, Insurrectionist, Extremist, Fanatic
-- Founder of ISIS and Jihad Squad should be a leaderboard
AddTitle("", {
    {10, "Insurrectionist"},
    {20, "Terrorist"},
    {30, "Islamist"},
    {40, "Founder of ISIS"}
}, "Kill at least %s active players in a suicide bombing", "s_bigjihad")

AddTitle("", {
    {50, "Suicide Bomber"},
    {1000, "Jihad Squad"}
}, "Kill a total of %s players by jihading theaters", "s_theaterjihad")

AddTitle("", {
    {99, "Cloud Chaser"},
    {999, "Junkie"},
    {9999, "Dropout"}
}, "Hit a vape %s times", "s_vapehit")

-- Philosopher, Intellectual, Elegant, Suave, Stylish
AddTitle("", {
    {1000, "Classy"},
    {10000, "Elegant"},
    {100000, "Sophisticated"},
    {1000000, "Enlightened"}
}, "Tip your flappy fedora %s times", "s_fedoratip")

AddTitle("", {
    {1, "Patriot"},
    {2, "Golden Patriot"},
    {3, "Platinum Patriot"}
}, {"Visit Donald Trump's donation box and give at least 100,000 points", "Be on Donald Trump's donation leaderboard", "Be the top donor to Donald Trump"}, {"s_trump_donation", "s_trump_donation_leader"}, function(ply) return ((ply.NWP.s_trump_donation or 0) >= 100000 and 1 or 0) + (ply.NWP.s_trump_donation_leader and 1 or 0) + (ply.NWP.s_trump_donation_leader == 1 and 1 or 0) end)

AddTitle("", {
    {1, "Ally"},
    {2, "Libtard"},
    {3, "Greatest Ally"}
}, {"Visit Joe Biden's donation box and give at least 100,000 points", "Be on Joe Biden's donation leaderboard", "Be the top donor to Joe Biden"}, {"s_lefty_donation", "s_lefty_donation_leader"}, function(ply) return ((ply.NWP.s_lefty_donation or 0) >= 100000 and 1 or 0) + (ply.NWP.s_lefty_donation_leader and 1 or 0) + (ply.NWP.s_lefty_donation_leader == 1 and 1 or 0) end)

--todo: print who currently has the title?
AddTitle("", {
    {1, "The 1%"},
    {13, "Illuminati"}
}, {"Be among the 15 richest players", "Be among the 3 richest players"}, "points_leader", function(ply) return 16 - (ply.NWP.points_leader or 16) end)
-- AddTitle("vandal", {
--     {200, "Tagger", 10000},
--     {1000, "Vandal", 100000}
-- }, "Place %s feet of spraypaint", "s_spraypaint")
-- fidget spinner max rpm: helicopter tard
--NOMINIFY
--TODO: titles where you don't have a description but the title itself hints at what you do? like a secret achievement but not totally secret
--TODO: if threshold=true, its 1 but you can put better text on the button in that case

if SERVER then
    local TitleFuncs =
    {
        ["weapon_gauntlet"] = function(atk) atk:AddStat("snaps") end,
        ["weapon_slitter"] = function(atk,vic) if vic:IsPlayer() && not vic:IsAfk() then atk:AddStat("knifekill") end end,
        ["dodgeball"] = function(atk,vic) atk:AddStat("dodgeballkill") end,
        ["weapon_fists"] = function(atk) atk:AddStat("fistkill") end
    }

    local function TitlesPlayerDeath(vic,inf,atk)
        if atk:IsPlayer() then
            if TitleFuncs[inf:GetClass()] then TitleFuncs[inf:GetClass()](atk,vic) end
            if vic:IsPlayer() && not vic:IsAfk() && vic:LastHitGroup() == 1 then atk:AddStat("headshotkill") end
            if vic:GetModel() == "models/player/kleiner.mdl" then atk:AddStat("kleinerkiller") end
            if atk:InTheater() && vic:InTheater() then
                if atk:GetTheater():GetOwner() == atk && vic:GetTheater():GetOwner() == atk then atk:AddStat("theaterkill") end
            end
        end
    end
    hook.Add("PlayerDeath", "TitlesPlayerDeath", TitlesPlayerDeath)
end