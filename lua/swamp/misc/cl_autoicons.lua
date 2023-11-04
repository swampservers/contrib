-- autoicons.lua: Automatically generates/renders weapon select icons and killicons
-- for SWEPs not containing them. Made by swamponions (STEAM_0:0:38422842)
-- https://steamcommunity.com/sharedfiles/filedetails/?id=2495300496
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
    ["$pp_colour_brightness"] = -0.25,
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
AUTOICON_INDICATOR_TEXTURE = GetRenderTargetEx(UniqueName(), 2, 2, 0, 2, 1, 0, IMAGE_FORMAT_RGB888)

AUTOICON_INDICATOR_MATERIAL = CreateMaterial(UniqueName(), "VertexLitGeneric", {
    ["$basetexture"] = "metal6",
})

local ValidCheckTime = 0

--NOMINIFY
local function CheckTexturesValid()
    if SysTime() - ValidCheckTime < 5.555 then return end
    ValidCheckTime = SysTime()
    assert(not AUTOICON_INDICATOR_TEXTURE:IsError())
    render.PushRenderTarget(AUTOICON_INDICATOR_TEXTURE)
    render.CapturePixels()
    -- local cap = render.Capture({format="png",x=0,y=0,w=1,h=1})
    -- print("CAP", cap:len())
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

    for x = math.floor(xs * Lerp(x1, px1, px2)), math.ceil(xs * Lerp(x2, px1, px2)) - 1 do
        for y = math.floor(ys * py1), math.ceil(ys * py2) - 1 do
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

local placeholder_model = "models/maxofs2d/logo_gmod_b.mdl"
local error_model = "models/error.mdl"

AUTOICONS_ANGLE_OVERRIDE = {
    ["models/weapons/w_toolgun.mdl"] = Angle(0, 0, 0),
    ["models/MaxOfS2D/camera.mdl"] = Angle(0, 90, 0),
    ["models/maxofs2d/logo_gmod_b.mdl"] = Angle(0, 90, 0),
    [error_model] = Angle(0, 90, 0),
}

AUTOICONS_PRESUMED_ENTITY_MODEL = {}

-- Note: This won't work for entities outside of PVS, but it's the best we can do without server code that might break other things
-- This won't override models for non-SENTs (prop_physics etc)
hook.Add("NetworkEntityCreated", "AutoIconsNetworkEntityCreated", function(ent)
    if (ent:GetModel() or "") ~= "" then
        AUTOICONS_PRESUMED_ENTITY_MODEL[ent:GetClass()] = ent:GetModel()
    end
end)

local function TranslateClassName(classname)
    if string.EndsWith(classname, ".mdl") then return classname end

    return weapons.GetStored(classname) or (scripted_ents.GetStored(classname) or {}).t
end

function AutoIconParams(data)
    local function translatemodel(mdl)
        return (mdl or "") == "" and placeholder_model or (util.IsValidModel(mdl) and mdl or "models/error.mdl")
    end

    local function datamainmodel()
        -- IronSightStruct indicates ARCCW. data.Model is an attempt to get something from an ENT table
        return (data.IronSightStruct and data.ViewModel or data.WorldModel) or data.Model or AUTOICONS_PRESUMED_ENTITY_MODEL[data.ClassName]
    end

    local p = {}

    if isentity(data) then
        local mdl = translatemodel(data:GetModel())

        -- If the "current model" is not the actual model, draw that instead
        if mdl == datamainmodel() then
            data = TranslateClassName(data:GetClass())
            assert(data)
        else
            data = mdl
        end
    end

    -- SWEP table
    if istable(data) then
        p.mainmodel = translatemodel(datamainmodel())
        p.cachekey = data.ClassName

        -- TFA
        if data.Offset and data.Offset.Ang then
            local a = data.Offset.Ang
            p.force_angle = Angle(8, 0, 180)
            p.force_angle:RotateAroundAxis(p.force_angle:Up(), a.Up)
            p.force_angle:RotateAroundAxis(p.force_angle:Right(), a.Right)
            p.force_angle:RotateAroundAxis(p.force_angle:Forward(), a.Forward)
            p.force_sense_angle = true
        end

        -- SCK, scifi sweps
        if data.ShowWorldModel == false or data.SciFiWorld == "dev/hide" or data.SciFiWorld == "vgui/white" then
            p.hide_mainmodel = true
        end

        -- SCK
        p.welements = data.WElements
        p.force_angle = data.AutoIconAngle or AUTOICONS_ANGLE_OVERRIDE[p.mainmodel] or p.force_angle
    else
        p.mainmodel = data
        p.cachekey = data
        p.force_angle = AUTOICONS_ANGLE_OVERRIDE[p.mainmodel]
    end

    assert(isstring(p.mainmodel) and (p.mainmodel or "") ~= "")
    assert(isstring(p.cachekey) and (p.cachekey or "") ~= "")
    p.LEGIT = p.mainmodel ~= placeholder_model and p.mainmodel ~= error_model

    return p
