-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local Player = FindMetaTable("Player")

--- Get current title string or ""
function Player:GetTitle()
    return self:GetNWString("title", "")
end

--NOMINIFY
Titles = {}
TitleRefreshDir = defaultdict(function() return {} end)
RewardIdTitleDir = defaultdict(function() return {} end)


--TODO: should we combine all title reward_ids into one? or maybe just some simpler ones like the kleinertp one?
function AddTitle(thresholds, description, nwp_vars, args)
    args = args or {}
    
    local title = {
        group_view = args.group_view,
        reward_id = args.reward_id or "title",
        nwp_vars = isstring(nwp_vars) and {nwp_vars} or nwp_vars
    }
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
                local cutoff = v[1]

                if isstring(cutoff) then
                    cutoff = NWGlobal[cutoff] or 999999999
                end

                return i, cutoff, v[2], (v[3] or 0)
            end
        end
    end

    local treward = 0
    for i,min,text,reward in title:Thresholds() do
        treward = treward + reward
    end
    if treward==0 then title.reward_id =nil end

    if isstring(description) then
        function title:Description(i, min)
            return description:format(min)
        end
    else
        function title:Description(i, min)
            return description[i]
        end
    end


    local function num(p)
        if not isnumber(p) then
            p = p and 1 or 0
        end

        return p
    end

    local progress_fn = args.progress_fn or function(ply)
        local p = 0

        for i, var in ipairs(title.nwp_vars) do
            p = p + num(ply.NWP[var])
        end

        return p
    end

    local titleindex = #Titles
    local maxkey = "lasttitlemax" .. titleindex

    function title:Progress(ply)
        local p = num(progress_fn(ply))

        -- if SERVER and reward_id ~= "" then
        --     local r = 0
        --     local t = nil
        --     local im = 0

        --     for i, min, name, reward in self:Thresholds() do
        --         if min > p then break end
        --         t = name
        --         r = r + reward
        --         im = i
        --     end

        --     if (ply[maxkey] or 0) < im then
        --         if ply.TitlesInitialized then
        --             ply:Notify("Unlocked a new title: " .. t .. "")
        --         end

        --         PlayerTitleRewardRefresh[ply][reward_id] = true
        --     end

        --     ply[maxkey] = im
        -- end

        return p
    end

    function title:CurrentReward(ply)
        local p = num(progress_fn(ply))
        local r = 0

        for i, min, name, reward in self:Thresholds() do
            if min > p then break end
            r = r + reward
        end

        return r
    end

    if title.reward_id then
        table.insert(RewardIdTitleDir[title.reward_id], title)
    end

    for i, v in ipairs(title.nwp_vars) do
        table.insert(TitleRefreshDir[v], title)
    end
end

--AddTitle(thresholds, description, nwpvars, args)
--thresholds: {{progress1, title1, reward1}, {progress2, title2, reward2}} rewards are optional
--description: string which can be formatted with the threshold for the next target, or list of strings corresponding to each level
--nwp_vars: var or list of vars that are used to calculate progress, so when they change the server can strip the title if necessary
--args:
--reward_id: string to identify points given for this sequence, use empty string if there are no rewards
--progress_fn: optional function to compute progess, defaults to summing nwp vars
--group_view: optional, pset id and verb to track with
AddTitle("Newfriend", "Welcome to the Swamp", {}, {
    progress_fn = function() return true end
})

-- TODO: make income max at 500k due to new ways to get points, make leaderboards network the threshold to get to a certain level
--jolly
AddTitle({
    {1, "Festive", 25000},
}, "During December, give a present (from shop) to another player", "s_christmas", {
    reward_id = "christmas"
})

-- {1000, "Saint Nick", 1000000}
AddTitle({
    {100, "Gift Giver", 1000000},
    {"s_giftgiver_size_place1", "Saint Nick", 0}
}, "Give a present (from shop) to %s different players", "s_giftgiver_size", {
    reward_id = "giftgiver",
    group_view = {"s_giftgiver", "gifted"}
})

