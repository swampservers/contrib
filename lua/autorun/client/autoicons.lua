-- autoicons.lua: Automatically generates/renders weapon select icons and killicons
-- for SWEPs not containing them. Made by swamponions (STEAM_0:0:38422842)
local ReplaceAllConvar = CreateClientConVar("autoicons_replaceall", "1", true, false)
local namejunk = "autoicon" .. tostring(os.time()) .. "_"

local function UniqueName()
    AUTOICON_UNIQUEIDX = (AUTOICON_UNIQUEIDX or 0) + 1

    return namejunk .. tostring(AUTOICON_UNIQUEIDX)
end

local function MakeRT(nf, xs, ys, depth, alpha)
    return GetRenderTargetEx(nf(), xs, ys, depth and RT_SIZE_DEFAULT or RT_SIZE_NO_CHANGE, depth and MATERIAL_RT_DEPTH_SEPARATE or MATERIAL_RT_DEPTH_NONE, 12 + 2, 0, alpha and IMAGE_FORMAT_RGBA8888 or IMAGE_FORMAT_RGB888)
end

AUTOICON_MODELCOLORMATERIAL = CreateMaterial(UniqueName(), "VertexLitGeneric", {
    ["$basetexture"] = "lights/white",
})

AUTOICON_TEXTUREMATERIAL = CreateMaterial(UniqueName(), "UnlitGeneric", {
    ["$basetexture"] = "lights/white",
    ["$vertexcolor"] = "1",
})

AUTOICON_DESATURATEMATERIAL = CreateMaterial(UniqueName(), "g_colourmodify", {
    ["$fbtexture"] = "lights/white",
    ["$pp_colour_addr"] = 0,
    ["$pp_colour_addg"] = 0,
    ["$pp_colour_addb"] = 0,
    ["$pp_colour_brightness"] = -0.22,
    ["$pp_colour_contrast"] = 3,
    ["$pp_colour_colour"] = 0,
    ["$pp_colour_mulr"] = 0,
    ["$pp_colour_mulg"] = 0,
    ["$pp_colour_mulb"] = 0,
})

AUTOICON_HL2WEAPONSELECT = 1
AUTOICON_HL2KILLICON = 2

AUTOICONS = {{}, {}}

-- The game likes to black out our textures sometimes (eg. when changing screen res). Make a little 1x1 square that is white when the textures still exist, so if the game blacks it out we'll know, without having to capture an entire large texture.
-- Still takes about 0.5ms to check it though.
AUTOICON_INDICATOR_TEXTURE = GetRenderTargetEx(UniqueName(), 1, 1, 0, 2, 1, 0, IMAGE_FORMAT_RGB888)

AUTOICON_INDICATOR_MATERIAL = CreateMaterial(UniqueName(), "VertexLitGeneric", {
    ["$basetexture"] = "metal6",
})

local ValidCheckTime = 0

local function CheckTexturesValid()
    if SysTime() - ValidCheckTime < 5 then return end
    ValidCheckTime = SysTime()
    render.PushRenderTarget(AUTOICON_INDICATOR_TEXTURE)
    render.CapturePixels()
    local r, g, b = render.ReadPixel(0, 0)
    render.PopRenderTarget()
    local curtex = AUTOICON_INDICATOR_MATERIAL:GetTexture("$basetexture")

    if r == 0 or not curtex or curtex:GetName() == "metal6" then
        render.PushRenderTarget(AUTOICON_INDICATOR_TEXTURE)
        render.Clear(255, 255, 255, 255)
        render.PopRenderTarget()
        AUTOICON_INDICATOR_MATERIAL:SetTexture("$basetexture", AUTOICON_INDICATOR_TEXTURE)

        -- Clear the cache
        AUTOICONS = {{}, {}}
    end
end

local function GetBitmap()
    render.CapturePixels()
    local xs, ys = ScrW(), ScrH()
    local bitmask = {}
    local bitcount = 0

    for x = 0, xs - 1 do
        bitmask[x] = {}

        for y = 0, ys - 1 do
            local r, g, b, a = render.ReadPixel(x, y)

            --math.max(r, g, b) > 0 then
            if r > 0 then
                bitcount = bitcount + 1
                bitmask[x][y] = true
            end
        end
    end

    return bitmask, bitcount
end

