-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

function PS_PreviewShopModel(self, data)
	local PrevMins, PrevMaxs = self.Entity:GetRenderBounds()
	local center = (PrevMaxs + PrevMins) / 2
	local diam = PrevMins:Distance(PrevMaxs) + (data.extrapreviewgap or 0)
	self:SetCamPos(center + (diam * Vector(0.5,0.5,0.5)))
	self:SetLookAt(center)
end

function PS_MouseInsidePanel(panel)
	local x,y = panel:LocalCursorPos()
	return x>0 and y>0 and x<panel:GetWide() and y<panel:GetTall()
end

local PANEL = {}

function PANEL:OnRemove()
	if self:IsSelected() then
		self:Deselect()
	end
end

function PANEL:OnMousePressed(b)
	if b~=MOUSE_LEFT then return end

	if self.product then
		local status = LocalPlayer():PS_CanBuyStatus(self.data)
	
		if status==PS_BUYSTATUS_OK then
			if not self.prebuyclick then
				self.prebuyclick=true
				return
			end

			self.prebuyclick = nil

			surface.PlaySound("UI/buttonclick.wav")
			PS_BuyProduct(self.data.class)
		else
			surface.PlaySound("common/wpn_denyselect.wav")
			LocalPlayerNotify(PS_BuyStatusMessage[status])
		end
	else
		if self:IsSelected() then
			local status = (not self.item.eq) and LocalPlayer():PS_CanEquipStatus(self.item.class, self.item.cfg) or PS_EQUIPSTATUS_OK

			if status == PS_EQUIPSTATUS_OK then
				surface.PlaySound("weapons/smg1/switch_single.wav")
				PS_EquipItem(self.item.id, not self.item.eq)
			else
				surface.PlaySound("common/wpn_denyselect.wav")
				LocalPlayerNotify(PS_EquipStatusMessage[status])
			end
		else
			self:Select()
		end
	end


end

function PANEL:OnCursorEntered()
	self.hovered = true
	if self.product then self:Select() end
end

function PANEL:OnCursorExited()
	self.hovered = false
	if self.product then self:Deselect() end
end

function PANEL:Select()
	if IsValid(PS_SelectedPanel) then
		PS_SelectedPanel:Deselect()
	end

	PS_SelectedPanel = self

	
	PS_HoverData = self.data
	PS_HoverCfg = (self.item or {}).cfg
	PS_HoverItemID = (self.item or {}).id

	local p = vgui.Create("DLabel", PS_DescriptionPanel)
	p:SetFont("PS_DESCTITLEFONT")
	p:SetText(self.data.name)
	p:SetColor(PS_SwitchableColor)
	p:SetContentAlignment(5)
	p:SizeToContents()
	p:DockMargin(0,-4,0,0)
	p:Dock(TOP)

	if self.data.description then
		p = vgui.Create("DLabel", PS_DescriptionPanel)
		p:SetFont("PS_DESCFONT")
		p:SetText(self.data.description)
		p:SetColor(PS_SwitchableColor)
		--HACK
		if string.len(self.data.description)>45 then
			p:SetWrap(true)
			p:SetAutoStretchVertical(true)
		else
			p:SetContentAlignment(5)
			p:SizeToContents()
		end
		p:DockMargin(14,6,14,10)
		p:Dock(TOP)
	end

	if self.product then

		local function addline(txt)
			p = vgui.Create("DLabel", PS_DescriptionPanel)
			p:SetFont("PS_DESCINSTFONT")
			p:SetText(txt)
			p:SetContentAlignment(5)
			p:SetColor(PS_SwitchableColor)
			--p:SetWrap(true)
			--bp:SetAutoStretchVertical(true)
			p:SizeToContents()
			p:DockMargin(14,6,14,2)
			p:Dock(TOP)
		end

		addline("Price: "..(self.data.price==0 and "Free" or (string.Comma(self.data.price).." points")))

		local status = LocalPlayer():PS_CanBuyStatus(self.data)


		if status==PS_BUYSTATUS_OK then
			addline("Double-click to "..(self.data.price==0 and "get" or "buy"))
		else
			addline(PS_BuyStatusMessage[status])
		end

		if status~=PS_BUYSTATUS_OWNED then
			if PS_Items[self.data.class] then
				local count = LocalPlayer():PS_CountItem(self.data.class)
				if count>0 then
					addline("You own "..tostring(count).." of these")
				end
			end
		end

		local typetext = nil

		if self.data.keepnotice then
			p = vgui.Create("DLabel", PS_DescriptionPanel)
			p:SetFont("PS_DESCFONT")
			p:SetText(self.data.keepnotice)
			p:SetContentAlignment(5)
			p:SetColor(PS_SwitchableColor)
			p:SizeToContents()
			p:DockMargin(14,2,14,8)
			p:Dock(BOTTOM)
		end

	else

		if self.data.configurable then
			p = vgui.Create('DButton', PS_DescriptionPanel)
			p:SetText("Customize")
			p:SetTextColor(PS_SwitchableColor)
			p:DockMargin(16,12,16,4)
			p:Dock(TOP)
			p.DoClick = function(butn)
				if PS_CustomizerPanel:IsVisible() then
					PS_CustomizerPanel:Close()
				else
					PS_CustomizerPanel:Open(self.item)
				end
			end
			p.Paint = function(panel, w, h)
			    if panel.Depressed then
			    	panel:SetTextColor(PS_ColorWhite)
			        draw.RoundedBox(4, 0, 0, w, h, BrandColorAlternate)
			    else
			    	panel:SetTextColor(PS_SwitchableColor)
			        draw.RoundedBox(4, 0, 0, w, h, PS_TileBGColor)
			    end
			end
		end

		p = vgui.Create('DButton', PS_DescriptionPanel)
		p:SetText("Sell for "..tostring(PS_CalculateSellPrice(LocalPlayer(), self.data)).." points")
		p:SetTextColor(PS_SwitchableColor)
		p:DockMargin(16,12,16,12)
		p:Dock(TOP)
		p.DoClick = function(butn)
			if butn:GetText()=="CONFIRM?" then
				PS_SellItem(self.item.id)
			else
				butn:SetText("CONFIRM?")
			end
		end
		p.Paint = function(panel, w, h)
		    if panel.Depressed then
		    	panel:SetTextColor(PS_ColorWhite)
		        draw.RoundedBox(4, 0, 0, w, h, BrandColorAlternate)
		    else
		    	panel:SetTextColor(PS_SwitchableColor)
		        draw.RoundedBox(4, 0, 0, w, h, PS_TileBGColor)
		    end
		end

	end

