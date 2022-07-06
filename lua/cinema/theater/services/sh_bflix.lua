-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local SERVICE = {}
SERVICE.Name = "BFlix"
--SERVICE.Mature = true
SERVICE.NeedsCodecs = true
SERVICE.CacheLife = 0

function SERVICE:GetKey(url)
    if util.JSONToTable(url.encoded) then return false end
    if string.match(url.encoded, "bflix.gg/watch%-%w-/.-%d-%.%d-$") then return url.encoded end

    return false
end

if CLIENT then
    function SERVICE:GetVideoInfoClientside(key, callback)

        local info = {}
        local isTV = string.match(key, "bflix.gg/watch%-tv")
        local year,episode

        timer.Create("AwaitBFlixFetches", 1, 15, function() //fetches are asynchronous so they need to be handled this way
            if timer.RepsLeft("AwaitBFlixFetches") == 0 then
                print("Failed")
                timer.Remove("AwaitBFlixFetches")
                callback()
            end
            if info.data and info.thumb and info.title and info.duration then
                info.title = info.title .. " " .. (isTV and episode or year)
                timer.Remove("AwaitBFlixFetches")
                callback(info)
            end
        end)

        local catid,epid = string.match(key,"%-(%d-)%.(%d-)$")

        http.Fetch("https://bflix.gg/ajax/get_link/"..epid, //embed link
            function(body,length,headers,code)
                local t = util.JSONToTable(body)
                episode = "| " .. t['title']
                http.Fetch("https://mzzcloud.life/ajax/embed-4/getSources?id="..string.match(t['link'],"mzzcloud.life/.-/(.-)%?z="), //embed api
                    function(body,length,headers,code)
                        local subs = ''
                        t = util.JSONToTable(body)
                        for _,v in pairs(t['tracks']) do
                            if string.match(v['label'],'[Ee]nglish') then
                                subs = v['file']
                                break
                            end
                        end
                        info.data = util.TableToJSON({
                            url = t['sources'][1]['file'],
                            subs = subs
                        })
                        http.Fetch(t['sources'][1]['file'], //m3u8 playlist
                            function(body)
                                local duration = 0
                                for k, v in ipairs(string.Split(body, "\n")) do
                                    if string.find(v, ".m3u8") then
                                        http.Fetch(v, function(body) //m3u8 stream
                                            if #string.Split(body, "\n") < 2 then
                                                callback()
                                                return
                                            end
                                            for k, v in ipairs(string.Split(body, "\n")) do
                                                if v:StartWith("#EXTINF:") then
                                                    duration = duration + tonumber(string.Split(string.sub(v, 9), ",")[1])
                                                end
                                            end
                                            info.duration = math.ceil(duration)
                                        end,
                                        function(err)
                                            print(err)
                                        end)
                                        break
                                    end
                                end
                            end,
                            function(err)
                                print(err)
                            end)
                    end,
                    function(err)
                        print(err)
                    end,
                    {["X-Requested-With"] = "XMLHttpRequest"} //required
                )
            end,
            function(err)
                print(err)
            end
        )

        http.Fetch(key, //player page
            function(body,length,headers,code)
               local thumb = string.match(body,'"film%-poster%-img".-src="(.-)"')
               info.thumb = string.Replace(thumb,string.match(thumb,'/(%d-x%d-)/'),"99999x99999") //max resolution
               info.title = string.match(body,'"film%-poster%-img".-title="(.-)"')
               year = "(" .. string.match(body,'Released:.-(%d%d%d%d)') .. ")"
            end,
            function(err)
                print(err)
            end
        )
    end

    function SERVICE:LoadVideo(Video, panel)
        panel:EnsureURL("https://swamp.sv/s/cinema/file.html")
        local key = util.JSONToTable(Video:Data()).url
        local subs = util.JSONToTable(Video:Data()).subs
        panel:QueueJavascript("xor=(str)=>{return 'https://holyublocker.herokuapp.com/search/'+encodeURIComponent(str.toString().split('').map((char,ind)=>ind%2?String.fromCharCode(char.charCodeAt()^2):char).join(''));}") //proxy because chromium doesn't like the sub domain
        local str = string.format("th_video('%s',xor('%s'));", string.JavascriptSafe(key),string.JavascriptSafe(subs))
        panel:QueueJavascript(str)
    end
end

theater.RegisterService('bflix', SERVICE)
