-- This file is subject to copyright - contact swampservers@gmail.com for more information.
SERVICE = {}
SERVICE.Name = "YouTube"
SERVICE.NeedsChromium = true
SERVICE.LivestreamNeedsCodecs = true
SERVICE.CacheLife = 3600 * 24 * 14

function SERVICE:IsMature(video)
    return string.match(video:Data(), "adult") and true
end

function SERVICE:IsEmbedDisabled(video)
    return string.match(video:Data(), "noembed") and true
end

function SERVICE:GetKey(url)
    if not string.match(url.host or "", "youtu.?be[.com]?") then return false end
    local key = false

    -- https://www.youtube.com/watch?v=(videoId)
    if url.query and url.query.v and string.len(url.query.v) == 11 then
        key = url.query.v
        -- https://www.youtube.com/v/(videoId)
    elseif url.path and string.match(url.path, "^/v/([%a%d-_]+)") then
        key = string.match(url.path, "^/v/([%a%d-_]+)")
    elseif url.path and string.match(url.path, "^/shorts/([%a%d-_]+)") then
        -- https://www.youtube.com/shorts/(videoId)
        key = string.match(url.path, "^/shorts/([%a%d-_]+)")
    elseif string.match(url.host, "youtu.be") and url.path and string.match(url.path, "^/([%a%d-_]+)$") and (not info.query or #info.query == 0) then
        -- https://youtu.be/(videoId)
        -- short url
        key = string.match(url.path, "^/([%a%d-_]+)$")
    end

    return key
end

if CLIENT then
    local js = [[
        function timestamp() {
            return (new Date().getTime()) * 0.001;
        }
        function target_time() {
            return Math.max(0, (timestamp() - start_time) - 0.5);
        }

        var player = null;
        var player_ready = false;
        var to_video = null;
        var to_volume = 0;
        var start_time = 0;
        var seek_to_end = false;

        function think() {
            if (player_ready) {
                if (player.isMuted()){
                    player.unMute();
                }
                if (to_video !== null) {
                    player.loadVideoById(to_video);
                    to_video = null;
                }
                if (to_volume !== null) {
                    player.setVolume(to_volume);
                    to_volume = null;
                }
                if (seek_to_end && player.getDuration() > 0) {
                    start_time = timestamp() - player.getDuration();
                    seek_to_end = false;
                }
                var target_t = target_time();
                if (target_t < (player.getDuration() - 1.0)) {
                    if (Math.abs(player.getCurrentTime() - target_t) > 2.0) {
                        player.seekTo(target_t, true);
                    }
                }
                // ended or playing
                if (player.getPlayerState() != 0 && player.getPlayerState() != 1) {
                    player.playVideo();
                }
            }
            if (player_ready) {
                gmod.update_timestamp(player.getCurrentTime());
            }
        }
        setInterval(think, 200);

        function th_volume(volume) {
            to_volume = volume;
        }
        function th_seek(seconds) {
            start_time = timestamp() - seconds;
        }
        function onPlayerReady() {
            player_ready = true;
            gmod.loaded();
            player.removeEventListener("onStateChange", onPlayerStateChange);
        }
        function onPlayerStateChange(state) {
            if (parseInt(state) == 1) { // Playing
                onPlayerReady();
            }
        }

        var player = document.getElementById("movie_player") || document.getElementsByClassName("html5-video-player")[0];
        player.addEventListener("onStateChange", onPlayerStateChange);
        player.addEventListener("onError", gmod.player_error);

        if (player.getPlayerState() == 1) {
            // It may be so fast it's already in the Playing state by the time we get here
            onPlayerReady();
        } else if (window.location.href.includes("/embed/") && player.getPlayerState() == -1) {
            // Assume if it's still unstarted by this point that it failed (probably because of embed disabled or referer issues)
            gmod.player_error(101);
        }

        // Try again if we're STILL unstarted after 10 seconds, regardless of the page
        setTimeout(function() {
            if (player.getPlayerState() == -1) {
                gmod.player_error(101);
            }
        }, 10000);

        // Behold! The Ad-Destroyer-Inator!
        setInterval(function() {
            const adSkipButton = document.getElementsByClassName("ytp-ad-skip-button-slot")[0] || document.getElementsByClassName("ytp-skip-ad-button")[0];
            if (adSkipButton) {
                adSkipButton.click();
            }
        }, 500);
    ]]
    local noembed_js = [[
        document.body.appendChild(player);
        player.style.backgroundColor = "#000";
        player.style.height = "100vh";

        var playerSizeTimerNumRuns = 0;
        var playerSizeTimer = setInterval(function() {
            for (const elem of document.getElementsByTagName("ytd-app")) {
                elem.remove();
            }
            for (const elem of document.getElementsByClassName("watch-skeleton")) {
                elem.remove();
            }
            for (const elem of document.getElementsByClassName("skeleton")) {
                elem.remove();
            }

            player.setInternalSize("100vw", "100vh");
            document.body.style.overflow = "hidden";

            playerSizeTimerNumRuns++;

            // A whole second has elapsed, we can stop
            if (playerSizeTimerNumRuns > 100) {
                clearInterval(playerSizeTimer);
            }
        }, 10);
    ]]
    -- https://github.com/zerodytrash/Simple-YouTube-Age-Restriction-Bypass/blob/main/dist/Simple-YouTube-Age-Restriction-Bypass.user.js
    -- Version 2.5.9 (#4c5c61a)
    local age_restrict_js = [[
        const UNLOCKABLE_PLAYABILITY_STATUSES=['AGE_VERIFICATION_REQUIRED','AGE_CHECK_REQUIRED','CONTENT_CHECK_REQUIRED','LOGIN_REQUIRED'];const VALID_PLAYABILITY_STATUSES=['OK','LIVE_STREAM_OFFLINE'];const ACCOUNT_PROXY_SERVER_HOST='https://youtube-proxy.zerody.one';const VIDEO_PROXY_SERVER_HOST='https://ny.4everproxy.com';let ENABLE_UNLOCK_CONFIRMATION_EMBED=false;let ENABLE_UNLOCK_NOTIFICATION=true;let SKIP_CONTENT_WARNINGS=true;const GOOGLE_AUTH_HEADER_NAMES=['Authorization','X-Goog-AuthUser','X-Origin'];const BLURRED_THUMBNAIL_SQP_LENGTHS=[32,48,56,68,72,84,88,];var Config=window[Symbol()]={UNLOCKABLE_PLAYABILITY_STATUSES,VALID_PLAYABILITY_STATUSES,ACCOUNT_PROXY_SERVER_HOST,VIDEO_PROXY_SERVER_HOST,ENABLE_UNLOCK_CONFIRMATION_EMBED,ENABLE_UNLOCK_NOTIFICATION,SKIP_CONTENT_WARNINGS,GOOGLE_AUTH_HEADER_NAMES,BLURRED_THUMBNAIL_SQP_LENGTHS};function isGoogleVideoUrl(url){return url.host.includes('.googlevideo.com')}function isGoogleVideoUnlockRequired(googleVideoUrl,lastProxiedGoogleVideoId){const urlParams=new URLSearchParams(googleVideoUrl.search);const hasGcrFlag=urlParams.get('gcr');const wasUnlockedByAccountProxy=urlParams.get('id')===lastProxiedGoogleVideoId;return hasGcrFlag&&wasUnlockedByAccountProxy}const nativeJSONParse=window.JSON.parse;const nativeXMLHttpRequestOpen=window.XMLHttpRequest.prototype.open;const isDesktop=window.location.host!=='m.youtube.com';const isMusic=window.location.host==='music.youtube.com';const isEmbed=window.location.pathname.indexOf('/embed/')===0;const isConfirmed=window.location.search.includes('unlock_confirmed');class Deferred{constructor(){return Object.assign(new Promise((resolve,reject)=>{this.resolve=resolve;this.reject=reject}),this,)}}function createElement(tagName,options){const node=document.createElement(tagName);options&&Object.assign(node,options);return node}function isObject(obj){return obj!==null&&typeof obj==='object'}function findNestedObjectsByAttributeNames(object,attributeNames){var results=[];if(attributeNames.every((key)=>typeof object[key]!=='undefined')){results.push(object)}Object.keys(object).forEach((key)=>{if(object[key]&&typeof object[key]==='object'){results.push(...findNestedObjectsByAttributeNames(object[key],attributeNames))}});return results}function pageLoaded(){if(document.readyState==='complete'){return Promise.resolve()}const deferred=new Deferred();window.addEventListener('load',deferred.resolve,{once:true});return deferred}function createDeepCopy(obj){return nativeJSONParse(JSON.stringify(obj))}function getYtcfgValue(name){var _window$ytcfg;return(_window$ytcfg=window.ytcfg)===null||_window$ytcfg===void 0?void 0:_window$ytcfg.get(name)}function getSignatureTimestamp(){return(getYtcfgValue('STS')||(()=>{var _document$querySelect;const playerBaseJsPath=(_document$querySelect=document.querySelector('script[src*="/base.js"]'))===null||_document$querySelect===void 0?void 0:_document$querySelect.src;if(!playerBaseJsPath){return}const xmlhttp=new XMLHttpRequest();xmlhttp.open('GET',playerBaseJsPath,false);xmlhttp.send(null);return parseInt(xmlhttp.responseText.match(/signatureTimestamp:([0-9]*)/)[1])})())}function isUserLoggedIn(){if(typeof getYtcfgValue('LOGGED_IN')==='boolean'){return getYtcfgValue('LOGGED_IN')}if(typeof getYtcfgValue('DELEGATED_SESSION_ID')==='string'){return true}if(parseInt(getYtcfgValue('SESSION_INDEX'))>=0){return true}return false}function getCurrentVideoStartTime(currentVideoId){if(window.location.href.includes(currentVideoId)){var _ref;const urlParams=new URLSearchParams(window.location.search);const startTimeString=(_ref=urlParams.get('t')||urlParams.get('start')||urlParams.get('time_continue'))===null||_ref===void 0?void 0:_ref.replace('s','');if(startTimeString&&!isNaN(startTimeString)){return parseInt(startTimeString)}}return 0}function setUrlParams(params){const urlParams=new URLSearchParams(window.location.search);for(const paramName in params){urlParams.set(paramName,params[paramName])}window.location.search=urlParams}function waitForElement(elementSelector,timeout){const deferred=new Deferred();const checkDomInterval=setInterval(()=>{const elem=document.querySelector(elementSelector);if(elem){clearInterval(checkDomInterval);deferred.resolve(elem)}},100);if(timeout){setTimeout(()=>{clearInterval(checkDomInterval);deferred.reject()},timeout)}return deferred}function parseRelativeUrl(url){if(typeof url!=='string'){return null}if(url.indexOf('/')===0){url=window.location.origin+url}try{return url.indexOf('https://')===0?new window.URL(url):null}catch{return null}}function isWatchNextObject(parsedData){var _parsedData$currentVi;if(!(parsedData!==null&&parsedData!==void 0&&parsedData.contents)||!(parsedData!==null&&parsedData!==void 0&&(_parsedData$currentVi=parsedData.currentVideoEndpoint)!==null&&_parsedData$currentVi!==void 0&&(_parsedData$currentVi=_parsedData$currentVi.watchEndpoint)!==null&&_parsedData$currentVi!==void 0&&_parsedData$currentVi.videoId)){return false}return!!parsedData.contents.twoColumnWatchNextResults||!!parsedData.contents.singleColumnWatchNextResults}function isWatchNextSidebarEmpty(parsedData){var _parsedData$contents2,_content$find;if(isDesktop){var _parsedData$contents;const result=(_parsedData$contents=parsedData.contents)===null||_parsedData$contents===void 0||(_parsedData$contents=_parsedData$contents.twoColumnWatchNextResults)===null||_parsedData$contents===void 0||(_parsedData$contents=_parsedData$contents.secondaryResults)===null||_parsedData$contents===void 0||(_parsedData$contents=_parsedData$contents.secondaryResults)===null||_parsedData$contents===void 0?void 0:_parsedData$contents.results;return!result}const content=(_parsedData$contents2=parsedData.contents)===null||_parsedData$contents2===void 0||(_parsedData$contents2=_parsedData$contents2.singleColumnWatchNextResults)===null||_parsedData$contents2===void 0||(_parsedData$contents2=_parsedData$contents2.results)===null||_parsedData$contents2===void 0||(_parsedData$contents2=_parsedData$contents2.results)===null||_parsedData$contents2===void 0?void 0:_parsedData$contents2.contents;const result=content===null||content===void 0||(_content$find=content.find((e)=>{var _e$itemSectionRendere;return((_e$itemSectionRendere=e.itemSectionRenderer)===null||_e$itemSectionRendere===void 0?void 0:_e$itemSectionRendere.targetId)==='watch-next-feed'}))===null||_content$find===void 0?void 0:_content$find.itemSectionRenderer;return typeof result!=='object'}function isPlayerObject(parsedData){return(parsedData===null||parsedData===void 0?void 0:parsedData.videoDetails)&&(parsedData===null||parsedData===void 0?void 0:parsedData.playabilityStatus)}function isEmbeddedPlayerObject(parsedData){return typeof(parsedData===null||parsedData===void 0?void 0:parsedData.previewPlayabilityStatus)==='object'}function isAgeRestricted(playabilityStatus){var _playabilityStatus$er;if(!(playabilityStatus!==null&&playabilityStatus!==void 0&&playabilityStatus.status)){return false}if(playabilityStatus.desktopLegacyAgeGateReason){return true}if(Config.UNLOCKABLE_PLAYABILITY_STATUSES.includes(playabilityStatus.status)){return true}return(isEmbed&&((_playabilityStatus$er=playabilityStatus.errorScreen)===null||_playabilityStatus$er===void 0||(_playabilityStatus$er=_playabilityStatus$er.playerErrorMessageRenderer)===null||_playabilityStatus$er===void 0||(_playabilityStatus$er=_playabilityStatus$er.reason)===null||_playabilityStatus$er===void 0||(_playabilityStatus$er=_playabilityStatus$er.runs)===null||_playabilityStatus$er===void 0||(_playabilityStatus$er=_playabilityStatus$er.find((x)=>x.navigationEndpoint))===null||_playabilityStatus$er===void 0||(_playabilityStatus$er=_playabilityStatus$er.navigationEndpoint)===null||_playabilityStatus$er===void 0||(_playabilityStatus$er=_playabilityStatus$er.urlEndpoint)===null||_playabilityStatus$er===void 0||(_playabilityStatus$er=_playabilityStatus$er.url)===null||_playabilityStatus$er===void 0?void 0:_playabilityStatus$er.includes('/2802167')))}function isSearchResult(parsedData){var _parsedData$contents3,_parsedData$contents4,_parsedData$onRespons;return(typeof(parsedData===null||parsedData===void 0||(_parsedData$contents3=parsedData.contents)===null||_parsedData$contents3===void 0?void 0:_parsedData$contents3.twoColumnSearchResultsRenderer)==='object'||(parsedData===null||parsedData===void 0||(_parsedData$contents4=parsedData.contents)===null||_parsedData$contents4===void 0||(_parsedData$contents4=_parsedData$contents4.sectionListRenderer)===null||_parsedData$contents4===void 0?void 0:_parsedData$contents4.targetId)==='search-feed'||(parsedData===null||parsedData===void 0||(_parsedData$onRespons=parsedData.onResponseReceivedCommands)===null||_parsedData$onRespons===void 0||(_parsedData$onRespons=_parsedData$onRespons.find((x)=>x.appendContinuationItemsAction))===null||_parsedData$onRespons===void 0||(_parsedData$onRespons=_parsedData$onRespons.appendContinuationItemsAction)===null||_parsedData$onRespons===void 0?void 0:_parsedData$onRespons.targetId)==='search-feed')}function attach$4(obj,prop,onCall){if(!obj||typeof obj[prop]!=='function'){return}let original=obj[prop];obj[prop]=function(){try{onCall(arguments)}catch{};original.apply(this,arguments)}}const logPrefix='%cSimple-YouTube-Age-Restriction-Bypass:';const logPrefixStyle='background-color: #1e5c85; color: #fff; font-size: 1.2em;';const logSuffix='\uD83D\uDC1E You can report bugs at: https://github.com/zerodytrash/Simple-YouTube-Age-Restriction-Bypass/issues';function error(err,msg){console.error(logPrefix,logPrefixStyle,msg,err,getYtcfgDebugString(),'\n\n',logSuffix);if(window.SYARB_CONFIG){window.dispatchEvent(new CustomEvent('SYARB_LOG_ERROR',{detail:{message:(msg?msg+'; ':'')+(err&&err.message?err.message:''),stack:err&&err.stack?err.stack:null}}),)}}function info(msg){console.info(logPrefix,logPrefixStyle,msg);if(window.SYARB_CONFIG){window.dispatchEvent(new CustomEvent('SYARB_LOG_INFO',{detail:{message:msg}}),)}}function getYtcfgDebugString(){try{return(`InnertubeConfig: `+`innertubeApiKey: ${getYtcfgValue('INNERTUBE_API_KEY')} `+`innertubeClientName: ${getYtcfgValue('INNERTUBE_CLIENT_NAME')} `+`innertubeClientVersion: ${getYtcfgValue('INNERTUBE_CLIENT_VERSION')} `+`loggedIn: ${getYtcfgValue('LOGGED_IN')} `)}catch(err){return `Failed to access config: ${ err }`}}function attach$3(onInitialData){interceptObjectProperty('playerResponse',(obj,playerResponse)=>{info(`playerResponse property set, contains sidebar: ${!!obj.response }`);if(isObject(obj.response)){onInitialData(obj.response)}playerResponse.unlocked=false;onInitialData(playerResponse);return playerResponse.unlocked?createDeepCopy(playerResponse):playerResponse});window.addEventListener('DOMContentLoaded',()=>{if(isObject(window.ytInitialData)){onInitialData(window.ytInitialData)}})}function interceptObjectProperty(prop,onSet){var _Object$getOwnPropert;const dataKey='__SYARB_'+prop;const{get:getter,set:setter}=(_Object$getOwnPropert=Object.getOwnPropertyDescriptor(Object.prototype,prop))!==null&&_Object$getOwnPropert!==void 0?_Object$getOwnPropert:{set(value){this[dataKey]=value},get(){return this[dataKey]}};Object.defineProperty(Object.prototype,prop,{set(value){setter.call(this,isObject(value)?onSet(this,value):value)},get(){return getter.call(this)},configurable:true})}function attach$2(onJsonDataReceived){window.JSON.parse=function(){const data=nativeJSONParse.apply(this,arguments);return isObject(data)?onJsonDataReceived(data):data}}function attach$1(onRequestCreate){if(typeof window.Request!=='function'){return}window.Request=new Proxy(window.Request,{construct(target,args){const[url,options]=args;try{const parsedUrl=parseRelativeUrl(url);const modifiedUrl=onRequestCreate(parsedUrl,options);if(modifiedUrl){args[0]=modifiedUrl.toString()}}catch(err){error(err,`Failed to intercept Request()`)}return Reflect.construct(...arguments)}})}function attach(onXhrOpenCalled){XMLHttpRequest.prototype.open=function(method,url){try{let parsedUrl=parseRelativeUrl(url);if(parsedUrl){const modifiedUrl=onXhrOpenCalled(method,parsedUrl,this);if(modifiedUrl){arguments[1]=modifiedUrl.toString()}}}catch(err){error(err,`Failed to intercept XMLHttpRequest.open()`)}nativeXMLHttpRequestOpen.apply(this,arguments)}}const localStoragePrefix='SYARB_';function set(key,value){localStorage.setItem(localStoragePrefix+key,JSON.stringify(value))}function get(key){try{return JSON.parse(localStorage.getItem(localStoragePrefix+key))}catch{return null}}function getPlayer$1(payload,useAuth){return sendInnertubeRequest('v1/player',payload,useAuth)}function getNext$1(payload,useAuth){return sendInnertubeRequest('v1/next',payload,useAuth)}function sendInnertubeRequest(endpoint,payload,useAuth){const xmlhttp=new XMLHttpRequest();xmlhttp.open('POST',`/youtubei/${ endpoint }?key=${getYtcfgValue('INNERTUBE_API_KEY')}&prettyPrint=false`,false);if(useAuth&&isUserLoggedIn()){xmlhttp.withCredentials=true;Config.GOOGLE_AUTH_HEADER_NAMES.forEach((headerName)=>{xmlhttp.setRequestHeader(headerName,get(headerName))})}xmlhttp.send(JSON.stringify(payload));return nativeJSONParse(xmlhttp.responseText)}var innertube={getPlayer:getPlayer$1,getNext:getNext$1};let nextResponseCache={};function getGoogleVideoUrl(originalUrl){return Config.VIDEO_PROXY_SERVER_HOST+'/direct/'+btoa(originalUrl.toString())}function getPlayer(payload){if(!nextResponseCache[payload.videoId]&&!isMusic&&!isEmbed){payload.includeNext=1}return sendRequest('getPlayer',payload)}function getNext(payload){if(nextResponseCache[payload.videoId]){return nextResponseCache[payload.videoId]}return sendRequest('getNext',payload)}function sendRequest(endpoint,payload){const queryParams=new URLSearchParams(payload);const proxyUrl=`${Config.ACCOUNT_PROXY_SERVER_HOST }/${ endpoint }?${ queryParams }&client=js`;try{const xmlhttp=new XMLHttpRequest();xmlhttp.open('GET',proxyUrl,false);xmlhttp.send(null);const proxyResponse=nativeJSONParse(xmlhttp.responseText);proxyResponse.proxied=true;if(proxyResponse.nextResponse){nextResponseCache[payload.videoId]=proxyResponse.nextResponse;delete proxyResponse.nextResponse}return proxyResponse}catch(err){error(err,'Proxy API Error');return{errorMessage:'Proxy Connection failed'}}}var proxy={getPlayer,getNext,getGoogleVideoUrl};function getUnlockStrategies$1(videoId,lastPlayerUnlockReason){var _getYtcfgValue$client;const clientName=getYtcfgValue('INNERTUBE_CLIENT_NAME')||'WEB';const clientVersion=getYtcfgValue('INNERTUBE_CLIENT_VERSION')||'2.20220203.04.00';const hl=getYtcfgValue('HL');const userInterfaceTheme=(_getYtcfgValue$client=getYtcfgValue('INNERTUBE_CONTEXT').client.userInterfaceTheme)!==null&&_getYtcfgValue$client!==void 0?_getYtcfgValue$client:document.documentElement.hasAttribute('dark')?'USER_INTERFACE_THEME_DARK':'USER_INTERFACE_THEME_LIGHT';return[{name:'Content Warning Bypass',skip:!lastPlayerUnlockReason||!lastPlayerUnlockReason.includes('CHECK_REQUIRED'),optionalAuth:true,payload:{context:{client:{clientName,clientVersion,hl,userInterfaceTheme}},videoId,racyCheckOk:true,contentCheckOk:true},endpoint:innertube},{name:'Account Proxy',payload:{videoId,clientName,clientVersion,hl,userInterfaceTheme,isEmbed: +isEmbed,isConfirmed: +isConfirmed},endpoint:proxy}]}function getUnlockStrategies(videoId,reason){const clientName=getYtcfgValue('INNERTUBE_CLIENT_NAME')||'WEB';const clientVersion=getYtcfgValue('INNERTUBE_CLIENT_VERSION')||'2.20220203.04.00';const signatureTimestamp=getSignatureTimestamp();const startTimeSecs=getCurrentVideoStartTime(videoId);const hl=getYtcfgValue('HL');return[{name:'Content Warning Bypass',skip:!reason||!reason.includes('CHECK_REQUIRED'),optionalAuth:true,payload:{context:{client:{clientName:clientName,clientVersion:clientVersion,hl}},playbackContext:{contentPlaybackContext:{signatureTimestamp}},videoId,startTimeSecs,racyCheckOk:true,contentCheckOk:true},endpoint:innertube},{name:'TV Embedded Player',requiresAuth:false,payload:{context:{client:{clientName:'TVHTML5_SIMPLY_EMBEDDED_PLAYER',clientVersion:'2.0',clientScreen:'WATCH',hl},thirdParty:{embedUrl:'https://www.youtube.com/'}},playbackContext:{contentPlaybackContext:{signatureTimestamp}},videoId,startTimeSecs,racyCheckOk:true,contentCheckOk:true},endpoint:innertube},{name:'Creator + Auth',requiresAuth:true,payload:{context:{client:{clientName:'WEB_CREATOR',clientVersion:'1.20210909.07.00',hl}},playbackContext:{contentPlaybackContext:{signatureTimestamp}},videoId,startTimeSecs,racyCheckOk:true,contentCheckOk:true},endpoint:innertube},{name:'Account Proxy',payload:{videoId,reason,clientName,clientVersion,signatureTimestamp,startTimeSecs,hl,isEmbed: +isEmbed,isConfirmed: +isConfirmed},endpoint:proxy}]}var buttonTemplate='<div style="margin-top: 15px !important; padding: 3px 10px 3px 10px; margin: 0px auto; background-color: #4d4d4d; width: fit-content; font-size: 1.2em; text-transform: uppercase; border-radius: 3px; cursor: pointer;">\n    <div class="button-text"></div>\n</div>';let buttons={};async function addButton(id,text,backgroundColor,onClick){const errorScreenElement=await waitForElement('.ytp-error',2000);const buttonElement=createElement('div',{class:'button-container',innerHTML:buttonTemplate});buttonElement.getElementsByClassName('button-text')[0].innerText=text;if(backgroundColor){buttonElement.querySelector(':scope > div').style['background-color']=backgroundColor}if(typeof onClick==='function'){buttonElement.addEventListener('click',onClick)}if(buttons[id]&&buttons[id].isConnected){return}buttons[id]=buttonElement;errorScreenElement.append(buttonElement)}function removeButton(id){if(buttons[id]&&buttons[id].isConnected){buttons[id].remove()}}const confirmationButtonId='confirmButton';const confirmationButtonText='Click to unlock';function isConfirmationRequired(){return!isConfirmed&&isEmbed&&Config.ENABLE_UNLOCK_CONFIRMATION_EMBED}function requestConfirmation(){addButton(confirmationButtonId,confirmationButtonText,null,()=>{removeButton(confirmationButtonId);confirm()})}function confirm(){setUrlParams({unlock_confirmed:1,autoplay:1})}var tDesktop='<tp-yt-paper-toast></tp-yt-paper-toast>\n';var tMobile='<c3-toast>\n    <ytm-notification-action-renderer>\n        <div class="notification-action-response-text"></div>\n    </ytm-notification-action-renderer>\n</c3-toast>\n';const template=isDesktop?tDesktop:tMobile;const nToastContainer=createElement('div',{id:'toast-container',innerHTML:template});const nToast=nToastContainer.querySelector(':scope > *');if(isMusic){nToast.style['margin-bottom']='85px'}if(!isDesktop){nToast.nMessage=nToast.querySelector('.notification-action-response-text');nToast.show=(message)=>{nToast.nMessage.innerText=message;nToast.setAttribute('dir','in');setTimeout(()=>{nToast.setAttribute('dir','out')},nToast.duration+225)}}async function show(message,duration=5){if(!Config.ENABLE_UNLOCK_NOTIFICATION){return}if(isEmbed){return}await pageLoaded();if(document.visibilityState==='hidden'){return}if(!nToastContainer.isConnected){document.documentElement.append(nToastContainer)}nToast.duration=duration*1000;nToast.show(message)}var Toast={show};const messagesMap={success:'Age-restricted video successfully unlocked!',fail:'Unable to unlock this video 🙁 - More information in the developer console'};let lastPlayerUnlockVideoId=null;let lastPlayerUnlockReason=null;let lastProxiedGoogleVideoUrlParams;let cachedPlayerResponse={};function getLastProxiedGoogleVideoId(){var _lastProxiedGoogleVid;return(_lastProxiedGoogleVid=lastProxiedGoogleVideoUrlParams)===null||_lastProxiedGoogleVid===void 0?void 0:_lastProxiedGoogleVid.get('id')}function unlockResponse$1(playerResponse){var _playerResponse$video,_playerResponse$playa,_playerResponse$previ,_unlockedPlayerRespon,_unlockedPlayerRespon3;if(isConfirmationRequired()){info('Unlock confirmation required.');requestConfirmation();return}const videoId=((_playerResponse$video=playerResponse.videoDetails)===null||_playerResponse$video===void 0?void 0:_playerResponse$video.videoId)||getYtcfgValue('PLAYER_VARS').video_id;const reason=((_playerResponse$playa=playerResponse.playabilityStatus)===null||_playerResponse$playa===void 0?void 0:_playerResponse$playa.status)||((_playerResponse$previ=playerResponse.previewPlayabilityStatus)===null||_playerResponse$previ===void 0?void 0:_playerResponse$previ.status);if(!Config.SKIP_CONTENT_WARNINGS&&reason.includes('CHECK_REQUIRED')){info(`SKIP_CONTENT_WARNINGS disabled and ${ reason } status detected.`);return}lastPlayerUnlockVideoId=videoId;lastPlayerUnlockReason=reason;const unlockedPlayerResponse=getUnlockedPlayerResponse(videoId,reason);if(unlockedPlayerResponse.errorMessage){Toast.show(`${messagesMap.fail } (ProxyError)`,10);throw new Error(`Player Unlock Failed, Proxy Error Message: ${unlockedPlayerResponse.errorMessage }`)}if(!Config.VALID_PLAYABILITY_STATUSES.includes((_unlockedPlayerRespon=unlockedPlayerResponse.playabilityStatus)===null||_unlockedPlayerRespon===void 0?void 0:_unlockedPlayerRespon.status,)){var _unlockedPlayerRespon2;Toast.show(`${messagesMap.fail } (PlayabilityError)`,10);throw new Error(`Player Unlock Failed, playabilityStatus: ${(_unlockedPlayerRespon2=unlockedPlayerResponse.playabilityStatus)===null||_unlockedPlayerRespon2===void 0?void 0:_unlockedPlayerRespon2.status }`,)}if(unlockedPlayerResponse.proxied&&(_unlockedPlayerRespon3=unlockedPlayerResponse.streamingData)!==null&&_unlockedPlayerRespon3!==void 0&&_unlockedPlayerRespon3.adaptiveFormats){var _unlockedPlayerRespon4,_unlockedPlayerRespon5;const cipherText=(_unlockedPlayerRespon4=unlockedPlayerResponse.streamingData.adaptiveFormats.find((x)=>x.signatureCipher))===null||_unlockedPlayerRespon4===void 0?void 0:_unlockedPlayerRespon4.signatureCipher;const videoUrl=cipherText?new URLSearchParams(cipherText).get('url'):(_unlockedPlayerRespon5=unlockedPlayerResponse.streamingData.adaptiveFormats.find((x)=>x.url))===null||_unlockedPlayerRespon5===void 0?void 0:_unlockedPlayerRespon5.url;lastProxiedGoogleVideoUrlParams=videoUrl?new URLSearchParams(new window.URL(videoUrl).search):null}if(playerResponse.previewPlayabilityStatus){playerResponse.previewPlayabilityStatus=unlockedPlayerResponse.playabilityStatus}Object.assign(playerResponse,unlockedPlayerResponse);playerResponse.unlocked=true;Toast.show(messagesMap.success)}function getUnlockedPlayerResponse(videoId,reason){if(cachedPlayerResponse.videoId===videoId){return createDeepCopy(cachedPlayerResponse)}const unlockStrategies=getUnlockStrategies(videoId,reason);let unlockedPlayerResponse={};unlockStrategies.every((strategy,index)=>{var _unlockedPlayerRespon6;if(strategy.skip||strategy.requiresAuth&&!isUserLoggedIn()){return true}info(`Trying Player Unlock Method #${index+1} (${strategy.name })`);try{unlockedPlayerResponse=strategy.endpoint.getPlayer(strategy.payload,strategy.requiresAuth||strategy.optionalAuth)}catch(err){error(err,`Player Unlock Method ${index+1} failed with exception`)}const isStatusValid=Config.VALID_PLAYABILITY_STATUSES.includes((_unlockedPlayerRespon6=unlockedPlayerResponse)===null||_unlockedPlayerRespon6===void 0||(_unlockedPlayerRespon6=_unlockedPlayerRespon6.playabilityStatus)===null||_unlockedPlayerRespon6===void 0?void 0:_unlockedPlayerRespon6.status,);if(isStatusValid){var _unlockedPlayerRespon7;if(!unlockedPlayerResponse.trackingParams||!((_unlockedPlayerRespon7=unlockedPlayerResponse.responseContext)!==null&&_unlockedPlayerRespon7!==void 0&&(_unlockedPlayerRespon7=_unlockedPlayerRespon7.mainAppWebResponseContext)!==null&&_unlockedPlayerRespon7!==void 0&&_unlockedPlayerRespon7.trackingParam)){unlockedPlayerResponse.trackingParams='CAAQu2kiEwjor8uHyOL_AhWOvd4KHavXCKw=';unlockedPlayerResponse.responseContext={mainAppWebResponseContext:{trackingParam:'kx_fmPxhoPZRzgL8kzOwANUdQh8ZwHTREkw2UqmBAwpBYrzRgkuMsNLBwOcCE59TDtslLKPQ-SS'}}}if(strategy.payload.startTimeSecs&&strategy.name==='Account Proxy'){unlockedPlayerResponse.playerConfig={playbackStartConfig:{startSeconds:strategy.payload.startTimeSecs}}}}return!isStatusValid});cachedPlayerResponse={videoId,...createDeepCopy(unlockedPlayerResponse)};return unlockedPlayerResponse}let cachedNextResponse={};function unlockResponse(originalNextResponse){const videoId=originalNextResponse.currentVideoEndpoint.watchEndpoint.videoId;if(!videoId){throw new Error(`Missing videoId in nextResponse`)}if(videoId!==lastPlayerUnlockVideoId){return}const unlockedNextResponse=getUnlockedNextResponse(videoId);if(isWatchNextSidebarEmpty(unlockedNextResponse)){throw new Error(`Sidebar Unlock Failed`)}mergeNextResponse(originalNextResponse,unlockedNextResponse)}function getUnlockedNextResponse(videoId){if(cachedNextResponse.videoId===videoId){return createDeepCopy(cachedNextResponse)}const unlockStrategies=getUnlockStrategies$1(videoId,lastPlayerUnlockReason);let unlockedNextResponse={};unlockStrategies.every((strategy,index)=>{if(strategy.skip){return true}info(`Trying Next Unlock Method #${index+1} (${strategy.name })`);try{unlockedNextResponse=strategy.endpoint.getNext(strategy.payload,strategy.optionalAuth)}catch(err){error(err,`Next Unlock Method ${index+1} failed with exception`)}return isWatchNextSidebarEmpty(unlockedNextResponse)});cachedNextResponse={videoId,...createDeepCopy(unlockedNextResponse)};return unlockedNextResponse}function mergeNextResponse(originalNextResponse,unlockedNextResponse){var _unlockedNextResponse;if(isDesktop){originalNextResponse.contents.twoColumnWatchNextResults.secondaryResults=unlockedNextResponse.contents.twoColumnWatchNextResults.secondaryResults;const originalVideoSecondaryInfoRenderer=originalNextResponse.contents.twoColumnWatchNextResults.results.results.contents.find((x)=>x.videoSecondaryInfoRenderer,).videoSecondaryInfoRenderer;const unlockedVideoSecondaryInfoRenderer=unlockedNextResponse.contents.twoColumnWatchNextResults.results.results.contents.find((x)=>x.videoSecondaryInfoRenderer,).videoSecondaryInfoRenderer;if(unlockedVideoSecondaryInfoRenderer.description){originalVideoSecondaryInfoRenderer.description=unlockedVideoSecondaryInfoRenderer.description}else if(unlockedVideoSecondaryInfoRenderer.attributedDescription){originalVideoSecondaryInfoRenderer.attributedDescription=unlockedVideoSecondaryInfoRenderer.attributedDescription}return}const unlockedWatchNextFeed=(_unlockedNextResponse=unlockedNextResponse.contents)===null||_unlockedNextResponse===void 0||(_unlockedNextResponse=_unlockedNextResponse.singleColumnWatchNextResults)===null||_unlockedNextResponse===void 0||(_unlockedNextResponse=_unlockedNextResponse.results)===null||_unlockedNextResponse===void 0||(_unlockedNextResponse=_unlockedNextResponse.results)===null||_unlockedNextResponse===void 0||(_unlockedNextResponse=_unlockedNextResponse.contents)===null||_unlockedNextResponse===void 0?void 0:_unlockedNextResponse.find((x)=>{var _x$itemSectionRendere;return((_x$itemSectionRendere=x.itemSectionRenderer)===null||_x$itemSectionRendere===void 0?void 0:_x$itemSectionRendere.targetId)==='watch-next-feed'},);if(unlockedWatchNextFeed){originalNextResponse.contents.singleColumnWatchNextResults.results.results.contents.push(unlockedWatchNextFeed)}const originalStructuredDescriptionContentRenderer=originalNextResponse.engagementPanels.find((x)=>x.engagementPanelSectionListRenderer).engagementPanelSectionListRenderer.content.structuredDescriptionContentRenderer.items.find((x)=>x.expandableVideoDescriptionBodyRenderer);const unlockedStructuredDescriptionContentRenderer=unlockedNextResponse.engagementPanels.find((x)=>x.engagementPanelSectionListRenderer).engagementPanelSectionListRenderer.content.structuredDescriptionContentRenderer.items.find((x)=>x.expandableVideoDescriptionBodyRenderer);if(unlockedStructuredDescriptionContentRenderer.expandableVideoDescriptionBodyRenderer){originalStructuredDescriptionContentRenderer.expandableVideoDescriptionBodyRenderer=unlockedStructuredDescriptionContentRenderer.expandableVideoDescriptionBodyRenderer}}function handleXhrOpen(method,url,xhr){let proxyUrl=unlockGoogleVideo(url);if(proxyUrl){Object.defineProperty(xhr,'withCredentials',{set:()=>{},get:()=>false});return proxyUrl}if(url.pathname.indexOf('/youtubei/')===0){attach$4(xhr,'setRequestHeader',([headerName,headerValue])=>{if(Config.GOOGLE_AUTH_HEADER_NAMES.includes(headerName)){set(headerName,headerValue)}})}if(Config.SKIP_CONTENT_WARNINGS&&method==='POST'&&['/youtubei/v1/player','/youtubei/v1/next'].includes(url.pathname)){attach$4(xhr,'send',(args)=>{if(typeof args[0]==='string'){args[0]=setContentCheckOk(args[0])}})}}function handleFetchRequest(url,requestOptions){let newGoogleVideoUrl=unlockGoogleVideo(url);if(newGoogleVideoUrl){if(requestOptions.credentials){requestOptions.credentials='omit'}return newGoogleVideoUrl}if(url.pathname.indexOf('/youtubei/')===0&&isObject(requestOptions.headers)){for(let headerName in requestOptions.headers){if(Config.GOOGLE_AUTH_HEADER_NAMES.includes(headerName)){set(headerName,requestOptions.headers[headerName])}}}if(Config.SKIP_CONTENT_WARNINGS&&['/youtubei/v1/player','/youtubei/v1/next'].includes(url.pathname)){requestOptions.body=setContentCheckOk(requestOptions.body)}}function unlockGoogleVideo(url){if(Config.VIDEO_PROXY_SERVER_HOST&&isGoogleVideoUrl(url)){if(isGoogleVideoUnlockRequired(url,getLastProxiedGoogleVideoId())){return proxy.getGoogleVideoUrl(url)}}}function setContentCheckOk(bodyJson){try{let parsedBody=JSON.parse(bodyJson);if(parsedBody.videoId){parsedBody.contentCheckOk=true;parsedBody.racyCheckOk=true;return JSON.stringify(parsedBody)}}catch{};return bodyJson}function processThumbnails(responseObject){const thumbnails=findNestedObjectsByAttributeNames(responseObject,['url','height']);let blurredThumbnailCount=0;for(const thumbnail of thumbnails){if(isThumbnailBlurred(thumbnail)){blurredThumbnailCount+=1;thumbnail.url=thumbnail.url.split('?')[0]}}info(blurredThumbnailCount+'/'+thumbnails.length+' thumbnails detected as blurred.')}function isThumbnailBlurred(thumbnail){const hasSQPParam=thumbnail.url.indexOf('?sqp=')!==-1;if(!hasSQPParam){return false}const SQPLength=new URL(thumbnail.url).searchParams.get('sqp').length;const isBlurred=Config.BLURRED_THUMBNAIL_SQP_LENGTHS.includes(SQPLength);return isBlurred}try{attach$3(processYtData);attach$2(processYtData);attach(handleXhrOpen);attach$1(handleFetchRequest)}catch(err){error(err,'Error while attaching data interceptors')}function processYtData(ytData){try{if(isPlayerObject(ytData)&&isAgeRestricted(ytData.playabilityStatus)){unlockResponse$1(ytData )}else if(isEmbeddedPlayerObject(ytData)&&isAgeRestricted(ytData.previewPlayabilityStatus)){unlockResponse$1(ytData)}}catch(err){error(err,'Video unlock failed')}try{if(isWatchNextObject(ytData)&&isWatchNextSidebarEmpty(ytData)){unlockResponse(ytData)}if(isWatchNextObject(ytData.response)&&isWatchNextSidebarEmpty(ytData.response)){unlockResponse(ytData.response)}}catch(err){error(err,'Sidebar unlock failed')}try{if(isSearchResult(ytData)){processThumbnails(ytData)}}catch(err){error(err,'Thumbnail unlock failed')}return ytData}
    ]]

    function SERVICE:LoadVideo(Video, panel)
        -- NOTE(winter): We aren't using https://swamp.sv/s/cinema/youtube.html anymore; embedding JS like this makes us more flexible to support Age Restricted and Embed Disabled videos
        -- NOTE(noz): mute=1 to prevent annoying full volume initialization; immediately check player.isMuted() to player.unMute() when possible, player.setVolume(0) doesn't set player.isMuted() to true so it's fine
        panel:OpenURL("https://www.youtube.com/embed/" .. Video:Key() .. "?autoplay=1&controls=0&showinfo=0&modestbranding=1&rel=0&iv_load_policy=3&enablejsapi=1&mute=1&start=" .. math.Round(CurTime() - Video:StartTime()))

        panel.OnBeginLoadingDocument = function(_, url)
            if not string.match(url, "/embed/") then
                -- This will get overridden by our think function in OnDocumentReady's js once it's run
                panel:RunJavascript([[
                    function think() {
                        if (typeof(player_ready) == "undefined"){
                            var player = document.getElementsByClassName("html5-video-player")[0];
                            player.setVolume(]] .. theater.GetVolume() .. [[);
                        }
                    }
                    setInterval(think, 100);
                ]])
            end

            if self:IsMature(Video) then
                panel:RunJavascript(age_restrict_js)
            end
        end

        panel.OnDocumentReady = function(_, url)
            panel:OnDocumentReadyBase(url)

            panel:AddFunction("gmod", "loaded", function()
                self:SeekTo(CurTime() - Video:StartTime(), panel)
                self:SetVolume(theater.GetVolume(), panel)
            end)

            panel:AddFunction("gmod", "player_error", function(code)
                if code == 101 or code == 150 then
                    -- Retry once in case it's a Referer issue
                    if not Video.TriedReferer then
                        Video.TriedReferer = true
                        panel:QueueJavascript("window.location.href = window.location.href;")

                        return
                    end

                    -- TODO: CC support for Embed Disabled Videos
                    panel:OpenURL("https://www.youtube.com/watch?v=" .. Video:Key() .. "&start=" .. math.Round(CurTime() - Video:StartTime()))
                end
            end)

            panel:AddFunction("gmod", "update_timestamp", function(timestamp)
                YOUTUBE_TRUE_START = SysTime() - tonumber(timestamp)
                YOUTUBE_TRUE_START_PING = SysTime()
            end)

            panel:QueueJavascript(js)
            panel:QueueJavascript("start_time = timestamp(); seek_to_end = " .. (Video:Duration() > 0 and "false" or "true") .. ";")

            if not string.match(url, "/embed/") then
                panel:QueueJavascript(noembed_js)
            end

            panel:QueueJavascript("if(document.getElementsByClassName('ytp-watermark').length)document.getElementsByClassName('ytp-watermark')[0].remove()") --bottom right watermark
            panel:QueueJavascript("if(document.getElementsByClassName('ytp-show-cards-title').length)document.getElementsByClassName('ytp-show-cards-title')[0].remove()") --title bar
            panel:QueueJavascript("if(document.getElementsByClassName('ytp-paid-content-overlay').length)document.getElementsByClassName('ytp-paid-content-overlay')[0].remove()") --ad?
            panel:QueueJavascript("if(document.getElementsByClassName('ytp-pause-overlay').length)document.getElementsByClassName('ytp-pause-overlay')[0].remove()") --pause overlay
            panel:QueueJavascript("if(document.getElementsByClassName('videowall-endscreen').length)document.getElementsByClassName('videowall-endscreen')[0].remove()") --endscreen
            panel:QueueJavascript("if(document.getElementsByClassName('ytp-gradient-top').length)document.getElementsByClassName('ytp-gradient-top')[0].remove()") --top gradient
        end
    end

    function YoutubeActualTimestamp()
        if (YOUTUBE_TRUE_START_PING or -100) > SysTime() - 2 then return SysTime() - YOUTUBE_TRUE_START end
    end
end

theater.RegisterService("youtube", SERVICE)
