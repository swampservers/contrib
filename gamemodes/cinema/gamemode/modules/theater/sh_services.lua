-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
module("theater", package.seeall)
Services = {}

function RegisterService(class, object, base)
    if not class or not object then return end

    if not base then
        base = "base"
    end

    Services[class] = object
    Services[class].ClassName = class

    if not Services[base] then
        ErrorNoHalt("theater.RegisterService: Base class '" .. tostring(base) .. "' not found!")
    else
        if class == "base" then return end

        setmetatable(Services[class], {
            __index = Services[base]
        })
    end
end

function GetServiceByClass(class)
    return Services[class]
end

-- Load the base service before anything else
include('services/sh_base.lua')
Loader.Load("modules/theater/services")