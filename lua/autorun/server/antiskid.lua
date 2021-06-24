-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
-- hook.Add("PlayerInitialSpawn", "antiskid", function(ply)
--     if not ply:SteamID64() then return end --singleplayer

--     http.Fetch("https://steamcommunity.com/profiles/" .. tostring(ply:SteamID64()), function(body, len, headers, code)
--         avatar = string.match(body, 'avatars/(%x+/%x+_full%.jpg)')

--         if avatar ~= nil then
--             http.Fetch("https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/" .. avatar, function(body, len, headers, code)
--                 if code == 404 then
--                     ply:Kick("woah a missing profile picture? you're so cool bro")
--                 end
--             end, function(err) end)
--         end
--     end, function(err) end)
-- end)

concommand.Add("triforce", function(ply)
    ply:Freeze(true)
end)