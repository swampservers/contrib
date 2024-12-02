﻿-- This file is subject to copyright - contact swampservers@gmail.com for more information.
--[[hook.Add("PostDrawOpaqueRenderables","SnowAdder",function()
    --timer.Simple(1, function() RunConsoleCommand('snow') end)
    hook.Remove("PostDrawOpaqueRenderables","SnowAdder")
end)]]
local materials = {}

local function GetAndBackupMaterial(matname)
    local mat = Material(matname)

    if mat then
        materials[matname] = materials[matname] or {}

        if not materials[matname]["$basetexture"] then
            materials[matname]["$basetexture"] = mat:GetTexture("$basetexture"):GetName()
        end

        if not materials[matname]["$basetexture2"] then
            local tex2 = mat:GetTexture("$basetexture2")

            if tex2 then
                materials[matname]["$basetexture2"] = tex2:GetName()
            end
        end
    end

    return mat
end

function UndoSnow()
    for matname, textures in pairs(materials) do
        local mat = Material(matname)

        if mat then
            for texkey, texval in pairs(textures) do
                mat:SetTexture(texkey, texval)
            end
        end
    end
end

concommand.Add("undosnow", UndoSnow)

function AddSnow()
    GetAndBackupMaterial("swamponions/ground/concretefloor016a"):SetTexture("$basetexture", "nature/snowfloor001a")
    GetAndBackupMaterial("swamp_minigolf/golf_concretefloor016a"):SetTexture("$basetexture", "nature/snowfloor001a")
    GetAndBackupMaterial("CONCRETE/CONCRETEFLOOR023A"):SetTexture("$basetexture", "nature/snowfloor001a")
    GetAndBackupMaterial("swamponions/ground/blendgravelconcrete"):SetTexture("$basetexture", "nature/snowfloor002a")
    GetAndBackupMaterial("swamponions/ground/blendgravelconcrete"):SetTexture("$basetexture2", "nature/snowfloor001a")
    GetAndBackupMaterial("SWAMPONIONS/GROUND/CONCRETEFLOOR023A"):SetTexture("$basetexture", "nature/snowfloor001a")
    GetAndBackupMaterial("BRICK/BRICKFLOOR001A"):SetTexture("$basetexture", "nature/snowfloor001a")
    GetAndBackupMaterial("SWAMPONIONS/GROUND/CONCRETEFLOOR005A"):SetTexture("$basetexture", "nature/snowfloor001a")
    GetAndBackupMaterial("SWAMPONIONS/GROUND/RADIALTILE1"):SetTexture("$basetexture", "nature/snowfloor002a")
    GetAndBackupMaterial("maps/cinema_swamp_v2/metal/metalroof006a_-512_4608_512"):SetTexture("$basetexture", "nature/snowfloor002a")
    GetAndBackupMaterial("CONCRETE/CONCRETEFLOOR001A"):SetTexture("$basetexture", "nature/snowfloor001a")
    GetAndBackupMaterial("SWAMPONIONS/STONE/CONCRETERING"):SetTexture("$basetexture", "nature/snowfloor001a")
    --GetAndBackupMaterial("CONCRETE/CONCRETEFLOOR011A"):SetTexture("$basetexture","nature/snowfloor001a")
    GetAndBackupMaterial("CONCRETE/CONCRETEWALL040D"):SetTexture("$basetexture", "nature/snowfloor001a")
    GetAndBackupMaterial("wood/woodshingles002a"):SetTexture("$basetexture", "nature/snowfloor001a")
    GetAndBackupMaterial("CONCRETE/CONCRETEFLOOR012A"):SetTexture("$basetexture", "nature/snowfloor001a")
    GetAndBackupMaterial("CONCRETE/CONCRETEWALL032A"):SetTexture("$basetexture", "nature/snowfloor002a")
    GetAndBackupMaterial("metal/metalroof006a"):SetTexture("$basetexture", "nature/snowfloor002a")
    GetAndBackupMaterial("maps/" .. game.GetMap() .. "/metal/metalroof006a_2584_2300_-671"):SetTexture("$basetexture", "nature/snowfloor002a")
    GetAndBackupMaterial("maps/" .. game.GetMap() .. "/metal/metalroof006a_-10240_-2904_-6528"):SetTexture("$basetexture", "nature/snowfloor002a")
    GetAndBackupMaterial("ALTS/POWERP/CONROOF001"):SetTexture("$basetexture", "nature/snowfloor002a")
    GetAndBackupMaterial("PROPS/RUBBERROOF001A"):SetTexture("$basetexture", "nature/snowfloor002a")
    GetAndBackupMaterial("building_template/building_template028a"):SetTexture("$basetexture", "nature/snowfloor002a")
    GetAndBackupMaterial("CONCRETE/CONCRETEFLOOR009A"):SetTexture("$basetexture", "nature/snowfloor001a")
    GetAndBackupMaterial("NATURE/GRAVELFLOOR001A"):SetTexture("$basetexture", "nature/snowfloor001a")
    GetAndBackupMaterial("nature/gravelfloor002a"):SetTexture("$basetexture", "nature/snowfloor001a")
    GetAndBackupMaterial("SWAMPONIONS/GROUND/CONCRETETILE"):SetTexture("$basetexture", "nature/snowfloor001a")
    GetAndBackupMaterial("SWAMPONIONS/STONE/SMOOTHCONCRETE"):SetTexture("$basetexture", "nature/snowfloor001a")
    GetAndBackupMaterial("SWAMPONIONS/GROUND/CONCRETEFLOOR023A_TINT1"):SetTexture("$basetexture", "nature/snowfloor001a")
    GetAndBackupMaterial("SWAMPONIONS/GROUND/STAGGERED_CONCRETE2"):SetTexture("$basetexture", "nature/snowfloor002a")
    GetAndBackupMaterial("concrete/concretefloor039a"):SetTexture("$basetexture", "nature/snowfloor002a")
    --GetAndBackupMaterial("swamponions/ground/dirtgrass1"):SetTexture("$basetexture", "nature/snowfloor003a")
    --GetAndBackupMaterial("swamponions/ground/dirtgrass1"):SetTexture("$basetexture2", "nature/snowfloor002a")
    GetAndBackupMaterial("swamponions/ground/dirtgrass_skybox"):SetTexture("$basetexture", "nature/snowfloor003a")
    GetAndBackupMaterial("swamponions/ground/dirtgrass_skybox"):SetTexture("$basetexture2", "nature/snowfloor002a")
    GetAndBackupMaterial("nature/blendgrassgravel001b"):SetTexture("$basetexture", "nature/snowfloor002a")
    GetAndBackupMaterial("nature/blendgrassgravel001b"):SetTexture("$basetexture2", "nature/snowfloor001a")
    GetAndBackupMaterial("nature/blendgrassgravel002a"):SetTexture("$basetexture", "nature/snowfloor001a")
    GetAndBackupMaterial("nature/blendgrassgravel002a"):SetTexture("$basetexture2", "nature/snowfloor002a")
    GetAndBackupMaterial("nature/blendsandsand008a"):SetTexture("$basetexture", "nature/snowfloor003a")
    GetAndBackupMaterial("nature/blendsandsand008a"):SetTexture("$basetexture2", "nature/snowfloor002a")
    GetAndBackupMaterial("swamp_minigolf/golf_blendsandsand008a"):SetTexture("$basetexture", "nature/snowfloor003a")
    GetAndBackupMaterial("swamp_minigolf/golf_blendsandsand008a"):SetTexture("$basetexture2", "nature/snowfloor002a")
    GetAndBackupMaterial("nature/blendrocksand004a"):SetTexture("$basetexture", "nature/snowfloor002a")
    GetAndBackupMaterial("nature/blendrocksand004a"):SetTexture("$basetexture2", "nature/snowfloor003a")
    GetAndBackupMaterial("swamponions/ground/grass_brush"):SetTexture("$basetexture", "nature/snowfloor002a")
    --GetAndBackupMaterial("swamp_minigolf/golf_grass_brush"):SetTexture("$basetexture", "nature/snowfloor002a")
    GetAndBackupMaterial("swamponions/ground/grass_dirt"):SetTexture("$basetexture", "nature/snowfloor002a")
    GetAndBackupMaterial("swamponions/ground/grass_dirt"):SetTexture("$basetexture2", "nature/snowfloor001a")
    GetAndBackupMaterial("swamponions/ground/grass_muck"):SetTexture("$basetexture", "nature/snowfloor002a")
    GetAndBackupMaterial("swamponions/ground/grass_muck"):SetTexture("$basetexture2", "nature/snowfloor001a")
    GetAndBackupMaterial("swamponions/ground/grass_nicegrass"):SetTexture("$basetexture", "nature/snowfloor002a")
    GetAndBackupMaterial("swamponions/ground/grass_nicegrass"):SetTexture("$basetexture2", "nature/snowfloor001a")
    GetAndBackupMaterial("swamponions/ground/concretefloor023a_tint1_weedy"):SetTexture("$basetexture", "nature/snowfloor002a")
    GetAndBackupMaterial("dojo/shingles"):SetTexture("$basetexture", "nature/snowfloor002a")
    GetAndBackupMaterial("concrete/concretefloor038c"):SetTexture("$basetexture", "nature/snowfloor002a")
    GetAndBackupMaterial("maps/" .. game.GetMap() .. "/concrete/concretefloor038c_2584_2300_-671"):SetTexture("$basetexture", "nature/snowfloor002a")
    --golf border
    GetAndBackupMaterial("METAL/METALFLOOR007A"):SetTexture("$basetexture", "nature/snowfloor001a")
    --the pit
    GetAndBackupMaterial("SWAMPONIONS/GROUND/blendtoxictoxic002a"):SetTexture("$basetexture", "nature/snowfloor002a")
    GetAndBackupMaterial("SWAMPONIONS/GROUND/blendtoxictoxic002a"):SetTexture("$basetexture2", "nature/snowfloor003a")
    --water
    -- GetAndBackupMaterial("swamponions/water_swamp"):SetTexture("$basetexture", "lights/white")
    -- GetAndBackupMaterial("swamponions/water_swamp"):SetVector("$color", Vector(0.6, 0.6, 0.7))
    -- GetAndBackupMaterial("swamponions/water_swamp"):SetVector("$envmaptint", Vector(0.1, 0.1, 0.1))
    -- GetAndBackupMaterial("SWAMPONIONS/WATER_SWAMP_SOLID"):SetTexture("$basetexture", "lights/white")
    -- GetAndBackupMaterial("SWAMPONIONS/WATER_SWAMP_SOLID"):SetVector("$color", Vector(0.6, 0.6, 0.7))
    -- GetAndBackupMaterial("SWAMPONIONS/WATER_SWAMP_SOLID"):SetVector("$envmaptint", Vector(0.1, 0.1, 0.1))
    -- GetAndBackupMaterial("SWAMPONIONS/water_swamp_liquid"):SetTexture("$basetexture", "lights/white")
    -- GetAndBackupMaterial("SWAMPONIONS/water_swamp_liquid"):SetVector("$color", Vector(0.6, 0.6, 0.7))
    -- GetAndBackupMaterial("SWAMPONIONS/water_swamp_liquid"):SetVector("$envmaptint", Vector(0.1, 0.1, 0.1))