end

function PANEL:Deselect()
	if not self:IsSelected() then return end
	PS_SelectedPanel = nil

	PS_HoverData = nil
	PS_HoverCfg = nil
	PS_HoverItemID = nil

	if IsValid(PS_HoverCSModel) then PS_HoverCSModel:Remove() end

	if IsValid(PS_DescriptionPanel) then
		for k,v in pairs(PS_DescriptionPanel:GetChildren()) do
			v:Remove()
		end
	end
end

function PANEL:IsSelected()
	return PS_SelectedPanel==self
end

function PANEL:SetProduct(product)
	self.data = product
	self.item = nil
	self.product = true
	self:Setup()
end

function PANEL:SetItem(itemdata, uniqitemdata)
	self.data = itemdata
	self.item = uniqitemdata
	self.product = false
	self:Setup()
end

function PANEL:Setup()
	local DModelPanel = vgui.Create('DModelPanel', self)
	--DModelPanel:SetModel(self.data.model)
	DModelPanel.model2set = self.data.model

	DModelPanel:Dock(FILL)

	function DModelPanel:LayoutEntity(ent)
		if self:GetParent().hovered then
			ent:SetAngles(Angle(0, ent:GetAngles().y + (RealFrameTime()*120), 0))
		end
		
		PS_PreviewShopModel(self, self:GetParent().data)
	end
	
	function DModelPanel:OnMousePressed(b)
		self:GetParent():OnMousePressed(b)
	end

	function DModelPanel:OnCursorEntered()
		self:GetParent():OnCursorEntered()
	end
	
	function DModelPanel:OnCursorExited()
		self:GetParent():OnCursorExited()
	end

	DModelPanel.Paint = function(dmp,w,h)
		if dmp.model2set then
			-- might be a workshop model, will be an error till user clicks it and it appears in the preview
			dmp:SetModel(dmp.model2set)
			dmp.model2set = nil
		end
		
		if ( !IsValid( dmp.Entity ) ) then return end
		
		PS_PreRender(self.data, (self.item or {}).cfg)

		local x, y = dmp:LocalToScreen( 0, 0 )

		dmp:LayoutEntity( dmp.Entity )

		local ang = dmp.aLookAngle
		if ( !ang ) then
			ang = ( dmp.vLookatPos - dmp.vCamPos ):Angle()
		end

		cam.Start3D( dmp.vCamPos, ang, dmp.fFOV, x, y, w, h, 5, dmp.FarZ )

		render.SuppressEngineLighting( true )
		render.SetLightingOrigin( dmp.Entity:GetPos() )
		render.ResetModelLighting( dmp.colAmbientLight.r / 255, dmp.colAmbientLight.g / 255, dmp.colAmbientLight.b / 255 )
		render.SetBlend( ( dmp:GetAlpha() / 255 ) * ( dmp.colColor.a / 255 ) )

		for i = 0, 6 do
			local col = dmp.DirectionalLight[ i ]
			if ( col ) then
				render.SetModelLighting( i, col.r / 255, col.g / 255, col.b / 255 )
			end
		end

		dmp:DrawModel()

		render.SuppressEngineLighting( false )
		cam.End3D()

		dmp.LastPaint = RealTime()

		PS_PostRender()
	end
