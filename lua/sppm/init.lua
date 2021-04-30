-- This file is subject to copyright - contact swampservers@gmail.com for more information.
PPM = PPM or {}
PPM.serverPonydata = PPM.serverPonydata or {}
PPM.isLoaded = false
include("items.lua")
include("variables.lua")
include("pony_player.lua")
include("resources.lua")
include("preset.lua")

if CLIENT then
    include("render_texture.lua")
    include("render.lua")
    include("editor3.lua")
    include("editor3_body.lua")
    include("editor3_presets.lua")
    include("presets_base.lua")
end

if SERVER then
    include("serverside.lua")
end