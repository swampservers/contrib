-- This file is subject to copyright - contact swampservers@gmail.com for more information.
--[[hook.Add("PostDrawOpaqueRenderables","SnowAdder",function()
    --timer.Simple(1, function() RunConsoleCommand('snow') end)
    hook.Remove("PostDrawOpaqueRenderables","SnowAdder")
end)]]
function AddSnow()
    Material("swamponions/ground/concretefloor016a"):SetTexture("$basetexture", "nature/snowfloor001a")
    Material("CONCRETE/CONCRETEFLOOR023A"):SetTexture("$basetexture", "nature/snowfloor001a")
    Material("SWAMPONIONS/GROUND/CONCRETEFLOOR023A"):SetTexture("$basetexture", "nature/snowfloor001a")
    Material("BRICK/BRICKFLOOR001A"):SetTexture("$basetexture", "nature/snowfloor001a")
    Material("SWAMPONIONS/GROUND/CONCRETEFLOOR005A"):SetTexture("$basetexture", "nature/snowfloor001a")
    Material("SWAMPONIONS/GROUND/RADIALTILE1"):SetTexture("$basetexture", "nature/snowfloor002a")
    Material("maps/cinema_swamp_v2/metal/metalroof006a_-512_4608_512"):SetTexture("$basetexture", "nature/snowfloor002a")
    Material("CONCRETE/CONCRETEFLOOR001A"):SetTexture("$basetexture", "nature/snowfloor001a")
    Material("SWAMPONIONS/STONE/CONCRETERING"):SetTexture("$basetexture", "nature/snowfloor001a")
    --Material("CONCRETE/CONCRETEFLOOR011A"):SetTexture("$basetexture","nature/snowfloor001a")
    Material("CONCRETE/CONCRETEWALL040D"):SetTexture("$basetexture", "nature/snowfloor001a")
    Material("wood/woodshingles002a"):SetTexture("$basetexture", "nature/snowfloor001a")
    Material("CONCRETE/CONCRETEFLOOR012A"):SetTexture("$basetexture", "nature/snowfloor001a")
    Material("CONCRETE/CONCRETEWALL032A"):SetTexture("$basetexture", "nature/snowfloor002a")
    Material("METAL/METALROOF006A"):SetTexture("$basetexture", "nature/snowfloor002a")
    Material("ALTS/POWERP/CONROOF001"):SetTexture("$basetexture", "nature/snowfloor002a")
    Material("PROPS/RUBBERROOF001A"):SetTexture("$basetexture", "nature/snowfloor002a")
    Material("CONCRETE/CONCRETEFLOOR009A"):SetTexture("$basetexture", "nature/snowfloor001a")
    Material("NATURE/GRAVELFLOOR001A"):SetTexture("$basetexture", "nature/snowfloor001a")
    Material("nature/gravelfloor002a"):SetTexture("$basetexture", "nature/snowfloor001a")
    Material("SWAMPONIONS/GROUND/CONCRETETILE"):SetTexture("$basetexture", "nature/snowfloor001a")
    Material("SWAMPONIONS/STONE/SMOOTHCONCRETE"):SetTexture("$basetexture", "nature/snowfloor001a")
    Material("SWAMPONIONS/GROUND/CONCRETEFLOOR023A_TINT1"):SetTexture("$basetexture", "nature/snowfloor001a")
    Material("SWAMPONIONS/GROUND/STAGGERED_CONCRETE2"):SetTexture("$basetexture", "nature/snowfloor002a")
    Material("concrete/concretefloor039a"):SetTexture("$basetexture", "nature/snowfloor002a")
    Material("maps/cinema_swamp_v3/concrete/concretefloor039a_-5632_1536_576"):SetTexture("$basetexture", "nature/snowfloor002a")
    Material("swamponions/ground/dirtgrass1"):SetTexture("$basetexture", "nature/snowfloor003a")
    Material("swamponions/ground/dirtgrass1"):SetTexture("$basetexture2", "nature/snowfloor002a")
    Material("swamponions/ground/dirtgrass_skybox"):SetTexture("$basetexture", "nature/snowfloor003a")
    Material("swamponions/ground/dirtgrass_skybox"):SetTexture("$basetexture2", "nature/snowfloor002a")
    Material("nature/blendgrassgravel001b"):SetTexture("$basetexture", "nature/snowfloor002a")
    Material("nature/blendgrassgravel001b"):SetTexture("$basetexture2", "nature/snowfloor001a")
    Material("swamponions/ground/grass_dirt"):SetTexture("$basetexture", "nature/snowfloor002a")
    Material("swamponions/ground/grass_dirt"):SetTexture("$basetexture2", "nature/snowfloor001a")
    Material("swamponions/ground/grass_muck"):SetTexture("$basetexture", "nature/snowfloor002a")
    Material("swamponions/ground/grass_muck"):SetTexture("$basetexture2", "nature/snowfloor001a")
    Material("swamponions/ground/grass_nicegrass"):SetTexture("$basetexture", "nature/snowfloor002a")
    Material("swamponions/ground/grass_nicegrass"):SetTexture("$basetexture2", "nature/snowfloor001a")
    Material("swamponions/ground/concretefloor023a_tint1_weedy"):SetTexture("$basetexture", "nature/snowfloor002a")
    Material("dojo/shingles"):SetTexture("$basetexture", "nature/snowfloor002a")
    Material("concrete/concretefloor038c"):SetTexture("$basetexture", "nature/snowfloor002a")
    Material("concrete/concretefloor038c"):SetTexture("$basetexture2", "nature/snowfloor001a")
    --golf border
    Material("METAL/METALFLOOR007A"):SetTexture("$basetexture", "nature/snowfloor001a")
    --the pit
    Material("SWAMPONIONS/GROUND/blendtoxictoxic002a"):SetTexture("$basetexture", "nature/snowfloor002a")
    Material("SWAMPONIONS/GROUND/blendtoxictoxic002a"):SetTexture("$basetexture2", "nature/snowfloor003a")
    --water
    -- Material("swamponions/water_swamp"):SetTexture("$basetexture", "lights/white")
    -- Material("swamponions/water_swamp"):SetVector("$color", Vector(0.6, 0.6, 0.7))
    -- Material("swamponions/water_swamp"):SetVector("$envmaptint", Vector(0.1, 0.1, 0.1))
    -- Material("SWAMPONIONS/WATER_SWAMP_SOLID"):SetTexture("$basetexture", "lights/white")
    -- Material("SWAMPONIONS/WATER_SWAMP_SOLID"):SetVector("$color", Vector(0.6, 0.6, 0.7))
    -- Material("SWAMPONIONS/WATER_SWAMP_SOLID"):SetVector("$envmaptint", Vector(0.1, 0.1, 0.1))
    -- Material("SWAMPONIONS/water_swamp_liquid"):SetTexture("$basetexture", "lights/white")
    -- Material("SWAMPONIONS/water_swamp_liquid"):SetVector("$color", Vector(0.6, 0.6, 0.7))
    -- Material("SWAMPONIONS/water_swamp_liquid"):SetVector("$envmaptint", Vector(0.1, 0.1, 0.1))
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