end

local function SCKLocalToWorld(ipos, iang, pos, ang)
    pos = pos + ipos.x * ang:Forward()
    pos = pos + ipos.y * ang:Right()
    pos = pos + ipos.z * ang:Up()
    ang = Angle(ang)
    ang:RotateAroundAxis(ang:Up(), iang.y)
    ang:RotateAroundAxis(ang:Right(), iang.p)
    ang:RotateAroundAxis(ang:Forward(), iang.r)

    return pos, ang
end

local AutoIconsToMake = {}

hook.Add("PreRender", "MakeAutoIcons", function()
    CheckTexturesValid()

    for mode, modetable in pairs(AutoIconsToMake) do
        for cachekey, p in pairs(modetable) do
            MakeAutoIcon(p, mode)
        end

        AutoIconsToMake[mode] = nil
    end
end)

function GetAutoIcon(p, mode)
    if not AUTOICONS[mode][p.cachekey] then
        AUTOICONS[mode][p.cachekey] = CreateMaterial(UniqueName(), "UnlitGeneric", {
            ["$basetexture"] = "tools/toolsblack",
        })

        AutoIconsToMake[mode] = AutoIconsToMake[mode] or {}
        AutoIconsToMake[mode][p.cachekey] = p
    end

    return AUTOICONS[mode][p.cachekey]
end

