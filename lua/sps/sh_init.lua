-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

AddCSLuaFile()

include("net_hd.lua")
include("config.lua")

PS_Categories = PS_Categories or {}
PS_Products = PS_Products or {}
PS_Items = PS_Items or {}

function PS_AngleGen(func)
	local ang = Angle()
	func(ang)
	return ang
end

function PS_GenericProduct(product)
	product.price = product.price or 0
	PS_Products[product.class] = product

	if product.model then
		util.PrecacheModel(product.model)
		if product.workshop then
			register_workshop_model(product.model, product.workshop)
		end
	end
end

function PS_ProductlessItem(item)
	PS_Items[item.class] = item
end

function PS_PlayermodelItemProduct(item)
	item.playermodel = true

	item.PlayerSetModelOrig = item.PlayerSetModel
	item.PlayerSetModel = function(self, ply)
		--if ply:GetModel()~=self.model then 
			ply:SetModel(self.model)
			--end
		if self.PlayerSetModelOrig then
			self:PlayerSetModelOrig(ply)
		end
	end

	--gets called just before this object changes state
	item.OnChangeEquip = function(self, ply, eq)
		if eq then
			for k,v in ipairs(ply.PS_EQItems) do
				if PS_Items[v.class] and PS_Items[v.class].PlayerSetModel then
					ply:PS_EquipItem(v.id, false)
				end
			end
		end
	end

	item.invcategory = "Playermodels"

	PS_ItemProduct(item)
end

--ITEMS are stuff that is saved in the database
function PS_ItemProduct(item)
	if item.wear then
		local itmcw = (item.configurable or {}).wear or {}
		local xscale = itmcw.xs or {max=(item.maxscale or 1.0)}
		local yscale = itmcw.ys or {max=(item.maxscale or 1.0)}
		local zscale = itmcw.zs or {max=(item.maxscale or 1.0)}
		xscale.min = xscale.min or 0.05 --(xscale.max/20.0)
		yscale.min = yscale.min or 0.05 --(yscale.max/20.0)
		zscale.min = zscale.min or 0.05 --(zscale.max/20.0)
		item.configurable = {
			color = {max=5.0},
			wear = {
				x={min=-16.0,max=16.0},
				y={min=-16.0,max=16.0},
				z={min=-16.0,max=16.0},
				xs=xscale,
				ys=yscale,
				zs=zscale
			},
			imgur = true
		}
		item.accessory_slot = true
		item.invcategory = "Accessories"
	end

	PS_Items[item.class] = item

	product = item

	product.keepnotice = "This "..((item.price or 0)==0 and "item" or "purchase").." is kept forever unless you "..((item.price or 0)==0 and "return" or "sell").." it."

	function product:OnBuy(ply)
		ply:PS_GiveItem(self.class)
		net.Start("PS_PointOutInventory")
		net.Send(ply)
	end

	PS_GenericProduct(product)
end

function PS_DeathKeepnotice(product)
	product.keepnotice = "This "..((product.price or 0)==0 and "item" or "purchase").." will be lost if you die or log out."
end

function PS_WeaponProduct(product)
--[[	wt = weapons.GetStored(product.class)
	if wt and wt.WorldModel then
		product.model = wt.WorldModel
	end ]]
	product.OnBuyOrig = product.OnBuy

	PS_DeathKeepnotice(product)

	function product:OnBuy(ply)
		ply:Give(self.class)
		ply:SelectWeapon(self.class)

		if self.OnBuyOrig then
			self:OnBuyOrig(ply)
		end
	end

	PS_GenericProduct(product)
end

function PS_WeaponAndAmmoProduct(product)

	PS_DeathKeepnotice(product)

	function product:OnBuy(ply)
		if not ply:HasWeapon(self.class) then
			ply:Give(self.class)
			local wep = ply:GetWeapon(self.class)
			if wep:Clip1()>0 then wep:SetClip1(0) end
			ply:SetAmmo(self.amount, self.ammotype)
		else
			ply:GiveAmmo(self.amount, self.ammotype)
		end
		ply:SelectWeapon(self.class)
	end

	PS_GenericProduct(product)
end

function PS_AmmoProduct(product)
	product.class="ammo_"..product.ammotype.."_"..tostring(product.amount)

	PS_DeathKeepnotice(product)

	function product:OnBuy(ply)
		ply:GiveAmmo(self.amount, self.ammotype)
	end

	PS_GenericProduct(product)
end

function PS_UniqueModelProduct(product)
	product.playermodel = true
	product.CanBuyStatusOrig = product.CanBuyStatus
	product.OnBuyOrig = product.OnBuy
	function product:CanBuyStatus(ply)
		if self.CanBuyStatusOrig then
			local s = self:CanBuyStatusOrig(ply) or PS_BUYSTATUS_OK
			if s~=PS_BUYSTATUS_OK then
				return s
			end
		end

		for k,v in pairs(player.GetAll()) do
			if v:GetNWString("uniqmodl") == self.name and v:Alive() then
				return v==ply and PS_BUYSTATUS_OWNED or PS_BUYSTATUS_TAKEN
			end
		end

		return PS_BUYSTATUS_OK
	end

	PS_DeathKeepnotice(product)

	function product:OnBuy(ply)
		ply:SetNWString("uniqmodl",self.name)
		ply:SetModel(self.model)

		if self.OnBuyOrig then
			self:OnBuyOrig(ply)
		end
	end

	PS_GenericProduct(product)