AddTitle({
    {200, "Gift Receiver", 10000},
    {1000, "Greedy", 100000},
    {10000, "Spoiled Child", 1000000},
}, "Open %s presents which you didn't buy yourself", "s_giftopener")

AddTitle({
    {10, "Goofball", 2000},
    {200, "Troll", 10000},
    {1000, "Minge", 50000},
    {100000, "Retard", 0}
}, "Throw popcorn in someone's face %s times", "s_popcornhit", {
    reward_id = "popcornhit"
})

AddTitle({
    {20, "Digger", 10000},
    {100, "Spelunker", 20000},
    {500, "Excavator", 30000},
    {2000, "Earth Mover", 40000},
    {10000, "Minecraft Steve", 50000}
}, "Dig up %s pieces of ore (In Minecraft)", "s_mined", {
    reward_id = "mined"
})

AddTitle({
    {200, "Chonkers", 10000},
    {1000, "Fat Cat", 100000},
    {10000, "I Eat, Jon.", 1000000}
}, "Become Garfield and grow to weigh at least %s pounds", "s_garfield", {
    reward_id = "garfield"
})

AddTitle({
    {1, "Vapist", 50000}
}, "Find the mega vape and hit it", "s_megavape")

AddTitle({
    {1, "Test Subject", 10000}
}, "Be subjected to one of Dr. Isaac Kleiner's teleportation experiments", "s_kleinertp")


AddTitle( {
    {1, "Curious"},
    {10, "Sharp Eye"},
    {100, "Seeker"},
    {1000, "Button Hunter"}
}, "Find and press %s buttons.", "s_buttonfind")

AddTitle( {
    {100, "Frosty The Snowman"}
}, "Hit %s active players with a snowball.", "s_snowballhit")

-- Quake Was A Good Game
AddTitle( {
    {10, "30 Year Old Boomer", 10000},
    {100, "Bitcoin Investor", 20000},
    {500, "Firm Handshaker", 50000},
    {1000, "Quake Pro", 100000},
    {5000, "Quake Champion"}
}, "Stand around drinking monster energy %s times", "s_boomer")

AddTitle( {
    {5, "Bounty Hunter", 100000},
    {50, "Hitman", 100000},
    {200, "The Cleaner", 100000}
}, "Collect bounties (funded by others) of at least 100,000 points on %s different players.", "s_bountyhunt_size", {
    reward_id = "bountyhunt",
    group_view = {"s_bountyhunt", "slayed"}
})


AddTitle( {
    {10, "Steady Hand", 10000},
    {100, "Boom, Headshot!"},
    {500, "American Sniper"},
    {1000, "HEADBANGER"}
}, "Kill %s active players with headshots.", "s_headshotkill")

AddTitle( {
    {20, "Kleiner Kleaner", 5000},
    {100, "Kleiner Killer", 10000},
    {1000, "Anti-Kleiner", 20000},
    {10000, "Exterminator", 50000}
}, "Kill %s Kleiners.", "s_kleinerkill")

AddTitle( {
    {100, "Shanker", 0},
    {1000, "Edge Lord", 0},
    {5000, "Throat-Neck Slitter", 0},
    {10000, "American Psycho", 0}
}, "Kill %s active players with a throatneck slitter.", "s_knifekill")

AddTitle( {
    {20, "Protector", 0},
    {100, "Guardian", 0},
    {500, "Homeland Security", 0},
    {2000, "The Law", 0}
}, "Kill %s players while protecting your private theater.", "s_theaterdefend")

AddTitle( {
    {25, "Fightclub Member", 5000},
    {100, "Chad", 1000},
    {500, "Giga Chad", 25000},
    {1000, "Billy's Disciple", 100000}
}, "Get %s kills with the fists.", "s_fistkill")

AddTitle( {
    {25, "Jock", 2500},
    {100, "Bully", 10000},
    {500, "Dodgeball Pro", 50000},
}, "Get %s kills with the dodgeball.", "s_dodgeballkill")

