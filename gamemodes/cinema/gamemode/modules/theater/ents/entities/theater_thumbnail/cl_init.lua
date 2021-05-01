-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
include('sh_init.lua')
ENT.RenderGroup = RENDERGROUP_OPAQUE
local ThumbWidth = 512 -- Expected to be PO2
local ThumbHeight = 384 -- Expected <= width
local RenderScale = 0.2 * (480 / 512)
local DefaultThumbnail = Material("theater/static.vmt")

function ENT:Draw()
    self:DrawModel()

    if not self.Attach then
        local attachId = self:LookupAttachment("thumb3d2d")
        self.Attach = self:GetAttachment(attachId)

        if self.Attach then
            self.Attach.Ang = self.Attach.Ang + Angle(0, 90, 90)
        else
            return
        end
    end

    if cam.StartCulled3D2D(self.Attach.Pos, self.Attach.Ang, RenderScale) then
        self:DrawThumbnail()
        cam.End3D2D()
    end
end

function ENT:DrawThumbnail()
    local theatername_esc = string.JavascriptSafe(self:GetTheaterName())

    if self:GetNWBool("Rentable") then
        location = self:GetNWInt("Location")
        local tb = protectedTheaterTable[location]

        if tb ~= nil and tb["time"] > 1 then
            theatername_esc = theatername_esc .. "<br>Protected"
        end
    end

    local videotitle = self:GetTitle()
    local thumbnail = self:GetThumbnail()

    if thumbnail == "" then
        thumbnail = "http://swampservers.net/video/logos/movie.png"
    end

    local background = [[background:black url(]] .. string.JavascriptSafe(thumbnail) .. [[) no-repeat fixed center;]]

    if self:GetService() == "" then
        surface.SetDrawColor(80, 80, 80)
        surface.SetMaterial(DefaultThumbnail)
        surface.DrawTexturedRect(0, 0, ThumbWidth - 1, ThumbHeight - 1)
        background = ""
    end

    local setting = theatername_esc .. ":" .. videotitle .. ":" .. background

    if self.ThumbMat then
        local t = self.ThumbMat:GetTexture("$basetexture")

        if self.ThumbMat:IsError() or t:IsError() or t:IsErrorTexture() then
            self.ThumbMat = nil
        end
    end

    if self.LastSetting ~= setting then
        if ValidPanel(self.HTML) then
            self.HTML:Remove()
        end

        -- 
        self.LastSetting = setting
        self.ThumbMat = nil
    elseif self.LastSetting and not self.ThumbMat then
        if not ValidPanel(self.HTML) then
            self.HTML = vgui.Create("Awesomium")
            self.HTML:SetSize(ThumbWidth, ThumbHeight)
            self.HTML:SetPaintedManually(true)
            self.HTML:SetKeyBoardInputEnabled(false)
            self.HTML:SetMouseInputEnabled(false)
            self.HTML:SetHTML([[
                <html>
                <head>
                <link rel="preconnect" href="https://fonts.gstatic.com">
                <link href="https://fonts.googleapis.com/css2?family=Open+Sans+Condensed:wght@700&family=Righteous&display=swap" rel="stylesheet">
                <style>
                body {
                    margin:0;
                    ]] .. background .. [[
                    background-size:contain;
                }
                div {
                    color:white; 
                    text-align: center;
                    background-color: rgba(0,0,0,0.5);
                }
                #div1 {
                    font-family: 'Righteous', sans-serif;
                    text-transform: uppercase;
                    font-size: 10vw;
                }
                #div2 {
                    font-family: 'Open Sans Condensed', sans-serif; /*'Times New Roman', serif;*/
                    position:absolute;
                    bottom:0;left:0;right:0;
                    font-size:5vw;
                }
                </style>
                </head>
                <body>
                    <div id="div1">]] .. theatername_esc .. [[</div>
                    <div id="div2">]] .. string.JavascriptSafe(videotitle) .. [[</div>
                    <script>
                    var div = document.getElementById("div2");
                    div.style.fontSize = Math.min(10,((div.innerText.length > 50 ? 400 : 200)/div.innerText.length))+"vw";
                    </script>
                </body>
                </html>
            ]])

            return
        elseif not self.HTML:IsLoading() and not self.JSDelay then
            self.JSDelay = true

            -- Add delay to wait for JS to run
            timer.Simple(0.01, function()
                if not IsValid(self) then return end
                if not ValidPanel(self.HTML) then return end
                self.HTML:UpdateHTMLTexture()
                self.ThumbMat = self.HTML:GetHTMLMaterial()
                self.HTML:Remove()
                self.JSDelay = nil
            end)
        else
            -- Waiting for download to finish
            return
        end
    end

    -- Draw the HTML material
    if self.ThumbMat then
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(self.ThumbMat)
        surface.DrawTexturedRectUV(0, 0, ThumbWidth, ThumbHeight, 0, 0, 1, ThumbHeight / ThumbWidth)
    end
end