-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

include("sh_init.lua")

include("vgui/DPointShopMenu.lua")
include("vgui/DPointShopItem.lua")
include("vgui/DPointShopPreview.lua")
include("vgui/DPointShopCustomizer.lua")
include("vgui/DPointShopGivePoints.lua")

local wasf3down = false
hook.Add("Think", "PSToggler", function()
	local isf3down = input.IsKeyDown(KEY_F3)
	if isf3down and not wasf3down then PS_ToggleMenu() end
	wasf3down = isf3down
end)

concommand.Add("ps_togglemenu", function(ply, cmd, args) PS_ToggleMenu() end)

CreateClientConVar("ps_darkmode", "0", true)

function SetPointshopTheme(dark)
	PS_DarkMode = dark
	if PS_DarkMode then
		PS_TileBGColor = Color(37, 37, 37)
		PS_GridBGColor = Color(33, 33, 33)
		PS_BotBGColor = Color(33, 33, 33)
		PS_SwitchableColor = Color(200, 200, 200)
	else
		PS_TileBGColor = Color(234, 234, 234)
		PS_GridBGColor = Color(200, 200, 200)
		PS_BotBGColor = Color(64, 64, 64)
		PS_SwitchableColor = Color(0, 0, 0)
	end

	if IsValid(PS_CustomizerPanel) then
		PS_CustomizerPanel:Remove()
	end
	if IsValid(PS_ShopMenu) then
		if PS_ShopMenu:IsVisible() then
			PS_ShopMenu:Remove()
			PS_ShopMenu = vgui.Create('DPointShopMenu')
			PS_ShopMenu:Show()
		else
			PS_ShopMenu:Remove()
			PS_ShopMenu = vgui.Create('DPointShopMenu')
			PS_ShopMenu:SetVisible(false)
		end
	end
end
SetPointshopTheme(GetConVar("ps_darkmode"):GetBool())

cvars.AddChangeCallback("ps_darkmode", function(cvar, old, new)
	SetPointshopTheme(tobool(new))
end)

concommand.Add("ps_destroymenu", function( ply, cmd, args )
	if IsValid(PS_CustomizerPanel) then
		PS_CustomizerPanel:Close()
	end
	if IsValid(PS_ShopMenu) then
		PS_ShopMenu:Remove()
	end
end)

function PS_ToggleMenu()
	if not IsValid(PS_ShopMenu) then
		PS_ShopMenu = vgui.Create('DPointShopMenu')
		PS_ShopMenu:SetVisible(false)
	end
	
	if PS_ShopMenu:IsVisible() then
		if IsValid(PS_CustomizerPanel) then
			PS_CustomizerPanel:Close()
		end
		PS_ShopMenu:Hide()
		gui.EnableScreenClicker(false)
	else
		PS_ShopMenu:Show()
		gui.EnableScreenClicker(true)
	end
end

--[[
function PS:SetHoverItem(item_id)
	local ITEM = PS.Items[item_id]
	
	if ITEM.Model then
		self.HoverModel = item_id
	
		self.HoverModelClientsideModel = ClientsideModel(ITEM.Model, RENDERGROUP_OPAQUE)
		self.HoverModelClientsideModel:SetNoDraw(true)
	end
end

function PS:RemoveHoverItem()
	self.HoverModel = nil
	self.HoverModelClientsideModel = nil
end ]]

--[[
function PS:ShowColorChooser(item, modifications)
	-- TODO: Do this
	local chooser = vgui.Create('DPointShopColorChooser')
	chooser:SetColor(modifications.color)
	
	chooser.OnChoose = function(color)
		modifications.color = color
		self:SendModifications(item.ID, modifications)
	end
end

function PS:SendModifications(item_id, modifications)
	net.Start('PS_ModifyItem')
		net.WriteString(item_id)
		net.WriteTable(modifications)
	net.SendToServer()
end ]]

function SetLoadingPlayerProperty(pi, prop, val, callback, calls)
	if not calls then calls = 10 end

	local ply = pi==-1 and LocalPlayer() or Entity(pi)

	if IsValid(ply) then
		ply[prop] = val
		if callback then callback(ply) end
	else
		if calls<1 then
			print("ERROR loading "..prop.." for "..tostring(pi))
		else
			timer.Simple(1, function()
				SetLoadingPlayerProperty(pi, prop, val, callback, calls-1)
			end)
		end		
	end
end

