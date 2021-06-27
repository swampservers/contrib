-- This file is subject to copyright - contact swampservers@gmail.com for more information.
concommand.Add("imgur_refresh", function(ply, cmd, args)
    print('-------- IMGUR REFRESH --------')

    for k, v in pairs(ImgurPanels) do
        v:Remove()
    end

    ImgurPanels = {}

    ImgurTexs = ImgurTexs or {
        ap = {},
        sp = {},
        ab = {},
        sb = {}
    }

    ImgurMats = ImgurMats or {
        ap = {},
        sp = {},
        ab = {},
        sb = {}
    }

    ImgurTexReferenceTime = ImgurTexReferenceTime or {
        ap = {},
        sp = {},
        ab = {},
        sb = {}
    }

    ImgurNameMats = {}
end)

concommand.Add("imgur_names", function(ply, cmd, args)
    ImgurNameShowTime = RealTime()
end)

local function ImgurDebug(...)
    if ImgurDebugOn then
        print(...)
    end
end

concommand.Add("imgur_debug", function(ply, cmd, args)
    ImgurDebugOn = not ImgurDebugOn
    print(ImgurDebugOn)
end)

local loadingImgurMat = Material("tools/toolsblack")
local loadingImgurMatT = Material("models/effects/vol_light001")
local errorImgurMat = Material("models/error/new light1")
local adultWarningImgurID = "raGbMDK.png"
local adultDefiniteWarningImgurID = "IYX0faK.png"
local nonsenseImgurID = "PxOc7TC.png"

ImgurSafeIDs = {
    ["PxOc7TC.png"] = true,
    ["nbn0zwo.jpg"] = true,
    ["2UdwxGb.png"] = true,
}

ImgurTexs = ImgurTexs or {
    ap = {},
    sp = {},
    ab = {},
    sb = {}
}

ImgurMats = ImgurMats or {
    ap = {},
    sp = {},
    ab = {},
    sb = {}
}

ImgurTexReferenceTime = ImgurTexReferenceTime or {
    ap = {},
    sp = {},
    ab = {},
    sb = {}
}

ImgurDimensions = ImgurDimensions or {}
ImgurNameMats = ImgurNameMats or {}
ImgurNameMatsRequested = ImgurNameMatsRequested or {}
ImgurNameMatReferenceTime = ImgurNameMatReferenceTime or {}
local IMGUR_STATE_COOLDOWN = 0
local IMGUR_STATE_LOADING = 1
local IMGUR_STATE_LOADED = 2
ImgurPanels = ImgurPanels or {}

local function GetImgurPanel()
    if not IMGUR_ALLOW_LOAD then return end
    local cd = false

    for k, v in ipairs(ImgurPanels) do
        if v.state == IMGUR_STATE_COOLDOWN then
            cd = true

            if RealTime() > (v.state_time + 0.1) then
                IMGUR_ALLOW_LOAD = false
                ImgurDebug("PANEL DISPATCH")

                return v
            end
        end
    end

    if cd then return end

    if #ImgurPanels < 3 then
        ImgurDebug("PANEL CREATE")
        panel = vgui.Create("DHTML")
        panel:SetSize(2 ^ ImgurMaxP2, 2 ^ ImgurMaxP2)
        panel:SetVisible(false)
        panel:SetMouseInputEnabled(false)
        panel:SetKeyboardInputEnabled(false)
        local the_panel = panel

        panel:AddFunction("lua", "ImageSize", function(msg)
            local stuff = string.Explode("_", msg)

            ImgurDimensions[the_panel.id] = {tonumber(stuff[1]), tonumber(stuff[2])}

            the_panel.state = IMGUR_STATE_LOADED
            the_panel.state_time = RealTime()
            ImgurDebug(the_panel.id, "LOADED", msg)
        end)

        function panel:ConsoleMessage(msg)
            ImgurDebug(msg)
        end

        panel.state = IMGUR_STATE_COOLDOWN
        panel.state_time = RealTime()
        table.insert(ImgurPanels, panel)
    end
