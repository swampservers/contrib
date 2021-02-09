-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

local PANEL = {}

function PANEL:Init()
	self:SetModel(LocalPlayer():GetModel())
end

function PANEL:Paint()
	if ( !IsValid( self.Entity ) ) then return end

	local x, y = self:LocalToScreen( 0, 0 )

	self:LayoutEntity( self.Entity )

	local ang = self.aLookAngle
	if ( !ang ) then
		ang = (self.vLookatPos-self.vCamPos):Angle()
	end

	local pos = self.vCamPos

	if PS_CustomizerPanel:IsVisible() then
		if IsValid(PS_HoverCSModel) then
			PS_DrawWornCSModel(PS_HoverData, PS_HoverCfg, PS_HoverCSModel, self.Entity, true)
			pos = LerpVector(0, PS_HoverCSModel:GetPos() - (ang:Forward() * 25), pos)
		end

		if PS_HoverData and PS_HoverData.bonemod then
			pos = pos + (ang:Forward() * 25)
			--positions are wrong
--[[
			local pone = isPonyModel(self.Entity:GetModel())
			local suffix = pone and "_p" or "_h"

			local bn = PS_HoverCfg["bone"..suffix] or (pone and "LrigScull" or "ValveBiped.Bip01_Head")
			local x = self.Entity:LookupBone(bn)
			if x then
				local pos2,ang2 = self.Entity:GetBonePosition(x)

				pos = LerpVector(0, pos2 - (ang:Forward() * 35), pos)
			end
			]]
		end
	end

	local w, h = self:GetSize()
	cam.Start3D( pos + ang:Forward() * (self.ZoomOffset or 0) * 2.0, ang, self.fFOV, x, y, w, h, 5, 4096 )
	cam.IgnoreZ( true )

	render.SuppressEngineLighting( true )
	render.SetLightingOrigin( self.Entity:GetPos() )
	render.ResetModelLighting( self.colAmbientLight.r/255, self.colAmbientLight.g/255, self.colAmbientLight.b/255 )
	render.SetBlend( self.colColor.a/255 )

	for i=0, 6 do
		local col = self.DirectionalLight[ i ]
		if ( col ) then
			render.SetModelLighting( i, col.r/255, col.g/255, col.b/255 )
		end
	end


	local ply = LocalPlayer()

	local mdl = ply:GetModel()
	if PS_HoverData and (not PS_HoverData.wear) and (not PS_HoverData.bonemod) then
		mdl = PS_HoverData.model
	end

	require_workshop_model(mdl)
	self:SetModelCaching(mdl)

	if isPonyModel(self.Entity:GetModel()) then
		PPM.PrePonyDraw(self.Entity,true)
		PPM.setBodygroups(self.Entity,true)
	end

	if PS_HoverData and (not PS_HoverData.playermodel) and (not PS_HoverData.wear) and (not PS_HoverData.bonemod) then
		PS_PreRender(PS_HoverData, PS_HoverCfg)
		PS_PreviewShopModel(self, PS_HoverData)

		self.Entity:DrawModel()

		PS_PostRender()	
	else
		local PrevMins, PrevMaxs = self.Entity:GetRenderBounds()
		if isPonyModel(self.Entity:GetModel()) then
			PrevMins = Vector(-42, -20, -2.5)
			PrevMaxs = Vector(38, 20, 83)
		end
		
		local center = (PrevMaxs + PrevMins) / 2
		local diam = PrevMins:Distance(PrevMaxs)
		self:SetCamPos(center + (diam * Vector(0.4,0.4,0.1)))
		self:SetLookAt(center)

		self.Entity.GetPlayerColor = function() return LocalPlayer():GetPlayerColor() end

		local mods = LocalPlayer():PS_GetActiveBonemods()
		if PS_HoverData and PS_HoverData.bonemod then
			table.insert(mods, {itm=PS_HoverData, cfg=PS_HoverCfg})
			local rm = nil
			for i,v in ipairs(mods) do
				if v.id == PS_HoverItemID then
					rm = i
					break
				end
			end
			if rm then table.remove(mods,rm) end
		end
		PS_ApplyBoneMods(self.Entity, mods)
		self.Entity:DrawModel()
	end


	if PS_HoverData==nil or PS_HoverData.playermodel or PS_HoverData.wear or PS_HoverData.bonemod then
		for _, prop in pairs(ply:PS_GetCSModels()) do
			if PS_HoverItemID==nil or PS_HoverItemID~=prop.id then
				PS_DrawWornCSModel(prop.itm, prop.cfg, prop.mdl, self.Entity)
			end
		end
	end
	
	if PS_HoverData and PS_HoverData.wear then
		if not IsValid(PS_HoverCSModel) then
			PS_HoverCSModel = PS_CreateWornCSModel(PS_HoverData, PS_HoverCfg)
		end
			
		PS_DrawWornCSModel(PS_HoverData, PS_HoverCfg, PS_HoverCSModel, self.Entity)
	end

	render.SuppressEngineLighting( false )
	cam.IgnoreZ( false )
	cam.End3D()

	if PS_CustomizerPanel:IsVisible() then
		if ValidPanel(XRSL) then
			if IsValid(PS_HoverCSModel) then
				draw.SimpleText("RMB + drag to rotate", "PS_DESCFONT", self:GetWide() / 2, 14, PS_SwitchableColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)	
			end
		end
	end
end

function PANEL:SetModelCaching( sm )
	if sm ~= self.ModelName then
		self.ModelName = sm
		self:SetModel(sm)

		if isPonyModel(sm) then
			self.Entity.isEditorPony = true 
			PPM.editor3_pony = self.Entity
			PPM.copyLocalPonyTo(LocalPlayer(),self.Entity)
		end	
	end
end

vgui.Register('DPointShopPreview', PANEL, 'DModelPanel')
