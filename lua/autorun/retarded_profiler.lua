-- This file is subject to copyright - contact swampservers@gmail.com for more information.

function RetardedProfiler()
    if IS_RETARDED then
        function MAKE_UNRETARDED(tab,scope)
            if tab.UNRETARDED_FUNCTIONS then
                for k,v in pairs(tab.UNRETARDED_FUNCTIONS) do
                    tab[k]=v
                end
                tab.UNRETARDED_FUNCTIONS=nil
            end
        end
        WHATTODO = MAKE_UNRETARDED

        timer.Remove("RetardedPrint")
    else
        function MAKE_RETARDED(tab,scope)
            tab.UNRETARDED_FUNCTIONS = setmetatable({},{__call=noop})

            for k,v in pairs(tab) do
                if isfunction(v) then
                    local funt = v
                    local name = (scope or "").."::"..tostring(k)
                    tab.UNRETARDED_FUNCTIONS[k] = funt
                    tab[k] = function(...)
                        RP_PUSH(name)
                        local ret={funt(...)}
                        RP_POP()
                        return unpack(ret)
                    end
                end
            end
        end

        RP_COUNTS = {}
        RP_STACK = {}
        function RP_PUSH(name)
            table.insert(RP_STACK, {name, SysTime(), 0})
        end
        function RP_POP()
            local name,t1,subtime = unpack(table.remove(RP_STACK))
            local totaltime = (SysTime() - t1)
            RP_COUNTS[name] = (RP_COUNTS[name] or 0) + (totaltime - subtime)
            if #RP_STACK > 0 then
                RP_STACK[#RP_STACK][3] = RP_STACK[#RP_STACK][3] + totaltime
            end
        end
        timer.Create("RetardedPrint",1,0,function()
            print("\n\nRETARDED THINGS ASC:\n")
    
            local sorted = {}
            for k,v in pairs(RP_COUNTS) do
                table.insert(sorted, {k,v})
            end
            table.SortByMember(sorted, 2, true)
            local total = 0
            for i,stuff in ipairs(sorted) do
                total = total + stuff[2]
                print(unpack(stuff))
            end
            print("TOTAL", total)
            RP_COUNTS = {}
            RP_STACK = {}
        end)

        WHATTODO = MAKE_RETARDED
    end

    WHATTODO(GAMEMODE,"GM")
    for k,v in pairs(hook.GetTable()) do
        WHATTODO(v,k)
    end

    -- this doesnt work for spawned in ents i dont think, which is pretty retarded
    for i,wep in ipairs(weapons.GetList()) do
        WHATTODO(wep,wep.ClassName or "UNKNOWNWEP")
    end
    for i,et in ipairs(scripted_ents.GetList()) do
        WHATTODO(et.t,et.type)
    end

    --TODO timers

    IS_RETARDED = not IS_RETARDED
end


concommand.Add("rp", function( ply, cmd, args )
    if SERVER and IsValid(ply) then return end
    RetardedProfiler()
end)
