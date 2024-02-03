-- print("hi")
-- local x = setmetatable({}, {__call=print})
local function basememo(func, meta_params)
    local tab, index = nil, function(tab, key)
        local value, uncached_value = func(key)

        if value == nil then
            return uncached_value
        else
            tab[key] = value

            return value
        end
    end

    if meta_params == nil then
        tab, meta_params = {}, {
            __index = index
        }
    else
        tab, meta_params.__index = meta_params[1], index

        if tab == nil then
            tab = {}
        else
            meta_params[1] = nil
        end
    end

    return setmetatable(tab, meta_params)
end

-- should support vararg and be called with __call
-- note: stack will belong to callee
function multimemo(func, stack, nparams)
    if #stack == nparams - 1 then
        return basememo(function(arg)
            stack[nparams] = arg

            return func(unpack(stack))
        end)
    else
        return basememo(function(arg)
            local i, childstack = 1, {}

            while stack[i] ~= nil do
                childstack[i] = stack[i]
                i = i + 1
            end

            childstack[i] = arg

            return multimemo(func, childstack, nparams)
        end)
    end
end

--- Wraps a function with a cache to store computations when the same arguments are reused. Google: Memoization
-- The returned memo should be "called" by indexing it:
-- a = memo(function(x,y) return x*y end)
-- print(a[2][3]) --prints 6
-- If the function returns nil, nothing will be stored, and the second return value will be returned by the indexing.
-- params are extra things to put in the metatable (eg __mode), or index 1 can be a default initialization for the table
function memo(func, meta_params)
    local nparams = debug.getinfo(func, "u").nparams

    if nparams > 1 then
        assert(meta_params == nil, "params only for single argument memo")

        return multimemo(func, {}, nparams)
    else --if nparams==1 then
        return basememo(func, meta_params)
    end

    -- else
    --     error("No arguments to memo")
    assert(nparams >= 1, "Need 1 argument")
    -- Note: we must support a custom __call in params if we even want a default __call
    -- getmetatable(the_memo).__call = function()

    return the_memo
end

Memo = memo
--- Returns a table such that when indexing the table, if the value doesn't exist, the constructor will be called with the key to initialize it.
-- function defaultdict(constructor, args)
--     assert(args==nil)
--     return setmetatable(args or {}, {
--         __index = function(tab, key)
--             local d = constructor(key)
--             tab[key] = d
--             return d
--         end,
--         __mode = mode
--     })
-- end
-- -- __mode = weak and "v" or nil
-- local memofunc = {
--     function(func)
--         return setmetatable({}, {
--             __index = function(tab, key)
--                 local d = func(key)
--                 tab[key] = d
--                 return d
--             end
--         })
--     end
-- }
-- for i=2,10 do
--     local nextmemo = memofunc[i-1]
--     memofunc[i] = function(func, weak)
--         return memo(function(arg) 
--             return nextmemo[funci(function(arg) return func(arg) end, weak)
--         end, weak)
--     end
-- end
