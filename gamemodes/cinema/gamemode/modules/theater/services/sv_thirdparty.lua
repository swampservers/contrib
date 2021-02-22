-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

sv_GetVideoInfo = sv_GetVideoInfo or {}

sv_GetVideoInfo.thirdparty = function(self, key, ply, onSuccess, onFailure)

	local t = util.JSONToTable(key)
	local referer = t["referer"]
	local realkey = t["key"]

	HTTP({
		method="HEAD",
		url=realkey,
		headers={
				["Referer"]=referer,
				["Origin"]=referer,
				["Cache-Control"] = "no-cache"
		},
		success=function(code,body,headers)
			ply:PrintMessage(HUD_PRINTCONSOLE,"REFERER HEADER "..code)
			if (string.find(realkey,".m3u8") and ((not headers["Access-Control-Allow-Origin"]) or headers["Access-Control-Allow-Origin"] and (headers["Access-Control-Allow-Origin"] != "*" and headers["Access-Control-Allow-Origin"] != referer))) then
				ply:PrintMessage(HUD_PRINTCONSOLE,"WRONG ORIGIN")
				if (headers["Access-Control-Allow-Origin"]) then
					ply:PrintMessage(HUD_PRINTCONSOLE,"TRY REFERER: "..headers["Access-Control-Allow-Origin"])
				end
			end
		end,
		failed=function(err) ply:PrintMessage(HUD_PRINTCONSOLE,"REFERER HEADER ERROR: "..err) end
	})
	
	HTTP({
		method="HEAD",
		url=realkey,
		headers={
				["Referer"]="https://swampservers.net/",
				["Origin"]="https://swampservers.net/",
				["Cache-Control"] = "no-cache"
		},
		success=function(code,body,headers)
			ply:PrintMessage(HUD_PRINTCONSOLE,"SWAMP HEADER "..code)
			if (code == 200 and theater.ExtractURLInfo(realkey) and not string.find(realkey,".m3u8")) then
				ply:PrintMessage(HUD_PRINTCONSOLE,"SUCCESS")
			end
		end,
		failed=function(err) ply:PrintMessage(HUD_PRINTCONSOLE,"SWAMP HEADER ERROR: "..err) end
	})

	theater.GetVideoInfoClientside(self:GetClass(), key, ply, onSuccess, onFailure)
end
