-- This file is subject to copyright - contact swampservers@gmail.com for more information.
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

function SS_SanitizeModel(mdl)
    if not isstring(mdl) then return nil end
    if mdl:len() > 100 then return nil end
    if not mdl:StartWith("models/") or not mdl:EndsWith(".mdl") then return nil end

    return mdl
end
