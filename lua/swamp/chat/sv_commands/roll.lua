ProvableGenerator = nil

if not ProvableGenerator then
    -- close to the highest int we can store precisely in a lua number
    local maxseed = 1000 ^ 5

    ProvableGenerator = memo(function(genfor)
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