net.Receive('PS_Items', function(length)
	local pi = net.ReadUInt(8)
	local items = net.ReadTableHD()
	SetLoadingPlayerProperty(pi, "PS_Items", items,
		function(ply)
			ply:PS_ClearCSModels()
			ply.PS_BoneModsClean = false
			if LocalPlayer()==ply then PS_ValidInventory = false end
		end)
end)

net.Receive('PS_EQItems', function(length)
	local pi = net.ReadUInt(8)
	local items = net.ReadTableHD()
	SetLoadingPlayerProperty(pi, "PS_EQItems", items,
		function(ply)
			ply:PS_ClearCSModels()
			ply.PS_BoneModsClean = false
		end)
end)

net.Receive('PS_Pts', function(length)
	SetLoadingPlayerProperty(-1, "PS_Points", net.ReadUInt(32))
end)

net.Receive('PS_Row', function(length)
	local pi = net.ReadUInt(8)
	SetLoadingPlayerProperty(pi, "PS_Points", net.ReadUInt(32))
	SetLoadingPlayerProperty(pi, "PS_Donation", net.ReadUInt(32))
end)

PS_CSModels = PS_CSModels or {}

hook.Add('Think', 'PS_Cleanup', function()
	for ply,mdls in pairs(PS_CSModels) do
		if not IsValid(ply) then
			for k,v in pairs(mdls) do
				v.mdl:Remove()
			end
			PS_CSModels[ply] = nil			
		end
	end
end)

--makes a CSModel for a worn item
function PS_CreateWornCSModel(itm, cfg)
	if itm==nil or itm.wear==nil then return end
	return PS_CreateCSModel(itm, cfg)
end

--makes a CSModel for a product or item
function PS_CreateCSModel(itm, cfg)
	if itm == nil then return end
	
	local mdlname = itm.model or (cfg or {}).model
	if mdlname == nil then return end

	local mdl = ClientsideModel(mdlname, RENDERGROUP_OPAQUE)
	if IsValid(mdl) then
		mdl:SetNoDraw(true)
		return mdl
	end
end

PS_MaterialCache = {}
function PS_GetMaterial(nam)
	local cur = PS_MaterialCache[nam]
	if cur then return cur end
	PS_MaterialCache[nam] = Material(nam)
	return PS_MaterialCache[nam]
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

hook.Add("PrePlayerDraw","PS_BoneMods",function(ply)

	-- will be "false" if the model is not mounted yet
	local mounted_model = require_workshop_model(ply:GetModel()) and ply:GetModel()

	if ply.PS_BoneModsLastModel ~= mounted_model then
		ply.PS_BoneModsClean = false
		--seems to have issues if you apply the bone mods as soon as the model changes...
		--timer.Simple(1, function() if IsValid(ply) then ply.PS_BoneModsClean = false end end)
	end
	if not ply.PS_BoneModsClean then
		ply.PS_BoneModsClean = PS_ApplyBoneMods(ply, ply:PS_GetActiveBonemods())
		ply.PS_BoneModsLastModel = mounted_model
	end
end)


local function AddScaleRecursive(ent, b, scn, recurse, safety)
	if safety[b] then
		error("BONE LOOP!")
	end
	safety[b]=true
	local sco = ent:GetManipulateBoneScale(b)
	sco.x = sco.x * scn.x
	sco.y = sco.y * scn.y
	sco.z = sco.z * scn.z
	
	if ent:GetModel() == "models/milaco/minecraft_pm/minecraft_pm.mdl" then
		sco.x = math.min(sco.x,1)
		sco.y = math.min(sco.y,1)
		sco.z = math.min(sco.z,1)
	end
	
	ent:ManipulateBoneScale(b, sco)

	if recurse then
		for i,v in ipairs(ent:GetChildBones(b)) do
			AddScaleRecursive(ent, v, scn, recurse, safety)
		end
	end
end