AddTitle( {
    {10, "Snap", 0},
    {50, "Perfectly Balanced", 0}
}, "Snap and kill %s seated players with the Thanos Gauntlet.", "s_gauntletkill")



-- Jihadi, Fundamentalist, Islamist, Insurrectionist, Extremist, Fanatic
AddTitle({
    {10, "Insurrectionist"},
    {15, "Terrorist"},
    {20, "Islamist"},
    {"s_bigjihad_place1", "Founder of ISIS"}
}, "Kill at least %s active players in a suicide bombing", "s_bigjihad")

AddTitle({
    {50, "Suicide Bomber"},
    {"s_theaterjihad_place5", "Jihad Squad"}
}, {"Kill a total of %s players by jihading theaters", "Be among the top 5 theater jihaders"}, "s_theaterjihad")

AddTitle({
    {99, "Cloud Chaser"},
    {999, "Junkie"},
    {9999, "Dropout"}
}, "Hit a vape %s times", "s_vapehit")

-- Philosopher, Intellectual, Elegant, Suave, Stylish
AddTitle({
    {1000, "Classy"},
    {10000, "Elegant"},
    {100000, "Sophisticated"},
    {1000000, "Enlightened"}
}, "Tip your flappy fedora %s times", "s_fedoratip")

AddTitle({
    {100000, "Patriot"},
    {"s_trump_donation_place10", "Golden Patriot"},
    {"s_trump_donation_place1", "Platinum Patriot"}
}, {"Visit Donald Trump's donation box and give at least 100,000 points", "Be on Donald Trump's donation leaderboard", "Be the top donor to Donald Trump"}, "s_trump_donation")

AddTitle({
    {100000, "Ally"},
    {"s_lefty_donation_place10", "Libtard"},
    {"s_lefty_donation_place1", "Greatest Ally"}
}, {"Visit Joe Biden's donation box and give at least 100,000 points", "Be on Joe Biden's donation leaderboard", "Be the top donor to Joe Biden"}, "s_lefty_donation")

--todo: print who currently has the title?
AddTitle({
    {"points_place15", "The 1%"},
    {"points_place3", "Illuminati"}
}, {"Be among the 15 richest players", "Be among the 3 richest players"}, "points")

AddTitle({
    {20, "Bug Chaser"},
    {100, "Dev Server Proponent"}
}, "Experience %s different Lua errors.", "s_clienterror_size")


if SERVER then
    local weaponcallbacks =
    {
        weapon_gauntlet = function(atk,vic) if vic:InVehicle() then atk:AddStat("gauntletkill")  end end,
        weapon_slitter = function(atk,vic) if vic:IsActive() then atk:AddStat("knifekill") end end,
        dodgeball = function(atk,vic) atk:AddStat("dodgeballkill") end,
        weapon_fists = function(atk,vic) atk:AddStat("fistkill") end
    }

    hook.Add("PlayerDeath", "TitlesPlayerDeath", function(vic,inf,atk)
        if atk:IsPlayer() and atk!=vic then
            if weaponcallbacks[inf:GetClass()] then weaponcallbacks[inf:GetClass()](atk,vic) end
            if vic:IsActive() && vic:LastHitGroup() == HITGROUP_HEAD then atk:AddStat("headshotkill") end
            if vic:GetModel() == "models/player/kleiner.mdl" then atk:AddStat("kleinerkill") end
            if atk:InTheater() && vic:InTheater() and atk:GetTheater():GetOwner() == atk && vic:GetTheater():GetOwner() == atk then
                 atk:AddStat("theaterdefend")
            end
        end
    end)
end

print("HERE")


-- AddTitle("vandal", {
--     {200, "Tagger", 10000},
--     {1000, "Vandal", 100000}
-- }, "Place %s feet of spraypaint", "s_spraypaint")
-- fidget spinner max rpm: helicopter tard
--NOMINIFY
--TODO: titles where you don't have a description but the title itself hints at what you do? like a secret achievement but not totally secret
--TODO: if threshold=true, its 1 but you can put better text on the button in that case
