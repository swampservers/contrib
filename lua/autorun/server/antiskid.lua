-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

hook.Add("PlayerInitialSpawn", "antiskid", function(ply)
    http.Fetch("https://steamcommunity.com/profiles/"..tostring(ply:SteamID64()),
        function(body,len,headers,code)
            avatar = string.match(body,'avatars/(%x+/%x+_full%.jpg)')
            if avatar != nil then
                http.Fetch("https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/"..avatar,
                    function(body,len,headers,code)
                        if code == 404 then
                            ply:Kick("gay fat ugly loser missing profile pic")
                        end
                    end,
                    function(err)
                    end
                )
            end
        end,
        function(err)
        end
    )
end)