--only bone scale right now...
--if you do pos/angles, must do a combination override to make it work with emotes, vape arm etc
function PS_ApplyBoneMods(ent, mods)
	for x=0,(ent:GetBoneCount()-1) do
		ent:ManipulateBoneScale(x, Vector(1,1,1))
		ent:ManipulateBonePosition(x, Vector(0,0,0))
	end

	if ent:GetModel()==HumanTeamModel or ent:GetModel()==PonyTeamModel then return end

	local pone = isPonyModel(ent:GetModel())
	local suffix = pone and "_p" or "_h"

	--if pelvis has no children, its not ready!
	local pelvis = ent:LookupBone(pone and "LrigPelvis" or "ValveBiped.Bip01_Pelvis")
	if pelvis then
		if #ent:GetChildBones(pelvis) == 0 then return false end
	end

	for _,v in ipairs(mods) do
		local bn = v.cfg["bone"..suffix] or (pone and "LrigScull" or "ValveBiped.Bip01_Head1")
		local x = ent:LookupBone(bn)
		if x then
			if (v.itm.configurable or {}).scale then
				local scn = v.cfg["scale"..suffix] or Vector(1,1,1.5)
				AddScaleRecursive(ent, x, scn, v.cfg["scale_children"..suffix], {})
			end
			if (v.itm.configurable or {}).pos then
				local psn = v.cfg["pos"..suffix] or Vector(10,0,0)
				--don't allow moving the root bone
				if ent:GetBoneParent(x)==-1 then
					psn.x=0
					psn.y=0
				end
				local pso = ent:GetManipulateBonePosition(x)
				pso = pso + psn
				ent:ManipulateBonePosition(x, pso)
			end
		end
	end

	--clamp the amount of stacking
	for x=0,(ent:GetBoneCount()-1) do
		local old = ent:GetManipulateBoneScale(x)
		local mn = 0.125 --0.5*0.5*0.5
		local mx = 3.375 --1.5*1.5*1.5
		if ent.GetNetData and ent:GetNetData('OF') ~= nil then mx=1.5 end
		old.x = math.Clamp(old.x, mn, mx)
		old.y = math.Clamp(old.y, mn, mx)
		old.z = math.Clamp(old.z, mn, mx)
		ent:ManipulateBoneScale(x, old)

		old = ent:GetManipulateBonePosition(x)
		old.x = math.Clamp(old.x, -8, 8)
		old.y = math.Clamp(old.y, -8, 8)
		old.z = math.Clamp(old.z, -8, 8)
		ent:ManipulateBonePosition(x, old)
	end

	return true
end


--TODO: add "defaultcfg" as a standard field in items rather than this hack!
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

hook.Add("DrawOpaqueAccessories", 'PS_DrawPlayerAccessories', function(ply)
	if ply.PS_Items==nil and ply.PS_EQItems==nil then return end

	if not ply:Alive() then return end
	--if EyePos():DistToSqr(ply:GetPos()) > 2000000 then return end

	-- and (GetConVar('thirdperson') and GetConVar('thirdperson'):GetInt() == 0)
	--if ply == LocalPlayer() and GetViewEntity():GetClass() == 'player' then return end
	

	if GAMEMODE.FolderName == "fatkid" and ply:Team()~=TEAM_HUMAN then return end
	
	--in SPADES, the renderboost.lua is disabled!

	for _, prop in ipairs(ply:PS_GetCSModels()) do
		PS_DrawWornCSModel(prop.itm, prop.cfg, prop.mdl, ply)
	end
end)

PS_GibProps = {}

hook.Add('CreateClientsideRagdoll', 'PS_CreateClientsideRagdoll', function(ply, rag)
	if IsValid(ply) and ply:IsPlayer() then
		--print(rag:GetPhysicsObjectNum(0):GetVelocity())
		local counter = 0
		for k,v in pairs(PS_CSModels[ply] or {}) do
			counter = counter+1
			if counter>8 then return end 
			vm = v.mdl
			local gib = GibClientProp(vm:GetModel(), vm:GetPos(), vm:GetAngles(), ply:GetVelocity(), 1, 6)
			if vm.matrix then
				gib:EnableMatrix("RenderMultiply", vm.matrix)
			end
			gib.csmodel = v
			gib:SetNoDraw(true)
			table.insert(PS_GibProps, gib)
		end		
	end
end)

concommand.Add("ps_proptest", function()
	for j,itm in pairs(PS_Items) do
		local mdl = itm.model
		local gib = GibClientProp(mdl, LocalPlayer():EyePos(), Angle(0,0,0), LocalPlayer():GetVelocity(), 1, 6)
		gib = gib:GetPhysicsObject():GetMesh()
		local mins = nil
		local maxs = nil
		for k,v in pairs(gib) do
			local p = v.pos
			if mins then
				mins = Vector(math.min(mins.x, p.x),math.min(mins.y, p.y),math.min(mins.z, p.z))
				maxs = Vector(math.max(maxs.x, p.x),math.max(maxs.y, p.y),math.max(maxs.z, p.z))
			else
				mins = p
				maxs = p
			end
		end
		print(mdl)
		maxs = (maxs-mins)
		print("Vector("..tostring(math.Round(maxs.x,0))..", "..tostring(math.Round(maxs.y,0))..", "..tostring(math.Round(maxs.z,0))..")")
	end

end)