function MakeAutoIcon(p, mode)
    -- print("MAKE",p.mainmodel)
    SetCrashData("AUTOICON", p.mainmodel, 0.05)
    local mainent = ClientsideModel(p.mainmodel)
    assert(IsValid(mainent))
    local extraents = {}
    mainent:SetPos(Vector(0, 0, 0))
    mainent:SetAngles(Angle(0, 0, 0))
    mainent:SetupBones()

    for k, v in pairs(p.welements or {}) do
        if not v.model then continue end
        if v.color and v.color.a == 0 then continue end
        local mat

        if (v.material or "") ~= "" then
            mat = Material(v.material)
            if mat:GetShader() ~= "VertexLitGeneric" and mat:GetShader() ~= "UnlitGeneric" then continue end
            -- nodraw, vertexalpha, additive, -- translucent 2097152
            if bit.band(mat:GetInt("$flags"), 4 + 32 + 128) ~= 0 then continue end
        end

        -- Compute position relative to mainent position
        local lpos, lang = Vector(0, 0, 0), Angle(0, 0, 0) -- SCKLocalToWorld(Vector(0,0,0), Angle(0,0,0), v.pos or Vector(0,0,0), v.angle or Angle(0,0,0))
        local bn = v.bone
        local parent = v

        for i = 1, 10 do
            if (parent.rel or "") == "" then break end
            parent = p.welements[parent.rel]
            if not parent then break end
            lpos, lang = SCKLocalToWorld(lpos, lang, parent.pos or Vector(0, 0, 0), parent.angle or Angle(0, 0, 0))
            bn = parent.bone
        end

        --"ValveBiped.Bip01_R_Hand"?
        if bn == "Base" then
            bn = nil
        end

        if bn then
            bn = mainent:LookupBone(bn)
            if not bn then continue end
            local p, a = mainent:GetBonePosition(bn)
            -- a.r = -a.r
            lpos, lang = SCKLocalToWorld(lpos, lang, p, a)
        end

        lpos, lang = SCKLocalToWorld(v.pos or Vector(0, 0, 0), v.angle or Angle(0, 0, 0), lpos, lang)
        local e = ClientsideModel(v.model)

        if mat then
            e:SetMaterial(v.material)
        end

        e.lpos = lpos
        e.lang = lang
        mat = Matrix()
        mat:Scale(v.size or Vector(1, 1, 1))
        e:EnableMatrix("RenderMultiply", mat)
        table.insert(extraents, e)
    end

    -- If we have an error, we'll still delete the entities
    local ok, ret = pcall(function()
        local function drawmodel()
            if not p.hide_mainmodel then
                mainent:DrawModel()
            end

            for i, v in ipairs(extraents) do
                local p, a = LocalToWorld(v.lpos, v.lang, mainent:GetPos(), mainent:GetAngles())
                v:SetPos(p)
                v:SetAngles(a)
                v:SetupBones()
                v:DrawModel()
            end
        end

        local min, max = mainent:GetRenderBounds()
        local center, rad = (min + max) / 2, min:Distance(max) / 2
        local ang
        local b

        if p.force_angle then
            ang = p.force_angle
        else
            local muzzleatt = mainent:LookupAttachment("muzzle")

            if muzzleatt < 1 then
                muzzleatt = mainent:LookupAttachment("muzzle_flash")
            end

            b = mainent:LookupBone("ValveBiped.Bip01_R_Hand")

            if muzzleatt > 0 or b then
                mainent:SetAngles(Angle(0, 0, 0))
                mainent:SetupBones()

                local v = muzzleatt > 0 and mainent:GetAttachment(muzzleatt).Ang:Forward() or ({mainent:GetBonePosition(b)})[2]:Forward()

                -- Despite various attachments and bones existing, this is the best I could do.
                -- Pretty pathetic huh? Half the SWEPs on workshop have totally wrong attachment/bone angles and anything more than this completely messes them up.
                -- There is a second pass below where it tries to fix the angle by looking at the drawn mask itself
                ang = Angle(0, -math.deg(math.atan2(v.y, v.x)), 0)
            else
                -- One of these is usually correct
                ang = Angle(0, max.x - min.x >= max.y - min.y and 0 or 90, 0)
                ang:RotateAroundAxis(Vector(1, 0, 0), -11)
            end
        end

        -- Flip weaponselect icons the other way
        if mode == AUTOICON_HL2WEAPONSELECT then
            ang:RotateAroundAxis(Vector(0, 0, 1), 180)
        end

        mainent:SetAngles(ang)
        mainent:SetupBones()
        local zpd = math.min(max.x - min.x, max.y - min.y)
        local viewdist = 5 * rad + 1
        local znear = viewdist - zpd / 2
        local zfar = znear + zpd
        local hw, hh, cx, cy = 0.5, 0.5, 0.5, 0.5
        local rtx, rty = 512, 512

        if mode == AUTOICON_HL2KILLICON then
            rtx, rty = 256, 256
        end

        local crtx, crty = 512, 512
        local fov = 30

        local function StartOrthoCam()
            local function unclampedlerp(t, x, y)
                return (1 - t) * x + t * y
            end

            cam.Start({
                x = 0,
                y = 0,
                w = ScrW(),
                h = ScrH(),
                type = "3D",
                origin = mainent:LocalToWorld(center) + Vector(0, -viewdist, 0),
                angles = Vector(0, 90, 0),
                aspect = 1,
                fov = fov,
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

            return namejunk .. tostring(mode) .. "_" .. tostring(lnameidx)
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
        drawmodel()
        render.MaterialOverride()
        cam.End3D()

        -- If it's bonemerged to the player (and no angle override), assume it's a gun, and try to fix the angle by looking at the mask
        if b or p.force_sense_angle then
            -- Make a version of the mask essentially blurred horizontally to remove noise from attachment rails
            render.PushRenderTarget(cbmaskrt)
            render.Clear(0, 0, 0, 0)
            cam.Start2D()

            for blur = -3, 3 do
                drawtexture(cmaskrt, bf_add, blur, 0)
            end

            cam.End2D()
            render.PopRenderTarget()
            assert(not canglert:IsError())
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
                ang = mainent:GetAngles()
                ang:RotateAroundAxis(Vector(0, -1, 0), fixang)
                mainent:SetAngles(ang)
                mainent:SetupBones()
                render.Clear(0, 0, 0, 0)
                StartOrthoCam()
                render.MaterialOverride(AUTOICON_MODELCOLORMATERIAL)
                drawmodel()
                render.MaterialOverride()
                cam.End3D()
            end
        end

        bitmask, bitcount = GetBitmap()
        local px1, py1, px2, py2 = GetBBox(bitmask)

        -- Zoom out until the whole actual model is in view (needed by some SCK weapons)
        while px1 == 0 or py1 == 0 or px2 == 1 or py2 == 1 do
            fov = fov + 10
            if fov > 150 then break end
            render.Clear(0, 0, 0, 0)
            StartOrthoCam()
            render.MaterialOverride(AUTOICON_MODELCOLORMATERIAL)
            drawmodel()
            render.MaterialOverride()
            cam.End3D()
            bitmask, bitcount = GetBitmap()
            px1, py1, px2, py2 = GetBBox(bitmask)
        end

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

        local icon_max_area = mode == AUTOICON_HL2WEAPONSELECT and 0.15 or 0.5
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
        drawmodel()
        render.MaterialOverride()
        cam.End3D()
        render.PopRenderTarget()
        -- Render the model fullbright
        local colorrt = MakeRT(ReusableName, rtx, rty, true)
        render.PushRenderTarget(colorrt)
        render.Clear(0, 0, 0, 0, true, true)
        StartOrthoCam()
        drawmodel()
        cam.End3D()
        render.BlurRenderTarget(colorrt, 1 / rtx, 1 / rty, 1) --make it less noisy
        render.PopRenderTarget()
        -- Render the model normals
        local normalrt = MakeRT(ReusableName, rtx, rty, true)
        render.PushRenderTarget(normalrt)
        render.Clear(0, 0, 0, 0, true, true)
        StartOrthoCam()
        render.MaterialOverride(AUTOICON_MODELCOLORMATERIAL)
        render.SetModelLighting(0, 1, 0.5, 0.5)
        render.SetModelLighting(1, 0, 0.5, 0.5)
        render.SetModelLighting(2, 0.5, 1, 0.5)
        render.SetModelLighting(3, 0.5, 0, 0.5)
        render.SetModelLighting(4, 0.5, 0.5, 1)
        render.SetModelLighting(5, 0.5, 0.5, 0)
        drawmodel()
        render.MaterialOverride()
        cam.End3D()
        render.ResetModelLighting(1, 1, 1)
        render.BlurRenderTarget(colorrt, 1 / rtx, 1 / rty, 1) --make it less noisy
        render.PopRenderTarget()
        -- Do edge detection convolution
        local coloredgert = MakeRT(ReusableName, rtx, rty)
        render.PushRenderTarget(coloredgert)
        render.Clear(0, 0, 0, 0)
        cam.Start2D()
        -- Dialation (makes edges thicker)
        local d = 1

        if mode == AUTOICON_HL2WEAPONSELECT then
            d = 3
        end

        -- g_sharpen seems to be a convolution of [[-a 0] [0 a+1]]
        -- sobel seems to run a proper sobel/laplacian but then thresholds the result and adds it back
        -- Note: We can't just increase mul 8* and add the unshifted image one time
        -- Nor can we use mul/8 for the shifted images and then mul the result
        -- (the bytes don't accumulate correctly)
        local mul = Vector(1, 1, 1) * 0.7

        -- edge detection from normals
        for x = -1, 1 do
            for y = -1, 1 do
                if x ~= 0 or y ~= 0 then
                    drawtexture(normalrt, mul, bf_add)
                    drawtexture(normalrt, mul, bf_sub, x * d, y * d)
                end
            end
        end

        if mode == AUTOICON_HL2WEAPONSELECT then
            mul = Vector(1, 1, 1) * 0.7

            -- edge detection from color
            for x = -1, 1 do
                for y = -1, 1 do
                    if x ~= 0 or y ~= 0 then
                        drawtexture(colorrt, mul, bf_add)
                        drawtexture(colorrt, mul, bf_sub, x * d, y * d)
                    end
                end
            end

            d = 3
            mul = Vector(1, 1, 1) * 0.5

            -- edge detection from mask
            -- maybe replace the mask with the depth buffer version? render.FogMode(MATERIAL_FOG_LINEAR) (NOTE: fog seems to only work with non-orthographic 3D that also doesn't have custom near/far z planes)
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
            render.BlurRenderTarget(bluredgert, 14, 14, 8)
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
            render.BlurRenderTarget(finalrt, 20, 20, 2)
            drawtexture(bluredgert, Vector(1, 1, 1) * 16, bf_add)
            -- Multiply = masks the glow
            drawtexture(blurmaskrt, Vector(1, 1, 1) * 128, bf_mul)
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

            for x = -1, 1 do
                for y = -1, 1 do
                    drawtexture(maskrt, bf_add, x, y)
                end
            end

            -- Subtract edges * 10 to make the image more thresholded looking
            drawtexture(edgert, Vector(1, 1, 1) * 10, bf_sub)
            cam.End2D()
            render.PopRenderTarget()
        end

        -- color2 gets overridden by killicons
        -- local m = CreateMaterial(UniqueName(), "UnlitGeneric", {
        --     ["$basetexture"] = finalrt:GetName(),
        -- })
        -- AUTOICONS[mode][p.cachekey] = m
        AUTOICONS[mode][p.cachekey]:SetTexture("$basetexture", finalrt)
        render.SuppressEngineLighting(false)
        render.OverrideBlend(false)

        return m
    end)

    mainent:Remove()

    for i, v in ipairs(extraents) do
        v:Remove()
    end

    if ok then
        return ret
    else
        error(ret)
    end
end

local weaponselectcolor = NamedColor("FgColor")
weaponselectcolor = Vector(weaponselectcolor.r / 255, weaponselectcolor.g / 255, weaponselectcolor.b / 255)

function AUTOICON_DRAWWEAPONSELECTION(self, x, y, wide, tall, alpha)
    if not ReplaceAllConvar:GetBool() and (self.BasedDrawWeaponSelection or self.WepSelectIcon ~= AUTOICONS_BASEDWEPSELECTICON or self.WorldModel == "") then return (self.BasedDrawWeaponSelection or AUTOICONS_BASEDDRAWWEAPONSELECTION)(self, x, y, wide, tall, alpha) end
    local shift = math.floor(tall / 4)
    local y2 = y + shift
    local tall2 = tall - shift
    local weaponselect = GetAutoIcon(AutoIconParams(self), AUTOICON_HL2WEAPONSELECT)
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

-- Override killicon library
BASED_KILLICON_EXISTS = BASED_KILLICON_EXISTS or killicon.Exists
BASED_KILLICON_DRAW = BASED_KILLICON_DRAW or killicon.Draw
BASED_KILLICON_GETSIZE = BASED_KILLICON_GETSIZE or killicon.GetSize

-- It might be cool to override GM:PlayerDeath and have it actually send the inflictor entity as well as classname...
local function ClassNameParams(classname)
    local p = TranslateClassName(classname)

    if p then
        return AutoIconParams(p)
    else
        return {}
    end
end

killicon.Exists = function(name) return BASED_KILLICON_EXISTS(name) or ClassNameParams(name).LEGIT end
local killiconsize = 96
local killiconcolor = Vector(1, 80 / 255, 0)

killicon.GetSize = function(name, dontEqualizeHeight)
    if not ReplaceAllConvar:GetBool() and BASED_KILLICON_EXISTS(name) then return BASED_KILLICON_GETSIZE(name, dontEqualizeHeight) end

    if ClassNameParams(name).LEGIT then
        print("GetSize", name)

        return killiconsize / 2, killiconsize / 2
    end

    return BASED_KILLICON_GETSIZE(name, dontEqualizeHeight)
end

killicon.Draw = function(x, y, name, alpha, noCorrections, dontEqualizeHeight)
    print("Draw", name)
    if not ReplaceAllConvar:GetBool() and BASED_KILLICON_EXISTS(name) then return BASED_KILLICON_DRAW(x, y, name, alpha, noCorrections, dontEqualizeHeight) end
    local p = ClassNameParams(name)

    if p.LEGIT then
        local w, h = killiconsize, killiconsize
        x = x - w * 0.5
        y = y - h * 0.35
        cam.Start2D()
        local killicon = GetAutoIcon(p, AUTOICON_HL2KILLICON)
        render.SetMaterial(killicon)
        killicon:SetVector("$color2", killiconcolor * alpha / 255)
        render.OverrideBlend(true, BLEND_ONE_MINUS_DST_COLOR, BLEND_ONE, BLENDFUNC_ADD, BLEND_ZERO, BLEND_ONE, BLENDFUNC_ADD)
        render.OverrideDepthEnable(true, false)
        render.DrawScreenQuadEx(x, y, w, h)
        render.OverrideDepthEnable(false, false)
        render.OverrideBlend(false)
        cam.End2D()
    else
        return BASED_KILLICON_DRAW(x, y, name, alpha, noCorrections, dontEqualizeHeight)
    end
end
