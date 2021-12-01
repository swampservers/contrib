-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
SERVICE = {}
SERVICE.Name = "YouTube"
SERVICE.NeedsChromium = true
SERVICE.LivestreamNeedsCodecs = true
SERVICE.CacheLife = 3600 * 24 * 14

function SERVICE:IsMature(video)
    return video:Data() == "adult"
end

function SERVICE:GetKey(url)
    if not string.match(url.host or "", "youtu.?be[.com]?") then return false end
    local key = false

    -- http://www.youtube.com/watch?v=(videoId)
    if url.query and url.query.v and string.len(url.query.v) == 11 then
        key = url.query.v
        -- http://www.youtube.com/v/(videoId)
    elseif url.path and string.match(url.path, "^/v/([%a%d-_]+)") then
        key = string.match(url.path, "^/v/([%a%d-_]+)")
    elseif string.match(url.host, "youtu.be") and url.path and string.match(url.path, "^/([%a%d-_]+)$") and (not info.query or #info.query == 0) then
        -- http://youtu.be/(videoId)
        -- short url
        key = string.match(url.path, "^/([%a%d-_]+)$")
    end

    return key
end

if CLIENT then
	local payload = [[
		const UNLOCKABLE_PLAYER_STATES=["AGE_VERIFICATION_REQUIRED","AGE_CHECK_REQUIRED","LOGIN_REQUIRED"],PLAYER_RESPONSE_ALIASES=["ytInitialPlayerResponse","playerResponse"],ACCOUNT_PROXY_SERVER_HOST="https://youtube-proxy.zerody.one",VIDEO_PROXY_SERVER_HOST="https://phx.4everproxy.com",isDesktop="m.youtube.com"!==window.location.host,isEmbed=window.location.pathname.includes("/embed/");class Deferred{constructor(){return Object.assign(new Promise(((e,t)=>{this.resolve=e,this.reject=t})),this)}}function createElement(e,t){const n=document.createElement(e);return t&&Object.assign(n,t),n}function isObject(e){return null!==e&&"object"==typeof e}function getCookie(e){const t=`; ${document.cookie}`.split(`; ${e}=`);if(2===t.length)return t.pop().split(";").shift()}function generateSha1Hash(e){function t(e,t){return e<<t|e>>>32-t}function n(e){var t,n="";for(t=7;t>=0;t--)n+=(e>>>4*t&15).toString(16);return n}var o,i,r,a,s,l,c,d,u,p=new Array(80),g=1732584193,f=4023233417,y=2562383102,v=271733878,h=3285377520,R=(e=function(e){e=e.replace(/\r\n/g,"\n");for(var t="",n=0;n<e.length;n++){var o=e.charCodeAt(n);o<128?t+=String.fromCharCode(o):o>127&&o<2048?(t+=String.fromCharCode(o>>6|192),t+=String.fromCharCode(63&o|128)):(t+=String.fromCharCode(o>>12|224),t+=String.fromCharCode(o>>6&63|128),t+=String.fromCharCode(63&o|128))}return t}(e)).length,m=new Array;for(i=0;i<R-3;i+=4)r=e.charCodeAt(i)<<24|e.charCodeAt(i+1)<<16|e.charCodeAt(i+2)<<8|e.charCodeAt(i+3),m.push(r);switch(R%4){case 0:i=2147483648;break;case 1:i=e.charCodeAt(R-1)<<24|8388608;break;case 2:i=e.charCodeAt(R-2)<<24|e.charCodeAt(R-1)<<16|32768;break;case 3:i=e.charCodeAt(R-3)<<24|e.charCodeAt(R-2)<<16|e.charCodeAt(R-1)<<8|128}for(m.push(i);m.length%16!=14;)m.push(0);for(m.push(R>>>29),m.push(R<<3&4294967295),o=0;o<m.length;o+=16){for(i=0;i<16;i++)p[i]=m[o+i];for(i=16;i<=79;i++)p[i]=t(p[i-3]^p[i-8]^p[i-14]^p[i-16],1);for(a=g,s=f,l=y,c=v,d=h,i=0;i<=19;i++)u=t(a,5)+(s&l|~s&c)+d+p[i]+1518500249&4294967295,d=c,c=l,l=t(s,30),s=a,a=u;for(i=20;i<=39;i++)u=t(a,5)+(s^l^c)+d+p[i]+1859775393&4294967295,d=c,c=l,l=t(s,30),s=a,a=u;for(i=40;i<=59;i++)u=t(a,5)+(s&l|s&c|l&c)+d+p[i]+2400959708&4294967295,d=c,c=l,l=t(s,30),s=a,a=u;for(i=60;i<=79;i++)u=t(a,5)+(s^l^c)+d+p[i]+3395469782&4294967295,d=c,c=l,l=t(s,30),s=a,a=u;g=g+a&4294967295,f=f+s&4294967295,y=y+l&4294967295,v=v+c&4294967295,h=h+d&4294967295}return(n(g)+n(f)+n(y)+n(v)+n(h)).toLowerCase()}const nativeJSONParse=window.JSON.parse,nativeXMLHttpRequestOpen=XMLHttpRequest.prototype.open,nativeObjectDefineProperty=(()=>{if(Object.defineProperty.toString().includes("[native code]"))return Object.defineProperty;const e=createElement("iframe",{style:"display: none;"});document.documentElement.append(e);const t=e.contentWindow.Object.defineProperty;return e.remove(),t})();let wrappedPlayerResponse,wrappedNextResponse;function attachInitialDataInterceptor(e){let{get:t,set:n}=Object.getOwnPropertyDescriptor(window,"ytInitialPlayerResponse")||{};Object.defineProperty=(e,o,i)=>{e===window&&PLAYER_RESPONSE_ALIASES.includes(o)?(console.info("Another extension tries to redefine '"+o+"' (probably an AdBlock extension). Chain it..."),null!=i&&i.set&&(n=i.set),null!=i&&i.get&&(t=i.get)):nativeObjectDefineProperty(e,o,i)},nativeObjectDefineProperty(window,"ytInitialPlayerResponse",{set:t=>{t!==wrappedPlayerResponse&&(wrappedPlayerResponse=isObject(t)?e(t):t,"function"==typeof n&&n(wrappedPlayerResponse))},get:()=>{if("function"==typeof t)try{return t()}catch(e){}return wrappedPlayerResponse||{}},configurable:!0}),nativeObjectDefineProperty(window,"ytInitialData",{set:t=>{wrappedNextResponse=isObject(t)?e(t):t},get:()=>wrappedNextResponse,configurable:!0})}function attachJsonInterceptor(e){window.JSON.parse=(t,n)=>{const o=nativeJSONParse(t,n);return isObject(o)?e(o):o}}function attachXhrOpenInterceptor(e){XMLHttpRequest.prototype.open=function(t,n){if(arguments.length>1&&"string"==typeof n&&0===n.indexOf("https://")){const o=e(this,t,new URL(n));"string"==typeof o&&(n=o)}nativeXMLHttpRequestOpen.apply(this,arguments)}}function isPlayerObject(e){return(null==e?void 0:e.videoDetails)&&(null==e?void 0:e.playabilityStatus)}function isEmbeddedPlayerObject(e){return"object"==typeof(null==e?void 0:e.previewPlayabilityStatus)}function isAgeRestricted(e){var t,n,o,i,r,a,s,l;return!(null==e||!e.status)&&(!!e.desktopLegacyAgeGateReason||(!!UNLOCKABLE_PLAYER_STATES.includes(e.status)||isEmbed&&(null===(t=e.errorScreen)||void 0===t||null===(n=t.playerErrorMessageRenderer)||void 0===n||null===(o=n.reason)||void 0===o||null===(i=o.runs)||void 0===i||null===(r=i.find((e=>e.navigationEndpoint)))||void 0===r||null===(a=r.navigationEndpoint)||void 0===a||null===(s=a.urlEndpoint)||void 0===s||null===(l=s.url)||void 0===l?void 0:l.includes("/2802167"))))}function isWatchNextObject(e){var t,n;return!(null==e||!e.contents||null==e||null===(t=e.currentVideoEndpoint)||void 0===t||null===(n=t.watchEndpoint)||void 0===n||!n.videoId)&&(!!e.contents.twoColumnWatchNextResults||!!e.contents.singleColumnWatchNextResults)}function isWatchNextSidebarEmpty(e){var t,n,o,i,r;if(isDesktop){var a,s,l,c;return!(null===(a=e.contents)||void 0===a||null===(s=a.twoColumnWatchNextResults)||void 0===s||null===(l=s.secondaryResults)||void 0===l||null===(c=l.secondaryResults)||void 0===c?void 0:c.results)}const d=null===(t=e.contents)||void 0===t||null===(n=t.singleColumnWatchNextResults)||void 0===n||null===(o=n.results)||void 0===o||null===(i=o.results)||void 0===i?void 0:i.contents;return"object"!=typeof(null==d||null===(r=d.find((e=>{var t;return"watch-next-feed"===(null===(t=e.itemSectionRenderer)||void 0===t?void 0:t.targetId)})))||void 0===r?void 0:r.itemSectionRenderer)}function isGoogleVideo(e,t){return"GET"===e&&t.host.includes(".googlevideo.com")}function isGoogleVideoUnlockRequired(e,t){const n=new URLSearchParams(e.search),o=n.get("gcr"),i=n.get("id")===t;return o&&i}function getYtcfgValue(e){var t;return null===(t=window.ytcfg)||void 0===t?void 0:t.get(e)}function isUserLoggedIn(){return!!getSidCookie()&&("boolean"==typeof getYtcfgValue("LOGGED_IN")?getYtcfgValue("LOGGED_IN"):"string"==typeof getYtcfgValue("DELEGATED_SESSION_ID"))}function getPlayer$1(e,t,n){return sendInnertubeRequest("v1/player",getInnertubeEmbedPayload(e,t),n)}function getNext(e,t,n,o){return sendInnertubeRequest("v1/next",getInnertubeEmbedPayload(e,t,n,o),!1)}function getMainPageClientName(){return getYtcfgValue("INNERTUBE_CLIENT_NAME").replace("_EMBEDDED_PLAYER","")}function getSignatureTimestamp(){return getYtcfgValue("STS")||(()=>{var e;const t=null===(e=document.querySelector('script[src*="/base.js"]'))||void 0===e?void 0:e.src;if(!t)return;const n=new XMLHttpRequest;return n.open("GET",t,!1),n.send(null),parseInt(n.responseText.match(/signatureTimestamp:([0-9]*)/)[1])})()}function sendInnertubeRequest(e,t,n){const o=new XMLHttpRequest;return o.open("POST",`/youtubei/${e}?key=${getYtcfgValue("INNERTUBE_API_KEY")}`,!1),n&&isUserLoggedIn()&&(o.withCredentials=!0,o.setRequestHeader("Authorization",generateSidBasedAuth())),o.send(JSON.stringify(t)),nativeJSONParse(o.responseText)}function getInnertubeEmbedPayload(e,t,n,o){return{context:{client:{...getYtcfgValue("INNERTUBE_CONTEXT").client,clientName:getMainPageClientName(),...t||{}},thirdParty:{embedUrl:"https://www.youtube.com/"}},playbackContext:{contentPlaybackContext:{signatureTimestamp:getSignatureTimestamp()}},videoId:e,playlistId:n,playlistIndex:o}}function getSidCookie(){return getCookie("SAPISID")||getCookie("__Secure-3PAPISID")}function generateSidBasedAuth(){const e=getSidCookie(),t=Math.floor((new Date).getTime()/1e3);return`SAPISIDHASH ${t}_${generateSha1Hash(t+" "+e+" "+location.origin)}`}const logPrefix="Simple-YouTube-Age-Restriction-Bypass:",logSuffix="You can report bugs at: https://github.com/zerodytrash/Simple-YouTube-Age-Restriction-Bypass/issues";function error(e,t){console.error(logPrefix,t,e,getYtcfgDebugString(),logSuffix)}function info(e){console.info(logPrefix,e)}function getYtcfgDebugString(){try{return`InnertubeConfig: innertubeApiKey: ${getYtcfgValue("INNERTUBE_API_KEY")} innertubeClientName: ${getYtcfgValue("INNERTUBE_CLIENT_NAME")} innertubeClientVersion: ${getYtcfgValue("INNERTUBE_CLIENT_VERSION")} loggedIn: ${getYtcfgValue("LOGGED_IN")} `}catch(e){return`Failed to access config: ${e}`}}function getGoogleVideoUrl(e,t){return t+"/direct/"+btoa(e)}function getPlayer(e,t){const n=new URLSearchParams({videoId:e,reason:t,clientName:getMainPageClientName(),clientVersion:getYtcfgValue("INNERTUBE_CLIENT_VERSION"),signatureTimestamp:getSignatureTimestamp(),isEmbed:+isEmbed}).toString(),o=ACCOUNT_PROXY_SERVER_HOST+"/getPlayer?"+n,i=new XMLHttpRequest;i.open("GET",o,!1),i.send(null);const r=nativeJSONParse(i.responseText);return r.proxied=!0,r}var tDesktop="<tp-yt-paper-toast></tp-yt-paper-toast>\n",tMobile='<c3-toast>\n    <ytm-notification-action-renderer>\n        <div class="notification-action-response-text"></div>\n    </ytm-notification-action-renderer>\n</c3-toast>\n';const pageLoad=new Deferred,pageLoadEventName=isDesktop?"yt-navigate-finish":"state-navigateend",template=isDesktop?tDesktop:tMobile,nNotificationWrapper=createElement("div",{id:"notification-wrapper",innerHTML:template}),nNotification=nNotificationWrapper.querySelector(":scope > *"),nMobileText=!isDesktop&&nNotification.querySelector(".notification-action-response-text");function init(){document.body.append(nNotificationWrapper),pageLoad.resolve()}function show(e,t=5){pageLoad.then((function(){const n=1e3*t;isDesktop?(nNotification.duration=n,nNotification.show(e)):(nMobileText.innerText=e,nNotification.setAttribute("dir","in"),setTimeout((()=>{nNotification.setAttribute("dir","out")}),n+225))}))}window.addEventListener(pageLoadEventName,init,{once:!0});var Notification={show:show};const messagesMap={success:"Age-restricted video successfully unlocked!",fail:"Unable to unlock this video 🙁 - More information in the developer console"},unlockStrategies=[{name:"Innertube Embed",requireAuth:!1,fn:e=>getPlayer$1(e,{clientScreen:"EMBED"},!1)},{name:"Innertube Creator + Auth",requireAuth:!0,fn:e=>getPlayer$1(e,{clientName:"WEB_CREATOR",clientVersion:"1.20210909.07.00"},!0)},{name:"Account Proxy",requireAuth:!1,fn:(e,t)=>getPlayer(e,t)}];let lastProxiedGoogleVideoUrlParams,responseCache={};function getLastProxiedGoogleVideoId(){var e;return null===(e=lastProxiedGoogleVideoUrlParams)||void 0===e?void 0:e.get("id")}function unlockPlayerResponse(e){var t,n,o,i,r;const a=getUnlockedPlayerResponse((null===(t=e.videoDetails)||void 0===t?void 0:t.videoId)||getYtcfgValue("PLAYER_VARS").video_id,(null===(n=e.playabilityStatus)||void 0===n?void 0:n.status)||(null===(o=e.previewPlayabilityStatus)||void 0===o?void 0:o.status));if(a.errorMessage)throw Notification.show(`${messagesMap.fail} (ProxyError)`,10),new Error(`Player Unlock Failed, Proxy Error Message: ${a.errorMessage}`);var s;if("OK"!==(null===(i=a.playabilityStatus)||void 0===i?void 0:i.status))throw Notification.show(`${messagesMap.fail} (PlayabilityError)`,10),new Error(`Player Unlock Failed, playabilityStatus: ${null===(s=a.playabilityStatus)||void 0===s?void 0:s.status}`);if(a.proxied&&null!==(r=a.streamingData)&&void 0!==r&&r.adaptiveFormats){var l,c;const e=null===(l=a.streamingData.adaptiveFormats.find((e=>e.signatureCipher)))||void 0===l?void 0:l.signatureCipher,t=e?new URLSearchParams(e).get("url"):null===(c=a.streamingData.adaptiveFormats.find((e=>e.url)))||void 0===c?void 0:c.url;lastProxiedGoogleVideoUrlParams=t?new URLSearchParams(new URL(t).search):null}e.previewPlayabilityStatus&&(e.previewPlayabilityStatus=a.playabilityStatus),Object.assign(e,a),Notification.show(messagesMap.success)}function getUnlockedPlayerResponse(e,t){if(responseCache.videoId===e)return responseCache.playerResponse;let n;return unlockStrategies.every(((o,i)=>{var r,a;return!(!o.requireAuth||isUserLoggedIn())||(info(`Trying Unlock Method #${i+1} (${o.name})`),n=o.fn(e,t),"OK"!==(null===(r=n)||void 0===r||null===(a=r.playabilityStatus)||void 0===a?void 0:a.status))})),responseCache={videoId:e,playerResponse:n},n}function unlockNextResponse(e){info("Trying Sidebar Unlock Method (Innertube Embed)");const{videoId:t,playlistId:n,index:o}=e.currentVideoEndpoint.watchEndpoint,i=getNext(t,{clientScreen:"EMBED"},n,o);if(isWatchNextSidebarEmpty(i))throw new Error("Sidebar Unlock Failed");mergeNextResponse(e,i)}function mergeNextResponse(e,t){var n,o,i,r,a;if(isDesktop){e.contents.twoColumnWatchNextResults.secondaryResults=t.contents.twoColumnWatchNextResults.secondaryResults;const n=e.contents.twoColumnWatchNextResults.results.results.contents.find((e=>e.videoSecondaryInfoRenderer)).videoSecondaryInfoRenderer,o=t.contents.twoColumnWatchNextResults.results.results.contents.find((e=>e.videoSecondaryInfoRenderer)).videoSecondaryInfoRenderer;return void(o.description&&(n.description=o.description))}const s=null===(n=t.contents)||void 0===n||null===(o=n.singleColumnWatchNextResults)||void 0===o||null===(i=o.results)||void 0===i||null===(r=i.results)||void 0===r||null===(a=r.contents)||void 0===a?void 0:a.find((e=>{var t;return"watch-next-feed"===(null===(t=e.itemSectionRenderer)||void 0===t?void 0:t.targetId)}));s&&e.contents.singleColumnWatchNextResults.results.results.contents.push(s);const l=e.engagementPanels.find((e=>e.engagementPanelSectionListRenderer)).engagementPanelSectionListRenderer.content.structuredDescriptionContentRenderer.items.find((e=>e.expandableVideoDescriptionBodyRenderer)),c=t.engagementPanels.find((e=>e.engagementPanelSectionListRenderer)).engagementPanelSectionListRenderer.content.structuredDescriptionContentRenderer.items.find((e=>e.expandableVideoDescriptionBodyRenderer));c.expandableVideoDescriptionBodyRenderer&&(l.expandableVideoDescriptionBodyRenderer=c.expandableVideoDescriptionBodyRenderer)}try{attachInitialDataInterceptor(checkAndUnlock),attachJsonInterceptor(checkAndUnlock),attachXhrOpenInterceptor(onXhrOpenCalled)}catch(e){error(e,"Error while attaching data interceptors")}function checkAndUnlock(e){try{isPlayerObject(e)&&isAgeRestricted(e.playabilityStatus)?unlockPlayerResponse(e):isPlayerObject(e.playerResponse)&&isAgeRestricted(e.playerResponse.playabilityStatus)?unlockPlayerResponse(e.playerResponse):isEmbeddedPlayerObject(e)&&isAgeRestricted(e.previewPlayabilityStatus)?unlockPlayerResponse(e):isWatchNextObject(e)&&isWatchNextSidebarEmpty(e)?unlockNextResponse(e):isWatchNextObject(e.response)&&isWatchNextSidebarEmpty(e.response)&&unlockNextResponse(e.response)}catch(e){error(e,"Video or sidebar unlock failed")}return e}function onXhrOpenCalled(e,t,n){if(isGoogleVideo(t,n))return isGoogleVideoUnlockRequired(n,getLastProxiedGoogleVideoId())?(Object.defineProperty(e,"withCredentials",{set:()=>{},get:()=>!1}),getGoogleVideoUrl(n.toString(),VIDEO_PROXY_SERVER_HOST)):void 0}
	]]
	local loaded = false
	
    function SERVICE:LoadVideo(Video, panel)
        panel:EnsureURL("http://swamp.sv/s/cinema/" .. self:GetClass() .. ".html")
		panel.vid = Video
		local enabled = false
		
		if (self:IsMature(Video)) then
			panel:EnsureURL("https://www.youtube.com/embed/"..Video:Key().."?autoplay=1&controls=0&showinfo=0&modestbranding=1&rel=0&iv_load_policy=3&enablejsapi=1")
			enabled = true
			loaded = false
			timer.Create("youtubemature"..tostring(math.random(1, 100000)), .1, 30, function()
				if IsValid(panel) then
					if enabled then
						panel:RunJavascript(payload)
						panel:RunJavascript("if(window.ytcfg)console.log('PAGE LOADED');")
						self:SetVolume(theater.GetVolume(), panel)
					end
					panel:RunJavascript([[
						if (think == null){
							function timestamp(){
								return (new Date().getTime()) * 0.001;
							}
						
							function target_time(){
								return Math.max(0, (timestamp() - start_time) - 0.5);
							}
							
							start_time = timestamp();
							to_volume = 0;
							
							function think() {
								if (document.getElementsByTagName('video').length){
									document.getElementsByTagName('video')[0].volume = to_volume/100;
									
									var target_t = target_time();
									
									if (target_t < (document.getElementsByTagName('video')[0].duration - 1.0)){
										if (Math.abs(document.getElementsByTagName('video')[0].currentTime - target_t) > 2.0){
											document.getElementsByTagName('video')[0].currentTime = target_t;
										}
									}
									
									document.getElementsByTagName('video')[0].play();
								}
							}
							setInterval(think,100);
							
							function th_volume(volume){
								to_volume = volume;
							};
							
							function th_seek(seconds){
								start_time = timestamp() - seconds;
							};
						}
					]])
					panel:RunJavascript("if(document.getElementsByClassName('ytp-watermark').length)document.getElementsByClassName('ytp-watermark')[0].remove()") --bottom right watermark
					panel:RunJavascript("if(document.getElementsByClassName('ytp-show-cards-title').length)document.getElementsByClassName('ytp-show-cards-title')[0].remove()") --title bar
					panel:RunJavascript("if(document.getElementsByClassName('ytp-paid-content-overlay').length)document.getElementsByClassName('ytp-paid-content-overlay')[0].remove()") --ad?
					panel:RunJavascript("if(document.getElementsByClassName('ytp-pause-overlay').length)document.getElementsByClassName('ytp-pause-overlay')[0].remove()") --pause overlay
					panel:RunJavascript("if(document.getElementsByClassName('videowall-endscreen').length)document.getElementsByClassName('videowall-endscreen')[0].remove()") --endscreen
					panel:RunJavascript("if(document.getElementsByClassName('ytp-gradient-top').length)document.getElementsByClassName('ytp-gradient-top')[0].remove()") --top gradient
				end
			end)
		else
			panel:EnsureURL("http://swamp.sv/s/cinema/" .. self:GetClass() .. ".html")
			local str = string.format("th_video('%s',%s);", string.JavascriptSafe(Video:Key()), Video:Duration() > 0 and "false" or "true")
			panel:QueueJavascript(str)
		end
		
		local fn = panel.ConsoleMessage
        panel.ConsoleMessage = function(a, str)
			fn(a, str)
			if (str == "PAGE LOADED") then
				enabled = false
				loaded = true
			else
				if str:len() > 2 and str:sub(1, 2) == "T:" and tonumber(str:sub(3)) then
					YOUTUBE_TRUE_START = SysTime() - tonumber(str:sub(3))
					YOUTUBE_TRUE_START_PING = SysTime()
				end
			end
        end
    end
	
    function SERVICE:SetVolume(vol, panel)
		if (self:IsMature(panel.vid)) then
			local str = "{let volint=setInterval(function(){if(typeof(th_volume)!='undefined'){th_volume("..vol..");clearInterval(volint);}},10)}"
			panel:RunJavascript(str)
		else
			local str = string.format("th_volume(%s);", vol)
			panel:QueueJavascript(str)
		end
    end

    function SERVICE:SeekTo(time, panel)
		local str = string.format("th_seek(%s);", time)
		if (self:IsMature(panel.vid)) then
			if (not loaded) then
				timer.Simple(3,function() if IsValid(panel) then panel:RunJavascript(str) end end)
			else
				panel:RunJavascript(str)
			end
		else
			panel:QueueJavascript(str)
		end
    end

    function YoutubeActualTimestamp()
        if (YOUTUBE_TRUE_START_PING or -100) > SysTime() - 2 then return SysTime() - YOUTUBE_TRUE_START end
    end
end

theater.RegisterService('youtube', SERVICE)