-- Find the bounds of nonzero pixels
local function GetBBox(bitmask)
    local xs, ys = ScrW(), ScrH()
    local px1, py1, px2, py2 = 0, 0, 1, 1

    for x = 0, xs - 1 do
        for y = 0, ys - 1 do
            if bitmask[x][y] then
                px1 = x / xs
                goto g1
            end
        end
    end

    ::g1::

    for y = 0, ys - 1 do
        for x = 0, xs - 1 do
            if bitmask[x][y] then
                py1 = y / ys
                goto g2
            end
        end
    end

    ::g2::

    for x = xs - 1, 0, -1 do
        for y = 0, ys - 1 do
            if bitmask[x][y] then
                px2 = (x + 1) / xs
                goto g3
            end
        end
    end

    ::g3::

    for y = ys - 1, 0, -1 do
        for x = 0, xs - 1 do
            if bitmask[x][y] then
                py2 = (y + 1) / ys
                goto g4
            end
        end
    end

    ::g4::

    return px1, py1, px2, py2
end

local function EstimateAngle(bitmask, x1, x2)
    local px1, py1, px2, py2 = GetBBox(bitmask)
    -- Taller than long, probably a knife
    if py2 - py1 > px2 - px1 then return 0 end
    local xs, ys = ScrW(), ScrH()
    local linesused = {}
    local slopeweight = {}

    for x = 0, xs - 1 do
        linesused[x] = {}
    end

    for x = math.floor(xs * Lerp(x1, px1, px2)), math.ceil(xs * Lerp(x2, px1, px2)) do
        for y = math.floor(ys * py1), math.ceil(ys * py2) do
            if bitmask[x][y] and not linesused[x][y] then
                local passed = 0
                local sx = x

                while (bitmask[sx] or {})[y] do
                    linesused[sx][y] = true
                    passed = passed + 1
                    sx = sx + 1
                end

                local slope = 0

                if (bitmask[sx] or {})[y + 1] then
                    slope = passed
                elseif (bitmask[sx] or {})[y - 1] then
                    slope = -passed
                end

                if math.abs(slope) > 40 then
                    slope = 0
                end

                if slope == 0 and passed < 3 then
                    passed = 0
                end

                slopeweight[slope] = (slopeweight[slope] or 0) + passed
            end
        end
    end

    local highestsl = 0
    local highestslw = slopeweight[0] or 1
    local highestsla = 0

    for k, v in pairs(slopeweight) do
        if math.abs(k) > 2 then
            local uw = slopeweight[k - 1] or 0
            local dw = slopeweight[k + 1] or 0
            local slw = v + math.max(uw, dw)

            if slw > highestslw then
                highestsl = k
                highestslw = slw
                local isl

                if uw > dw then
                    isl = (v * k + uw * (k - 1)) / (v + uw)
                else
                    isl = (v * k + dw * (k + 1)) / (v + dw)
                end

                highestsla = math.deg(math.atan(1 / isl))
            end
        end
    end

    return highestsla
end

AUTOICONS_ANGLE_OVERRIDE = {
    ["models/weapons/w_toolgun.mdl"] = Angle(0, 0, 0),
    ["models/maxofs2d/logo_gmod_b.mdl"] = Angle(0, 90, 0),
    ["models/error.mdl"] = Angle(0, 90, 0),
}

