-- This file is subject to copyright - contact swampservers@gmail.com for more information.
RP_PUSH = function() end
RP_POP = function() end

concommand.Add("bp", function(ply, cmd, args)
    if SERVER and IsValid(ply) then return end

    if IS_RETARDED then
        function MAKE_UNRETARDED(tab, scope)
            if tab.UNRETARDED_FUNCTIONS then
                for k, v in pairs(tab.UNRETARDED_FUNCTIONS) do
                    tab[k] = v
                end

                tab.UNRETARDED_FUNCTIONS = nil
            end
        end

        WHATTODO = MAKE_UNRETARDED
        TIMER_DETOUR = nil
        debug.sethook()
        RP_PUSH = function() end
        RP_POP = function() end
    else
        function MAKE_RETARDED(tab, scope)
            tab.UNRETARDED_FUNCTIONS = setmetatable({}, {
                __call = noop
            })

            for k, v in pairs(tab) do
                if isfunction(v) then
                    local funt = v
                    local name = (scope or "") .. "::" .. tostring(k)
                    tab.UNRETARDED_FUNCTIONS[k] = funt

                    tab[k] = function(...)
                        if coroutine.running() then
                            print("CO")

                            return funt(...)
                        end

                        RP_PUSH(name)

                        local ret = {funt(...)}

                        RP_POP()

                        return unpack(ret)
                    end
                end
            end
        end

        RP_COUNTS = {}
        RP_SUBCOUNTS = {}
        RP_STACK = {}
        RP_LUAHOOKCALLS = 0

        function RP_PUSH(name)
            table.insert(RP_STACK, {name, SysTime(), 0})
        end

        function RP_POP()
            local name, t1, subtime = unpack(table.remove(RP_STACK))
            local totaltime = (SysTime() - t1)
            RP_COUNTS[name] = (RP_COUNTS[name] or 0) + (totaltime - subtime)
            RP_SUBCOUNTS[name] = (RP_SUBCOUNTS[name] or 0) + totaltime

            if #RP_STACK > 0 then
                RP_STACK[#RP_STACK][3] = RP_STACK[#RP_STACK][3] + totaltime
            end
        end

        timer.Create("RetardedPrint", 1, 0, function()
            local sorted = {}

            for k, v in pairs(RP_COUNTS) do
                table.insert(sorted, {k, v})
            end

            table.SortByMember(sorted, 2, true)
            local total = 0
            local dwmtotal, dwmtotal2 = 0, 0

            for i, stuff in ipairs(sorted) do
                total = total + stuff[2]

                --dwmtotal2 = dwmtotal2 + stuff[3] end
                if stuff[1]:find("DrawWorldModel") then
                    dwmtotal = dwmtotal + stuff[2]
                end

                if i > (#sorted - (CLIENT and 100 or 30)) then
                    print(unpack(stuff))
                end
            end

            if total > 0 then
                print("TOTAL", total)
                print("DRAWWORLDMODEL TOTALS", dwmtotal)
            end

            RP_COUNTS = {}
            RP_SUBCOUNTS = {}
            RP_STACK = {}
        end)

        -- debug.sethook(function(thing)
        --     -- print(thing)
        --     if thing=="call" then
        --         -- RP_LUAHOOKCALLS = RP_LUAHOOKCALLS+1
        --         if debug.getinfo(3,"l")==nil then print("ENTER") end
        --     elseif thing=="return" then
        --         -- RP_LUAHOOKCALLS = math.max(RP_LUAHOOKCALLS-1,0)
        --         -- print(RP_LUAHOOKCALLS)
        --         if debug.getinfo(3,"l")==nil then print("END") end
        --     else
        --         print(thing)
        --     end
        -- end, "cr")
        TIMER_DETOUR = function(name, funt)
            RP_PUSH(name)
            funt()

            --it gets reset by the printer
            if #RP_STACK > 0 then
                RP_POP()
            end
        end

        WHATTODO = MAKE_RETARDED
    end

    WHATTODO(GAMEMODE, "GM")
    WHATTODO(net.Receivers, "NET")

    for k, v in pairs(hook.GetTable()) do
        WHATTODO(v, k)
    end

    -- this doesnt work for spawned in ents i dont think, which is pretty retarded
    for i, wep in ipairs(weapons.GetList()) do
        WHATTODO(wep, wep.ClassName or "UNKNOWNWEP")
    end

    for i, et in ipairs(scripted_ents.GetList()) do
        WHATTODO(et.t, et.type)
    end

    for i, ent in ipairs(ents.GetAll()) do
        WHATTODO(ent:GetTable(), ent:GetClass())
    end

    --TODO timers
    IS_RETARDED = not IS_RETARDED
end)

-- concommand.Add("bp", function( ply, cmd, args )
--     if SERVER and IsValid(ply) then return end
--     timer.Create("BasedPrint",1,0,function()
--         local sorted = {}
--         for k,v in pairs(BASED_TIMES) do
--             table.insert(sorted, {k,v[1],v[2],v[1]/v[2]})
--         end
--         table.SortByMember(sorted, 4, true)
--         local total = 0
--         for i,stuff in ipairs(sorted) do
--             total = total + stuff[2]
--             print(unpack(stuff))
--         end
--         if total>0 then
--          print("TOTAL", total)
--         end
--         BASED_TIMES = {}
--         BASED_STACK = {}
--     end)
--     BASED_TIMES = {}
--     BASED_STACK = {}
--     -- function RP_POP()
--     --     local name,t1,subtime = unpack(table.remove(RP_STACK))
--     --     local totaltime = (SysTime() - t1)
--     --     RP_COUNTS[name] = (RP_COUNTS[name] or 0) + (totaltime - subtime)
--     --     if #RP_STACK > 0 then
--     --         RP_STACK[#RP_STACK][3] = RP_STACK[#RP_STACK][3] + totaltime
--     --     end
--     -- end
--     STACK2 = {}
--     function BASEDPROFILE(thing)
--         if coroutine.running() then print("CO") return end
--         if thing=="call" then
--             local info = debug.getinfo(2,"nS")
--             local ss = tostring(info.short_src)
--             if ss=="[C]" then
--                 table.insert(BASED_STACK, false)
--                 return
--             end
--             info = ss..":"..tostring(info.name)..":"..tostring(info.linedefined)
--             -- print(info)
--             table.insert(BASED_STACK, {info, SysTime(), 0})
--             -- table.insert(STACK2, info)
--         elseif thing=="return" then
--             -- print("RETURN", table.remove(STACK2))
--             local remd = table.remove(BASED_STACK)
--             if not remd then return end
--             local name,t1,subtime = unpack(remd)
--             local totaltime = (SysTime() - t1)
--             local old = BASED_TIMES[name] or {0,0}
--             BASED_TIMES[name] = {old[1] + (totaltime - subtime),old[2] + 1 }
--             if #BASED_STACK > 0 and BASED_STACK[#BASED_STACK] then
--                 BASED_STACK[#BASED_STACK][3] = BASED_STACK[#BASED_STACK][3] + totaltime
--             end
--         end
--     end
--     if ISBASEDPROFILER then
--         debug.sethook()
--     else
--         debug.sethook(BASEDPROFILE, "cr")
--     end
--     ISBASEDPROFILER = not ISBASEDPROFILER
-- end)
--hopefully this loads faster than timers are made
RP_ACTUAL_TIMERSIMPLE = RP_ACTUAL_TIMERSIMPLE or timer.Simple
RP_ACTUAL_TIMERCREATE = RP_ACTUAL_TIMERCREATE or timer.Create

function timer.Simple(t, f)
    local name = "TimerSimple_" .. tostring(t)
    local fonc = f

    RP_ACTUAL_TIMERSIMPLE(t, function()
        if TIMER_DETOUR then
            TIMER_DETOUR(name, fonc)
        else
            fonc()
        end
    end)
end

function timer.Create(id, t, r, f)
    local name = "Timer_" .. tostring(id)
    local fonc = f

    RP_ACTUAL_TIMERCREATE(id, t, r, function()
        if TIMER_DETOUR then
            TIMER_DETOUR(name, fonc)
        else
            fonc()
        end
    end)
end