end

function PS_Initialize()
	include('sps/categories.lua')

	local files, _ = file.Find('sps/items/*', 'LUA')
			
	for _, name in pairs(files) do
		AddCSLuaFile('sps/items/' .. name)
		include('sps/items/' .. name)
	end
end


local Player = FindMetaTable('Player')

function Player:PS_GetDonation()
	return self.PS_Donation or 0
end

function Player:PS_GetPoints()
	return self.PS_Points or 0
end

function Player:PS_HasPoints(points)
	return (self.PS_Points or 0) >= points
end

PS_BUYSTATUS_OK = 0
PS_BUYSTATUS_AFFORD = 1
PS_BUYSTATUS_OWNED = 2
PS_BUYSTATUS_OWNED_MULTI = 3
PS_BUYSTATUS_SLOTS = 4
PS_BUYSTATUS_TAKEN = 5
PS_BUYSTATUS_PRIVATETHEATER = 6
PS_BUYSTATUS_CANTBUILD = 7
PS_BUYSTATUS_PONYONLY = 8
PS_BUYSTATUS_PREVIOUS_SLOTS = 9

PS_BuyStatusMessage = {
	"You can't afford this.",
	"You already own this.",
	"You own the maximum number of these.",
	"Buy more accessory slots (in Upgrades) first.",
	"Someone else is using this - kill them.",
	"You must own a private theater to use this.",
	"You can't build here.",
	"You must own the ponymodel to buy this.",
	"Buy the previous slots to unlock this one."
}

function Player:PS_CanBuyStatus(product)
	local buycode = PS_BUYSTATUS_OK
	if product.CanBuyStatus then
		buycode = product:CanBuyStatus(self) or PS_BUYSTATUS_OK
	end
	
	if buycode == PS_BUYSTATUS_OK then
		if not self:PS_HasPoints(product.price) then
			buycode = PS_BUYSTATUS_AFFORD
		end

		local maxcount = (product.accessory_slot and self:PS_AccessorySlots()*(product.perslot or 1)) or product.maxowned or 1
		if self:PS_CountItem(product.class) >= maxcount then
			buycode = product.accessory_slot and PS_BUYSTATUS_SLOTS or (maxcount>1 and PS_BUYSTATUS_OWNED_MULTI or PS_BUYSTATUS_OWNED)
		end
	end
	
	return buycode
end

PS_EQUIPSTATUS_OK = 0
PS_EQUIPSTATUS_WEARABLE = 1
PS_EQUIPSTATUS_IMGUR = 2
PS_EQUIPSTATUS_NEVER = 3

PS_EquipStatusMessage = {
	"Buy more accessory slots (in Upgrades) to wear more items.",
	"You can only equip 4 different imgur materials at once.",
	"This item can't be equipped."
}

function Player:PS_CanEquipStatus(class, cfg, already_equipped)
	local item = PS_Items[class]
	if item.never_equip then
		return PS_EQUIPSTATUS_NEVER
	end
	if item.accessory_slot then
		local c = already_equipped and 0 or 1/(item.perslot or 1)
		for k,v in pairs(self.PS_Items) do
			if v.eq and (PS_Items[v.class] or {}).accessory_slot then
				c = c+(1/(PS_Items[v.class].perslot or 1))
			end
		end
		if c>self:PS_AccessorySlots() then 
			return PS_EQUIPSTATUS_WEARABLE
		end
	end
	if cfg.imgur then
		local urls = {[cfg.imgur.url]=true}
		for k,v in pairs(self.PS_Items) do
			if v.eq and v.cfg.imgur then
				urls[v.cfg.imgur.url]=true
			end
		end
		if table.Count(urls)>4 then
			return PS_EQUIPSTATUS_IMGUR
		end
	end
	return PS_EQUIPSTATUS_OK
end

function Player:PS_FindItem(item_id)
	for k,v in ipairs(self.PS_Items or {}) do
		if v.id == item_id then
			return k
		end
	end
	return false
end

function Player:PS_HasItem(item_class)
	for k,v in ipairs(self.PS_Items or {}) do
		if v.class == item_class then
			return true
		end
	end
	return false
end

function Player:PS_CountItem(item_class)
	local c =0
	for k,v in ipairs(self.PS_Items or {}) do
		if v.class == item_class then
			c=c+1
		end
	end
	return c
end

function Player:PS_AccessorySlots()
	local c = 1
	for k,v in ipairs(self.PS_Items or {}) do
		if v.class:StartWith("accslot_") then
			c=c+1
		end
	end
	return c
end
