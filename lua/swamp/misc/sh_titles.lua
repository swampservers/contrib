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

if SERVER then
    for k, v in pairs(player.GetAll()) do
        v.TitleCache = nil
    end
end

--TODO: should we combine all title reward_ids into one? or maybe just some simpler ones like the kleinertp one?
function AddTitle(thresholds, description, nwp_vars, args)
    args = args or {}
    local reward_id = args.reward_id or "title"
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
                local cutoff = v[1]

                if isstring(cutoff) then
                    cutoff = NWGlobal[cutoff] or 999999999
                end

                return i, cutoff, v[2], (v[3] or 0)
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

    local progress_fn = args.progress_fn or function(ply)
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

            if (ply[maxkey] or 0) < im then
                if not ply.SUPPRESSTITLEUNLOCK then
                    ply:Notify("Unlocked a new title: " .. t .. "")
                end

                PlayerTitleRewardRefresh[ply][reward_id] = true
            end

            ply[maxkey] = im
        end

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

    title.pset_verb = args.pset_verb

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
    {100, "Gift Giver", 1000000}
}, "Give a present (from shop) to %s different players", "s_giftgiver", {
    reward_id = "giftgiver",
    progress_fn = function(ply) return PartnerSetSize(ply.NWP.s_giftgiver or "") end,
    pset_verb = "gifted"
})

AddTitle({
    {200, "Gift Receiver"},
    {1000, "Spoiled Child"},
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

-- Jihadi, Fundamentalist, Islamist, Insurrectionist, Extremist, Fanatic
-- Founder of ISIS and Jihad Squad should be a leaderboard
AddTitle({
    {10, "Insurrectionist"},
    {20, "Terrorist"},
    {30, "Islamist"},
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
-- AddTitle("vandal", {
--     {200, "Tagger", 10000},
--     {1000, "Vandal", 100000}
-- }, "Place %s feet of spraypaint", "s_spraypaint")
-- fidget spinner max rpm: helicopter tard
--NOMINIFY
--TODO: titles where you don't have a description but the title itself hints at what you do? like a secret achievement but not totally secret
--TODO: if threshold=true, its 1 but you can put better text on the button in that case
