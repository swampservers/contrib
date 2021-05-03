-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
module("theater", package.seeall)
local gradientDown = surface.GetTextureID("VGUI/gradient_down")
local refreshTexture = surface.GetTextureID("gui/html/refresh")
local NoVideoScreen = Material("theater/static.vmt")
local THLIGHT_CANVAS_XS = 16
local THLIGHT_CANVAS_YS = 16
local LocationChangeTime = 0
local LoadingStartTime = 0
local LastTitle = ""
local Title = ""
local WasFullscreen = false
LastInfoDraw = LastInfoDraw or 0
InfoDrawDelay = 3
LastHtmlMaterial = nil
TheaterCustomRT = GetRenderTarget("ThLights2", THLIGHT_CANVAS_XS, THLIGHT_CANVAS_YS, true)
LastLocation = LastLocation or -1

function DrawVideoInfo(w, h)
    local Video = CurrentVideo
    if not Video then return end
    local explicitblock = false

    if not GetConVar("swamp_mature_content"):GetBool() then
        explicitblock = Video:IsMature() and not (LocalPlayer():GetTheater():Name() == "Movie Theater" and IsValid(Video:GetOwner()) and Video:GetOwner():IsStaff())
    end

    if input.IsKeyDown(KEY_Q) then
        LastInfoDraw = CurTime()
    end

    if not (explicitblock or LastInfoDraw + InfoDrawDelay > CurTime()) then return end

    if explicitblock then
        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawRect(0, 0, w, h)
    end

    surface.SetDrawColor(0, 0, 0, 255)
    surface.SetTexture(gradientDown)
    surface.DrawTexturedRect(0, -1, w + 1, h + 1)

    -- Title
    if LastTitle ~= Video:Title() or WasFullscreen ~= Fullscreen then
        LastTitle = Video:Title()
        WasFullscreen = Fullscreen
        Title = string.reduce(LastTitle, "VideoInfoMedium", w)
    end

    DrawTheaterText(Title, "VideoInfoMedium", 10, 10, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    DrawTheaterText("VOLUME", "VideoInfoSmall", w - 72, 120, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    DrawTheaterText(GetVolume() .. "%", "VideoInfoMedium", w - 72, 136, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

    -- Vote Skips
    if NumVoteSkips > 0 then
        DrawTheaterText("VOTESKIPS", "VideoInfoSmall", w - 72, 230, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        DrawTheaterText(NumVoteSkips .. "/" .. ReqVoteSkips, "VideoInfoMedium", w - 72, 246, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    if Safe(LocalPlayer()) then
        DrawTheaterText("PROTECTED", "VideoInfoSmall", w - 72, 90, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    -- Timed video info
    if Video:IsTimed() then
        local current = (CurTime() - Video:StartTime())
        local percent = math.Clamp((current / Video:Duration()) * 100, 0, 100)
        -- Bar
        local bh = h * 1 / 32
        draw.RoundedBox(0, 0, h - bh, w, bh + 1, Color(0, 0, 0, 200))
        draw.RoundedBox(0, 0, h - bh, w * (percent / 100), bh + 1, Color(255, 255, 255, 255))
        local strSeconds = string.FormatSeconds(math.Clamp(math.Round(current), 0, Video:Duration()))
        DrawTheaterText(strSeconds, "VideoInfoMedium", 16, h - bh, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
        local strDuration = string.FormatSeconds(Video:Duration())
        DrawTheaterText(strDuration, "VideoInfoMedium", w - 16, h - bh, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
    end

    -- Loading indicater
    if IsValid(ActivePanel) and ActivePanel:IsLoading() then
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetTexture(refreshTexture)
        surface.DrawTexturedRectRotated(32, 128, 64, 64, RealTime() * -256)
    end

    if explicitblock then
        surface.SetDrawColor(0, 0, 0, 220)
        surface.DrawRect(0, 0, w, h)
        DrawTheaterText("This video may contain explicit content.", "VideoInfoMedium", w / 2, h * 0.44, Color(255, 50, 50, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        DrawTheaterText("Press F6 if you're okay with seeing adult material.", "VideoInfoALittleSmaller", w / 2, h * 0.56, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

hook.Add("PostDrawOpaqueRenderables", "DrawTheaterScreen", function(bDrawingDepth, bDrawingSkybox)
    if bDrawingDepth or bDrawingSkybox then return end --oof

    if LastLocation ~= LocalPlayer():GetLocation() then
        LocationChangeTime = RealTime()
        LastLocation = LocalPlayer():GetLocation()
    end

    if (not IsValid(ActivePanel)) or (not ActivePanel:IsLoading()) then
        LoadingStartTime = RealTime()
    end

    --Don't draw a panel that is loading unless it has been loading for a long time
    if IsValid(ActivePanel) then
        ActivePanel:UpdateHTMLTexture()
    end

    local drawpanel = IsValid(ActivePanel) and ((not ActivePanel:IsLoading()) or (RealTime() - LoadingStartTime) > 1.0)
    LastHtmlMaterial = drawpanel and ActivePanel:GetHTMLMaterial() or nil
    -- gets at least to here once each frame
    local Theater = LocalPlayer():GetTheater()
    if not Theater or Fullscreen then return end
    local ang = Angle(Theater:GetAngles()) -- makes copy
    ang:RotateAroundAxis(ang:Forward(), 90)
    local pos = Theater:GetPos()
    local w, h = Theater:GetSize()
    render.OverrideDepthEnable(true, false) -- needed?
    local iw = 1100 -- Is <=1024 faster than 1100? dont think so
    local infoscale = iw / w
    local ih = infoscale * h

    cam.Culled3D2D(pos, ang, 1 / infoscale, function()
        local blackness = 1.0 - math.Clamp((RealTime() - (LocationChangeTime + 0.3)) * 0.8, 0, 1)

        if LastHtmlMaterial ~= nil then
            -- ActivePanel:UpdateHTMLTexture()
            -- local matt = ActivePanel:GetHTMLMaterial()
            surface.SetMaterial(LastHtmlMaterial)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawTexturedRectUV(0, 0, iw, ih, 0, 0, ActivePanel:GetUVMax())
        else
            local untrusted = CurrentVideo and (not CurrentVideo:ShouldTrust())

            if IsValid(ActivePanel) or untrusted then
                surface.SetDrawColor(0, 0, 0, 255)
                surface.DrawRect(0, 0, iw, ih)

                if untrusted then
                    DrawTheaterText("This video is hosted at: ", "VideoInfoMedium", iw / 2, ih * 0.34, Color(255, 50, 50, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    DrawTheaterText(CurrentVideo:Key(), "VideoInfoMedium", iw / 2, ih * 0.46, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    DrawTheaterText("Press F8 to load it.", "VideoInfoALittleSmaller", iw / 2, ih * 0.58, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    DrawTheaterText("This may reveal your IP address to the host;", "VideoInfoALittleSmaller", iw / 2, ih * 0.67, Color(255, 50, 50, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    DrawTheaterText("you can use a VPN to hide it.", "VideoInfoALittleSmaller", iw / 2, ih * 0.76, Color(255, 50, 50, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            else
                surface.SetMaterial(NoVideoScreen)
                surface.SetDrawColor(255, 255, 255, 255)
                surface.DrawTexturedRect(0, 0, iw, ih)
                DrawTheaterText("SWAMP CINEMA", "VideoInfoBrand", iw / 2, (ih / 2) - 44, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                DrawTheaterText("To request a video, hold Q", "VideoInfoNV1", iw / 2, (ih / 2) + 30, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                DrawTheaterText("Need help? Say /help", "VideoInfoNV2", iw / 2, (ih / 2) + 96, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end

        DrawVideoInfo(iw, ih)

        if blackness > 0 then
            surface.SetDrawColor(0, 0, 0, blackness * 255.0)
            surface.DrawRect(0, -1, iw + 1, ih + 2)
        end
    end)

    render.OverrideDepthEnable(false, true)
end)

hook.Add("HUDPaint", "DrawFullscreenInfo", function()
    if not IsValid(ActivePanel) then return end

    if Fullscreen then
        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawRect(0, 0, ScrW(), ScrH())

        if LastHtmlMaterial ~= nil then
            surface.SetMaterial(LastHtmlMaterial)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawTexturedRectUV(0, 0, ScrW(), ScrH(), 0, 0, ActivePanel:GetUVMax())
        end

        DrawVideoInfo(ScrW(), ScrH())
    else
        local Theater = LocalPlayer().GetTheater and LocalPlayer():GetTheater() or nil
        if not Theater or Theater:Name() == "Vapor Lounge" then return end
        if LastHtmlMaterial == nil then return end
        if GetConVar("cinema_lightfx"):GetInt() < 1 then return end
        -- Dynamic lighting from screen colors (Swamp Cinema)
        local ang = Angle(Theater:GetAngles()) -- makes copy
        ang:RotateAroundAxis(ang:Forward(), 90)
        local pos = Theater:GetPos() + ang:Right() * 0.01
        local w, h = Theater:GetSize()
        local OldRT = render.GetRenderTarget()
        local ow, oh = ScrW(), ScrH()
        render.SetRenderTarget(TheaterCustomRT)
        render.SetViewPort(0, 0, THLIGHT_CANVAS_XS, THLIGHT_CANVAS_YS)
        cam.Start2D()
        surface.SetMaterial(LastHtmlMaterial)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRectUV(0, 0, THLIGHT_CANVAS_XS, THLIGHT_CANVAS_YS, 0, 0, ActivePanel:GetUVMax())
        render.CapturePixels()
        local sumr, sumg, sumb = 0, 0, 0

        for x = 0, THLIGHT_CANVAS_XS - 1 do
            for y = 0, THLIGHT_CANVAS_YS - 1 do
                local r, g, b = render.ReadPixel(x, y)
                sumr, sumg, sumb = sumr + r, sumg + g, sumb + b
            end
        end

        cam.End2D()
        render.SetViewPort(0, 0, ow, oh)
        render.SetRenderTarget(OldRT)
        local avgc = THLIGHT_CANVAS_XS * THLIGHT_CANVAS_YS
        local dlight = DynamicLight(1439)

        if dlight then
            dlight.pos = pos + (ang:Forward() * (w / 2)) + (ang:Right() * (h / 2)) + (ang:Up() * ((w + h) / 4))
            dlight.r = sumr / avgc
            dlight.g = sumg / avgc
            dlight.b = sumb / avgc
            dlight.brightness = 2
            dlight.Decay = 100
            dlight.Size = (w + h) * 2.5
            dlight.DieTime = CurTime() + 1
        end
    end
end)

hook.Add("HUDPaint", "DrawNoFlashWarning", function()
    local Theater = LocalPlayer().GetTheater and LocalPlayer():GetTheater()

    if Theater and Theater._Video then
        if (not EmbeddedIsReady()) then return end
        local needschromium = Theater._Video:Service().NeedsChromium and (not EmbeddedHasChromium())
        local needsflash = Theater._Video:Service().NeedsFlash and (not EmbeddedHasFlash())
        local needscodecs = ((Theater._Video:Duration() == 0 and Theater._Video:Service().LivestreamNeedsCodecs) or Theater._Video:Service().NeedsCodecs) and (not EmbeddedHasCodecs())

        if needschromium or needsflash or needscodecs then
            local plural = (needschromium and 1 or 0) + (needsflash and 1 or 0) + (needscodecs and 1 or 0) > 1 and "them" or "it"
            draw.WordBox(10, ScrW() / 2 - 80, ScrH() / 2 - 50, "You don't have" .. (needschromium and " Chromium," or "") .. (needsflash and " the Adobe Flash plugin," or "") .. (needscodecs and " the video codec patch," or ""), "CloseCaption_Bold", Color(0, 0, 0, 255), Color(255, 255, 255, 255))
            draw.WordBox(10, ScrW() / 2 - 80, ScrH() / 2, "Without " .. plural .. ", you can't watch this video", "CloseCaption_Bold", Color(0, 0, 0, 255), Color(255, 255, 255, 255))
            draw.WordBox(10, ScrW() / 2 - 80, ScrH() / 2 + 50, "Press F2 to install " .. plural .. "! Then fully reboot Garry's Mod.", "CloseCaption_Bold", Color(0, 0, 0, 255), Color(255, 255, 255, 255))

            if needschromium and (not needsflash) and Theater._Video:Service().NeedsFlash then
                draw.WordBox(10, ScrW() / 2 - 80, ScrH() / 2 + 100, "This video also requires flash", "CloseCaption_Bold", Color(0, 0, 0, 255), Color(255, 255, 255, 255))
            end
        end
    end
end)

function DrawTheaterText(text, font, x, y, c, xalign, yalign)
    -- if OLDTEXT then 
    --     draw.SimpleText(text, font, x, y + 4, Color(0, 0, 0, colour.a), xalign, yalign)
    --     draw.SimpleText(text, font, x + 1, y + 2, Color(0, 0, 0, colour.a), xalign, yalign)
    --     draw.SimpleText(text, font, x - 1, y + 2, Color(0, 0, 0, colour.a), xalign, yalign)
    --     draw.SimpleText(text, font, x, y, colour, xalign, yalign)
    --     return
    -- end
    -- draw.SimpleTextOutlined(text, font, x, y+2, bc, xalign, yalign,0.5,bc)
    -- draw.SimpleText(text, font, x, y+3, bc, xalign, yalign)
    -- draw.SimpleTextOutlined(text, font, x, y, c, xalign, yalign,0.5,bc)
    local bc = Color(0, 0, 0, 255 * math.pow(c.a / 255, 0.5))
    draw.SimpleText(text, font, x + 1, y + 3, bc, xalign, yalign)
    draw.SimpleText(text, font, x, y, c, xalign, yalign)
end

_G.DrawTheaterText = DrawTheaterText

-- local function CreateTheaterFont(name, data)
--     surface.CreateFont(name, data)
--     -- data.antialias=false
--     -- data.outline=true
--     -- surface.CreateFont(name.."O", data)
--     -- data.antialias=true
--     -- data.outline=false
--     -- data.shadow=true
--     -- surface.CreateFont(name.."S", data)
-- end
surface.CreateFont("VideoInfoMedium", {
    font = "Open Sans Condensed",
    size = 72,
    weight = 700,
    antialias = true
})

surface.CreateFont("VideoInfoALittleSmaller", {
    font = "Open Sans Condensed",
    size = 60,
    weight = 700,
    antialias = true
})

surface.CreateFont("VideoInfoSmall", {
    font = "Open Sans Condensed",
    size = 32,
    weight = 700,
    antialias = true
})

surface.CreateFont("VideoInfoBrand", {
    font = "Righteous",
    size = 72,
    antialias = true
})

surface.CreateFont("VideoInfoNV1", {
    font = "Open Sans Condensed",
    size = 56,
    weight = 700,
    antialias = true
})

surface.CreateFont("VideoInfoNV2", {
    font = "Open Sans Condensed",
    size = 40,
    weight = 700,
    antialias = true
})

surface.CreateFont("3D2DName", {
    font = "Bebas Neue",
    size = 80,
    weight = 600
})

surface.CreateFont("TheaterDermaLarge", {
    font = "Roboto",
    size = 32,
    weight = 500,
    extended = true
})