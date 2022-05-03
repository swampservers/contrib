ProvableGenerator = nil

if not ProvableGenerator then
    -- close to the highest int we can store precisely in a lua number
    local maxseed = 1000 ^ 5

    ProvableGenerator = defaultdict(function(genfor)
        local seed, state, ledger, samples

        -- This object stores its state in upvalues that reset when you call Ledger, making it EXTREMELY SECURE
        local generator = {
            Ledger = function()
                local ledger_txt = ""

                if ledger and #ledger > 1 then
                    ledger[1] = ledger[1] .. samples
                    table.insert(ledger, "  Generated for " .. genfor .. "\n\n")
                    ledger_txt = table.concat(ledger, "\n")
                end

                state = math.random(maxseed)
                samples = 0

                ledger = {("%s: Seed changed. COMMAND TO VERIFY: verify %u "):format(os.date("%a %H:%M:%S"), state)}

                return ledger_txt
            end,
            Next = function(max, txt)
                if isstring(max) then
                    max, txt = false, max
                end

                local entropy = math.random()
                math.randomseed(state)
                state = math.random()
                math.randomseed(entropy)
                txt = "  For: " .. (txt or "Unknown")
                local v = state

                if max then
                    v = math.floor(state * max)
                    max = tostring(max)
                    txt = (" *%s=%" .. #max .. "i %s"):format(max, v, txt)
                end

                samples = samples + 1
                table.insert(ledger, ("    %s: Roll %2i: %.9f"):format(os.date("%H:%M:%S"), samples, state) .. txt)

                return v
            end,
            Skip = function(n)
                local entropy = math.random()

                for i = 1, n do
                    math.randomseed(state)
                    state = math.random()
                end

                math.randomseed(entropy)
                samples = samples + n
                table.insert(ledger, ("    %s: Skipped %i rolls"):format(os.date("%H:%M:%S"), n))

                return v
            end,
        }

        generator.Ledger()

        return generator
    end)

    -- attempt to brute force the seed, just for testing
    function BruteForce(timelimit)
        local entropy = math.random()
        math.randomseed(math.random(maxseed))
        local val = math.random()
        math.randomseed(entropy)
        local checks, t1 = 0, SysTime()

        local function cps()
            return (checks < 1000000 and checks .. " CHECKS, " or math.Round(checks / 1000000) .. "m checks, ") .. math.Round((checks / 1000000) / (SysTime() - t1)) .. "m checks/sec"
        end

        print("Searching for the seed")

        while SysTime() < t1 + timelimit do
            local t2 = SysTime()

            while SysTime() < t2 + 1 do
                for i = 1, 100000 do
                    entropy = math.random()
                    math.randomseed(math.random(maxseed))
                    local val2 = math.random()
                    math.randomseed(entropy)

                    if val == val2 then
                        checks = checks + i
                        print("FOUND. " .. cps())

                        return
                    end
                end

                checks = checks + 100000
            end

            print(cps())
        end

        print("Failed. " .. cps())
    end

    -- TODO dont fully clear them on restart?
    if file.IsDir("roll_ledgers", "DATA") then
        local files, directories = file.Find("roll_ledgers/*", "DATA")

        for i, f in ipairs(files) do
            file.Delete("roll_ledgers/" .. f)
        end
    else
        file.CreateDir("roll_ledgers")
    end
end

function ProvableRandom(max_or_txt, txt)
    ProvableGenerator.multiplayer.Ledger() -- stopgap

    return ProvableGenerator.multiplayer(max_or_txt, txt)
end

function Player:ProvableRandom(max_or_txt, txt)
    ProvableGenerator[self:SteamID()].Ledger() -- stopgap

    return ProvableGenerator[self:SteamID()].Next(max_or_txt, txt)
end

local global_reset, reset_every = 0, 10

function SaveRollLedger()
    file.Append("roll_ledgers/multiplayer.txt", ProvableGenerator.multiplayer.Ledger())
end

timer.Create("SaveRollLedger", 1, 0, function()
    if os.time() > global_reset then
        global_reset = math.ceil(os.time() / reset_every) * reset_every
        SaveRollLedger()
    end
end)

hook.Add("ShutDown", "SaveRollLedger", SaveRollLedger)

concommand.Add("showseeds", function(ply, cmd, args)
    if ply:RateLimit("showseeds", 5, 5) then return end
    local gen = ProvableGenerator[ply:SteamID()]
    local secret = tostring(gen)
    assert(secret:StartWith("table: 0x"))
    file.Append("roll_ledgers/" .. secret:sub(10) .. ".txt", ProvableGenerator[ply:SteamID()].Ledger())
    ply:SendLua("ShowMotd('https://swamp.sv/prove?" .. secret:sub(10) .. "')")
end)

concommand.Add("skipseed", function(ply, cmd, args)
    if ply:RateLimit("skipseed", 3, 3) then return end
    local n = math.Clamp(math.floor(tonumber(args) or 0), 0, 10000)

    if n == 0 then
        ply:PrintMessage(HUD_PRINTCONSOLE, "Input the number of rolls: skipseed 1000")
    else
        ProvableGenerator[ply:SteamID()].Skip(n)
        ply:PrintMessage(HUD_PRINTCONSOLE, "Skipped " .. n .. " rolls")
    end
end)

RegisterChatCommand('roll', function(ply, arg, oarg, teamchat)
    local bet = math.floor(math.max(tonumber(string.Explode("%D", arg:gsub(",", ""), true)[1]) or 0, 0))
    local get = ("%06.f"):format(ply:ProvableRandom(1000000, "/roll " .. bet))
    local getsize = 1

    while get[-1 - getsize] == get[-1] do
        getsize = getsize + 1
    end

    local compliment = ""

    if getsize > 1 then
        compliment = " " .. table.Random({'Nice', 'Ebin', 'Noice', 'Sick', 'Euphoric', 'Cool', 'Sexy', 'Based', 'Epic', 'Dope', 'Autistic'}) .. " " .. ({"singles", "dubs", "trips", "quads", "quints", "sexts"})[getsize] .. "!"
    else
        if ({
            true, [9] = true
        })[math.abs(tonumber(get[-1]) - tonumber(get[-2]))] then
            compliment = " Off by one!"
        end
    end

    ply:SendLua("chat.PlaySound()")

    ply:TryTakePoints(bet, function()
        BotWhisper(ply, bet > 0 and string.Comma(bet) .. " points removed." or "Rolling...")

        ply:TimerSimple(0.9, function()
            if getsize == 1 then
                ply:SendLua("chat.PlaySound()")
            else
                ply:SendLua("local nxt,blips=0," .. (getsize == 2 and 1 or getsize) .. " hook.Add('Think','blippa',function() local t=SysTime() if t>nxt then nxt=t+0.2 surface.PlaySound('HL1/fvox/blip.wav') blips=blips-1 if blips<1 then hook.Remove('Think','blippa') end end end)")
            end

            ply:TimerSimple(0.1, function()
                if bet > 0 and getsize > 1 then
                    BotSayToWhoCanSee(ply, teamchat, ply:Nick() .. ' [fbc]rolled ' .. get .. " and won [gold]" .. string.Comma(bet * 10) .. " points[fbc].[red]" .. compliment)
                    ply:GivePoints(bet * 10)
                else
                    BotSayToWhoCanSee(ply, teamchat, ply:Nick() .. ' [fbc]rolled ' .. get .. ".[red]" .. compliment)
                end

                if bet == 0 then
                    BotWhisper(ply, "To bet, say: /roll 100")
                end
            end)
        end)
    end, function()
        BotSayToWhoCanSee(ply, teamchat, '[red]' .. ply:Nick() .. " has gone broke!")
    end)
end, {
    throttle = true
})

-- function autistic_random()
--     local start,deltas = SysTime(),{}
--     local t = start
--     for bit=1,32 do   
--         local t2, delta
--         repeat
--             t2 = SysTime()
--             delta = t2-t
--         until delta>0
--         deltas[bit]={delta, bit-1}
--         t = SysTime()
--     end
--     local total = t-start
--     table.SortByMember(deltas, 1)
--     local x = 0
--     for i=1,16 do 
--         x = x + 2^deltas[i][2]
--     end
--     return x
-- end
-- debts = {
--     ['STEAM_0:1:23047261']=6,
--     ['STEAM_0:0:39563158']=9,
--     ['STEAM_0:0:53661865']=90,
--     ['STEAM_0:0:67511512']=11111,
--     ['STEAM_0:0:140161727']=11751,
--     ['STEAM_0:0:34784858']=15000,
--     ['STEAM_0:1:35055873']=20000,
--     ['STEAM_0:1:531331642']=50000,
--     ['STEAM_0:0:145223680']=50001,
--     ['STEAM_0:1:101402219']=60000,
--     ['STEAM_0:0:5187772']=94308,
--     ['STEAM_0:1:3482227']=100000,
--     ['STEAM_0:1:28994676']=100000,
--     ['STEAM_0:0:568380636']=100000,
--     ['STEAM_0:0:540083950']=100000,
--     ['STEAM_0:1:172872147']=100000,
--     ['STEAM_0:1:525686973']=100000,
--     ['STEAM_0:1:435333738']=100000,
--     ['STEAM_0:1:116591910']=100000,
--     ['STEAM_0:1:602283900']=100000,
--     ['STEAM_0:1:18507388']=100000,
--     ['STEAM_0:1:156730056']=100000,
--     ['STEAM_0:0:53300152']=100000,
--     ['STEAM_0:0:49710163']=100000,
--     ['STEAM_0:1:47574479']=100000,
--     ['STEAM_0:0:197804076']=100000,
--     ['STEAM_0:1:63276007']=100006,
--     ['STEAM_0:0:144922869']=100021,
--     ['STEAM_0:0:102804185']=120000,
--     ['STEAM_0:0:82861677']=132233,
--     ['STEAM_0:0:463590373']=150000,
--     ['STEAM_0:1:426323708']=200000,
--     ['STEAM_0:1:99039415']=200000,
--     ['STEAM_0:1:87151526']=200000,
--     ['STEAM_0:1:100955464']=218093,
--     ['STEAM_0:0:198936519']=241000,
--     ['STEAM_0:0:59581667']=258005,
--     ['STEAM_0:0:99331744']=300000,
--     ['STEAM_0:1:231003690']=300000,
--     ['STEAM_0:1:183297617']=300000,
--     ['STEAM_0:1:34211430']=300000,
--     ['STEAM_0:0:145592041']=300000,
--     ['STEAM_0:1:129595296']=400000,
--     ['STEAM_0:1:170434795']=400000,
--     ['STEAM_0:1:77334752']=480000,
--     ['STEAM_0:0:419547508']=500000,
--     ['STEAM_0:0:510671546']=500000,
--     ['STEAM_0:1:47341797']=500000,
--     ['STEAM_0:0:41026968']=500000,
--     ['STEAM_0:0:111265161']=500000,
--     ['STEAM_0:0:52666705']=500000,
--     ['STEAM_0:0:87208393']=500001,
--     ['STEAM_0:0:514381902']=690000,
--     ['STEAM_0:1:53275084']=729000,
--     ['STEAM_0:0:611842054']=820000,
--     ['STEAM_0:1:197372390']=944400,
--     ['STEAM_0:0:116617000']=998000,
--     ['STEAM_0:1:154540094']=999999,
--     ['STEAM_0:1:219620353']=1000000,
--     ['STEAM_0:0:29766066']=1000000,
--     ['STEAM_0:1:63695431']=1000000,
--     ['STEAM_0:1:193432690']=1000000,
--     ['STEAM_0:0:106790869']=1000000,
--     ['STEAM_0:1:63316253']=1000000,
--     ['STEAM_0:0:505790398']=1000000,
--     ['STEAM_0:0:42985682']=1000000,
--     ['STEAM_0:0:60508139']=1000000,
--     ['STEAM_0:0:129704314']=1000000,
--     ['STEAM_0:0:60015196']=1000000,
--     ['STEAM_0:0:11310748']=1000000,
--     ['STEAM_0:0:421267812']=1000000,
--     ['STEAM_0:1:640287585']=1000000,
--     ['STEAM_0:1:560512020']=1048001,
--     ['STEAM_0:0:7830543']=1099500,
--     ['STEAM_0:1:12807338']=1195300,
--     ['STEAM_0:1:27980659']=1200000,
--     ['STEAM_0:1:128184836']=1315000,
--     ['STEAM_0:0:55060510']=1319998,
--     ['STEAM_0:1:119651734']=1462165,
--     ['STEAM_0:0:83164761']=1500001,
--     ['STEAM_0:1:66529438']=1600010,
--     ['STEAM_0:1:24544700']=2000000,
--     ['STEAM_0:0:46757779']=2000000,
--     ['STEAM_0:0:41887334']=2111110,
--     ['STEAM_0:0:526452196']=2227250,
--     ['STEAM_0:0:170072501']=2300000,
--     ['STEAM_0:1:79181308']=2500000,
--     ['STEAM_0:1:15173955']=2970000,
--     ['STEAM_0:0:182606116']=2990000,
--     ['STEAM_0:1:56633992']=3000000,
--     ['STEAM_0:1:199207741']=3078931,
--     ['STEAM_0:1:109979017']=3469809,
--     ['STEAM_0:0:511026693']=3668000,
--     ['STEAM_0:0:80036080']=3851650,
--     ['STEAM_0:0:573151498']=3899998,
--     ['STEAM_0:0:66604622']=4000000,
--     ['STEAM_0:1:74349994']=4000000,
--     ['STEAM_0:1:569144167']=4127000,
--     ['STEAM_0:0:170244110']=4282962,
--     ['STEAM_0:0:17911812']=4670999,
--     ['STEAM_0:0:242748116']=5000000,
--     ['STEAM_0:1:203787033']=5000000,
--     ['STEAM_0:0:447891894']=5999998,
--     ['STEAM_0:0:83399127']=6000000,
--     ['STEAM_0:0:572706035']=6000000,
--     ['STEAM_0:1:444088718']=6000000,
--     ['STEAM_0:1:210604232']=7000000,
--     ['STEAM_0:0:60265408']=7500000,
--     ['STEAM_0:0:162899387']=9100000,
--     ['STEAM_0:1:13280836']=9199991,
--     ['STEAM_0:0:28332384']=10000000,
--     ['STEAM_0:0:64555072']=10005000,
--     ['STEAM_0:1:45370257']=10940000,
--     ['STEAM_0:0:49858564']=11000002,
--     ['STEAM_0:1:654358560']=14800000,
--     ['STEAM_0:1:38369552']=15000000,
--     ['STEAM_0:0:160116379']=20300000,
--     ['STEAM_0:1:56345098']=25100000,
--     ['STEAM_0:0:533163488']=27523834,
--     ['STEAM_0:1:83611554']=30922215,
--     ['STEAM_0:0:596316360']=37000000,
--     ['STEAM_0:0:35944948']=39499999,
--     ['STEAM_0:0:193137409']=40484000,
--     ['STEAM_0:1:33932035']=44170000,
--     ['STEAM_0:0:93514451']=100100000,
--     ['STEAM_0:1:25548166']=164665980,
--     ['STEAM_0:1:542434605']=292760156,
--     ['STEAM_0:1:49770828']=336200000,
--     ['STEAM_0:0:440807732']=408035993,
--     ['STEAM_0:0:78209110']=625353211,
--     ['STEAM_0:0:17507109']=650744066,
--     ['STEAM_0:0:16678862']=1162499999,
-- }
if not RUNTHISN then
    RUNTHISN = true

    for k, v in pairs(debts) do
        local k1 = k
        k = util.SteamIDTo64(k)

        SQL_Query("SELECT points FROM lastusers WHERE id64=?", {k}, function(res)
            local p = res.data[1].points

            if p > v then
                SQL_Query("UPDATE users SET points=? WHERE id64=?", {p - v, k}, function()
                    debts[k1] = nil
                    print("PAID", k1)
                end)
            else
                SQL_Query("UPDATE users SET points=? WHERE id64=?", {0, k}, function()
                    debts[k1] = v - p
                    print("UNPAID", k1)
                end)
            end
        end)
        -- print((res.row or {}).points, "vs", v)
    end

    timer.Simple(10, function()
        for k, v in pairs(debts) do
            if v >= 1000000 then
                print(util.SteamIDTo64(k), v)
            end
        end
    end)
end

for k, v in pairs(debts) do
    if v >= 1000000 then
        print(util.SteamIDTo64(k), v)
    end
end
-- 76561198982319114       3311238
-- 76561198300410730       1476524
-- 76561198848443165       4984952
-- 76561198053781286       1999550
-- 76561198051006243       10874805
-- 76561198120337888       3850822
-- 76561199152898448       36999900
-- 76561198358681211       2676931
-- 76561199106568724       2813098
-- 76561198381474193       1964650
-- 76561198089375872       2128810
-- 76561198280498486       11591821
-- 76561199013170120       2226125
-- 76561198011362061       160591291
-- 76561198325477960       2190062
-- 76561197996089352       4669399
-- 76561198300753948       4282626
-- 76561199268982849       5436913
-- 76561197995279946       126335916
-- 76561198016227047       1168888
-- 76561198367839795       4697114
-- 76561198126595250       1499357
-- 76561198127488837       30584756
-- 76561198346540546       40183876
-- 76561198072955925       25064228
-- 76561197993623452       1141367217
-- 76561198116683948       625332475
-- 76561198841881192       392149696
-- 76561199026592704       27333218
-- 76561198028129799       15890632
-- 76561198059807385       286198100
-- 76561198856049516       3458973
-- 76561198044040396       2103120
-- 76561199045134939       274681907
-- 76561198032155624       36866294
-- 76561198093324605       1599303
-- 76561199240840899       1000000
-- 76561199081289769       1046942
-- 76561198286064502       8927988
-- STEAM_0:0:511026693     3311238
-- STEAM_0:0:170072501     1476524
-- STEAM_0:1:444088718     4984952
-- STEAM_0:0:46757779      1999550
-- STEAM_0:1:45370257      10874805
-- STEAM_0:0:80036080      3850822
-- STEAM_0:0:596316360     36999900
-- STEAM_0:1:199207741     2676931
-- STEAM_0:0:573151498     2813098
-- STEAM_0:1:210604232     1964650
-- STEAM_0:0:64555072      2128810
-- STEAM_0:0:160116379     11591821
-- STEAM_0:0:526452196     2226125
-- STEAM_0:1:25548166      160591291
-- STEAM_0:0:182606116     2190062
-- STEAM_0:0:17911812      4669399
-- STEAM_0:0:170244110     4282626
-- STEAM_0:1:654358560     5436913
-- STEAM_0:0:17507109      126335916
-- STEAM_0:1:27980659      1168888
-- STEAM_0:1:203787033     4697114
-- STEAM_0:0:83164761      1499357
-- STEAM_0:1:83611554      30584756
-- STEAM_0:0:193137409     40183876
-- STEAM_0:1:56345098      25064228
-- STEAM_0:0:16678862      1141367217
-- STEAM_0:0:78209110      625332475
-- STEAM_0:0:440807732     392149696
-- STEAM_0:0:533163488     27333218
-- STEAM_0:1:33932035      15890632
-- STEAM_0:1:49770828      286198100
-- STEAM_0:0:447891894     3458973
-- STEAM_0:0:41887334      2103120
-- STEAM_0:1:542434605     274681907
-- STEAM_0:0:35944948      36866294
-- STEAM_0:1:66529438      1599303
-- STEAM_0:1:640287585     1000000
-- STEAM_0:1:560512020     1046942
-- STEAM_0:0:162899387     8927988
