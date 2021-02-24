-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- IGNORE THIS LINE!!!!!
PREVIEWITEMS = {} function PS_ItemProduct(itm) table.insert(PREVIEWITEMS, itm) end

--[[
This utility makes it easy to make hats and other wearable props for Swamp Cinema.

Setup:
- Sub to this addon: https://steamcommunity.com/sharedfiles/filedetails/?id=821872963
- Install a text editor such as: https://code.visualstudio.com/
- Place this file in: C:\Program Files (x86)\Steam\steamapps\common\GarrysMod\garrysmod\lua\autorun
	(or whereever gmod is installed) and make sure the file extension ends in .lua
- Launch gmod sandbox on "gm_construct" and go to where the mirror is underground

To make props:
- Copy and paste the "Example item" below then modify your copy until it looks good on kleiner and on pony
- To get model names, hold q and right click the model, then "copy to clipboard"

When you are done:
- Add the PS_ItemProduct blocks in this file: https://github.com/swampservers/contrib/blob/master/lua/sps/items/wearables.lua
	(more example items are in this file as well)
- Add the classname to this file so it appears in the shop: https://github.com/swampservers/contrib/blob/master/lua/sps/categories.lua
]]

-- Change this to 'true' or 'false' depending on if you want to be a pony
SHOW_PONY = false

-- Example item
PS_ItemProduct({
	class = "buckethat",
	price = 10000,
	name = 'Bucket Head',
	description = "Did you get this out of the trash?",
	model = 'models/props_junk/MetalBucket01a.mdl',
	wear = {
		attach = "eyes",
		scale = 0.5,
		translate = Vector(-3.3,-1,6),
		rotate = Angle(0,-15,-170),
		pony = {
			scale = 0.9,
			translate = Vector(-11.1,-3.5,15.5),
			rotate = Angle(-10,-15,-163),
		}
	}
})

-- Put more PS_ItemProduct({ .... }) blocks here...








------------------------------------------
-- IGNORE EVERYTHING BELOW THIS LINE !!!!!
------------------------------------------
if SERVER then
	timer.Create("PlayerModelUpdater",0,0.1,function()
		for k,v in pairs(player.GetAll()) do
			local PREVIEW_PLAYERMODEL = SHOW_PONY and "models/ppm/player_default_base.mdl" or "models/player/kleiner.mdl" 
			if v:GetModel()~=PREVIEW_PLAYERMODEL then
				v:SetModel(PREVIEW_PLAYERMODEL)
				if SHOW_PONY then
					v:SetViewOffset(Vector(0,0,v:GetModelScale()*42))
					v:SetViewOffsetDucked(Vector(0,0,v:GetModelScale()*32))
				else
					v:SetViewOffset(Vector(0,0,v:GetModelScale()*64))
					v:SetViewOffsetDucked(Vector(0,0,v:GetModelScale()*28))
				end
			end
		end
	end)
	return
end


hook.Add("PrePlayerDraw","DrawTheStuff",function(ply)
	for k,itm in pairs(PREVIEWITEMS) do
		if not itm.mdl then itm.mdl = ClientsideModel(itm.model, RENDERGROUP_OPAQUE) itm.mdl:SetNoDraw(true) end
		PS_DrawWornCSModel(itm, {}, itm.mdl, ply, nil)
    end
end)

PS_Attachments = {
    eyes = "I'm special",
    head = {"ValveBiped.Bip01_Head1", "LrigScull"},
    neck = {"ValveBiped.Bip01_Neck1", "LrigNeck2"},
    upper_body = {"ValveBiped.Bip01_Spine4", "LrigSpine2"},
    lower_body = {"ValveBiped.Bip01_Spine", "LrigSpine1"},
    left_hand = {"ValveBiped.Bip01_L_Hand", "Lrig_LEG_FL_FrontHoof"},
    right_hand = {"ValveBiped.Bip01_R_Hand", "Lrig_LEG_FR_FrontHoof"},
    left_shoulder = {"ValveBiped.Bip01_L_Clavicle", "Lrig_LEG_FL_Humerus"},
    right_shoulder = {"ValveBiped.Bip01_R_Clavicle", "Lrig_LEG_FR_Humerus"},
    left_foot = {"ValveBiped.Bip01_L_Foot", "Lrig_LEG_BL_RearHoof"},
    right_foot = {"ValveBiped.Bip01_R_Foot", "Lrig_LEG_BR_RearHoof"},
}
function PS_AngleGen(func)
	local ang = Angle()
	func(ang)
	return ang
