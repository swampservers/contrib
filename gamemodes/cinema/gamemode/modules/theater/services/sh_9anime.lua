-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
local SERVICE = {}
SERVICE.Name = "9Anime"
SERVICE.NeedsCodecs = true
SERVICE.CacheLife = 0

function SERVICE:GetKey(url)
    if (string.match(url.encoded, "9anime.to/watch/(.+)")) then return url.encoded end

    return false
end

if CLIENT then
    function SERVICE:GetVideoInfoClientside(key, callback)
        EmbeddedCheckCodecs(function()
            if (vpanel) then vpanel:Remove() end
            vpanel = vgui.Create("DHTML")
            vpanel:SetSize(1000, 800)
            vpanel:SetAlpha(0)
            vpanel:SetMouseInputEnabled(false)
            vpanel.phase = 0
            vpanel.title = nil
            vpanel.player = nil
            vpanel.data = nil
            vpanel.episode = nil
            vpanel.duration = nil

            timer.Simple(30, function()
                if IsValid(vpanel) then
                    vpanel:Remove()
                    print("Failed")
                    callback()
                end
            end)

            timer.Create("9animeupdate" .. tostring(math.random(1, 100000)), 1, 30, function()
                if IsValid(vpanel) then
                    if vpanel.phase == 0 then
                        vpanel:RunJavascript("x=document.getElementsByClassName('tabs servers notab');if(x)x=x[0].children;for(i=x.length-1;i>=0;i--)if(x[i].innerText=='MyCloud'||x[i].innerText=='Vidstream')x[i].click();")
                        vpanel:RunJavascript("x=document.getElementsByClassName('play')[0];if(x){x.dispatchEvent(new Event('mousedown'));x.click();}")
                        vpanel:RunJavascript("x=document.getElementsByClassName('episodes')[0].children;for(i=0;i<x.length;i++)if(x[i].children[0].className=='active'){console.log('EPISODE:'+x[i].children[0].text);x[i].children[0].click();}")
                        vpanel:RunJavascript("x=document.getElementsByTagName('h2');for(i=0;i<x.length;i++)if(x[i].attributes.itemprop.value=='name')console.log('TITLE:'+x[i].textContent);")
                        vpanel:RunJavascript("x=document.getElementsByTagName('iframe');for(i=0;i<x.length;i++)if(x[i].parentElement.id=='player')console.log('PLAYER:'+x[i].src);")

                        return
                    elseif vpanel.phase == 1 then
                        vpanel:RunJavascript("xmlHttp=new XMLHttpRequest();xmlHttp.open('GET',window.location.origin+'/info/'+window.location.href.substring(window.location.href.lastIndexOf('/')+1)+'?skey='+window.skey,false);xmlHttp.send(null);x=JSON.parse(xmlHttp.responseText).media.sources;for(i in x){if(x[i].file.indexOf('#.mp4')==-1){console.log('URL:'+x[i].file);break;}}")

                        return
                    end
                end
            end)

            function vpanel:ConsoleMessage(msg)
                if msg then
                    msg = tostring(msg)

                    if (LocalPlayer().videoDebug) then
                        print(msg)
                    end

                    if self.phase == 0 then
                        if string.StartWith(msg, "EPISODE:") and not self.episode then
                            self.episode = msg:sub(9, -1)
                            print("EPISODE: " .. self.episode)
                        end

                        if string.StartWith(msg, "TITLE:") and not self.title then
                            self.title = msg:sub(7, -1)
                            print("TITLE: " .. self.title)
                        end

                        if string.StartWith(msg, "PLAYER:") and not self.player then
                            self.player = msg:sub(8, -1)
                            print("PLAYER: " .. self.player)
                        end

                        if (self.episode ~= nil and self.title ~= nil and self.player ~= nil) then
                            vpanel:RunJavascript("location.href='" .. self.player .. "'")
                            self.phase = 1
                        end
                    elseif self.phase == 1 then
                        if string.StartWith(msg, "URL:") then
                            self.data = msg:sub(5, -1)
                            print("URL: " .. self.data)
							self.phase = 2
							
                            if string.find(self.data, ".m3u8") then
                                cachedURL[key] = self.data
                            end
							
							vpanel:OpenURL("https://swamp.sv/s/cinema/file.html")
							timer.Simple(.5, function()
								vpanel:QueueJavascript(string.format("th_video('%s');to_volume=0;setInterval(function(){console.log('DURATION:'+player.duration())},100);", string.JavascriptSafe(self.data)))
							end)
                        end
					elseif self.phase == 2 then
                        if (msg:StartWith("DURATION:") and msg ~= "DURATION:NaN" and msg ~= "DURATION:0" and msg ~= "DURATION:undefined") then
                            self.duration = math.ceil(tonumber(string.sub(msg, 10)))
                            print("DURATION: " .. self.duration)

                            if (self.episode ~= "Full") then
                                self.title = self.title .. " Episode " .. self.episode
                            end

                            callback({
                                title = self.title,
                                data = self.data,
                                duration = self.duration
                            })

                            self:Remove()
                            print("Success!")
                        end
                    end
                end
            end

            vpanel:OpenURL("https://9anime.to/")

            --9anime has a fit if you don't have a referrer
            timer.Simple(.5, function()
				if IsValid(vpanel) then
					vpanel:OpenURL(key)
				end
            end)
        end, function()
            chat.AddText("You need codecs to request this. Press F2.")

            return callback()
        end)
    end

    cachedURL = cachedURL or {}
    function SERVICE:LoadVideo(Video, panel)
        local url = "http://swamp.sv/s/cinema/file.html"
        local k = Video:Data()
        local key = Video:Key()
        panel:EnsureURL(url)
        cachedURL[key] = cachedURL[key] or k
        if string.find(k, ".m3u8") then
            HTTP({
                method = "HEAD",
                url = cachedURL[key],
                headers = {
                    ["Cache-Control"] = "no-cache"
                },
                success = function(code, body, headers)
					if IsValid(panel) then
						if code == 200 then
							local str = string.format("th_video('%s');th_seek(%s);", string.JavascriptSafe(cachedURL[key]), LocalPlayer():GetTheater():VideoCurrentTime(true))
							panel:QueueJavascript(str)
						else
							EmbeddedCheckCodecs(function()
								if (vpanel) then vpanel:Remove() end
								vpanel = vgui.Create("DHTML")
								vpanel:SetSize(1000, 800)
								vpanel:SetAlpha(0)
								vpanel:SetMouseInputEnabled(false)
								vpanel.phase = 0
		
								timer.Simple(20, function()
									if IsValid(vpanel) then
										vpanel:Remove()
										print("Failed to find the video link")
									end
								end)
		
								timer.Create("9animeupdate" .. tostring(math.random(1, 100000)), 1, 20, function()
									if IsValid(vpanel) then
										if vpanel.phase == 0 then
											vpanel:RunJavascript("x=document.getElementsByClassName('tabs servers notab');if(x)x=x[0].children;for(i=x.length-1;i>=0;i--)if(x[i].innerText=='MyCloud'||x[i].innerText=='Vidstream')x[i].click();")
											vpanel:RunJavascript("x=document.getElementsByClassName('play')[0];if(x){x.dispatchEvent(new Event('mousedown'));x.click();}")
											vpanel:RunJavascript("x=document.getElementsByTagName('iframe');for(i=0;i<x.length;i++)if(x[i].parentElement.id=='player')console.log('PLAYER:'+x[i].src);")
		
											return
										elseif vpanel.phase == 1 then
											vpanel:RunJavascript("xmlHttp=new XMLHttpRequest();xmlHttp.open('GET',window.location.origin+'/info/'+window.location.href.substring(window.location.href.lastIndexOf('/')+1)+'?skey='+window.skey,false);xmlHttp.send(null);x=JSON.parse(xmlHttp.responseText).media.sources;for(i in x){if(x[i].file.indexOf('#.mp4')==-1){console.log('URL:'+x[i].file);break;}}")
		
											return
										end
									end
								end)
		
								function vpanel:ConsoleMessage(msg)
									if msg then
										msg = tostring(msg)
		
										if (LocalPlayer().videoDebug) then
											print(msg)
										end
		
										if self.phase == 0 then
											if string.StartWith(msg, "PLAYER:") then
												vpanel:RunJavascript("location.href='" .. msg:sub(8, -1) .. "'")
												self.phase = 1
											end
										elseif self.phase == 1 then
											if string.StartWith(msg, "URL:") then
												cachedURL[key] = msg:sub(5, -1)
												self:Remove()
												local str = string.format("th_video('%s');th_seek(%s);", string.JavascriptSafe(cachedURL[key]), LocalPlayer():GetTheater():VideoCurrentTime(true))
												panel:QueueJavascript(str)
											end
										end
									end
								end
		
								vpanel:OpenURL("https://9anime.to/")
		
								--9anime has a fit if you don't have a referrer
								timer.Simple(.5, function()
									if IsValid(vpanel) then
										vpanel:OpenURL(Video:Key())
									end
								end)
							end, function()
								chat.AddText("You need codecs to view this. Press F2.")
								return
							end)
						end
					end
                end,
                failed = function(err) end
            })
        else
            local str = string.format("th_video('%s');", string.JavascriptSafe(k))
            panel:QueueJavascript(str)
        end
    end
end

theater.RegisterService('9anime', SERVICE)
