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

            timer.Simple(45, function()
                if IsValid(vpanel) then
                    vpanel:Remove()
                    print("Failed")
                    callback()
                end
            end)

            timer.Create("9animeupdate" .. tostring(math.random(1, 100000)), 1, 45, function()
                if IsValid(vpanel) then
                    if vpanel.phase == 0 then
                        vpanel:RunJavascript("x=document.getElementsByClassName('tabs servers notab')[0].children;for(i=0;i<x.length;i++)if(x[i].innerText=='Vidstream')x[i].click();")
                        vpanel:RunJavascript("x=document.getElementsByClassName('play')[0];if(x){x.dispatchEvent(new Event('mousedown'));x.click();}")
                        vpanel:RunJavascript("x=document.getElementsByClassName('episodes')[0].children;for(i=0;i<x.length;i++)if(x[i].children[0].className=='active'){console.log('EPISODE:'+x[i].children[0].text);x[i].children[0].click();}")
                        vpanel:RunJavascript("x=document.getElementsByTagName('h2');for(i=0;i<x.length;i++)if(x[i].attributes.itemprop.value=='name')console.log('TITLE:'+x[i].textContent);")
                        vpanel:RunJavascript("x=document.getElementsByTagName('iframe');for(i=0;i<x.length;i++)if(x[i].parentElement.id=='player')console.log('PLAYER:'+x[i].src);")

                        return
                    elseif vpanel.phase == 1 then
                        vpanel:RunJavascript("if(typeof jwplayer==='function'){var jwp=jwplayer('player');jwp.setMute(1);jwp.play();console.log('DURATION:'+jwp.getDuration());}")
                        vpanel:RunJavascript("xmlHttp=new XMLHttpRequest();xmlHttp.open('GET',window.location.origin+'/info/'+window.location.href.substring(window.location.href.lastIndexOf('/')+1)+'?skey='+window.skey,false);xmlHttp.send(null);console.log('URL:'+JSON.parse(xmlHttp.responseText).media.sources[0].file);")

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

                        return
                    elseif self.phase == 1 then
                        if string.StartWith(msg, "URL:") and not self.data then
                            self.data = msg:sub(5, -1)
                            print("URL: " .. self.data)
                        end

                        if (msg:StartWith("DURATION:") and msg ~= "DURATION:NaN" and msg ~= "DURATION:0" and msg ~= "DURATION:undefined" and not self.duration) then
                            self.duration = math.ceil(tonumber(string.sub(msg, 10)))
                            print("DURATION: " .. self.duration)
                        end

                        if (self.data ~= nil and self.duration ~= nil) then
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

                        return
                    end
                end
            end

            vpanel:OpenURL("https://swamp.sv/video")

            --9anime has a fit if you don't have a referrer
            timer.Simple(.5, function()
                vpanel:OpenURL(key)
            end)
        end, function()
            chat.AddText("You need codecs to request this. Press F2.")

            return callback()
        end)
    end

    function SERVICE:LoadVideo(Video, panel)
        local url = "http://swamp.sv/s/cinema/file.html"
        local k = Video:Data()

        if string.find(k, ".m3u8") then
            url = "http://swamp.sv/s/cinema/hls.html"
        end

        panel:EnsureURL(url)
        -- Let the webpage handle loading a video
        local str = string.format("th_video('%s');", string.JavascriptSafe(k))
        panel:QueueJavascript(str)
    end
end

theater.RegisterService('9anime', SERVICE)
