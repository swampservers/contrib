-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local SERVICE = {}
SERVICE.Name = "LookMovie"
--SERVICE.Mature = true
SERVICE.NeedsCodecs = true
SERVICE.CacheLife = 0

--local domains = {"lmplayer.xyz", "contentmatserishere.com", "thisistheplacetowatch.com", "watchthesestuff.com", "bestofworldcontent.com", "wehaveallcontent.com", "bestalltimemovies.xyz", "contentforall.xyz", "watchmorestuff.xyz", "lookmovie%d+.xyz"}
--local domains = {"lookmovie.site", "lookmovie%d+.la"}

function SERVICE:GetKey(url)
    if util.JSONToTable(url.encoded) then return false end

    --if string.match(url.encoded, "lookmovie.io/movies/view/(.+)") or string.match(url.encoded, "lookmovie.io/shows/view/(.+)#.+%-(%d+)$") then return url.encoded end
    --for _, v in pairs(domains) do
    --    if string.match(url.encoded, v .. "/m/./(.+)/s") or string.match(url.encoded, v .. "/s/./(.+)/s#") then return url.encoded end
    --end
    if string.match(url.encoded, "lookmovie%d*%.%w+/m/.+/(.+)/s") or string.match(url.encoded, "lookmovie%d*%.%w+/s/.+/(.+)/s#") then return url.encoded end
    --if string.match(url.encoded, "lookmovie%d*%.%w+/%w+/play/(.+)") then return url.encoded end

    return false
end

