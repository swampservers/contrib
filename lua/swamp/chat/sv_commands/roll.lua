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
    return ProvableGenerator.multiplayer(max_or_txt, txt)
end

function Player:ProvableRandom(max_or_txt, txt)
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
-- PublicRandom("nigga")
-- print(PublicRandom:Ledger())
-- local seed = math.random(1, 10000)
-- function ReseedGambling()
--     if GamblingLog then
--         while GamblingLog[1] and GamblingLog[1].time < os.time()-100000 do
--             table.remove(GamblingLog, 1)
--         end
--         file.Write("rolldata.txt", util.TableToJSON(GamblingLog))
--     else
--         GamblingLog = util.JSONToTable(file.Read("rolldata.txt") or "") or {}
--     end
--     PUBLIC_RANDOM_SEED = math.random(1000^5)
--     GamblingLogPart = {}
--     -- seed = GetSeed()
--     seed = {
--         global
--     }
--     -- GamblingLogLines = {
--     --     "",
--     --     "--------",
--     --     os.date( "%a %H:%M:%S: " ).."Set the seed to "..seed
--     -- }
-- end
-- ReseedGambling()
-- -- hook.Add( "ShutDown", "SaveGamblingLog",FairReseed)
-- -- function FairRandom()
-- --     seed = bit.bxor(seed, bit.lshift(seed, 13)) -- 21
-- --     seed = bit.bxor(seed, bit.rshift(seed, 17)) --35
-- --     seed = bit.bxor(seed, bit.lshift(seed, 5)) -- 4
-- --     return seed
-- -- end
-- local seed = 0
-- function FairRandom()
--     local externalseed = math.random()
--     math.randomseed(seed)
--     seed = math.random()
--     math.randomseed(externalseed)
--     return seed
-- end
-- -- xorshift128 algorithm https://en.wikipedia.org/wiki/Xorshift
-- -- function FairRandom()
-- --     local t = seed[4]
-- --     local s = seed[1]
-- --     seed[4] = seed[3]
-- --     seed[3] = seed[2]
-- --     seed[2] = s
-- --     t = bit.bxor(t, bit.lshift(t, 11))
-- --     t = bit.bxor(t, bit.rshift(t, 8))
-- --     seed[1] = bit.bxor(t, s, bit.lshift(s, 19))
-- --     return seed[1]
-- -- end
-- local seedmax,seedmin = 2^31 -1 , -2^31
-- local testseed
-- local function NextTestSeed()
--     -- increment seed
--     -- local j=1
--     -- while true do
--     --     local v = testseed[j]+1
--     --     if bit.tobit(v) == v then testseed[j]=v break end
--     --     testseed[j]=bit.tobit(v)
--     --     j=j+1
--     --     if not testseed[j] then break end
--     -- end
--     -- testseed = testseed+1 --bit.tobit(testseed+1)
--     -- if testseed>seedmax then testseed = seedmin end
--     -- testseed = math.random()
--     -- seed = testseed 
--     seed = VeryRandomSeed()
-- end
-- function BruteForceSeed()
--     local pred =  FairRandom -- function() return FairRandom()%mod end
--     testseed = seed
--     local s1,s2,s3,s4,s5 = pred(),pred(),pred(),pred(),pred()
--     seed = testseed
--     if not (s1==pred() and s2==pred() and s3==pred() and s4==pred() and s5==pred()) then print("BASIC SELF TEST FAILED") return end
--     RunString("SNEED="..tostring(seed))
--     seed = SNEED
--     -- print(seed, SNEED, testseed==SNEED)
--     -- if not (s1==pred() and s2==pred() and s3==pred() and s4==pred() and s5==pred()) then print("PARSING SELF TEST FAILED") return end
--     seed = testseed
--     print("SELFTEST PASSED",s1,s2,s3,s4,s5)
--     local s0,s1,s2,s3,s4,s5,s6,s7,s8,s9 = pred(),pred(),pred(),pred(),pred(),pred(),pred(),pred(),pred(),pred()
--     local succ, checks = 0,0
--     local t1 = SysTime() 
--     local function cps()
--         return (checks<1000000 and ("ONLY "..checks.." CHECKS, ") or (math.Round(checks/1000000).."m checks, "))..math.Round((checks/1000000)/(SysTime()-t1)).."m checks/sec"
--     end
--     print("Searching for the seed "..testseed)
--     testseed = VeryRandomSeed()
--     while SysTime()<t1+3 do
--         local t2 = SysTime()
--         while SysTime()<t2+1 do
--             for i=1,10000 do
--                 NextTestSeed()
--                 if s0==pred() and s1==pred() and s2==pred() and s3==pred() and s4==pred() and s5==pred() and s6==pred() and s7==pred() and s8==pred() and s9==pred() then 
--                     checks = checks+i
--                     print("FOUND. "..cps())
--                     return
--                 end
--             end
--             checks=checks+10000
--         end
--         print(cps())
--     end
--     print("Failed. "..cps())
--     -- print("Result", succ, checks.."m") --, SysTime()-t)
-- end
-- BruteForceSeed()
-- function printbits(x)
--     local s =""
--     for i=0,31 do
--         s=( bit.band(x, 2^i )==0 and "0" or "1" )..s
--     end
--     print(s)
-- end
-- function GamblingRandom(bound, users, txt)
--     for k,v in pairs(users) do
--         users[k] = v:Name().." ("..v:SteamID()..")"
--     end
--     users = table.concat(users, ", ")
--     local gen = FairRandom()
--     local res = gen % bound
--     table.insert(GamblingLogLines, 
--         os.date( "%a %H:%M:%S: " )..(gen.." mod "..bound.." = "..res).." when "..users.." "..txt
--     )
--     return res
-- end
-- function printbits(x)
--     local s =""
--     for i=0,31 do
--         s=( bit.band(x, 2^i )==0 and "0" or "1" )..s
--     end
--     print(s)
-- end
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
