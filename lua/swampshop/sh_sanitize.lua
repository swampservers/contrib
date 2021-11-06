-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
AddCSLuaFile()


function SS_SanitizeVector(val, min, max)
    return isvector(val) and val:Clamp(min, max) or nil
end

function SS_SanitizeColor(val)
    return SS_SanitizeVector(val, Vector(0, 0, 0), Vector(5, 5, 5))
end

function SS_SanitizeImgur(imgur)
    local url = istable(imgur) and SanitizeImgurId(imgur.url)

    return url and {
        url = url
    } or nil
end