function GetAutoIcon(mdl, mode)
    if not util.IsValidModel(mdl) then
        mdl = "models/error.mdl"
    end

    CheckTexturesValid()
    if AUTOICONS[mode][mdl] then return AUTOICONS[mode][mdl] end

    -- if IsValid(AUTOICON_ENT) then AUTOICON_ENT:Remove() AUTOICON_ENT=nil end
    if not IsValid(AUTOICON_ENT) then
        AUTOICON_ENT = ClientsideModel(mdl)
        if not IsValid(AUTOICON_ENT) then return AUTOICON_TEXTUREMATERIAL end
        AUTOICON_ENT:SetNoDraw(true)
    end

    if AUTOICON_ENT:GetModel() ~= mdl then
        AUTOICON_ENT:SetModel(mdl)
    end

    local min, max = AUTOICON_ENT:GetRenderBounds()
    local center, rad = (min + max) / 2, min:Distance(max) / 2
    local ang

    if AUTOICONS_ANGLE_OVERRIDE[mdl] then
        ang = Angle(AUTOICONS_ANGLE_OVERRIDE[mdl])
    else
        local muzzleatt = AUTOICON_ENT:LookupAttachment("muzzle")

        if muzzleatt > 0 then
            AUTOICON_ENT:SetAngles(Angle(0, 0, 0))
            AUTOICON_ENT:SetupBones()
            local v = AUTOICON_ENT:GetAttachment(muzzleatt).Ang:Forward()
            -- Despite various attachments and bones existing, this is the best I could do.
            -- Pretty pathetic huh? Half the SWEPs on workshop have totally wrong attachment/bone angles and anything more than this completely messes them up.
            -- There is a second pass below where it tries to fix the angle by looking at the drawn mask itself
            ang = Angle(0, -math.deg(math.atan2(v.y, v.x)), 0)
        else
            -- One of these is usually correct
            ang = Angle(0, ((max.x - min.x >= max.y - min.y) and 0 or 90), 0)
            ang:RotateAroundAxis(Vector(1, 0, 0), -11)
        end
    end

    -- Flip weaponselect icons the other way
    if mode == AUTOICON_HL2WEAPONSELECT then
        ang:RotateAroundAxis(Vector(0, 0, 1), 180)
    end

    AUTOICON_ENT:SetAngles(ang)
    AUTOICON_ENT:SetupBones()
    local zpd = math.min(max.x - min.x, max.y - min.y)
    local viewdist = (5 * rad + 1)
    local znear = viewdist - zpd / 2
    local zfar = znear + zpd
    local hw, hh, cx, cy = 0.5, 0.5, 0.5, 0.5
    local rtx, rty = 512, 512

    if mode == AUTOICON_HL2KILLICON then
        rtx, rty = 256, 256
    end

    local crtx, crty = 512, 512

    local function StartOrthoCam()
        local function unclampedlerp(t, x, y)
            return (1 - t) * x + t * y
        end

        cam.Start({
            x = 0,
            y = 0,
            w = ScrW(),
            h = ScrH(),
            origin = AUTOICON_ENT:LocalToWorld(center) + Vector(0, -viewdist, 0),
            angles = Vector(0, 90, 0),
            aspect = 1,
            fov = 30,
            -- znear = znear, -- zfar = zfar, -- ortho = {left=unclampedlerp(cx-hw,-rad,rad),bottom=unclampedlerp(cy-hh,rad,-rad),right=unclampedlerp(cx+hw,-rad,rad),top=unclampedlerp(cy+hh,rad,-rad)},
            offcenter = {
                left = (cx - hw) * ScrW(),
                top = ((1 - cy) - hh) * ScrH(),
                bottom = ((1 - cy) + hh) * ScrH(),
                right = (cx + hw) * ScrW()
            },
        })
    end

    local function drawtexture(tex, col, bf, x, y)
        if isfunction(col) then
            col, bf, x, y = nil, col, bf, x
        end

        if isnumber(col) then
            col, bf, x, y = nil, nil, col, bf
        end

        col, x, y = col or Vector(1, 1, 1), x or 0, y or 0
        AUTOICON_TEXTUREMATERIAL:SetTexture("$basetexture", tex)
        AUTOICON_TEXTUREMATERIAL:SetVector("$color2", col)

        if bf then
            bf()
        else
            render.OverrideBlend(false)
        end

        AUTOICON_TEXTUREMATERIAL:SetMatrix("$basetexturetransform", Matrix({
            {1, 0, 0, x / tex:Width()},
            {0, 1, 0, y / tex:Height()},
            {0, 0, 1, 0},
            {0, 0, 0, 1}
        }))

        render.SetMaterial(AUTOICON_TEXTUREMATERIAL)
        render.DrawScreenQuad()
        render.OverrideBlend(false)
    end

    render.SuppressEngineLighting(true)
    render.SetColorModulation(1, 1, 1)
    local lnameidx = 0

    local function ReusableName()
        lnameidx = lnameidx + 1

        return namejunk .. tostring(mode) .. "_" .. mdl:gsub("%W", "-") .. "_" .. tostring(lnameidx)
    end

    local function bf_sub()
        render.OverrideBlend(true, BLEND_ONE, BLEND_ONE, BLENDFUNC_REVERSE_SUBTRACT, BLEND_ZERO, BLEND_ONE, BLENDFUNC_ADD)
    end

    local function bf_add()
        render.OverrideBlend(true, BLEND_ONE, BLEND_ONE, BLENDFUNC_ADD, BLEND_ZERO, BLEND_ONE, BLENDFUNC_ADD)
    end

    local function bf_mul()
        render.OverrideBlend(true, BLEND_DST_COLOR, BLEND_ZERO, BLENDFUNC_ADD, BLEND_ZERO, BLEND_ONE, BLENDFUNC_ADD)
    end

    -- Figure out the model bounds then make a mask (white on black, no grays)
    local cmaskrt = MakeRT(ReusableName, crtx, crty)
    local cbmaskrt = MakeRT(ReusableName, crtx, crty)
    local canglert = MakeRT(ReusableName, crtx, crty)
    render.PushRenderTarget(cmaskrt)
    -- DRAW THE MODEL (WHITE MASK)
    render.Clear(0, 0, 0, 0)
    StartOrthoCam()
    render.MaterialOverride(AUTOICON_MODELCOLORMATERIAL)
    AUTOICON_ENT:DrawModel()
    render.MaterialOverride()
    cam.End3D()

    -- If it's bonemerged to the player, assume it's a gun, and try to fix the angle by looking at the mask
    if AUTOICON_ENT:LookupBone("ValveBiped.Bip01_R_Hand") then
        -- Make a version of the mask essentially blurred horizontally to remove noise from attachment rails
        render.PushRenderTarget(cbmaskrt)
        render.Clear(0, 0, 0, 0)
        cam.Start2D()

        for blur = -3, 3 do
            drawtexture(cmaskrt, bf_add, blur, 0)
        end

        cam.End2D()
        render.PopRenderTarget()
        -- A mask of just the top edge of the gun
        render.PushRenderTarget(canglert)
        render.Clear(0, 0, 0, 0)
        cam.Start2D()
        drawtexture(cbmaskrt, bf_add)
        drawtexture(cbmaskrt, bf_sub, 0, -1)
        cam.End2D()
        local bitmask, bitcount = GetBitmap()
        local x0, x1 = 0.33, 1

        if mode == AUTOICON_HL2WEAPONSELECT then
            x0, x1 = 0, 0.67
        end

        local fixang = EstimateAngle(bitmask, x0, x1)
        render.PopRenderTarget()

        if fixang ~= 0 then
            ang = AUTOICON_ENT:GetAngles()
            ang:RotateAroundAxis(Vector(0, -1, 0), fixang)
            AUTOICON_ENT:SetAngles(ang)
            AUTOICON_ENT:SetupBones()
            render.Clear(0, 0, 0, 0)
            StartOrthoCam()
            render.MaterialOverride(AUTOICON_MODELCOLORMATERIAL)
            AUTOICON_ENT:DrawModel()
            render.MaterialOverride()
            cam.End3D()
        end
    end

    bitmask, bitcount = GetBitmap()
    local px1, py1, px2, py2 = GetBBox(bitmask)
    -- Adjust the ortho bounds to match the model (GetRenderBounds ARE RARELY TIGHT)
    local area = bitcount / (rtx * rty)
    local pad = 0.01
    local icon_max_height = 0.5

    if mode == AUTOICON_HL2WEAPONSELECT then
        pad = 0.04
        icon_max_height = 0.5
        px1, px2 = px1 - pad, px2 + pad
    else
        px1, py1, px2, py2 = px1 - pad, py1 - pad, px2 + pad, py2 + pad
    end

    hw, hh = (px2 - px1) / 2, (py2 - py1) / 2
    cx, cy = (px2 + px1) / 2, (py2 + py1) / 2
    local realhh = hh
    hw, hh = math.max(hw, hh), math.max(hw, hh)

    if realhh / hh > icon_max_height then
        hw = hw * (realhh / hh) / icon_max_height
        hh = hh * (realhh / hh) / icon_max_height
    end

    local icon_max_area = (mode == AUTOICON_HL2WEAPONSELECT) and 0.15 or 0.5
    area = area / (hw * hh * 4)
    local scale = math.sqrt(math.max(area / icon_max_area, 1))
    hw, hh = scale * hw, scale * hh
    -- code to supersample the mask, doesn't make much difference as image is already 4x
    -- local mask2 = MakeRT(ReusableName,rtx*2,rty*2,false,false)
    render.PopRenderTarget()
    -- Render the mask
    local maskrt = MakeRT(ReusableName, rtx, rty)
    render.PushRenderTarget(maskrt)
    render.Clear(0, 0, 0, 0)
    StartOrthoCam()
    render.MaterialOverride(AUTOICON_MODELCOLORMATERIAL)
    AUTOICON_ENT:DrawModel()
    render.MaterialOverride()
    cam.End3D()
    render.PopRenderTarget()
    -- Render the model fullbright
    local colorrt = MakeRT(ReusableName, rtx, rty, true)
    render.PushRenderTarget(colorrt)
    render.Clear(0, 0, 0, 0, true, true)
    StartOrthoCam()
    AUTOICON_ENT:DrawModel()
    cam.End3D()
    render.BlurRenderTarget(colorrt, 1 / rtx, 1 / rty, 1) --make it less noisy
    render.PopRenderTarget()
    -- Do edge detection convolution
    local coloredgert = MakeRT(ReusableName, rtx, rty)
    render.PushRenderTarget(coloredgert)
    render.Clear(0, 0, 0, 0)
    cam.Start2D()
    -- Dialation (makes edges thicker)
    local d = 2

    if mode == AUTOICON_HL2WEAPONSELECT then
        d = 3
    end

    local mul = Vector(1, 1, 1) * 0.75

    -- g_sharpen seems to be a convolution of [[-a 0] [0 a+1]]
    -- sobel seems to run a proper sobel/laplacian but then thresholds the result and adds it back
    -- edge detection from color
    -- Note: We can't just increase mul 8* and add the unshifted image one time
    -- Nor can we use mul/8 for the shifted images and then mul the result
    -- (the bytes don't accumulate correctly)
    for x = -1, 1 do
        for y = -1, 1 do
            if x ~= 0 or y ~= 0 then
                drawtexture(colorrt, mul, bf_add)
                drawtexture(colorrt, mul, bf_sub, x * d, y * d)
            end
        end
    end

    if mode == AUTOICON_HL2WEAPONSELECT then
        d = 3
        mul = Vector(1, 1, 1) * 0.5

        -- edge detection from mask
        -- maybe replace the mask with the depth buffer/fog version?
        for x = -1, 1 do
            for y = -1, 1 do
                if x ~= 0 or y ~= 0 then
                    drawtexture(maskrt, mul, bf_add)
                    drawtexture(maskrt, mul, bf_sub, x * d, y * d)
                end
            end
        end
    end

    cam.End2D()
    render.PopRenderTarget()
    local bluredgert
    -- Desaturate the edge detect image and adjust the min/max a little
    local edgert = MakeRT(ReusableName, rtx, rty)
    render.PushRenderTarget(edgert)
    render.Clear(0, 0, 0, 0)
    cam.Start2D()
    AUTOICON_DESATURATEMATERIAL:SetTexture("$fbtexture", coloredgert)
    render.SetMaterial(AUTOICON_DESATURATEMATERIAL)
    render.DrawScreenQuad()
    cam.End2D()

    if mode == AUTOICON_HL2WEAPONSELECT then
        -- Blurred version of edges
        bluredgert = MakeRT(ReusableName, rtx, rty)
        render.CopyRenderTargetToTexture(bluredgert)
        render.BlurRenderTarget(bluredgert, 16, 16, 8)
    end

    render.PopRenderTarget()
    local finalrt = MakeRT(UniqueName, rtx, rty)

    if mode == AUTOICON_HL2WEAPONSELECT then
        -- Blurred version of mask
        local blurmaskrt = MakeRT(ReusableName, rtx, rty)
        render.PushRenderTarget(blurmaskrt)
        render.Clear(0, 0, 0, 0)
        cam.Start2D()
        drawtexture(maskrt)
        render.BlurRenderTarget(blurmaskrt, 8, 8, 3)
        cam.End2D()
        render.PopRenderTarget()
        -- Final composition
        render.PushRenderTarget(finalrt)
        render.Clear(0, 0, 0, 0)
        cam.Start2D()
        -- Create "glow"
        drawtexture(maskrt, Vector(1, 1, 1) * 0.2)
        render.BlurRenderTarget(finalrt, 16, 16, 2)
        drawtexture(bluredgert, Vector(1, 1, 1) * 20, bf_add)
        -- Multiply = masks the glow
        drawtexture(blurmaskrt, Vector(1, 1, 1) * 128, bf_mul)
        -- drawtexture(maskrt,Vector(1,1,1)*0.7, bf_xcfx)
        -- drawtexture(blurmaskrt,Vector(1,1,1)*50)
        -- drawtexture(bluredgert,Vector(1,1,1)*50,bf_add)
        -- drawtexture(blurmaskrt,Vector(1,1,1)*50,bf_mul)
        -- drawtexture(maskrt,bf_sub)
        -- Mask out lines
        local stp = 10

        for y = 0, rty, stp do
            surface.SetDrawColor(0, 0, 0, 180)
            surface.DrawRect(0, y, rtx, stp - 1)
        end

        -- Add edges
        drawtexture(edgert, bf_add)
        cam.End2D()
        render.PopRenderTarget()
    else
        render.PushRenderTarget(finalrt)
        render.Clear(0, 0, 0, 0)
        cam.Start2D()

        for x = 0, 1 do
            for y = 0, 1 do
                drawtexture(maskrt, bf_add, x, y)
            end
        end

        -- Subtract edges * 10 to make the image more thresholded looking
        drawtexture(edgert, Vector(1, 1, 1) * 10, bf_sub)
        cam.End2D()
        render.PopRenderTarget()
    end

    -- Junk for drawing depth, not really needed
    -- local mask3 = MakeRT(ReusableName,true,false)
    -- render.PushRenderTarget(mask3)
    -- if true then
    --     -- DRAW THE MODEL AGAIN (WHITE MASK)
    --     render.Clear(0,0,0,255,true,true)
    --     StartOrthoCam() 
    --     render.MaterialOverride(AUTOICON_MODELCOLORMATERIAL)
    --     render.FogMode(MATERIAL_FOG_LINEAR)
    --     render.FogStart(znear)
    --     render.FogEnd(zfar)
    --     render.FogColor(0,0,0)
    --     render.FogMaxDensity(1)
    --     -- render.SetWriteDepthToDestAlpha(false)
    --     -- render.OverrideBlend(true, BLEND_DST_ALPHA, BLEND_ZERO, BLENDFUNC_ADD, BLEND_ZERO, BLEND_ONE, BLENDFUNC_ADD ) 
    --     -- render.DepthRange(,1)
    --     AUTOICON_ENT:DrawModel()
    --     render.FogMode(MATERIAL_FOG_NONE)
    --     -- -- render.OverrideBlend(false) 
    --     -- render.SetWriteDepthToDestAlpha(true)
    --     render.MaterialOverride()
    --     cam.End3D()
    -- end
    -- render.PopRenderTarget()
    -- color2 gets overridden by killicons
    local m = CreateMaterial(UniqueName(), "UnlitGeneric", {
        ["$basetexture"] = finalrt:GetName(),
    })

    AUTOICONS[mode][mdl] = m
    render.SuppressEngineLighting(false)
    render.OverrideBlend(false)

    return m
end

local weaponselectcolor = Vector(1, 0.93, 0.05)

function AUTOICON_DRAWWEAPONSELECTION(self, x, y, wide, tall, alpha)
    if not ReplaceAllConvar:GetBool() and (self.BasedDrawWeaponSelection or self.WepSelectIcon ~= AUTOICONS_BASEDWEPSELECTICON or self.WorldModel == "") then return (self.BasedDrawWeaponSelection or AUTOICONS_BASEDDRAWWEAPONSELECTION)(self, x, y, wide, tall, alpha) end
    local shift = math.floor(tall / 4)
    local y2 = y + shift
    local tall2 = tall - shift
    local mdl = self:GetModel()

    if self.AutoIconAngle then
        AUTOICONS_ANGLE_OVERRIDE[mdl] = self.AutoIconAngle
    end

    local weaponselect = GetAutoIcon(mdl == "" and "models/maxofs2d/logo_gmod_b.mdl" or mdl, AUTOICON_HL2WEAPONSELECT)
    render.SetMaterial(weaponselect)
    weaponselect:SetVector("$color2", weaponselectcolor * alpha / 255)
    -- Looks best at 256 (2:1 sampling) - at lower sizes (when below 1680x1050 game res) an interference pattern is visible on the lines
    -- I could draw the icons themselves smaller, but they might have some kind of custom weapon selctor that changes the wide/tall dynamically which would make the icons redraw every frame
    local sz = wide < 245 and wide or 256
    cam.Start2D()
    render.OverrideBlend(true, BLEND_ONE_MINUS_DST_COLOR, BLEND_ONE, BLENDFUNC_ADD, BLEND_ZERO, BLEND_ONE, BLENDFUNC_ADD)
    render.DrawScreenQuadEx(x + (wide - sz) * 0.5, y2 + (tall2 - sz) * 0.5, sz, sz)
    render.OverrideBlend(false)
    cam.End2D()

    -- Draw weapon info box
    if self.PrintWeaponInfo then
        self:PrintWeaponInfo(x + wide + 20, y + tall * 0.95, alpha)
    end
end

hook.Add("PreRegisterSWEP", "AutoIconsOverrideDrawWeaponSelection", function(swep, cls)
    if cls == "weapon_base" then
        AUTOICONS_BASEDDRAWWEAPONSELECTION = swep.DrawWeaponSelection
        AUTOICONS_BASEDWEPSELECTICON = swep.WepSelectIcon
        swep.BasedDrawWeaponSelection = false
    else
        swep.BasedDrawWeaponSelection = swep.DrawWeaponSelection
    end

    swep.DrawWeaponSelection = function(a, b, c, d, e, f)
        AUTOICON_DRAWWEAPONSELECTION(a, b, c, d, e, f)
    end
end)

BASE_KILLICON_EXISTS = BASE_KILLICON_EXISTS or killicon.Exists
BASE_KILLICON_DRAW = BASE_KILLICON_DRAW or killicon.Draw
BASE_KILLICON_GETSIZE = BASE_KILLICON_GETSIZE or killicon.GetSize

local function GetEntityModelName(name)
    -- It might be cool to override GM:PlayerDeath and have it actually send the inflictor's model instead of classname...
    if string.EndsWith(name, ".mdl") then return name end
    local ent = weapons.GetStored(name) or scripted_ents.GetStored(name)
    local mdl = nil

    if ent then
        if (ent.WorldModel or "") ~= "" then
            mdl = ent.WorldModel
        end

        -- "Model" isn't a standard part of the ENT structure but it gets used now and then.
        -- You could also ents.FindByClass()[1]:GetModel() and cache the result, but it would be unreliable especially due to PVS
        if (ent.Model or "") ~= "" then
            mdl = ent.Model
        end
    end

    if mdl and ent.AutoIconAngle then
        AUTOICONS_ANGLE_OVERRIDE[mdl] = ent.AutoIconAngle
    end

    return mdl
end

killicon.Exists = function(name)
    if BASE_KILLICON_EXISTS(name) or GetEntityModelName(name) then return true end

    return false
end

local killiconsize = 96
local killiconcolor = Vector(1, 80 / 255, 0)

killicon.GetSize = function(name)
    if not ReplaceAllConvar:GetBool() and BASE_KILLICON_EXISTS(name) then return BASE_KILLICON_GETSIZE(name) end
    if GetEntityModelName(name) then return killiconsize, killiconsize / 2 end

    return BASE_KILLICON_GETSIZE(name)
end

killicon.Draw = function(x, y, name, alpha)
    if not ReplaceAllConvar:GetBool() and BASE_KILLICON_EXISTS(name) then return BASE_KILLICON_DRAW(x, y, name, alpha) end
    local mdl = GetEntityModelName(name)

    if mdl then
        local w, h = killiconsize, killiconsize
        x = x - w * 0.5
        y = y - h * 0.35
        cam.Start2D()
        local killicon = GetAutoIcon(mdl, AUTOICON_HL2KILLICON)
        render.SetMaterial(killicon)
        killicon:SetVector("$color2", killiconcolor * alpha / 255)
        render.OverrideBlend(true, BLEND_ONE_MINUS_DST_COLOR, BLEND_ONE, BLENDFUNC_ADD, BLEND_ZERO, BLEND_ONE, BLENDFUNC_ADD)
        render.OverrideDepthEnable(true, false)
        render.DrawScreenQuadEx(x, y, w, h)
        render.OverrideDepthEnable(false, false)
        render.OverrideBlend(false)
        cam.End2D()
    else
        return BASE_KILLICON_DRAW(x, y, name, alpha)
    end
end