end

IMGUR_ALLOW_LOAD = true

timer.Create("imgur_throttle", 0.3, 0, function()
    IMGUR_ALLOW_LOAD = true
end)

ImgurMaxP2 = 10

local function ImgurDimension(actual)
    local P2 = 4

    while P2 < ImgurMaxP2 and 2 ^ P2 < actual do
        P2 = P2 + 1
    end

    return 2 ^ P2
end

hook.Add("PreDrawHUD", "ImgurFinisher", function()
    local i = 1

    while i <= #ImgurPanels do
        local panel = ImgurPanels[i]
        i = i + 1
        if panel.state == IMGUR_STATE_COOLDOWN then continue end
        local tf = panel.tf
        local id = panel.id

        if panel.state == IMGUR_STATE_LOADING and RealTime() > (panel.state_time + 10) then
            ImgurDebug(id, "ERROR")
            ImgurTexs[tf][id] = "ERROR"
            panel:Remove()
            i = i - 1
            table.remove(ImgurPanels, i)
            continue
        end

        panel:UpdateHTMLTexture()
        local mat = panel:GetHTMLMaterial()

        if mat then
            local tex = mat:GetTexture("$basetexture")
            ImgurTexs[tf][id] = tex

            if panel.state == IMGUR_STATE_LOADED and RealTime() > (panel.state_time + 1) then
                ImgurDebug(id, "FINISHING")
                panel.state = IMGUR_STATE_COOLDOWN
                panel.state_time = RealTime()

                local dims = ImgurDimensions[id] or {2 ^ ImgurMaxP2, 2 ^ ImgurMaxP2}

                local w, h
                local fix_aspect = tf[1] == "a"

                if fix_aspect then
                    w = ImgurDimension(math.max(dims[1], dims[2]))
                    h = w
                else
                    w = ImgurDimension(dims[1])
                    h = ImgurDimension(dims[2])
                end

                ImgurDebug(mat:Width(), mat:Height(), "to", w, h)
                local ntex = GetRenderTargetEx(ImgurNextMaterialName(), w, h, RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_NONE, 8192 + (fix_aspect and 12 or 0) + (tf[2] == "p" and 1 or 0), 0, 0) --CREATERENDERTARGETFLAGS_AUTOMIPMAP,
                render.PushRenderTarget(ntex)
                render.OverrideAlphaWriteEnable(true, true)
                cam.Start2D()

                if ScrW() ~= w or ScrH() ~= h then
                    print("Warning: render target size error: ", id, w, h, ScrW(), ScrH())
                    w = ScrW()
                    h = ScrH()
                end

                render.Clear(0, 0, 0, 0)
                surface.SetDrawColor(255, 255, 255, 255)
                surface.SetMaterial(mat)
                surface.DisableClipping(true)
                surface.DrawTexturedRect(0, 0, w, h)
                surface.DisableClipping(false)
                cam.End2D()
                render.OverrideAlphaWriteEnable(false)
                render.PopRenderTarget()
                ImgurTexs[tf][id] = ntex

                for k, v in pairs(ImgurMats[tf][id] or {}) do
                    v:SetTexture("$basetexture", ntex)
                end
            end
        end
    end

    for owner, t in pairs(ImgurNameMatsRequested) do
        local nt = GetRenderTargetEx("rt_owner_" .. owner, 512, 512, 0, 2, 0, 0, 0)
        local oldw, oldh, oldrt = ScrW(), ScrH(), render.GetRenderTarget()
        render.SetRenderTarget(nt)
        render.SetViewPort(0, 0, 512, 512)
        cam.Start2D()
        surface.SetDrawColor(0, 0, 0)
        surface.DrawRect(0, 0, 512, 512)
        local ply = player.GetBySteamID(owner)
        local txt = (IsValid(ply) and ply:Nick() or "Unknown") .. " (" .. owner .. ") "
        local txt2 = txt
        surface.SetFont("Trebuchet24")
        surface.SetTextColor(255, 255, 255, 255)
        local w, h = surface.GetTextSize(txt2)
        local w2 = w / 2

        while w < 512 + w2 do
            txt2 = txt2 .. txt
            w, h = surface.GetTextSize(txt2)
        end

        local ofs = false

        for y = 0, 512, h do
            surface.SetTextPos(ofs and -w2 or 0, y)
            ofs = not ofs
            surface.DrawText(txt2)
        end

        cam.End2D()
        render.SetRenderTarget(oldrt)
        render.SetViewPort(0, 0, oldw, oldh)

        local realmat = CreateMaterial(ImgurNextMaterialName(), "UnlitGeneric", {
            ["$basetexture"] = "tools/toolsblack"
        })

        realmat:SetTexture("$basetexture", nt)
        ImgurNameMats[owner] = realmat
    end

    ImgurNameMatsRequested = {}
end)

