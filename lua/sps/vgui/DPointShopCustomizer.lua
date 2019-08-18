
local PANEL = {}

function PANEL:Close()
	if IsValid(PS_PopupPanel) then
		PS_ShopMenu:SetParent()
		PS_PopupPanel:Remove()
	end
	self:SetVisible(false)
	PS_InventoryPanel:SetVisible(true)
end

function PANEL:Open(item)
	for k,v in pairs(self:GetChildren()) do
		v:Remove()
	end

	if IsValid(PS_PopupPanel) then
		PS_ShopMenu:SetParent()
		PS_PopupPanel:Remove()
	end

	PS_PopupPanel = vgui.Create("DFrame")
	PS_PopupPanel:SetPos(0,0)
	PS_PopupPanel:SetSize(ScrW(), ScrH())
	PS_PopupPanel:SetDraggable(false)
	PS_PopupPanel:ShowCloseButton(false)
	PS_PopupPanel:SetTitle("")
	PS_PopupPanel.Paint = function() end
	PS_PopupPanel:MakePopup()

	PS_ShopMenu:SetParent(PS_PopupPanel)

	self.itemobj = item
	self.item = PS_Items[item.class]
	self.cfg = table.Copy(item.cfg)
	self.wear = LocalPlayer():IsPony() and "wear_p" or "wear_h"

	self:SetVisible(true)
	PS_InventoryPanel:SetVisible(false)

	self:SetBackgroundColor(PS_GridBGColor)


	local inner = vgui.Create("DPanel", self)
	inner:SetBackgroundColor(PS_TileBGColor)
	inner:DockMargin(8,8,8,8)
	inner:Dock(FILL)


	local p = vgui.Create("DLabel", inner)
	p:SetFont("PS_LargeTitle")
	p:SetText("βUSTOMIZER")
	p:SetColor(PS_ColorBlack)
	p:SetContentAlignment(5)
	p:SizeToContents()
	p:DockMargin(14,6,14,10)
	p:Dock(TOP)

	local bot = vgui.Create("DPanel", inner)
	bot.Paint = function() end
	bot:SetTall(64)
	bot:Dock(BOTTOM)

	p = vgui.Create('DButton', bot)
	p:SetText("Reset")
	p:SetFont("PS_DESCTITLEFONT")
	p:SetWide(200)
	p.Paint = function(self,w,h)
		if self:IsHovered() then
			surface.SetDrawColor(0,0,0,100)
			surface.DrawRect(0,0,w,h)
		end
	end
	p.DoClick = function(butn)
		self.cfg = {}
		self:UpdateCfg()
		self:SetupControls()
	end
	p:Dock(LEFT)

	p = vgui.Create('DButton', bot)
	p:SetText("Cancel")
	p:SetFont("PS_DESCTITLEFONT")
	p:SetWide(200)
	p.Paint = function(self,w,h)
		if self:IsHovered() then
			surface.SetDrawColor(0,0,0,100)
			surface.DrawRect(0,0,w,h)
		end
	end
	p.DoClick = function(butn)
		PS_HoverCfg = self.itemobj.cfg
		self:Close()
	end
	p:Dock(LEFT)

	p = vgui.Create('DButton', bot)
	p:SetText("Done")
	p:SetFont("PS_DESCTITLEFONT")
	p.Paint = function(self,w,h)
		if self:IsHovered() then
			surface.SetDrawColor(0,0,0,100)
			surface.DrawRect(0,0,w,h)
		end
	end
	p.DoClick = function(butn)
		PS_ConfigureItem(self.itemobj.id, self.cfg)
		self:Close()
	end
	p:Dock(FILL)

	self.controlzone = vgui.Create("DPanel", inner)
	self.controlzone:Dock(FILL)
	self:SetupControls()
end

