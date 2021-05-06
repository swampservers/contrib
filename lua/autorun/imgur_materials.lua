-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local Entity = FindMetaTable("Entity")

--returns nil if invalid
function SanitizeImgurId(id)
    if not isstring(id) or id:len() < 5 or id:len() > 100 then return end
    id = table.remove(string.Explode("/", id, false))
    id = id:sub(1, -4) .. id:sub(-3):lower()
    id = id:gsub("%.jpeg", ".jpg")
    local id2 = " " .. id .. " "
    if id2:gsub("jp", "pn"):gsub(" %w+%.png ", "", 1) ~= "" then return end

    return id
end

function Entity:GetImgur()
    local url = self:GetNWString("imgur_url")
    if url ~= "" then return url, self:GetNWString("imgur_own") end
end

if SERVER then
    function Entity:SetImgur(url, own)
        url = SanitizeImgurId(url)

        if url then
            self:SetNWString("imgur_url", url)
            self:SetNWString("imgur_own", own or "")
        else
            self:SetNWString("imgur_url", "")
            self:SetNWString("imgur_own", "")
        end
    end

    hook.Add("OnSteamIDBanned", "ImgurEntityCleaner", function(id)
        for k, v in pairs(ents.GetAll()) do
            local url, own = v:GetImgur()

            if own == id then
                v:SetImgur()
            end
        end
    end)
end