timer.Create("imgur_cleanup", 1, 0, function()
    for tf, idlist in pairs(ImgurTexReferenceTime) do
        for id, t in pairs(idlist) do
            if t < RealTime() - 600 then
                ImgurTexReferenceTime[tf][id] = nil
                ImgurTexs[tf][id] = nil
                ImgurMats[tf][id] = nil
            end
        end
    end

    for owner, t in pairs(ImgurNameMatReferenceTime) do
        if t < RealTime() - 30 then
            ImgurNameMatReferenceTime[owner] = nil
            ImgurNameMats[owner] = nil
        end
    end

    local i = 1

    while i <= #ImgurPanels do
        if ImgurPanels[i].state == IMGUR_STATE_COOLDOWN and RealTime() > (ImgurPanels[i].state_time + 2.0) then
            ImgurDebug("PANEL REMOVE")
            ImgurPanels[i]:Remove()
            table.remove(ImgurPanels, i)
            break --so we only remove 1 per second
        else
            i = i + 1
        end
    end
end)

IMGUR_IN_SKYBOX = false

hook.Add("PreDrawSkyBox", "IMGURPRESB", function()
    IMGUR_IN_SKYBOX = true
end)

hook.Add("PostDrawSkyBox", "IMGURPOSTSB", function()
    IMGUR_IN_SKYBOX = false
end)

-- IMGUR_T_PARAM = IMGUR_T_PARAM or {}
-- function ImgurMaterial(id, owner, pos, fix_aspect, shader, params, pointsample)
--     IMGUR_T_PARAM[id]=IMGUR_T_PARAM[id] or ("?t=" .. tostring(RealTime()))
--     return WebMaterial({
--         url="http://i.imgur.com/" .. id .. IMGUR_T_PARAM[id],
--         owner=owner,
--         pos=pos,
--         shader=shader,
--         params=params,
--         contain=fix_aspect,
--         pointsample=pointsample,
--         translucent=true,
--     })
-- end
function ImgurMaterial(args)
    RP_PUSH("imgur")
    local r = ImgurMaterial1(args)
    RP_POP()

    return r
end

