
hook.Add("PostDrawOpaqueRenderables","SnowAdder",function()
	--timer.Simple(1, function() RunConsoleCommand('snow') end)
	hook.Remove("PostDrawOpaqueRenderables","SnowAdder")
end)

concommand.Add("snow", function()

	
Material("swamponions/ground/concretefloor016a"):SetTexture("$basetexture","nature/snowfloor001a")
Material("CONCRETE/CONCRETEFLOOR023A"):SetTexture("$basetexture","nature/snowfloor001a")
Material("SWAMPONIONS/GROUND/CONCRETEFLOOR023A"):SetTexture("$basetexture","nature/snowfloor001a")
Material("BRICK/BRICKFLOOR001A"):SetTexture("$basetexture","nature/snowfloor001a")
Material("SWAMPONIONS/GROUND/CONCRETEFLOOR005A"):SetTexture("$basetexture","nature/snowfloor001a")
Material("SWAMPONIONS/GROUND/RADIALTILE1"):SetTexture("$basetexture","nature/snowfloor002a")
Material("maps/cinema_swamp_v2/metal/metalroof006a_-512_4608_512"):SetTexture("$basetexture","nature/snowfloor002a")
Material("NATURE/GRAVELFLOOR001A"):SetTexture("$basetexture","nature/snowfloor001a")
Material("CONCRETE/CONCRETEFLOOR001A"):SetTexture("$basetexture","nature/snowfloor001a")
Material("SWAMPONIONS/STONE/CONCRETERING"):SetTexture("$basetexture","nature/snowfloor001a")
Material("CONCRETE/CONCRETEFLOOR011A"):SetTexture("$basetexture","nature/snowfloor001a")


Material("swamponions/ground/dirtgrass1"):SetTexture("$basetexture","nature/snowfloor003a")
Material("swamponions/ground/dirtgrass1"):SetTexture("$basetexture2","nature/snowfloor002a")
Material("SWAMPONIONS/GROUND/blendtoxictoxic002a"):SetTexture("$basetexture2","nature/snowfloor003a")
Material("swamponions/ground/dirtgrass_skybox"):SetTexture("$basetexture","nature/snowfloor003a")
Material("swamponions/ground/dirtgrass_skybox"):SetTexture("$basetexture2","nature/snowfloor002a")


Material("swamponions/water_swamp"):SetTexture("$basetexture","lights/white")
Material("swamponions/water_swamp"):SetVector("$color",Vector(0.6,0.6,0.7))
Material("swamponions/water_swamp"):SetVector("$envmaptint",Vector(0.1,0.1,0.1))

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
end)
--[[
concommand.Add("mattrace", function()
	tr = LocalPlayer():GetEyeTrace()

	if tr.HitTexture then
		PrintTable(tr)
		chat.AddText(tr.HitTexture)
		SetClipboardText(tr.HitTexture)
	end
end)]]