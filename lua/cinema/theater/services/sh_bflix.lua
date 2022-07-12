-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local SERVICE = {}
SERVICE.Name = "BFlix"
SERVICE.NeedsCodecs = true
SERVICE.CacheLife = 0

function SERVICE:GetKey(url)
    if string.match(url.encoded, "bflix.gg/watch%-%w-/.-%d-%.%d-$") then return url.encoded end

    return false
end

if CLIENT then
    function SERVICE:GetVideoInfoClientside(key, callback)
        local info = {}
        local isTV = string.match(key, "bflix.gg/watch%-tv")
        local year, episode, data, subs

        --fetches are asynchronous so they need to be handled this way
        timer.Create("AwaitBFlixFetches", 1, 15, function()
            if timer.RepsLeft("AwaitBFlixFetches") == 0 then
                print("Failed")
                timer.Remove("AwaitBFlixFetches")
                callback()
            end

            if data and subs and info.thumb and info.title and info.duration then
                info.title = info.title .. " " .. (isTV and episode or year)
                info.data = util.TableToJSON({
                    url = data,
                    subs = subs
                })
                timer.Remove("AwaitBFlixFetches")
                callback(info)
            end
        end)

        local catid, epid = string.match(key, "%-(%d-)%.(%d-)$")

        --embed link
        http.Fetch("https://bflix.gg/ajax/get_link/" .. epid, function(body, length, headers, code)
            local t = util.JSONToTable(body)
            episode = "| " .. t['title']

            --embed api
            http.Fetch("https://mzzcloud.life/ajax/embed-4/getSources?id=" .. string.match(t['link'], "mzzcloud.life/.-/(.-)%?z="), function(body, length, headers, code)
                t = util.JSONToTable(body)
                local url = t['sources'][1]['file']

                if #t['tracks'] > 0 then
                    vgui("DFrame", function(r)
                        r:SetSize(300, 300)
                        r:MakePopup()
                        r:SetTitle("Choose the Subtitles")
                        r:Center()

                        vgui("DScrollPanel", function(p)
                            p:Dock(FILL)
                            local tt = t['tracks']

                            table.insert(tt, 0, {
                                ['label'] = '(None)',
                                ['file'] = ''
                            })

                            for _, v in pairs(tt) do
                                local b = p:Add("DButton")
                                b:SetText(v['label'])
                                b:Dock(TOP)
                                b:DockMargin(0, 0, 0, 2)

                                function b:DoClick()
                                    subs = v['file']
                                    r:Close()
                                end
                            end
                        end)
                        function r:Close()
                            subs = subs or ''
                            r:Remove()
                        end
                    end)
                else
                    subs = ''
                end

                --m3u8 playlist
                http.Fetch(url, function(body)
                    local duration = 0
                    local resolution = ""
                    local stream = ""
                    for _, v in ipairs(string.Split(body, "\n")) do
                        if string.find(v, "RESOLUTION=") then
                            resolution = string.Split(v,"RESOLUTION=")[2]
                        end
                        if string.find(v, ".m3u8") then
                            if (resolution == "1280x720") then
                                url = v
                            end
                            stream = v
                        end
                    end

                    --m3u8 stream
                    http.Fetch(stream, function(body)
                        if #string.Split(body, "\n") < 2 then
                            callback()

                            return
                        end

                        for _, v in ipairs(string.Split(body, "\n")) do
                            if v:StartWith("#EXTINF:") then
                                duration = duration + tonumber(string.Split(string.sub(v, 9), ",")[1])
                            end
                        end

                        info.duration = math.ceil(duration)
                        data = url
                    end, function(err)
                        print(err)
                    end)
                end, function(err)
                    print(err)
                end)
            end, function(err)
                print(err)
            end, {
                ["X-Requested-With"] = "XMLHttpRequest" --required
                
            })
        end, function(err)
            print(err)
        end)

        --player page
        http.Fetch(key, function(body, length, headers, code)
            local thumb = string.match(body, '"film%-poster%-img".-src="(.-)"')
            info.thumb = string.Replace(thumb, string.match(thumb, '/(%d-x%d-)/'), "99999x99999") --max resolution
            info.title = string.match(body, '"film%-poster%-img".-title="(.-)"')
            year = "(" .. string.match(body, 'Released:.-(%d%d%d%d)') .. ")"
        end, function(err)
            print(err)
        end)
    end

    function SERVICE:LoadVideo(Video, panel)
        panel:EnsureURL("https://swamp.sv/s/cinema/file.html")
        local key = util.JSONToTable(Video:Data()).url
        local subs = string.JavascriptSafe(util.JSONToTable(Video:Data()).subs)

        if subs ~= '' then
            subs = "'https://holyublocker.herokuapp.com/search/'+encodeURIComponent(('" .. subs .. "').split('').map((char,ind)=>ind%2?String.fromCharCode(char.charCodeAt()^2):char).join(''))"
        end

        panel:QueueJavascript(string.format("th_video('%s',%s);", string.JavascriptSafe(key), subs))
    end
end

theater.RegisterService('bflix', SERVICE)
