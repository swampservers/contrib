-- This file is subject to copyright - contact swampservers@gmail.com for more information.

-- weapons.GetStored("weapon_base").WepSelectIcon 

local rtx,rty = 512,512

local function getbbox()
    local bitmask = {}
    local bitcount = 0
    for x = 0,rtx-1 do
        bitmask[x]={}
        for y = 0,rty-1 do
            local r,g,b,a = render.ReadPixel(x,y)
            if math.max(r,g,b)>0 then
                bitmask[x][y]=true
                bitcount = bitcount+1
            end
        end
    end
    local px1,py1,px2,py2 = 0,0,1,1
    for x = 0,rtx-1 do
        for y = 0,rty-1 do
            if bitmask[x][y] then
                px1 = x/rtx
                goto g1
            end
        end
    end
    ::g1::
    for y = 0,rty-1 do
        for x = 0,rtx-1 do
            if bitmask[x][y] then
                py1 = y/rty
                goto g2
            end
        end
    end
    ::g2::
    for x = rtx-1,0,-1 do
        for y = 0,rty-1 do
            if bitmask[x][y] then
                px2 = (x+1)/rtx
                goto g3
            end
        end
    end
    ::g3::
    for y = rty-1,0,-1 do
        for x = 0,rtx-1 do
            if bitmask[x][y] then
                py2 = (y+1)/rty
                goto g4
            end
        end
    end
    ::g4::
    return px1,py1,px2,py2,bitcount/(rtx*rty)
end

local function matname(mdl, nd)
    return mdl:gsub(".mdl","_"):gsub("/","_")..tostring(TESTTIDX)..nd
end

WEAPONICONS = {}

TESTTIDX = (TESTTIDX or 0) + 1

-- render.SetColorModulation(1, 0.8667, 0)

SWEPCOLORMATERIAL = CreateMaterial(matname("SWEPCOLORMATERIAL",""), "UnlitGeneric", {
    ["$basetexture"] = "lights/white", 
  } )


SWEPUNLITMATERIAL =  CreateMaterial(matname("SWEPUNLITMATERIAL",""),  "UnlitGeneric", {
    ["$basetexture"] = "lights/white", 
    ["$vertexcolor"] = "1",
  } )

-- g_sharpen seems to be a convolution of 
-- [-x 0  ]
-- [ 0 x+1]

-- sobel seems to run a proper sobel/laplacian but then thresholds the result

-- SHARPENMATERIAL = CreateMaterial(matname("SHARPENMATERIAL",""), "g_sharpen",
-- {
-- 	-- ["$basetexture"] = "lights/white", 
-- 	-- ["$threshold"] = "0.11",
-- })

SWEPRANGEADJUSTMATERIAL = CreateMaterial(matname("SWEPRANGEADJUSTMATERIAL",""), "g_colourmodify",
{
	["$fbtexture"] = "lights/white", 
    [ "$pp_colour_addr" ] = 0,
	[ "$pp_colour_addg" ] = 0,
	[ "$pp_colour_addb" ] = 0,
	[ "$pp_colour_brightness" ] = -0.3,
	[ "$pp_colour_contrast" ] = 3,
	[ "$pp_colour_colour" ] = 0,
	[ "$pp_colour_mulr" ] = 0,
	[ "$pp_colour_mulg" ] = 0,
	[ "$pp_colour_mulb" ] = 0,
})