end

concommand.Add("snow", AddSnow)

if os.date("%b") == "Dec" then
    hook.Add("InitPostEntity", "AddSnow", function()
        if file.Exists("dontsnow.txt", "DATA") then return end

        timer.Simple(3, function()
            file.Write("dontsnow.txt", "")
            AddSnow()

            timer.Simple(3, function()
                file.Delete("dontsnow.txt")
            end)
        end)
    end)
end

--[[
    Material("swamponions/ground/concretefloor016a"):SetString("$surfaceprop","snow")
    Material("CONCRETE/CONCRETEFLOOR023A"):SetString("$surfaceprop","snow")
    Material("SWAMPONIONS/GROUND/CONCRETEFLOOR023A"):SetString("$surfaceprop","snow")
    Material("BRICK/BRICKFLOOR001A"):SetString("$surfaceprop","snow")
    Material("SWAMPONIONS/GROUND/CONCRETEFLOOR005A"):SetString("$surfaceprop","snow")
    --Material("swamponions/ground/dirtgrass1"):SetString("$surfaceprop","snow")
    --Material("swamponions/ground/dirtgrass1"):SetString("$surfaceprop2","snow")
    Material("SWAMPONIONS/GROUND/RADIALTILE1"):SetString("$surfaceprop","snow")
    --Material("SWAMPONIONS/GROUND/blendtoxictoxic002a"):SetString("$surfaceprop2","snow")
    Material("maps/cinema_swamp_v2/metal/metalroof006a_-512_4608_512"):SetString("$surfaceprop","snow")
    Material("NATURE/GRAVELFLOOR001A"):SetString("$surfaceprop","snow")
    Material("CONCRETE/CONCRETEFLOOR001A"):SetString("$surfaceprop","snow")
    Material("SWAMPONIONS/STONE/CONCRETERING"):SetString("$surfaceprop","snow")
    Material("CONCRETE/CONCRETEFLOOR011A"):SetString("$surfaceprop","snow")
    ]]