end

local ownedcheckmark = Material("icon16/accept.png")
local visiblemark = Material("icon16/eye.png")

function PANEL:Think()
	if not self.product and self:IsSelected() then
		local c = input.IsMouseDown(MOUSE_LEFT)
		if c and not self.lastc then
			if not PS_MouseInsidePanel(self) and not PS_MouseInsidePanel(PS_PreviewPane) then
				self:Deselect()
			end
		end
		self.lastc = c
	end

	self.fademodel = false
	self.barcolor = nil
	self.barheight = nil
	self.text = nil
	self.textcolor = nil
	self.textfont = nil
	self.icon = nil
	self.icontext = nil
	self.BGColor = PS_TileBGColor

	if self.product then
		local buystatus = LocalPlayer():PS_CanBuyStatus(self.data)	
		if buystatus == PS_BUYSTATUS_OK then
			self.barcolor = Color(0, 112, 0, 160)
		else
			self.fademodel = true
			if buystatus == PS_BUYSTATUS_AFFORD then
				self.barcolor = Color(112, 0, 0, 160)
			else
				self.barcolor = Color(72, 72, 72, 160)
			end
		end
		local c = LocalPlayer():PS_CountItem(self.data.class)
		if c>0 then
			self.icon = ownedcheckmark
			if c>1 then
				self.icontext = tostring(c).."x"
			end
		end
		if self.hovered then
			self.barheight = 30
			self.textfont = "PS_Price"
			if self.prebuyclick then
				self.text = self.data.price == 0 and ">  GET  <" or ">  BUY  <"
			else
				self.text = self.data.price == 0 and "FREE" or "-"..tostring(self.data.price)
			end
		else
			self.barheight = 20
			self.textfont = "PS_ProductName"
			self.text = self.data.name
		end
		self.textcolor = PS_ColorWhite
	else
		if self.item.eq then
			self.icon = visiblemark
		else
			if not self.data.never_equip then
				self.fademodel = true
			end
		end
		self.barheight = 20
		self.textfont = "PS_ProductName"
		self.text = self.data.name
		local leqc = 0
		local totalc = 0
		for k,v in ipairs(LocalPlayer().PS_Items or {}) do
			local odata = PS_Items[v.class]
			if odata and self.data.name == odata.name then
				totalc = totalc+1
				if v.id <= self.item.id then
					leqc = leqc+1
				end
			end
		end
		if totalc > 1 then
			self.text = self.text .. " (" .. tostring(leqc) .. ")"
		end
		self.textcolor = PS_SwitchableColor
		if self:IsSelected() then
			self.BGColor = PS_DarkMode and Color(53, 53, 53, 255) or Color(192,192,255,255)
			if self.hovered then
				self.barheight = 30
				self.textfont = "PS_Price"
				self.text = self.item.eq and "HOLSTER" or "EQUIP"
			end
		elseif self.hovered then
			self.BGColor = PS_DarkMode and Color(43, 43, 43, 255) or Color(216,216,248,255)
		end
	end
end

function PANEL:Paint(w,h)
	surface.SetDrawColor(self.BGColor)
	surface.DrawRect(0, 0, w,h)
end

function PANEL:PaintOver(w,h)
	if self.fademodel then
		local c = self.BGColor
		surface.SetDrawColor(Color(c.r,c.g,c.b,144))
		surface.DrawRect(0, 0, w,h)
	end

	if self.icon then
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(self.icon)
		surface.DrawTexturedRect( w-20, 4, 16, 16 )

		if self.icontext then
			draw.SimpleText(self.icontext, "PS_ProductName", self:GetWide() - 22, 11, PS_SwitchableColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)				
		end
	end

	if self.barcolor then
		surface.SetDrawColor(self.barcolor)
		surface.DrawRect(0, self:GetTall() - self.barheight, self:GetWide(), self.barheight)
	end

	draw.SimpleText(self.text, self.textfont, self:GetWide() / 2, self:GetTall() - (self.barheight / 2), self.textcolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)	
end

vgui.Register('DPointShopItem', PANEL, 'DPanel')