function ImgurMaterial1(args)
    local id, owner, pos, fix_aspect, shader, params, pointsample, worksafe = args.id, args.owner, args.pos, (not args.stretch), (args.shader or "VertexLitGeneric"), (args.params or "{}"), (args.pointsample or false), args.worksafe
    assert(isstring(params))
    IMGUR_ERROR = false
    local should_load_this = true

    if isvector(pos) and pos:DistToSqr(EyePos()) > 1000000 then
        should_load_this = false
        --return errorImgurMat
    end

    if IMGUR_IN_SKYBOX then
        id = nonsenseImgurID
    end

    id = SanitizeImgurId(id)

    if not id then
        IMGUR_ERROR = true

        return errorImgurMat
    end

    if not isstring(owner) then
        if IsValid(owner) and isentity(owner) and owner:IsPlayer() then
            owner = owner:SteamID()
        else
            owner = "UNKNOWN"
        end
    end

    if (ImgurNameShowTime or 0) > RealTime() - 15 then
        ImgurNameMatReferenceTime[owner] = RealTime()

        if ImgurNameMats[owner] then
            return ImgurNameMats[owner]
        else
            ImgurNameMatsRequested[owner] = true
        end
    end

    if (not worksafe) and (not GetConVar("swamp_mature_content"):GetBool()) and (not ImgurSafeIDs[id]) then
        id = ((worksafe == false) and adultDefiniteWarningImgurID or adultWarningImgurID)
        fix_aspect = false
        pointsample = false
    end

    --texture flags
    local tf = (fix_aspect and "a" or "s") .. (pointsample and "p" or "b")
    local matkey = shader .. params
    ImgurTexReferenceTime[tf][id] = RealTime()
    local savedTex = ImgurTexs[tf][id]

    if savedTex then
        if savedTex == "ERROR" then
            IMGUR_ERROR = true

            return errorImgurMat
        end

        ImgurMats[tf][id] = ImgurMats[tf][id] or {}
        local mat = ImgurMats[tf][id][matkey]
        if mat then return mat end
        -- print("PARSE"..id)
        RunString("OUT=" .. params) --todo cache the parse result if you want to use it again (str->parsed table)
        local params_tab = OUT
        params_tab["$basetexture"] = "models/effects/vol_light001"
        mat = CreateMaterial(ImgurNextMaterialName(), shader, params_tab)
        mat:SetTexture("$basetexture", savedTex)
        ImgurMats[tf][id][matkey] = mat

        return mat
    end

    for _, v in ipairs(ImgurPanels) do
        if v.state == IMGUR_STATE_LOADING or v.state == IMGUR_STATE_LOADED and v.id == id and v.tf == tf then
            should_load_this = false
        end
    end

    local panel = should_load_this and GetImgurPanel()

    if panel then
        ImgurDebug(id, "STARTING")
        panel.state = IMGUR_STATE_LOADING
        panel.state_time = RealTime()
        panel.id = id
        panel.tf = tf
        local url = "http://i.imgur.com/" .. id .. "?t=" .. tostring(RealTime())
        local styles

        if fix_aspect then
            styles = [[background-size: contain;
		  background-repeat: no-repeat;
		  background-attachment: fixed;
		  background-position: center;]]
        else
            styles = [[background-size: 100% 100%;]]
        end

        panel:SetHTML([[
            <html>
                <head>
                    <style type="text/css">
                    body {
                        margin: 0px;
                        padding: 0px;
                        overflow: hidden;
                        background-image: url("]] .. url .. [[");
                        ]] .. styles .. [[
                    }
                    </style>
                </head>
                <body>
                    <img id="i" onload="loaded()" src="]] .. url .. [[" style="position:absolute;top:]] .. tostring((2 ^ ImgurMaxP2) + 2) .. [[px;">
                    <script type="text/javascript">
                    function loaded() {
                        var image = document.getElementById('i');
                        lua.ImageSize(image.width+'_'+image.height);
                    }
                    </script>
                </body>
            </html>
            ]])
    end

    --kinda hacky
    if params:find('["$translucent"]=1', 1, true) or params:find('["$alphatest"]=1', 1, true) then return loadingImgurMatT end --$vertexalpha?

    return loadingImgurMat
end

NextImgurMatIndex = NextImgurMatIndex or math.random(1, 1000000000)

function ImgurNextMaterialName()
    NextImgurMatIndex = NextImgurMatIndex + 1

    return "mat_imgur_" .. tostring(NextImgurMatIndex)
end

timer.Create("ImgurRefresh", 1000, 0, function()
    while ImgurNextMaterialName() and (not I2) do
        NextImgurMatIndex = math.random(1, 1000000000)
    end
end)
timer.Destroy("ImgurRefresh")