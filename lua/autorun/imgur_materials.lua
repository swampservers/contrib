﻿-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local Entity = FindMetaTable("Entity")

--[[
To use web materials, just call in your draw hook:

mat = ImgurMaterial(args)

Then set/override material to mat

args is a table with the following potential keys:
    id: from SanitizeImgurId
    owner: player/steamid
    pos: rendering position, used for distance loading
    stretch: bool = false (stretch to fill frame, or contain to maintain aspect)
    shader: str = "VertexLitGeneric"
    params: str = "{}" (NOT A TABLE, A STRING THAT CAN BE PARSED AS A TABLE)
    pointsample: bool = false
    worksafe: bool = false
]]
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

function AsyncSanitizeImgurId(id, callback)
    nid = SanitizeImgurId(id)

    if nid then
        timer.Simple(0, function()
            callback(nid)
        end)

        return
    end

    -- expect at least 1 slash: we need gallery/id or a/id
    if not isstring(id) or id:len() < 5 or id:len() > 100 or not string.find(id, "/") then
        timer.Simple(0, function()
            callback(nil)
        end)

        return
    end

    local split = string.Explode("/", id, false)

    HTTP({
        method = "GET",
        url = "https://imgur.com/" .. split[#split - 1] .. "/" .. split[#split],
        success = function(code, body, headers)
            if (code == 200) then
                callback(SanitizeImgurId(string.match(body, "og:image:height.+content=\"(.+)%?fb")))
            else
                callback(nil)
            end
        end,
        failed = function(err)
            callback(nil)
        end
    })
end

local inflight, q, qcb

local function donext()
    if inflight then return end
    local nq, nqcb = q, qcb
    q, qcb = nil, nil
    inflight = true
    local already = false

    local callback = function(id)
        if already then return end
        already = true
        nqcb(id)
        inflight = false

        if q then
            donext()
        end
    end

    timer.Simple(30, function()
        if not already then
            callback(nil)
            error("Imgur timeout")
        end
    end)

    AsyncSanitizeImgurId(nq, callback)
end

function SingleAsyncSanitizeImgurId(url, callback)
    if qcb then
        qcb(nil)
    end

    q, qcb = url, callback
    donext()
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