function GetWeaponIcon(mdl)
    if not IsValid(WEAPON_SELECT_ENT) then
        WEAPON_SELECT_ENT = ClientsideModel(mdl)
        if not IsValid(WEAPON_SELECT_ENT) then return end
        WEAPON_SELECT_ENT:SetNoDraw(true)
    end
    if WEAPON_SELECT_ENT:GetModel() ~= mdl then 
        WEAPON_SELECT_ENT:SetModel(mdl)
    end
    local min, max = WEAPON_SELECT_ENT:GetRenderBounds()
    local center, rad = (min + max) / 2, min:Distance(max) / 2
    if max.x-min.x > max.y-min.x then
        WEAPON_SELECT_ENT:SetAngles(Angle(0, 0, 0))
    else
        WEAPON_SELECT_ENT:SetAngles(Angle(0, 90, 0))
    end
    -- WEAPON_SELECT_ENT:SetAngles(Angle(0, 180, 0))
    local bx1,by1,bx2,by2 = -rad,rad,rad,-rad

    local function startcam() 
        cam.Start3D(
            WEAPON_SELECT_ENT:LocalToWorld(center) + ((rad + 1) * Vector(0, 5, 1)), 
            Vector(0,-5,-1):Angle(), fov, 0,0, rtx,rty, 1, 100)
        cam.StartOrthoView(bx1,by1,bx2,by2)
    end

    local function rgbrt(n)
        return GetRenderTargetEx(matname(mdl,n), rtx,rty, RT_SIZE_DEFAULT, MATERIAL_RT_DEPTH_NONE, 2, 0, IMAGE_FORMAT_RGB888)
    end

    local function localrgbrt(n)
        return GetRenderTargetEx(matname(mdl,n), rtx,rty, RT_SIZE_DEFAULT, MATERIAL_RT_DEPTH_NONE, 2, 0, IMAGE_FORMAT_RGB888)
    end

    local function drawtexture(tex,col,x,y)
        if isnumber(col) then
            col,x,y = nil,col,x
        end
        col,x,y = col or Vector(1,1,1),x or 0,y or 0
        SWEPUNLITMATERIAL:SetMatrix("$basetexturetransform",Matrix({{1, 0, 0, x/rtx}, {0, 1, 0, y/rty}, {0, 0, 1, 0}, {0, 0, 0, 1}}))
        SWEPUNLITMATERIAL:SetTexture("$basetexture", tex)
        SWEPUNLITMATERIAL:SetTexture("$color2", col)
        render.DrawScreenQuad()
    end

    local temprt = rgbrt("T")

    local mask1 = GetRenderTargetEx(matname(mdl,"A"), rtx,rty, RT_SIZE_DEFAULT, MATERIAL_RT_DEPTH_SEPARATE, 2, 0, IMAGE_FORMAT_RGB888)
    
    render.PushRenderTarget(mask1)
    render.Clear(0,0,0,0,true,true)
    if true then
        startcam() 
        render.SuppressEngineLighting(true)
        render.MaterialOverride(SWEPCOLORMATERIAL)
        render.SetColorModulation(1,1,1)

        render.DepthRange(0,1)
        WEAPON_SELECT_ENT:DrawModel()

        render.MaterialOverride()
        render.SuppressEngineLighting(false)   

        cam.EndOrthoView()
        cam.End3D()
    end

    render.CapturePixels()

    local px1,py1,px2,py2,area = getbbox()
    local pad = 0.01
    px1,py1,px2,py2=px1-pad,py1-pad,px2+pad,py2+pad

    local hw,hh = (px2-px1)/2,(py2-py1)/2
    local cx,cy = (px2+px1)/2,(py2+py1)/2
    local realhh = hh
    if hw>hh then
        hh = hw
    else
        hw = hh
    end

    local weaponselect_max_height = 0.6
    if realhh/hh > weaponselect_max_height then
        hw = hw * (realhh/hh)/weaponselect_max_height
        hh = hh * (realhh/hh)/weaponselect_max_height
    end

    -- local weaponselect_max_area = 0.5

    -- built in lerp is clamped
    local function lerp(t,x,y)
        return (1-t)*x + t*y
    end

    bx1,by1,bx2,by2 = lerp(cx-hw,-rad,rad),lerp(cy-hh,rad,-rad),lerp(cx+hw,-rad,rad),lerp(cy+hh,rad,-rad)

    render.Clear(0,0,0,0,true,true)
    if true then
        startcam() 
        render.SuppressEngineLighting(true)
        render.MaterialOverride(SWEPCOLORMATERIAL)
        render.SetColorModulation(1,1,1)

        render.DepthRange(0,1)
        WEAPON_SELECT_ENT:DrawModel()

        render.MaterialOverride()
        render.SuppressEngineLighting(false)   

        cam.EndOrthoView()
        cam.End3D()
    end
    
    render.PopRenderTarget()
    


    local colrt = GetRenderTargetEx(matname(mdl,"C"), rtx,rty, RT_SIZE_DEFAULT, MATERIAL_RT_DEPTH_SEPARATE, 2, 0, IMAGE_FORMAT_RGB888)
    render.PushRenderTarget(colrt)
    render.Clear(0,0,0,0,true,true)
    if true then
        startcam() 
        render.SuppressEngineLighting(true)
        render.SetColorModulation(1,1,1)

        render.DepthRange(0,1)
        WEAPON_SELECT_ENT:DrawModel()

        render.MaterialOverride()
        render.SuppressEngineLighting(false)   

        cam.EndOrthoView()
        cam.End3D()
        render.BlurRenderTarget(colrt, 1/rtx, 1/rty, 1)
    end
    render.PopRenderTarget()

    


    local function bf_sub() 
        render.OverrideBlend( true, BLEND_ONE, BLEND_ONE, BLENDFUNC_REVERSE_SUBTRACT, BLEND_ZERO, BLEND_ONE, BLENDFUNC_ADD ) 
    end
    local function bf_suba() 
        render.OverrideBlend( true, BLEND_DST_ALPHA, BLEND_ONE, BLENDFUNC_REVERSE_SUBTRACT, BLEND_ZERO, BLEND_ONE, BLENDFUNC_ADD ) 
    end
    local function bf_add() 
        render.OverrideBlend( true, BLEND_ONE, BLEND_ONE, BLENDFUNC_ADD, BLEND_ZERO, BLEND_ONE, BLENDFUNC_ADD ) 
    end
    local function bf_adda() 
        render.OverrideBlend( true, BLEND_DST_ALPHA, BLEND_ONE, BLENDFUNC_ADD, BLEND_ZERO, BLEND_ONE, BLENDFUNC_ADD ) 
    end
    local function bf_alpha() 
        render.OverrideBlend( true, BLEND_ZERO, BLEND_ONE, BLENDFUNC_ADD, BLEND_ONE, BLEND_ONE, BLENDFUNC_ADD ) 
    end


    local coledgert = GetRenderTargetEx(matname(mdl,"CE"), rtx,rty, RT_SIZE_DEFAULT, MATERIAL_RT_DEPTH_NONE, 2, 0, IMAGE_FORMAT_RGBA8888)
    render.PushRenderTarget(coledgert)
    render.Clear(0,0,0,255/10) --,true,true) -_WHAT
    if true then
        cam.Start2D()
        render.OverrideAlphaWriteEnable(true, false)
        local function shift(x,y, skip)
            SWEPUNLITMATERIAL:SetMatrix("$basetexturetransform",Matrix({{1, 0, 0, x/rtx}, {0, 1, 0, y/rty}, {0, 0, 1, 0}, {0, 0, 0, 1}}))
            if not skip then render.DrawScreenQuad() end
        end
        render.SetMaterial(SWEPUNLITMATERIAL)
        
        local s = 3

        -- outline from color
        SWEPUNLITMATERIAL:SetTexture("$basetexture", colrt)
        bf_add() shift(0,0)
        bf_sub() shift(s,s)
        bf_add() shift(0,0)
        bf_sub() shift(s,-s)
        bf_add() shift(0,0)
        bf_sub() shift(-s,-s)
        bf_add() shift(0,0)
        bf_sub() shift(-s,s)

        bf_add() shift(0,0)
        bf_sub() shift(s,0)
        bf_add() shift(0,0)
        bf_sub() shift(-s,0)
        bf_add() shift(0,0)
        bf_sub() shift(0,s)
        bf_add() shift(0,0)
        bf_sub() shift(0,-s)

        s = 3
        -- outline from mask
        SWEPUNLITMATERIAL:SetTexture("$basetexture", mask1)
        bf_adda() shift(0,0)
        bf_suba() shift(s,s)
        bf_adda() shift(0,0)
        bf_suba() shift(s,-s)
        bf_adda() shift(0,0)
        bf_suba() shift(-s,-s)
        bf_adda() shift(0,0)
        bf_suba() shift(-s,s)
        shift(0,0,true)

        --TODO: outline from depth buffer difference?

        -- bf_alpha()
        -- render.DrawScreenQuad()


        render.OverrideBlend( false)
        cam.End2D() 
    end
    render.PopRenderTarget()




    

    


    local edgert = GetRenderTargetEx(matname(mdl,"CE2"), rtx,rty, RT_SIZE_DEFAULT, MATERIAL_RT_DEPTH_NONE, 2, 0, IMAGE_FORMAT_RGB888)
    local bluredgert = rgbrt("BE")
    render.PushRenderTarget(edgert)
    render.Clear(0,0,0,0,true,true)
    cam.Start2D()
    SWEPRANGEADJUSTMATERIAL:SetTexture("$fbtexture", coledgert)
    render.SetMaterial(SWEPRANGEADJUSTMATERIAL)
    render.DrawScreenQuad()
    cam.End2D() 
    render.CopyRenderTargetToTexture(bluredgert)
    render.BlurRenderTarget(bluredgert, 20, 20, 1)
    render.PopRenderTarget()


    -- turn mask1 into the lines
    render.PushRenderTarget(mask1)
    render.BlurRenderTarget(mask1, 20, 20, 1)


    local abluredgert = rgbrt("ABE")
    render.PushRenderTarget(abluredgert)
    -- render.OverrideBlend(true, BLEND_ONE, BLEND_ONE, BLENDFUNC_ADD, BLEND_ONE, BLEND_ONE, BLENDFUNC_ADD ) 
    SWEPUNLITMATERIAL:SetTexture("$basetexture", bluredgert)
    SWEPUNLITMATERIAL:SetVector("$color2", Vector(10,10,10))
    render.SetMaterial(SWEPUNLITMATERIAL)
    render.DrawScreenQuad() 
    SWEPUNLITMATERIAL:SetVector("$color2", Vector(1,1,1))
    render.PopRenderTarget()

    


    -- 

    cam.Start2D()
    if true then
        local lines = 35
        local stp = math.floor(rty/lines)
        for y=0,rty,stp do
            surface.SetDrawColor(0,0,0,180)
            surface.DrawRect(0,y,rtx,stp - 1)
        end
        -- render.BlurRenderTarget(mask1, 1, 1, 1)

        surface.SetDrawColor(0,0,0,180)
        surface.DrawRect(0,0,rtx,rty)

        SWEPUNLITMATERIAL:SetTexture("$basetexture", edgert)
        render.SetMaterial(SWEPUNLITMATERIAL)
        render.OverrideBlend(true, BLEND_ONE, BLEND_ONE, BLENDFUNC_ADD, BLEND_ONE, BLEND_ONE, BLENDFUNC_ADD ) 
        render.DrawScreenQuad() 

        SWEPUNLITMATERIAL:SetTexture("$basetexture", "lights/white")
        -- SWEPUNLITMATERIAL:SetVector("$color2", Vector(1,0.8667,0))
        SWEPUNLITMATERIAL:SetVector("$color2", Vector(1,0.95,0.05))
        render.OverrideBlend(true, BLEND_DST_COLOR, BLEND_ZERO, BLENDFUNC_ADD, BLEND_ONE, BLEND_ONE, BLENDFUNC_ADD ) 
        render.DrawScreenQuad() 
        SWEPUNLITMATERIAL:SetVector("$color2", Vector(1,1,1))

        
    end
    cam.End2D() 
    render.PopRenderTarget()



    -- local finalrt = GetRenderTargetEx(matname(mdl,"FF"), rtx,rty, RT_SIZE_DEFAULT, MATERIAL_RT_DEPTH_NONE, 2, 0, IMAGE_FORMAT_RGBA8888)
    -- render.PushRenderTarget(finalrt)
    -- render.Clear(255,221,0,25)
    -- if true then
    --     cam.Start2D()
    --     SWEPUNLITMATERIAL:SetTexture("$basetexture", mask1)
    --     render.SetMaterial(SWEPUNLITMATERIAL)
    --     -- render.OverrideBlend( true, BLEND_ZERO, BLEND_ONE, BLENDFUNC_ADD, BLEND_SRC_COLOR, BLEND_ONE, BLENDFUNC_ADD ) 
    --     render.DrawScreenQuad() 

    --     render.OverrideBlend( false)
    --     cam.End2D() 
    -- end
    -- render.PopRenderTarget()
    -- local mask2 = GetRenderTargetEx(matname(mdl,"B"), rtx,rty, RT_SIZE_DEFAULT, MATERIAL_RT_DEPTH_SEPARATE, 2, 0, IMAGE_FORMAT_RGB888)
    -- render.PushRenderTarget(rt2)
    -- render.Clear(0,0,0,0,true,true)
    -- -- render.SetViewPort( 0, 0, rtx,rty )
    -- -- cam.Start2D()
	-- SHARPENMATERIAL:SetFloat( "$distance", 0.2/rtx )
    -- SHARPENMATERIAL:SetFloat( "$contrast", 10 )
    -- SHARPENMATERIAL:SetTexture("$fbtexture", rt1)
    -- -- SHARPENMATERIAL:SetTexture("$basetexture", rt1)
	-- render.SetMaterial( SHARPENMATERIAL )
	-- render.DrawScreenQuad()
    -- -- surface.SetDrawColor( 255, 255, 255, 255 )
    -- -- surface.SetMaterial( SHARPENMATERIAL )
    -- -- surface.DrawTexturedRect(0,0,rtx,rty)
    -- -- cam.End2D()
    -- render.PopRenderTarget()

    local m =CreateMaterial(matname(mdl,"Z"), "UnlitGeneric", {
        ["$basetexture"] = "lights/white",
        ["$additive"] = 1, 
        -- ["$model"] = 1,
        -- ["$translucent"] = 1,
        -- ["$alpha"] = 1,
        -- ["$vertexalpha"] = 1,
        -- ["$vertexcolor"] = 1
    } )
    m:SetTexture("$basetexture", mask1)


    render.OverrideBlend(false)
    return m