if CLIENT then
    function SERVICE:GetVideoInfoClientside(key, callback)
        if vpanel then
            vpanel:Remove()
        end

        vpanel = vgui.Create("DHTML")
        vpanel:SetSize(ScrW(), ScrH())
        vpanel:SetAlpha(0)
        vpanel:SetMouseInputEnabled(false)
        vpanel.response = ""
        local info = {}
        local isTV = string.match(key, "/s/.+/(.+)/s#")

        local function onFetchReceive(body)
            local t = util.JSONToTable(body)

            if t == nil then
                callback()
            else
                local url = t["streams"]["720p"] or t["streams"]["480p"] or t["streams"]["360p"] or t["streams"]["1080p"]
                local subs = ""

                if isTV then
                    url = t["streams"][720] or t["streams"][480] or t["streams"][360] or t["streams"][1080]
                end

                --find a good way to implement subtitle track choosing? lookmovie can have dozens of tracks and over a dozen tracks just for english with varying quality
                --[[for k,v in pairs(t["subtitles"]) do
                    if v["language"] == "English" then
                        subs = "https://lookmovie.io"..v["file"]
                        break
                    end
                end]]
                --change to t["streams"] and load based on quality setting?
                info.data = util.TableToJSON({
                    url = url,
                    subs = subs
                })

                self:Fetch(url, function(sbody)
                    local duration = 0

                    if #string.Split(sbody, "\n") < 2 then
                        callback()

                        return
                    end

                    for k, v in ipairs(string.Split(sbody, "\n")) do
                        if v:StartWith("#EXTINF:") then
                            duration = duration + tonumber(string.Split(string.sub(v, 9), ",")[1])
                        end
                    end

                    info.duration = math.ceil(duration)

                    if Me.videoDebug then
                        PrintTable(info)
                    end

                    callback(info)
                end, callback)
            end
        end

        timer.Simple(20, function()
            if IsValid(vpanel) then
                vpanel:Remove()
                print("Failed")
                callback()
            end
        end)

        timer.Create("lookmovieupdate" .. tostring(math.random(1, 100000)), 1, 10, function()
            if IsValid(vpanel) then
                vpanel:RunJavascript("console.log('CAPTCHA:'+document.title);")
                vpanel:RunJavascript("var stor = window['movie_storage'] || window['show_storage'];")

                if not info.title or not info.thumb then
                    if isTV then
                        vpanel:RunJavascript("if(stor){x=stor['seasons'];for(var i in x){if(x[i].id_episode==" .. string.match(key, "#.+%-(%d+)$") .. ")console.log('TITLE:'+stor.title+' ('+stor.year+') S'+x[i].season+' E'+x[i].episode+(x[i].title ? ' | '+x[i].title : ''));}console.log('THUMB:'+stor.poster_medium);}")
                    else
                        vpanel:RunJavascript("if(stor){console.log('TITLE:'+stor.title+' ('+stor.year+')');console.log('THUMB:'+stor.movie_poster);}")
                    end
                end

                if vpanel.response == "" then
                    vpanel:RunJavascript("if(stor){xmlHttp=new XMLHttpRequest();xmlHttp.open('GET',window.location.origin+'/api/v1/security/" .. (isTV and "episode" or "movie") .. "-access?id_" .. (isTV and "episode" or "movie") .. "=" .. (isTV and string.match(key, "#.+%-(%d+)$") .. "'" or "'+stor.id_movie") .. ",false);xmlHttp.send(null);console.log('JSON:'+xmlHttp.responseText);}")
                end
            end
        end)

        function vpanel:ConsoleMessage(msg)
            if msg then
                msg = tostring(msg)

                if Me.videoDebug then
                    print(msg)
                end

                if string.StartWith(msg, "CAPTCHA:") then
                    if msg:sub(9, -1) == 'Thread Defence' then
                        self:Remove()
                        chat.AddText("[red]Visit lookmovie.site, fill out the captcha, and then request the " .. (isTV and "tv show" or "movie") .. " again.")
                        callback()
                    end
                end

                if string.StartWith(msg, "TITLE:") and not info.title then
                    info.title = string.Replace(msg:sub(7, -1), "\\'", "'")
                end

                if string.StartWith(msg, "THUMB:") and not info.thumb then
                    info.thumb = msg:sub(7, -1)
                end

                if string.StartWith(msg, "JSON:") and self.response == "" then
                    self.response = msg:sub(6, -1)
                end

                if self.response ~= "" and info.title and info.thumb then
                    print("success")
                    self:Remove()
                    onFetchReceive(self.response)
                end
            end
        end

        --[[if string.match(key, "lookmovie.io/") then
            theater.Services.base:Fetch(string.Explode("#", key)[1], function(body)
                local nkey = string.match(body, '[a|"] href="(https://.+/s)" class="round%-button')

                if not nkey then
                    callback()

                    return
                end

                vpanel:OpenURL(nkey)
            end, callback)
        else
            vpanel:OpenURL(key)
        end]]
        vpanel:OpenURL(key)
    end

    cachedURL = cachedURL or {}

    function SERVICE:LoadVideo(Video, panel)
        panel:EnsureURL("http://swamp.sv/s/cinema/file.html")
        local key = Video:Key()
        cachedURL[key] = cachedURL[key] or util.JSONToTable(Video:Data()).url

        self:Fetch(cachedURL[key], function(b)
            local aesurl = string.match(b, 'URI="(https://.+)"')

            HTTP({
                method = "GET",
                url = aesurl or cachedURL[key],
                headers = {
                    ["Cache-Control"] = "no-cache"
                },
                success = function(code, body, headers)
                    if IsValid(panel) and Me:GetTheater() then
                        if code == 200 and body ~= "WRONG HASH!" then
                            panel:QueueJavascript(string.format("th_video('%s');th_seek(%s);", string.JavascriptSafe(cachedURL[key]), Me:GetTheater():VideoCurrentTime(true)))
                        else
                            if vpanel then
                                vpanel:Remove()
                            end

                            vpanel = vgui.Create("BrowserBase")
                            vpanel:SetAlpha(0)
                            vpanel:SetKeyboardInputEnabled(false)
                            vpanel:SetMouseInputEnabled(false)
                            vpanel.AddressBar.OnEnter = function() end
                            vpanel.BackButton.DoClick = function() end
                            vpanel.ForwardButton.DoClick = function() end
                            vpanel.RefreshButton.DoClick = function() end
                            vpanel.HomeButton.DoClick = function() end
                            vpanel.Browser:OpenURL(key)
                            vpanel.Text = vgui.Create('DButton', vpanel.BrowserContainer) --easier than a panel and label
                            vpanel.Text:Dock(TOP)
                            vpanel.Text:SetText("Complete the CAPTCHA")
                            vpanel.Text:SizeToContents()
                            vpanel.Text:SetWidth(math.min(vpanel.Text:GetSize(), 256) + 32)
                            vpanel.Text:SetTall(48)
                            vpanel.Text:SetEnabled(false)
                            vpanel.Text:SetFont("DermaLarge")

                            vpanel.Text.Paint = function(b, w, h)
                                b:SetColor(Color(255, 255, 255))
                                surface.SetDrawColor(Color(16, 16, 16))
                                surface.DrawRect(0, 0, w, h)
                            end

                            local isTV = string.match(key, "/s/.+/(.+)/s#")

                            timer.Create("lookmovieupdate" .. tostring(math.random(1, 100000)), 1, 60, function()
                                if IsValid(vpanel) and IsValid(panel) then
                                    vpanel.Browser:RunJavascript("console.log('URL:'+window.location);")
                                    vpanel.Browser:RunJavascript("var stor = window['movie_storage'] || window['show_storage'];")
                                    vpanel.Browser:RunJavascript("if(stor){xmlHttp=new XMLHttpRequest();xmlHttp.open('GET',window.location.origin+'/api/v1/security/" .. (isTV and "episode" or "movie") .. "-access?id_" .. (isTV and "episode" or "movie") .. "=" .. (isTV and string.match(key, "#.+%-(%d+)$") .. "'" or "'+stor.id_movie") .. ",false);xmlHttp.send(null);console.log('JSON:'+xmlHttp.responseText);}")
                                end
                            end)

                            function vpanel.Browser:ConsoleMessage(msg)
                                if msg then
                                    msg = tostring(msg)

                                    if msg:StartWith("HREF:") then
                                        if string.match(msg:sub(6), "threat%-protection") then
                                            vpanel:SetAlpha(255)
                                            vpanel:SetMouseInputEnabled(true)
                                        else
                                            vpanel:SetAlpha(0)
                                            vpanel:SetMouseInputEnabled(false)
                                        end
                                    end

                                    if string.StartWith(msg, "JSON:") then
                                        local t = util.JSONToTable(msg:sub(6, -1))
                                        cachedURL[key] = t["streams"]["720p"] or t["streams"]["480p"] or t["streams"]["360p"] or t["streams"]["1080p"]

                                        if isTV then
                                            cachedURL[key] = t["streams"][720] or t["streams"][480] or t["streams"][360] or t["streams"][1080]
                                        end

                                        if IsValid(panel) and Me:GetTheater() then
                                            panel:QueueJavascript(string.format("th_video('%s');th_seek(%s);", string.JavascriptSafe(cachedURL[key]), Me:GetTheater():VideoCurrentTime(true)))
                                        end

                                        vpanel:Remove()
                                    end
                                end
                            end
                        end
                    end
                end,
                failed = function(err)
                    print("2", err)
                end
            })
        end, function(err)
            print("1", err)
        end)
    end
end

theater.RegisterService('lookmovie', SERVICE)
