-- This file is subject to copyright - contact swampservers@gmail.com for more information.

/*hook.Add("PostDrawOpaqueRenderables","SnowAdder",function()
    --timer.Simple(1, function() RunConsoleCommand('snow') end)
    hook.Remove("PostDrawOpaqueRenderables","SnowAdder")
end)*/

concommand.Add("snow", function()
    Material("swamponions/ground/concretefloor016a"):SetTexture("$basetexture","nature/snowfloor001a")
    Material("CONCRETE/CONCRETEFLOOR023A"):SetTexture("$basetexture","nature/snowfloor001a")
    Material("SWAMPONIONS/GROUND/CONCRETEFLOOR023A"):SetTexture("$basetexture","nature/snowfloor001a")
    Material("BRICK/BRICKFLOOR001A"):SetTexture("$basetexture","nature/snowfloor001a")
    Material("SWAMPONIONS/GROUND/CONCRETEFLOOR005A"):SetTexture("$basetexture","nature/snowfloor001a")
    Material("SWAMPONIONS/GROUND/RADIALTILE1"):SetTexture("$basetexture","nature/snowfloor002a")
    Material("maps/cinema_swamp_v2/metal/metalroof006a_-512_4608_512"):SetTexture("$basetexture","nature/snowfloor002a")
    Material("CONCRETE/CONCRETEFLOOR001A"):SetTexture("$basetexture","nature/snowfloor001a")
    Material("SWAMPONIONS/STONE/CONCRETERING"):SetTexture("$basetexture","nature/snowfloor001a")
    --Material("CONCRETE/CONCRETEFLOOR011A"):SetTexture("$basetexture","nature/snowfloor001a")
    Material("CONCRETE/CONCRETEWALL040D"):SetTexture("$basetexture","nature/snowfloor001a")
    Material("wood/woodshingles002a"):SetTexture("$basetexture","nature/snowfloor001a")

    Material("CONCRETE/CONCRETEFLOOR012A"):SetTexture("$basetexture","nature/snowfloor001a")
    Material("CONCRETE/CONCRETEWALL032A"):SetTexture("$basetexture","nature/snowfloor002a")
    Material("METAL/METALROOF006A"):SetTexture("$basetexture","nature/snowfloor002a")
    Material("ALTS/POWERP/CONROOF001"):SetTexture("$basetexture","nature/snowfloor002a")
    Material("PROPS/RUBBERROOF001A"):SetTexture("$basetexture","nature/snowfloor002a")
    Material("CONCRETE/CONCRETEFLOOR009A"):SetTexture("$basetexture","nature/snowfloor001a")
    Material("NATURE/GRAVELFLOOR001A"):SetTexture("$basetexture","nature/snowfloor001a")
    Material("nature/gravelfloor002a"):SetTexture("$basetexture","nature/snowfloor001a")
    Material("SWAMPONIONS/GROUND/CONCRETETILE"):SetTexture("$basetexture","nature/snowfloor001a")
    Material("SWAMPONIONS/STONE/SMOOTHCONCRETE"):SetTexture("$basetexture","nature/snowfloor001a")
    Material("SWAMPONIONS/GROUND/CONCRETEFLOOR023A_TINT1"):SetTexture("$basetexture","nature/snowfloor001a")
    Material("SWAMPONIONS/GROUND/STAGGERED_CONCRETE2"):SetTexture("$basetexture","nature/snowfloor002a")
    Material("concrete/concretefloor039a"):SetTexture("$basetexture","nature/snowfloor002a")
    Material("maps/cinema_swamp_v3/concrete/concretefloor039a_-5632_1536_576"):SetTexture("$basetexture","nature/snowfloor002a")

    Material("swamponions/ground/dirtgrass1"):SetTexture("$basetexture","nature/snowfloor003a")
    Material("swamponions/ground/dirtgrass1"):SetTexture("$basetexture2","nature/snowfloor002a")
    Material("swamponions/ground/dirtgrass_skybox"):SetTexture("$basetexture","nature/snowfloor003a")
    Material("swamponions/ground/dirtgrass_skybox"):SetTexture("$basetexture2","nature/snowfloor002a")
    Material("nature/blendgrassgravel001b"):SetTexture("$basetexture","nature/snowfloor002a")
    Material("nature/blendgrassgravel001b"):SetTexture("$basetexture2","nature/snowfloor001a")
    Material("swamponions/ground/grass_dirt"):SetTexture("$basetexture","nature/snowfloor002a")
    Material("swamponions/ground/grass_dirt"):SetTexture("$basetexture2","nature/snowfloor001a")
    Material("swamponions/ground/grass_muck"):SetTexture("$basetexture","nature/snowfloor002a")
    Material("swamponions/ground/grass_muck"):SetTexture("$basetexture2","nature/snowfloor001a")
    Material("swamponions/ground/grass_nicegrass"):SetTexture("$basetexture","nature/snowfloor002a")
    Material("swamponions/ground/grass_nicegrass"):SetTexture("$basetexture2","nature/snowfloor001a")

    Material("swamponions/ground/concretefloor023a_tint1_weedy"):SetTexture("$basetexture","nature/snowfloor002a")
    Material("dojo/shingles"):SetTexture("$basetexture","nature/snowfloor002a")
    Material("concrete/concretefloor038c"):SetTexture("$basetexture","nature/snowfloor002a")
    Material("concrete/concretefloor038c"):SetTexture("$basetexture2","nature/snowfloor001a")

    --golf border
    Material("METAL/METALFLOOR007A"):SetTexture("$basetexture", "nature/snowfloor001a")

    --the pit
    Material("SWAMPONIONS/GROUND/blendtoxictoxic002a"):SetTexture("$basetexture","nature/snowfloor002a")
    Material("SWAMPONIONS/GROUND/blendtoxictoxic002a"):SetTexture("$basetexture2","nature/snowfloor003a")

    --water
    Material("swamponions/water_swamp"):SetTexture("$basetexture","lights/white")
    Material("swamponions/water_swamp"):SetVector("$color",Vector(0.6,0.6,0.7))
    Material("swamponions/water_swamp"):SetVector("$envmaptint",Vector(0.1,0.1,0.1))
    Material("SWAMPONIONS/WATER_SWAMP_SOLID"):SetTexture("$basetexture","lights/white")
    Material("SWAMPONIONS/WATER_SWAMP_SOLID"):SetVector("$color",Vector(0.6,0.6,0.7))
    Material("SWAMPONIONS/WATER_SWAMP_SOLID"):SetVector("$envmaptint",Vector(0.1,0.1,0.1))
    Material("SWAMPONIONS/water_swamp_liquid"):SetTexture("$basetexture","lights/white")
    Material("SWAMPONIONS/water_swamp_liquid"):SetVector("$color",Vector(0.6,0.6,0.7))
    Material("SWAMPONIONS/water_swamp_liquid"):SetVector("$envmaptint",Vector(0.1,0.1,0.1))

    /*
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
    */
end)

/*concommand.Add("mattrace", function()
    tr = LocalPlayer():GetEyeTrace()

    if tr.HitTexture then
        PrintTable(tr)
        chat.AddText(tr.HitTexture)
        SetClipboardText(tr.HitTexture)
    end
end)
