local SERVICE = {
    Name = "Yugen",
    NeedsCodecs = true,
    CacheFile = 0
}

function SERVICE:GetKey(url)
    if string.match(url.encoded, "yugen.to/watch/%d+/%w*/%d+/") then return url.encoded end
end

if CLIENT then
    function SERVICE:GetVideoInfoClientside(key, callback)
        local ani_info = string.Split(key, '/')
        local ani_id = ""

        if string.match(key, "yugen.to/watch/%d+/%w*-dub/%d+/") then
            ani_id = util.Base64Encode(ani_info[2] + '|' + ani_info[4] + '|dub')
        else
            ani_id = util.Base64Encode(ani_info[2] + '|' + ani_info[4])
        end

        -- cheesy workaround to getting something close to a video title
        -- technically you could also grab it directly from MAL as it's what yugen uses,
        -- but it relies on api keys and whatnot + i'm not with the patience lmao
        local function getVideoTitle(title_arr)
            local title = ""

            for _, t in title_arr do
                title = title + string.upper(string.sub(t, 1, 1)) + string.sub(t, 2)
            end

            return title + "- Episode " + ani_info[4]
        end

        YugenVideoInfo = {
            title = getVideoTitle(string.Split(ani_info[3], '-')),
        }

        -- gather video stream, and duration. derived from the bflix code
        local YugenData = {}

        timer.Create("AwaitYugen", 1, 40, function()
            if timer.RepsLeft("AwaitYugen") == 0 then
                print("Fail!")
                timer.remove("AwaitYugen")
                callback()
            end

            if YugenData.stream and YugenVideoInfo.duration then
                YugenVideoInfo.data = util.TableToJSON({
                    url = YugenData.stream
                })

                timer.remove("AwaitYugen")
                callback(YugenVideoInfo)
            end
        end)

        http.Post("https://yugen.to/api/embed", {
            id = ani_id,
            ac = 0
        }, function(body, length, headers, code)
            local tab = util.JSONToTable(body)
            local hls_link = tab["hls"][0]
            local stream = ""

            -- http playlist parsing, gets the best quality by default
            http.Fetch(hls_link, function()
                -- todo: for each newline
                for _, v in ipairs(string.Split(body, ",")) do
                    if string.find(v, "RESOLUTION=") then
                        -- always grab the best resolution from the playlist
                        local res_split = string.Split(v, "RESOLUTION=")
                        resolution = res_split[#res_split]
                    end

                    if string.find(v, ".m3u8") and string.match(resolution, "%d+x%d+") then
                        stream = v
                    end
                end
            end, function(message)
                print("m3u8 playlist error - ", message)
            end)

            -- duration from stream
            local duration = 0

            http.Fetch(stream, function(st_body)
                if #string.Split(st_body, "\n") < 2 then
                    callback()

                    return
                end

                for _, v in ipairs(string.Split(st_body, "\n")) do
                    if v:StartWith("#EXTINF:") then
                        duration = duration + tonumber(string.Split(string.sub(v, 9), ",")[1])
                    end
                end

                YugenVideoInfo.duration = math.ceil(duration)
                YugenData.stream = stream
            end, function(message)
                print("m3u8 stream error - ", message)
            end)
        end, function(message)
            print("embed error - ", message)
        end, {
            ["x-requested-with"] = "XMLHttpRequest" -- required
        })
    end

    function SERVICE:LoadVideo(Video, panel)
        panel:EnsureURL("https://swamp.sv/s/cinema/file.html")
        local key = util.JSONToTable(Video:Data()).url
        panel:QueueJavascript(string.format("th_video('%s','%s');", string.JavascriptSafe(key)))
    end
end

theater.RegisterService("yugen", SERVICE)