end
hook.Add( "RenderScreenspaceEffects", "SobelShader", function()

	-- DrawSobel( 0.01 )

    -- DrawSharpen( 10, 1 )

    -- DrawToyTown(2, ScrH() / 2)
    if LocalPlayer():GetActiveWeapon() and LocalPlayer():GetActiveWeapon().DrawWeaponSelection then LocalPlayer():GetActiveWeapon():DrawWeaponSelection(0,0,512,512,1) end

end )


function ALTDRAWWEAPONSELECTION(self, x, y, wide, tall, alpha)
    y = y + 40
    tall = tall - 40

    -- surface.SetDrawColor( 255, 255, 255, 255 )
    -- surface.SetMaterial(GetWeaponIcon(self:GetModel()))
    -- surface.SetAlphaMultiplier(1)
    -- surface.DrawTexturedRect(x+(wide-rtx)*0.5,y+(tall-rty)*0.5,rtx,rty)

    cam.Start2D()
    render.SetMaterial(GetWeaponIcon(self:GetModel()))
    local ortx,orty = rtx/2,rty/2
    render.DrawScreenQuadEx(x+(wide-ortx)*0.5,y+(tall-orty)*0.5,ortx,orty)
    cam.End2D() 
end
 

timer.Simple(0, function()
BASEDRAWWEAPONSELECTION = BASEDRAWWEAPONSELECTION or weapons.GetStored("weapon_base").DrawWeaponSelection
weapons.GetStored("weapon_base").DrawWeaponSelection = function(self, x, y, wide, tall, alpha)
    if self.WorldModel=="" then return BASEDRAWWEAPONSELECTION(self, x, y, wide, tall, alpha) end
    ALTDRAWWEAPONSELECTION(self, x, y, wide, tall, alpha)
end
end)

