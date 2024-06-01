-- This file is subject to copyright - contact swampservers@gmail.com for more information.
if SERVER then
    util.AddNetworkString("Print")
else
    net.Receive("Print", function()
        for i, v in ipairs(("\n"):Explode(net.ReadString())) do
            print(v)
        end
    end)
end

function time_function(func)
    local t = SysTime()
    func()

    return SysTime() - t
end

--- Prints how long it takes to run a function, averaging over a large number of samples with minimal overhead
function bench(func, reps)
    if istable(func) then
        print("Benchmarking " .. table.Count(func) .. " functions...")
    end

    if isfunction(func) and debug.getinfo(func, "u").nparams == 1 then
        print("Comparing running with false vs true")
        local basef = func

        func = {
            ["false"] = function()
                basef(false)
            end,
            ["true"] = function()
                basef(true)
            end
        }
    end

    if istable(func) then
        -- local function pop()
        --     if table.IsEmpty(func) then
        --         print("Done")
        --         return
        --     end
        for i = 1, reps or 1 do
            for k, v in pairs(func) do
                -- func[k] = nil
                print(k .. ":")
                bench(v)
                -- break
            end
        end
        --     timer.Simple(0.5, pop)
        -- end
        -- timer.Simple(0.5, pop)

        return
    end

    -- TODO: pass ... if that is possible
    -- , calls
    local t, calls

    if calls then
        t = time_function(function()
            for i = 1, calls do
                func()
            end
        end) / calls
    else
        repeat
            calls = calls and calls * 2 or 1

            t = time_function(function()
                for i = 1, calls do
                    func()
                end
            end)
        until t > 0.3
        t = t / calls
    end

    print(("Takes %.9f ms"):format(t * 1000))
end
--   function list_iter(t)
--     local i = 0
--     return function () i = i + 1 return t[i] end
--   end
--   local tab = {}
--   for i=1,100000 do
--     table.insert(tab, i)
--   end
-- print("GO")
-- bench(function() local n=#tab local i=0 for k = 1,n do i=i+tab[k] end end)
-- bench(function() local i=0 for _,v in ipairs(tab) do i=i+v end end)
-- bench(function() local i=0 for v in list_iter(tab) do i=i+v end end)
-- bench(function() local i=0 for k,v in next,tab do i=i+v end end)
-- bench(function() local i=0 for k,v in next,tab do i=i+k end end)
-- bench(function() local i=0 for k in next,tab do i=i+k end end)
-- bench(function() local i=0 for k,v in pairs(tab) do i=i+v end end)
-- print("DONE")
-- ipairs is fastest for ordered table, next,tab is fastest for assoc table (ommitting v doesn't matter for key only iteration)
