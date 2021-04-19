-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- Not an entity! Makes autorun_late work, and is here because of this: https://wiki.facepunch.com/gmod/Lua_Loading_Order
local files, directories = file.Find("autorun_late/*", "LUA")

for _, f in ipairs(files) do
    f = "autorun_late/" .. f
    AddCSLuaFile(f)
    include(f)
end

if SERVER then
    local files, directories = file.Find("autorun_late/server/*", "LUA")

    for _, f in ipairs(files) do
        f = "autorun_late/server/" .. f
        include(f)
    end
end

local files, directories = file.Find("autorun_late/client/*", "LUA")

for _, f in ipairs(files) do
    f = "autorun_late/client/" .. f
    AddCSLuaFile(f)

    if CLIENT then
        include(f)
    end
end

hook.Add("PostGamemodeLoaded", "Test2", function(gm)
    print(gm)

    if gm then
        print(gm.FolderName)
    end
end)

-- Just to prevent lua error
DEFINE_BASECLASS("base_anim")