end
function isPonyModel(modelName)
	modelName = modelName:sub(1,17)	
	if modelName=="models/ppm/player" then return true end
	if modelName=="models/mlp/player" then return true end
	return false
end
function PS_DrawWornCSModel(itm, cfg, mdl, ent, dontactually)
	local pone = isPonyModel(ent:GetModel())

	local attach = itm.wear.attach
	local scale = itm.wear.scale
	local translate = itm.wear.translate
	local rotate = itm.wear.rotate

	if pone and itm.wear.pony then
		attach = itm.wear.pony.attach or attach
		scale = itm.wear.pony.scale or scale
		translate = itm.wear.pony.translate or translate
		rotate = itm.wear.pony.rotate or rotate
	end

	if cfg then
		local cfgk = pone and "wear_p" or "wear_h"
		if cfg[cfgk] then
			attach = cfg[cfgk].attach or attach
			scale = cfg[cfgk].scale or scale
			translate = cfg[cfgk].pos or translate
			rotate = cfg[cfgk].ang or rotate
		end
	end

	local pos, ang
	
	if attach=="eyes" then
		local fn = FrameNumber()
		if ent.attachcacheframe ~= fn then
			ent.attachcacheframe = fn
			local attach_id = ent:LookupAttachment("eyes")
			if attach_id then
				local attacht = ent:GetAttachment(attach_id)
				if attacht then
					ent.attachcache = attacht
					pos = attacht.Pos
					ang = attacht.Ang
				end
			end
		else
			local attacht = ent.attachcache
			if attacht then
				pos = attacht.Pos
				ang = attacht.Ang
			end
		end
	else
		local bone_id = ent:LookupBone(PS_Attachments[attach][pone and 2 or 1])
		if bone_id then
			pos, ang = ent:GetBonePosition(bone_id)
		end	
	end

	if not pos then pos = ent:GetPos() ang = ent:GetAngles() end

	pos, ang = LocalToWorld(translate, rotate, pos, ang)

	if mdl.scaleapplied ~= scale then
		mdl.scaleapplied = scale
		if isnumber(scale) then
			mdl.matrix = Matrix({{scale, 0, 0, 0}, {0, scale, 0, 0}, {0, 0, scale, 0}, {0, 0, 0, 1}})
		else
			mdl.matrix = Matrix({{scale.x, 0, 0, 0}, {0, scale.y, 0, 0}, {0, 0, scale.z, 0}, {0, 0, 0, 1}})
		end
		mdl:EnableMatrix("RenderMultiply", mdl.matrix)
	end

	mdl:SetPos(pos)
	mdl:SetAngles(ang)

	mdl:SetupBones()
	
	
	if not dontactually then 
		PS_PreRender(itm, cfg, ent)
		mdl:DrawModel()
		PS_PostRender()
	end
end
function PS_PreRender(data, cfg, ent)
	cfg = (cfg or {})
	local imgur = cfg.imgur
	if imgur then

		local imat = ImgurMaterial(imgur.url, ent, IsValid(ent) and ent:IsPlayer() and ent:GetPos(), false, "VertexLitGeneric", {["$alphatest"]=1})
		render.MaterialOverride(imat)

		--render.OverrideDepthEnable(true,true)
	else
		local mat = cfg.material or data.material
		if mat then render.MaterialOverride(PS_GetMaterial(mat)) end
	end
	local col = cfg.color or data.color
	if col then render.SetColorModulation(col.x,col.y,col.z) end
end

function PS_PostRender()
	render.SetColorModulation(1,1,1)
	render.MaterialOverride()
	--render.OverrideDepthEnable(false)
end
