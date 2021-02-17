-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

local SERVICE = {}

SERVICE.Name 		= "ThirdParty"

SERVICE.Mature = true

SERVICE.NeedsCodecs = true

SERVICE.LivestreamCacheLife = 0

SERVICE.CacheLife = 0

function SERVICE:GetKey( tbl )
	local t = util.JSONToTable(tbl.encoded)
	if (t and t["referer"] and t["key"]) then
		if (url.parse2(t["referer"]).scheme and url.parse2(t["key"]).scheme) then
			return tbl.encoded
		end
	end
	return false
end

if CLIENT then
	local function LoadCustomPage(panel,js,k)
		local url = "http://swampservers.net/cinema/file.html"
		if string.find(k,".m3u8") then
			url = "http://swampservers.net/cinema/hls.html"
		end
		http.Fetch(url,function(body)
			if IsValid(panel) then
				--panel:StopLoading()
				panel:RunJavascript("document.write('"..string.JavascriptSafe(body).."');void 0;")
				panel:RunJavascript(js)
				panel:RunJavascript("setInterval(function(){killiframes=document.getElementsByTagName('iframe');while(killiframes[0]){killiframes[0].parentNode.removeChild(killiframes[0])}},100);") --kill foreign iframes like ads
			end
		end,function(err) print("Failed to fetch player page: "..err) end)
	end

	function SERVICE:GetVideoInfoClientside(key, callback)
		callback()
	end
	
	local loaded = false
	function SERVICE:LoadVideo( Video, panel )
		local t = util.JSONToTable(Video:Key())
		local referer = t["referer"]
		local realkey = t["key"]
		local str = string.format("cinemabool=setInterval(function(){if(typeof(th_video)!='undefined'){th_video('%s');th_volume(%s);clearInterval(cinemabool)}},100);",string.JavascriptSafe(realkey),theater.GetVolume())
		local b = true
		loaded = false
		timer.Simple(5,function() --failsafe
			if (b) then
				LoadCustomPage(panel,str,realkey)
				loaded = true
				b = false
			end
		end)
		
		function panel:ConsoleMessage(msg)
			local smsg = tostring(msg)
			if (LocalPlayer().videoDebug) then print(smsg) end
			if (smsg:StartWith("HREF:") and smsg == "HREF:"..referer and b) then
				LoadCustomPage(panel,str,realkey)
				loaded = true
				b = false
			end
		end
		
		panel:EnsureURL(referer)
	end
	
	local function RandomString()
		local s = {}
		for i=1,10 do
			s[i] = string.char(math.random(65,90))
		end
		return table.concat(s)
	end
	
	function SERVICE:SetVolume(vol, panel)
		local nvar = RandomString()
		panel:RunJavascript("var "..nvar.."=setInterval(function(){if(typeof(th_volume)!='undefined'){th_volume("..vol..");clearInterval("..nvar..");}},100);")
	end
	
	function SERVICE:SeekTo(time, panel)
		local nvar = RandomString()
		local str = "var "..nvar.."=setInterval(function(){if(typeof(th_seek)!='undefined'){th_seek("..time..");clearInterval("..nvar..");}},100);"
		if (not loaded) then
			timer.Simple(3,function() if IsValid(panel) then panel:RunJavascript(str) end end)
		else
			panel:RunJavascript(str)
		end
	end
end

theater.RegisterService( 'thirdparty', SERVICE )
