-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
-- www.animetoon.org support for cinema by Swamp
local SERVICE = {}
SERVICE.Name = "AnimeToon"
SERVICE.NeedsFlash = true

function SERVICE:GetKey(url)
    if url.authority ~= "www.animetoon.org" then return false end
    if string.len(url.path or "") < 2 then return false end
    local path = string.sub(url.path, 2)
    if path:StartWith("watch-") then return false end
    if path == "dubbed-anime" then return false end
    if path == "cartoon" then return false end
    if path == "movies" then return false end
    if path == "popular-list" then return false end
    if path == "updates" then return false end

    return path
end

if CLIENT then
    function SERVICE:GetVideoInfoClientside(key, callback)
        EmbeddedCheckFlash(function()
            local file = "http://www.animetoon.org/" .. key
            local vpanel = vgui.Create("DHTML")
            vpanel:SetSize(1000, 1000)
            vpanel:SetAlpha(0)
            vpanel:SetMouseInputEnabled(false)
            vpanel.failurecount = 0
            vpanel.phase = 0 --0=cloudflare gate(shouldnt be there) 1=video page 2=video embed
            vpanel.title = nil
            vpanel.data = nil
            vpanel.duration = nil

            timer.Simple(45.1, function()
                if IsValid(vpanel) then
                    vpanel:Remove()
                    print("Failed")
                    callback()
                end
            end)

            timer.Create("cartoonupdate" .. tostring(math.random(1, 100000)), 1, 45, function()
                if IsValid(vpanel) then
                    if vpanel.phase == 0 then
                        vpanel:RunJavascript("console.log('Title:'+document.title);")

                        return
                    end

                    if vpanel.phase == 1 then
                        if not vpanel.title then
                            vpanel:RunJavascript("console.log('VidTitle:'+(document.title.substring(6,document.title.length-7)));")
                        else
                            vpanel:RunJavascript([[
								var list = document.getElementsByTagName("IFRAME");
								for (var i = 0; i<list.length; i++) {
									if (list[i].src && list[i].src.startsWith("http://playpandanet.gogoanime.to/embed.php")) {
										console.log('EmbedURL:'+list[i].src);
									}
								}
							]])
                        end

                        return
                    end

                    if vpanel.phase == 2 then
                        vpanel:RunJavascript([[
							if (document.getElementById("ifr_adid")) { document.getElementById("ifr_adid").parentElement.remove(); }
							if (document.getElementById("addivwrapper_0")) { document.getElementById("addivwrapper_0").remove(); }
							if (flowplayer().getState()==1) { flowplayer().play(); }
							if (flowplayer().getClip()) { console.log('VidDuration:'+flowplayer().getClip().duration); }
						]])
                    end
                end
            end)

            function vpanel:ConsoleMessage(msg)
                if msg then
                    if msg:sub(1, 11) == "Unsafe Java" or msg:sub(1, 18) == "Refused to display" or msg:sub(1, 14) == "XMLHttpRequest" then return end

                    --print(msg)
                    if self.phase == 0 then
                        if msg:sub(1, 6) == 'Title:' and msg:sub(1, 17) ~= 'Title:Please wait' then
                            print("Passed Cloudflare...")
                            self.phase = 1

                            return
                        end
                    end

                    if self.phase == 1 then
                        if msg:sub(1, 9) == 'VidTitle:' then
                            self.title = msg:sub(10, -1)
                            print("Title: " .. self.title)

                            return
                        end

                        if msg:sub(1, 9) == 'EmbedURL:' then
                            self:OpenURL(msg:sub(10, -1))
                            self.data = msg:sub(10, -1)
                            print("Loading embed...")
                            self.phase = 2

                            return
                        end
                    end

                    if self.phase == 2 then
                        if msg:sub(1, 12) == 'VidDuration:' then
                            msg = msg:sub(13, -1)
                            if msg == "undefined" or tonumber(msg) < 2 then return end
                            self.duration = math.floor(tonumber(msg))
                            print("Duration: " .. self.duration)

                            callback({
                                title = self.title,
                                data = self.data,
                                duration = self.duration
                            })

                            self:Remove()
                            print("Success!")

                            return
                        end
                    end
                end
            end

            vpanel:OpenURL(file)
        end, function()
            chat.AddText("You need flash to request this. Press F2.")

            return callback()
        end)
    end

    function SERVICE:LoadVideo(Video, panel)
        panel:OpenURL(Video:Data())
        panel:QueueJavascript([[
		function timestamp() {
			return (new Date().getTime())*0.001;
		}

		VOLUME = 100;
		STARTTIME = timestamp();
		LASTSEEKATTEMPT = 0;

		function th_seek(time) { STARTTIME = timestamp()-time; }
		function th_volume(vol) { VOLUME = vol; }

		setInterval(function(){
			if (typeof flowplayer !=="undefined" && flowplayer()) {
			flowplayer().getControls().hide();

			if (document.getElementById('flowplayer_api')) {
				document.getElementById('flowplayer_api').style.width = window.innerWidth;
				document.getElementById('flowplayer_api').style.height = window.innerHeight+32;
			}

			if (document.getElementById("ifr_adid")) { document.getElementById("ifr_adid").parentElement.remove(); }
			if (document.getElementById("addivwrapper_0")) { document.getElementById("addivwrapper_0").remove(); }
			if (flowplayer().getState()==1) {
				flowplayer().play();
			} else {
				if (flowplayer().getState()==3) {
					var target_t = timestamp()-STARTTIME;
					if (Math.abs(flowplayer().getTime() - target_t) > 20) {
						if (timestamp() - LASTSEEKATTEMPT > 2) {
							LASTSEEKATTEMPT = timestamp();
							flowplayer().seek(Math.max(0,target_t));
						}
					}
				}
			}

			flowplayer().setVolume(VOLUME);
			}
		}, 200);

		document.body.style.overflow="hidden";
		]])
    end
end

theater.RegisterService('animetoon', SERVICE)