--[[concommand.Add("mattrace", function()
    tr = Me:GetEyeTrace()

    if tr.HitTexture then
        PrintTable(tr)
        chat.AddText(tr.HitTexture)
        SetClipboardText(tr.HitTexture)
    end
end)
]]
concommand.Add("shine", function()
    local surfs = game.GetWorld():GetBrushSurfaces()
    local mats = {}

    for i, surf in ipairs(surfs) do
        local mat = surf:GetMaterial()
        if mat:GetShader():lower() ~= "lightmappedgeneric" then continue end
        if mats[mat:GetName()] then continue end
        mats[mat:GetName()] = mat
        print(mat:GetName())
        -- local mat = Material( ("swamponions/carpet/rhallcarpet"):upper() )
        -- mat = Material( "models/swamponions/joker_statue/shirt")
        -- mat:SetInt("$phong", 1)
        -- mat:SetFloat("$phongexponent", 10)
        -- mat:SetFloat("$phongboost", 100)
        -- mat:SetVector("$phongfresnelranges", Vector(0,0.5,1))
        -- mat:SetTexture("$basetexture", "dev/reflectivity_90b") --swamponions/carpet/squares")
        -- "hlmv/cubemap"
        mat:SetTexture("$envmap", "environment maps/d1_trainstation_05") --"swamponions/cm_d")
        mat:SetTexture("$bumpmap", "dev/flat_normal")
        -- 0 is fresnel 1 is no fresnel
        mat:SetFloat("$fresnelreflection", 0.1)
        mat:SetFloat("$envmaplightscale", 10)
        mat:SetFloat("$envmapsaturation", 0)
        -- mat:SetVector("$envmaptint", Vector(1,1,1)*0.2) --0.2)
        mat:Recompute()
    end

    print("OK", table.Count(mats)) --,mat:GetTexture("$basetexture"))

    hook.Add("Think", "reflectivity", function()
        if IsValid(Me) then
            local l = render.ComputeLighting(Me:GetPos() + Vector(0, 0, 8), Vector(0, 0, 1))
            local i = math.min(1, (l.x + l.y + l.z) / 3)
            i = math.sqrt(i)
            print(i)

            for k, mat in pairs(mats) do
                mat:SetVector("$envmaptint", Vector(1, 1, 1) * 0.2 * i)
            end
        end
    end)
end)
-- $bumpmap				[texture]
-- $phongexponent			5			// either/or
-- $phongexponenttexture	[texture]	// either/or
-- $phongboost				1.0
-- $phongfresnelranges		"[0 0.5 1]"