hook.Add("PostDrawOpaqueRenderables","PS_RenderGibs",function(depth, sky)
	local nextgibs = {}
	while #PS_GibProps > 0 do
		local gib = table.remove(PS_GibProps)
		if IsValid(gib) then
			PS_PreRender(gib.csmodel.itm, gib.csmodel.cfg)
			gib:DrawModel()
			PS_PostRender()
			table.insert(nextgibs, gib)
		end
	end
	PS_GibProps = nextgibs
end)

function PS_BuyProduct(id)
	if not PS_Products[id] then
		LocalPlayerNotify("Unknown product '"..tostring(id).."'. Many products have new codes, update your binds.") 
		return
	end

	print('To quickbuy this product, run: bind <key> "ps_buy '..id..'"')

	net.Start('PS_BuyProduct')
	net.WriteString(id)
	net.SendToServer()
end

concommand.Add("ps_buy", function( ply, cmd, args )
	if #args < 1 then print("usage: ps_buy product") return end
	if LocalPlayer():HasWeapon(args[1]) and !PS_Products[args[1]]['ammotype'] then -- if they have the wep and the wep is not a single-use e.g. peacekeeper
        input.SelectWeapon(LocalPlayer():GetWeapon(args[1]))
        return
    end
	PS_BuyProduct(args[1])
end )

function PS_SellItem(item_id)
	if not LocalPlayer():PS_FindItem(item_id) then return end
	
	net.Start('PS_SellItem')
	net.WriteUInt(item_id, 32)
	net.SendToServer()
end

function PS_EquipItem(item_id, state)
	if not LocalPlayer():PS_FindItem(item_id) then return end
	
	net.Start('PS_EquipItem')
	net.WriteUInt(item_id, 32)
	net.WriteBool(state)
	net.SendToServer()
end

function PS_ConfigureItem(item_id, cfg)
	if not LocalPlayer():PS_FindItem(item_id) then return end
	
	net.Start('PS_ConfigureItem')
	net.WriteUInt(item_id, 32)
	net.WriteTableHD(cfg)
	net.SendToServer()
end

local Player = FindMetaTable('Player')

function Player:PS_ClearCSModels()
	for k,v in pairs(PS_CSModels[self] or {}) do
		v.mdl:Remove()
	end
	PS_CSModels[self] = nil
end

function Player:PS_GetCSModels()
	if PS_CSModels[self] == nil then
		PS_CSModels[self] = {}

		for k,v in pairs(self.PS_Items or self.PS_EQItems or {}) do
			--eq is nil in eqitems table
			if v.eq == false then continue end

			local itm = PS_Items[v.class]

			if not itm then
				continue
			end

			local mdl = PS_CreateWornCSModel(itm, v.cfg)
			if mdl then
				table.insert(PS_CSModels[self], {mdl=mdl, itm=itm, cfg=v.cfg, id=v.id})
			end
		end
	end

	return PS_CSModels[self]
end

function Player:PS_GetActiveBonemods()
	local mods = {}

	for k,v in pairs(self.PS_Items or self.PS_EQItems or {}) do
		--eq is nil in eqitems table
		if v.eq == false then continue end

		local itm = PS_Items[v.class]

		if not itm then
			continue
		end

		if itm.bonemod then
			table.insert(mods, {itm=itm, cfg=v.cfg, id=v.id})
		end
	end

	return mods
end

concommand.Add("ps_prop_autorefresh", function()
	timer.Create("ppau",0.05,0,function() LocalPlayer():PS_ClearCSModels() end)
end)


function SendPointsCmd(cmd)
	cmd = string.Explode(" ",cmd)
	local fail = true
	if #cmd >= 2 then
		local amt = tonumber(cmd[#cmd])
		if amt~=nil then
			table.remove(cmd)
			local ply,cnt = PlyCount(string.Implode(" ", cmd))
			fail = false
			if cnt==0 then
				chat.AddText("[orange]No player found")
			else
				if cnt==1 then
					net.Start("PS_SendPoints")
					net.WriteEntity(ply)
					net.WriteInt(amt,32)
					net.SendToServer()
				else
					chat.AddText("[orange]Multiple found")
				end
			end

		end
	end
	if fail then
		chat.AddText("[orange]Usage: !givepoints player amount")
	end
end