function PANEL:SetupControls()
	for k,v in pairs(self.controlzone:GetChildren()) do
		v:Remove()
	end

	local wearzone = vgui.Create("DPanel", self.controlzone)
	wearzone:SetWide(400)
	wearzone:Dock(LEFT)

	wearzone = vgui.Create( "DScrollPanel", wearzone )
	wearzone:Dock(FILL)

	local function LabelMaker(parent, text, top)
		local p2 = nil
		if not top then
			p2 = vgui.Create( "Panel", parent)
			p2:DockMargin(16,16,16,0)
			p2:Dock(TOP)
			if parent.AddItem then parent:AddItem(p2) end
		end

		local p = vgui.Create("DLabel", p2 or parent)
		p:SetFont("PS_DESCINSTFONT")
		p:SetText(text)
		p:SetColor(PS_ColorBlack)
		
		p:SizeToContents()
		if top then
			p:SetContentAlignment(5)
			p:DockMargin(16,16,16,16)
			p:Dock(TOP)
			if parent.AddItem then parent:AddItem(p) end
		else
			p:DockMargin(0,0,0,0)
			p:Dock(LEFT)
		end
	
		return p2
	end

	local function SliderMaker(parent, text)
		local p = vgui.Create( "DNumSlider", parent)
		p:SetText(text)
		p:SetDecimals(2)
		p:SetDark(true)
		p:DockMargin(32,8,32,0)
		p:Dock(TOP)
		p.TextArea:SetPaintBackground(true)

		p:SetTall(24)

		if parent.AddItem then parent:AddItem(p) end

		return p
	end

	local function CheckboxMaker(parent, text)
		local p2 = vgui.Create( "Panel", parent)
		p2:DockMargin(16,16,16,0)
		p2:Dock(TOP) --retarded wrapper

		local p3 = vgui.Create( "DCheckBox", p2)
		--p:SetText(text)
		p3:SetDark(true)
		p3:SetPos(0,2)
		--p:SetTall(24)

		local p = vgui.Create("DLabel", p2 or parent)
		p:SetFont("PS_DESCFONT")
		p:SetText(text)
		p:SetColor(PS_ColorBlack)
		p:SetPos(24,0)

		p:SizeToContents()

		--p2:SizeToChildren()

		if parent.AddItem then parent:AddItem(p2) end

		return p3
	end

	local pone = LocalPlayer():IsPony()
	local suffix = pone and "_p" or "_h"

	if (self.item.configurable or {}).wear then	
		LabelMaker(wearzone, "Position ("..(pone and "pony" or "human")..")", true)

		local p = vgui.Create( "Panel", wearzone )
		p:DockMargin(32,8,32,0)
		p:Dock(TOP)
		ATTACHSELECT = vgui.Create( "DComboBox", p )
		ATTACHSELECT:SetValue( (self.cfg[self.wear] or {}).attach or (pone and (self.item.wear.pony or {}).attach) or self.item.wear.attach )
		for k,v in pairs(PS_Attachments) do
			ATTACHSELECT:AddChoice(k)
		end
		ATTACHSELECT.OnSelect = function( panel, index, value )
			self.cfg[self.wear] = self.cfg[self.wear] or {}
			self.cfg[self.wear].attach = value
			self:UpdateCfg()
		end
		ATTACHSELECT:SetWide(200)
		ATTACHSELECT:Dock(RIGHT)

		p = vgui.Create ( "DLabel", p )
		p:Dock( LEFT )
		p:SetText("Attach to")
		p:SetDark(true)


		LabelMaker(wearzone, "Offset")

		local translate = (self.cfg[self.wear] or {}).pos or (pone and (self.item.wear.pony or {}).translate) or self.item.wear.translate

		XSL = SliderMaker(wearzone, "Forward/Backward")
		XSL:SetMinMax(self.item.configurable.wear.x.min,self.item.configurable.wear.x.max)
		XSL:SetValue(translate.x)
		YSL = SliderMaker(wearzone, "Left/Right")
		YSL:SetMinMax(self.item.configurable.wear.y.min,self.item.configurable.wear.y.max)
		YSL:SetValue(translate.y)
		ZSL = SliderMaker(wearzone, "Up/Down")
		ZSL:SetMinMax(self.item.configurable.wear.z.min,self.item.configurable.wear.z.max)
		ZSL:SetValue(translate.z)


		LabelMaker(wearzone, "Angle")

		local rotate = (self.cfg[self.wear] or {}).ang or (pone and (self.item.wear.pony or {}).rotate) or self.item.wear.rotate

		XRSL = SliderMaker(wearzone, "Pitch")
		XRSL:SetMinMax(-180,180)
		XRSL:SetValue(rotate.p)
		YRSL = SliderMaker(wearzone, "Yaw")
		YRSL:SetMinMax(-180,180)
		YRSL:SetValue(rotate.y)
		ZRSL = SliderMaker(wearzone, "Roll")
		ZRSL:SetMinMax(-180,180)
		ZRSL:SetValue(rotate.r)


		local scalelabel = LabelMaker(wearzone, "Scale")

		local itmcw = self.item.configurable.wear

		local scale = (self.cfg[self.wear] or {}).scale or (pone and (self.item.wear.pony or {}).scale) or self.item.wear.scale
		if isnumber(scale) then
			scale = Vector(scale,scale,scale)
		end

		SXSL = SliderMaker(wearzone, "Length")
		SXSL:SetMinMax(itmcw.xs.min,itmcw.xs.max)
		SXSL:SetValue(scale.x)
		SYSL = SliderMaker(wearzone, "Width")
		SYSL:SetMinMax(itmcw.ys.min,itmcw.ys.max)
		SYSL:SetValue(scale.y)
		SZSL = SliderMaker(wearzone, "Height")
		SZSL:SetMinMax(itmcw.zs.min,itmcw.zs.max)
		SZSL:SetValue(scale.z)

		local function transformslidersupdate()
			self.cfg[self.wear] = self.cfg[self.wear] or {}
			self.cfg[self.wear].pos = Vector(XSL:GetValue(), YSL:GetValue(), ZSL:GetValue())
			self.cfg[self.wear].ang = Angle(XRSL:GetValue(), YRSL:GetValue(), ZRSL:GetValue())
			self.cfg[self.wear].scale = Vector(SXSL:GetValue(), SYSL:GetValue(), SZSL:GetValue())
			self:UpdateCfg()
		end

		XSL.OnValueChanged = transformslidersupdate
		YSL.OnValueChanged = transformslidersupdate
		ZSL.OnValueChanged = transformslidersupdate
		XRSL.OnValueChanged = transformslidersupdate
		YRSL.OnValueChanged = transformslidersupdate
		ZRSL.OnValueChanged = transformslidersupdate
		SXSL.OnValueChanged = transformslidersupdate
		SYSL.OnValueChanged = transformslidersupdate
		SZSL.OnValueChanged = transformslidersupdate

		local scalebutton = vgui.Create( "DButton", scalelabel)
		scalebutton:SetText( "Use Uniform Scaling" )
		scalebutton:SetWide(160)
		scalebutton:Dock(RIGHT)
		scalebutton.DoClick = function(btn)
			if btn.UniformMode then
				btn.UniformMode = nil
				btn:SetText( "Use Uniform Scaling" )
				SXSL:SetVisible(true)
				SYSL:SetVisible(true)
				SZSL:SetVisible(true)
				SUSL:SetVisible(false)
			else
				btn.UniformMode = true
				btn:SetText( "Use Independent Scaling" )
				SXSL:SetVisible(false)
				SYSL:SetVisible(false)
				SZSL:SetVisible(false)
				SUSL:SetVisible(true)
				local v = {SXSL:GetValue(), SYSL:GetValue(), SZSL:GetValue()}
				table.sort(v, function( a, b ) return a > b end )
				SUSL:SetValue(v[2])
			end
		end

		SUSL = SliderMaker(wearzone, "Scale")
		SUSL:SetMinMax(math.max(itmcw.xs.min,itmcw.ys.min,itmcw.zs.min),math.min(itmcw.xs.max, itmcw.ys.max, itmcw.zs.max))
		SUSL.OnValueChanged = function(self)
			SXSL:SetValue(self:GetValue())
			SYSL:SetValue(self:GetValue())
			SZSL:SetValue(self:GetValue())
		end
		SUSL:SetVisible(false)
	
		if scale.x == scale.y and scale.y == scale.z then
			scalebutton:DoClick()
		end
	elseif (self.item.configurable or {}).bone then	
		LabelMaker(wearzone, "Mod ("..(LocalPlayer():IsPony() and "pony" or "human")..")", true)

		local function cleanbonename(bn)
			return bn:Replace("ValveBiped.Bip01_",""):Replace("Lrig",""):Replace("_LEG_","")
		end

		local p = vgui.Create( "Panel", wearzone )
		p:DockMargin(32,8,32,0)
		p:Dock(TOP)
		ATTACHSELECT = vgui.Create( "DComboBox", p )
		ATTACHSELECT:SetValue( cleanbonename(self.cfg["bone"..suffix] or (pone and "Scull" or "Head1")) )
		for x=0,(LocalPlayer():GetBoneCount()-1) do
			local bn = LocalPlayer():GetBoneName(x)
			local cleanname = cleanbonename(bn)
			if cleanname~="__INVALIDBONE__" then
				ATTACHSELECT:AddChoice(cleanname,bn)
			end
		end
		ATTACHSELECT.OnSelect = function( panel, index, word, value )
			self.cfg["bone"..suffix] = value
			self:UpdateCfg()
		end
		ATTACHSELECT:SetWide(200)
		ATTACHSELECT:Dock(RIGHT)

		p = vgui.Create ( "DLabel", p )
		p:Dock( LEFT )
		p:SetText("Attach to")
		p:SetDark(true)

		--bunch of copied shit
		local function transformslidersupdate()
			if self.item.configurable.scale then
				self.cfg["scale"..suffix] = Vector(SXSL:GetValue(), SYSL:GetValue(), SZSL:GetValue())
			end
			if self.item.configurable.pos then
				self.cfg["pos"..suffix] = Vector(XSL:GetValue(), YSL:GetValue(), ZSL:GetValue())
			end
			self:UpdateCfg()
		end

		local itmcw = self.item.configurable.pos

		if itmcw then
			LabelMaker(wearzone, "Offset")

			local translate = self.cfg["pos"..suffix] or Vector(0,0,0)

			XSL = SliderMaker(wearzone, "X (Along)")
			XSL:SetMinMax(itmcw.x.min,itmcw.x.max)
			XSL:SetValue(translate.x)
			YSL = SliderMaker(wearzone, "Y")
			YSL:SetMinMax(itmcw.y.min,itmcw.y.max)
			YSL:SetValue(translate.y)
			ZSL = SliderMaker(wearzone, "Z")
			ZSL:SetMinMax(itmcw.z.min,itmcw.z.max)
			ZSL:SetValue(translate.z)

			XSL.OnValueChanged = transformslidersupdate
			YSL.OnValueChanged = transformslidersupdate
			ZSL.OnValueChanged = transformslidersupdate
		end

		itmcw = self.item.configurable.scale

		if itmcw then

			local scalelabel = LabelMaker(wearzone, "Scale")

			local scale = self.cfg["scale"..suffix] or Vector(1,1,1)
			if isnumber(scale) then
				scale = Vector(scale,scale,scale)
			end

			SXSL = SliderMaker(wearzone, "X (Along)")
			SXSL:SetMinMax(itmcw.xs.min,itmcw.xs.max)
			SXSL:SetValue(scale.x)
			SYSL = SliderMaker(wearzone, "Y")
			SYSL:SetMinMax(itmcw.ys.min,itmcw.ys.max)
			SYSL:SetValue(scale.y)
			SZSL = SliderMaker(wearzone, "Z")
			SZSL:SetMinMax(itmcw.zs.min,itmcw.zs.max)
			SZSL:SetValue(scale.z)

			SXSL.OnValueChanged = transformslidersupdate
			SYSL.OnValueChanged = transformslidersupdate
			SZSL.OnValueChanged = transformslidersupdate

			local scalebutton = vgui.Create( "DButton", scalelabel)
			scalebutton:SetText( "Use Uniform Scaling" )
			scalebutton:SetWide(160)
			scalebutton:Dock(RIGHT)
			scalebutton.DoClick = function(btn)
				if btn.UniformMode then
					btn.UniformMode = nil
					btn:SetText( "Use Uniform Scaling" )
					SXSL:SetVisible(true)
					SYSL:SetVisible(true)
					SZSL:SetVisible(true)
					SUSL:SetVisible(false)
				else
					btn.UniformMode = true
					btn:SetText( "Use Independent Scaling" )
					SXSL:SetVisible(false)
					SYSL:SetVisible(false)
					SZSL:SetVisible(false)
					SUSL:SetVisible(true)
					local v = {SXSL:GetValue(), SYSL:GetValue(), SZSL:GetValue()}
					table.sort(v, function( a, b ) return a > b end )
					SUSL:SetValue(v[2])
				end
			end

			SUSL = SliderMaker(wearzone, "Scale")
			SUSL:SetMinMax(math.max(itmcw.xs.min,itmcw.ys.min,itmcw.zs.min),math.min(itmcw.xs.max, itmcw.ys.max, itmcw.zs.max))
			SUSL.OnValueChanged = function(self)
				SXSL:SetValue(self:GetValue())
				SYSL:SetValue(self:GetValue())
				SZSL:SetValue(self:GetValue())
			end
			SUSL:SetVisible(false)
		
			if scale.x == scale.y and scale.y == scale.z then
				scalebutton:DoClick()
			end

		end	
		--end bunch of copied shit

		if self.item.configurable.scale_children then
			CHILDCHECKBOX = CheckboxMaker(wearzone, "Scale child bones")
			CHILDCHECKBOX:SetValue(self.cfg["scale_children"..suffix] and 1 or 0)

			CHILDCHECKBOX.OnChange = function(checkboxself, ch)
				self.cfg["scale_children"..suffix] = ch
				self:UpdateCfg()
			end
		end
	end


	local colorzone = vgui.Create("DPanel", self.controlzone)
	--colorzone.Paint = function() end
	colorzone:Dock(FILL)

	colorzone = vgui.Create( "DScrollPanel", colorzone )
	colorzone:Dock(FILL)

	if (self.item.configurable or {}).color then
		LabelMaker(colorzone, "Appearance", true)

		local cv = Vector()
		cv:Set(self.cfg.color or self.item.color or Vector(1,1,1))
		local cvm = math.max(1,cv.x,cv.y,cv.z)

		PSCMixer = vgui.Create( "DColorMixer", colorzone)
		PSCMixer:SetPalette( true )
		PSCMixer:SetAlphaBar( false )
		PSCMixer:SetWangs( true )
		PSCMixer:SetVector(cv/cvm)
		PSCMixer:SetTall(250)
		PSCMixer:DockMargin(32,8,32,16)
		PSCMixer:Dock(TOP)

		PSBS = SliderMaker(colorzone, "Boost")
		PSBS:SetMinMax(1,self.item.configurable.color.max)
		PSBS:SetValue(cvm)

		local function colorchanged()
			self.cfg.color = PSCMixer:GetVector() * PSBS:GetValue()
			self:UpdateCfg()
		end
		
		PSCMixer.ValueChanged = colorchanged
		PSBS.OnValueChanged = colorchanged

		local matlabel = LabelMaker(colorzone, "Custom Material")

		IMGURREMOVEBUTTON = vgui.Create( "DButton", matlabel)
		IMGURREMOVEBUTTON:SetText( "Remove Custom Material" )
		IMGURREMOVEBUTTON:SetWide(160)
		IMGURREMOVEBUTTON:Dock(RIGHT)
		IMGURREMOVEBUTTON.DoClick = function(btn)
			IMGURENTRY:SetValue("")
		end

		local urlzone = vgui.Create( "Panel", colorzone)
		urlzone:DockMargin(0,8,32,0)
		urlzone:Dock(TOP)
		urlzone:SetTall(40)
		if colorzone.AddItem then colorzone:AddItem(urlzone) end

		IMGURENTRY = vgui.Create( "DTextEntry", urlzone)
		IMGURENTRY:DockMargin(32,8,32,0)
		IMGURENTRY:Dock(FILL)
		IMGURENTRY:SetPaintBackground(true)
		IMGURENTRY.OnValueChange = function(textself, new)
			local id = SanitizeImgurId(new)
			IMGURREMOVEBUTTON:SetVisible(id~=nil)
			if id then
				self.cfg.imgur = {url=id}
			else
				self.cfg.imgur = nil
			end
			self:UpdateCfg()
		end
		IMGURENTRY:SetUpdateOnType(true)
		IMGURENTRY:SetValue((self.cfg.imgur or {}).url or "")
	

		local imgurinfo = vgui.Create( "DLabel", urlzone)
		imgurinfo:SetText("Use an imgur direct URL such as:\nhttp://i.imgur.com/PxOc7TC.png\n(Right click -> Copy image address)")
		imgurinfo:SetDark(true)
		imgurinfo:Dock(RIGHT)
		imgurinfo:SetWide(100)
		imgurinfo:SizeToContents()

		


	end

end

function PANEL:UpdateCfg()
	PS_HoverCfg = self.cfg

end


vgui.Register('DPointShopCustomizer', PANEL, 'DPanel')