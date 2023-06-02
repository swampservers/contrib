-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local EmbeddedChromiumSuccessCallbacks = {}
local EmbeddedChromiumFailCallbacks = {}
local EmbeddedFlashSuccessCallbacks = {}
local EmbeddedFlashFailCallbacks = {}
local EmbeddedCodecsSuccessCallbacks = {}
local EmbeddedCodecsFailCallbacks = {}

function EmbeddedIsReady()
    RequestEmbeddedSupport()

    return EmbeddedFinishedRequest
end

function EmbeddedHasChromium()
    if not EmbeddedIsReady() then
        error('not ready')
    end

    return EmbeddedChromiumStatus
end

function EmbeddedHasFlash()
    if not EmbeddedIsReady() then
        error('not ready')
    end

    return EmbeddedFlashStatus
end

function EmbeddedHasCodecs()
    if not EmbeddedIsReady() then
        error('not ready')
    end

    return EmbeddedCodecsStatus
end

--if string.match(file.Read("steam.inf", "MOD"), "CEFCodecFix=true") then
function EmbeddedCheckChromium(succ, fail)
    if EmbeddedFinishedRequest then
        if EmbeddedChromiumStatus then
            succ()
        else
            fail()
        end
    else
        table.insert(EmbeddedChromiumSuccessCallbacks, succ)
        table.insert(EmbeddedChromiumFailCallbacks, fail)
        RequestEmbeddedSupport()
    end
end

function EmbeddedCheckFlash(succ, fail)
    if EmbeddedFinishedRequest then
        if EmbeddedFlashStatus then
            succ()
        else
            fail()
        end
    else
        table.insert(EmbeddedFlashSuccessCallbacks, succ)
        table.insert(EmbeddedFlashFailCallbacks, fail)
        RequestEmbeddedSupport()
    end
end

function EmbeddedCheckCodecs(succ, fail)
    if EmbeddedFinishedRequest then
        if EmbeddedCodecsStatus then
            succ()
        else
            fail()
        end
    else
        table.insert(EmbeddedCodecsSuccessCallbacks, succ)
        table.insert(EmbeddedCodecsFailCallbacks, fail)
        RequestEmbeddedSupport()
    end
end

function RequestEmbeddedSupport()
    if EmbeddedStartedRequest then return end
    EmbeddedStartedRequest = true
    local panel = vgui.Create("DHTML", nil, "EmbeddedSupport")
    panel:SetSize(100, 100)
    panel:SetAlpha(0)
    panel:SetMouseInputEnabled(false)

    function panel:ConsoleMessage(msg)
        if msg:StartWith("SUPPORT:") then
            EmbeddedChromiumStatus = msg[9] == "1"
            EmbeddedFlashStatus = msg[10] == "1"
            EmbeddedCodecsStatus = msg[11] == "1"
            EmbeddedFinishedRequest = true
            print("Embedded support:", EmbeddedChromiumStatus, EmbeddedFlashStatus, EmbeddedCodecsStatus)

            for _, f in ipairs(EmbeddedChromiumStatus and EmbeddedChromiumSuccessCallbacks or EmbeddedChromiumFailCallbacks) do
                f()
            end

            EmbeddedChromiumSuccessCallbacks = nil
            EmbeddedChromiumFailCallbacks = nil

            for _, f in ipairs(EmbeddedFlashStatus and EmbeddedFlashSuccessCallbacks or EmbeddedFlashFailCallbacks) do
                f()
            end

            EmbeddedFlashSuccessCallbacks = nil
            EmbeddedFlashFailCallbacks = nil

            for _, f in ipairs(EmbeddedCodecsStatus and EmbeddedCodecsSuccessCallbacks or EmbeddedCodecsFailCallbacks) do
                f()
            end

            EmbeddedCodecsSuccessCallbacks = nil
            EmbeddedCodecsFailCallbacks = nil
            self:Remove()
        end
    end

    panel:SetHTML([[
        <html>
            <body>
                <script src="https://cdnjs.cloudflare.com/ajax/libs/swfobject/2.2/swfobject.js" type="text/javascript"></script>
                <script>
                    var support = "SUPPORT:";
                    support += navigator.userAgent.indexOf("Awesomium")==-1?1:0;
                    support += swfobject.hasFlashPlayerVersion("1")?1:0;
                    support += (document.createElement("video").canPlayType('video/mp4; codecs="avc1.42E01E, mp4a.40.2"')=="probably")?1:0;
                </script>
            </body>
        </html>
    ]])

    function panel:OnDocumentReady()
        self:QueueJavascript("console.log(support);")
    end
end

local wasf2down = false

hook.Add("Think", "EmbedInfoToggler", function()
    local isf2down = input.IsKeyDown(KEY_F2)

    if isf2down and not wasf2down then
        ShowMotd("https://swamp.sv/video/plugin-guide.html")
    end

    wasf2down = isf2down
end)
