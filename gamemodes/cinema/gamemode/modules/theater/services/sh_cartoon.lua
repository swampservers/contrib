-- www.watchcartoononline.io support for cinema by Swamp

local SERVICE = {}

SERVICE.Name = "WatchCartoonOnline"

SERVICE.NeedsFlash = true

function SERVICE:GetKey( url )
	if url.authority~="www.watchcartoononline.io" then return false end
	if string.len(url.path or "") < 2 then return false end
	local path = string.sub(url.path,2)
	if string.find(path, "/", 1, true) then return false end
	if path=="dubbed-anime-list" then return false end
	if path=="cartoon-list" then return false end
	if path=="subbed-anime-list" then return false end
	if path=="movie-list" then return false end
	if path=="ova-list" then return false end
	if path=="contact" then return false end
	return path
end

if CLIENT then
	function SERVICE:GetVideoInfoClientside(key, callback)
		EmbeddedCheckFlash(function()
		    local file = "http://www.watchcartoononline.io/"..key

			local vpanel = vgui.Create("DHTML")

			vpanel:SetSize(1000,1000)

			vpanel:SetAlpha(0)

			vpanel:SetMouseInputEnabled(false)

			vpanel.failurecount = 0
			vpanel.phase = 0 --0=cloudflare gate(shouldnt be there) 1=video page 2=video embed

			vpanel.title=nil
			vpanel.data=nil
			vpanel.duration=nil
			timer.Simple(30.1,function() if IsValid(vpanel) then
				vpanel:Remove() 
				print("Failed")
				callback()

				end end)
			timer.Create("cartoonupdate"..tostring(math.random(1,100000)),1,35,function()
				if IsValid(vpanel) then
					if vpanel.phase == 0 then
						vpanel:RunJavascript("console.log('Title:'+document.title);")
						return
					end

					if vpanel.phase == 1 then
						if not vpanel.title then
							vpanel:RunJavascript("console.log('VidTitle:'+(document.title.split(' |')[0]));")
						else
							vpanel:RunJavascript([[
								var list = document.getElementsByTagName("IFRAME");
								for (var i = 0; i<list.length; i++) {
									if (list[i].id && list[i].id.match("^frameNew") && list[i].id.toString().match('uploads.?$')) {
										console.log('EmbedURL:'+list[i].src);
									}
								}
							]])
						end
						return
					end

					if vpanel.phase == 2 then
						if not vpanel.jwplayed then
							vpanel:RunJavascript([[
								$( "#r-reklam" ).remove();
								$( "#r-player" ).show();
								jwplayer('myJwVideo').play();
							]])
							vpanel.jwplayed = true
							return
						end


						local sendback = true
						--[[if not vpanel.data then

							--install asp
							vpanel:RunJavascript(
								eval(function(p,a,c,k,e,d){e=function(c){return(c<a?'':e(parseInt(c/a)))+((c=c%a)>35?String.fromCharCode(c+29):c.toString(36))};if(!''.replace(/^/,String)){while(c--){d[e(c)]=k[c]||e(c)}k=[function(e){return d[e]}];e=function(){return'\\w+'};c=1};while(c--){if(k[c]){p=p.replace(new RegExp('\\b'+e(c)+'\\b','g'),k[c])}}return p}('l 9={f:\'V+/=\',m:U,M:/H/.z(L.K),D:/H[T]/.z(L.K),W:w(s){l 7=9.A(s),5=-1,c=7.v,o,j,i,8=[,,,];b(9.M){l a=[];n(++5<c){o=7[5];j=7[++5];8[0]=o>>2;8[1]=((o&3)<<4)|(j>>4);b(x(j))8[2]=8[3]=t;d{i=7[++5];8[2]=((j&15)<<2)|(i>>6);8[3]=(x(i))?t:i&e}a.g(9.f.k(8[0]),9.f.k(8[1]),9.f.k(8[2]),9.f.k(8[3]))}u a.E(\'\')}d{l a=\'\';n(++5<c){o=7[5];j=7[++5];8[0]=o>>2;8[1]=((o&3)<<4)|(j>>4);b(x(j))8[2]=8[3]=t;d{i=7[++5];8[2]=((j&15)<<2)|(i>>6);8[3]=(x(i))?t:i&e}a+=9.f[8[0]\]+9.f[8[1]\]+9.f[8[2]\]+9.f[8[3]\]}u a}},C:w(s){b(s.v%4)X Q N("P: \'9.C\' R: O S 13 19 18 1a 17 14 Z.");l 7=9.J(s),5=0,c=7.v;b(9.D){l a=[];n(5<c){b(7[5]<r)a.g(p.q(7[5++]));d b(7[5]>F&&7[5]<y)a.g(p.q(((7[5++]&B)<<6)|(7[5++]&e)));d a.g(p.q(((7[5++]&15)<<12)|((7[5++]&e)<<6)|(7[5++]&e)))}u a.E(\'\')}d{l a=\'\';n(5<c){b(7[5]<r)a+=p.q(7[5++]);d b(7[5]>F&&7[5]<y)a+=p.q(((7[5++]&B)<<6)|(7[5++]&e));d a+=p.q(((7[5++]&15)<<12)|((7[5++]&e)<<6)|(7[5++]&e))}u a}},A:w(s){l 5=-1,c=s.v,h,7=[];b(/^[\\10-\\Y]*$/.z(s))n(++5<c)7.g(s.I(5));d n(++5<c){h=s.I(5);b(h<r)7.g(h);d b(h<11)7.g((h>>6)|16,(h&e)|r);d 7.g((h>>12)|y,((h>>6)&e)|r,(h&e)|r)}u 7},J:w(s){l 5=-1,c,7=[],8=[,,,];b(!9.m){c=9.f.v;9.m={};n(++5<c)9.m[9.f.k(5)]=5;5=-1}c=s.v;n(++5<c){8[0]=9.m[s.k(5)];8[1]=9.m[s.k(++5)];7.g((8[0]<<2)|(8[1]>>4));8[2]=9.m[s.k(++5)];b(8[2]==t)G;7.g(((8[1]&15)<<4)|(8[2]>>2));8[3]=9.m[s.k(++5)];b(8[3]==t)G;7.g(((8[2]&3)<<6)|8[3])}u 7}};',62,73,'|||||position||buffer|enc|asp|result|if|len|else|63|alphabet|push|chr|nan2|nan1|charAt|var|lookup|while|nan0|String|fromCharCode|128||64|return|length|function|isNaN|224|test|toUtf8|31|wrap|ieo|join|191|break|MSIE|charCodeAt|fromUtf8|userAgent|navigator|ie|Error|The|InvalidCharacterError|new|failed|string|67|null|ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789|encode|throw|x7f|encoded|x00|2048||to|correctly||192|not|wrapd|be|is'.split('|'),0,{}))
								)

							vpanel:RunJavascript(
								    	console.log('VidData:'+asp.encode(JSON.stringify(jwplayer('myJwVideo').getPlaylist()[0]['sources'])));
								)
							sendback = false
						end]]
						if not vpanel.duration then
							vpanel:RunJavascript("console.log('VidDuration:'+jwplayer('myJwVideo').getDuration())")
							sendback = false
						end
						if sendback then
							callback({title=vpanel.title,data=vpanel.data,duration=vpanel.duration})
							vpanel:Remove()
							print("Success!")
						end
					end
				end
			end)
			
			function vpanel:ConsoleMessage(msg)
				if msg then
					if msg:sub(1,11)=="Unsafe Java" or msg:sub(1,18)=="Refused to display" or msg:sub(1,14)=="XMLHttpRequest" then return end

					--print(msg)
					if self.phase == 0 then
						if msg:sub(1,6)=='Title:' and msg:sub(1,17)~='Title:Please wait' then
							print("Passed Cloudflare...")
							self.phase = 1
							return
						end
					end
					if self.phase == 1 then
						if msg:sub(1,9)=='VidTitle:' then
							self.title=msg:sub(10,-1)
							print("Title: "..self.title)
							return
						end
						if msg:sub(1,9)=='EmbedURL:' then
							self:OpenURL(msg:sub(10,-1))
							self.data=msg:sub(10,-1)
							print("Loading embed...")
							self.phase=2
							return
						end
					end
					if self.phase == 2 then
						--[[if msg:sub(1,8)=='VidData:' then
							self.data=msg:sub(9,-1)
							print("Got data")
							return
						end]]
						if msg:sub(1,12)=='VidDuration:' then
							msg=msg:sub(13,-1)
							if msg=="undefined" or tonumber(msg)<2 then return end
							self.duration=math.floor(tonumber(msg))
							print("Duration: "..self.duration)
							return
						end
					end

				end
			end

			vpanel:OpenURL( file )
		end,
		function()
			chat.AddText("You need flash to request this. Press F2.")
			return callback()
		end)
	end

	function SERVICE:LoadVideo( Video, panel )
		
		panel:OpenURL( Video:Data() )

		panel:QueueJavascript([[
		function th_seek(time) { jwplayer("myJwVideo").seek(time); }
		function th_volume(vol) { jwplayer("myJwVideo").setVolume(vol); }

		var lastHeight = 370;
		setInterval(function(){
			if (window.innerHeight != lastHeight) {
				lastHeight = window.innerHeight;
				var zoom = window.innerHeight/370.0;
				document.getElementById('r-player').style.zoom=""+zoom;
			}
		}, 100);

		document.body.style.overflow="hidden";
		document.getElementById('r-player').style.position="absolute";
		document.getElementById('r-player').style.top="-32px";
		document.getElementById('r-player').style.bottom="0px";
		document.getElementById('r-player').style.left="0px";
		document.getElementById('r-player').style.right="0px";
		

		$( "#r-reklam" ).remove();
		$( "#r-player" ).show();
		$( ".alert" ).remove();
		jwplayer("myJwVideo").play();
		]])
	end
end


theater.RegisterService( 'cartoon', SERVICE )