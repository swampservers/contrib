-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
SS_Products = SS_Products or {}

function SS_Product(product)
    assert(product.price)
    product.SS_Product_CannotBuy = product.CannotBuy or function() end

    function product:CannotBuy(ply)
        if ply.SQLCreatingItem then return "Database lock, try again." end

        return product:SS_Product_CannotBuy(ply) or (not ply:SS_HasPoints(self.price) and SS_CANNOTBUY_AFFORD)
    end

    assert(product.OnBuy)
    product.SS_Product_OnBuy = product.OnBuy

    function product:OnBuy(ply)
        local function finish_buy()
            self:SS_Product_OnBuy(ply)
            ply:Notify('Bought ', self:GetName(), ' for ', self.price, ' points')
        end

        if self.price > 0 then
            ply:SS_TryTakePoints(self.price, finish_buy)
        else
            finish_buy()
        end
    end

    -- if product.model then
    --     util.PrecacheModel(product.model)
    --     if product.workshop then
    --         register_workshop_model(product.model, product.workshop)
    --     end
    -- end
    -- product.primaryaction = {
    --     Text = function(self, second) return second and (self.price == 0 and ">  GET  <" or ">  BUY  <") or (self.price == 0 and "FREE" or "-" .. tostring(self.price)) end
    -- }
    -- OnClient= function(self, second)
    --     if second then
    --         surface.PlaySound("UI/buttonclick.wav")
    --         SS_BuyProduct(self.class)
    --     end
    -- end
    SS_ItemOrProduct(product)
    local tab = _SS_TABADDTARGET.layout
    table.insert(tab[#tab].products, product)
    SS_Products[product.class] = product

    if SS_ReloadMenu then
        SS_ReloadMenu()
    end
end

function SS_GenerateItem(ply, class, specs)
    local item = SS_MakeItem(ply, {
        class = class,
        id = -1,
        specs = specs or {},
        cfg = {},
        eq = true,
    })

    item:Sanitize()

    return item
end

function SS_ItemProduct(item)
    local product = table.Copy(item) --TODO maybe only copy needed keys
    product.keepnotice = "This " .. ((product.price or 0) == 0 and "item" or "purchase") .. " is kept forever unless you " .. ((product.price or 0) == 0 and "return" or "sell") .. " it."
    product.sample_item = SS_GenerateItem(SS_SAMPLE_ITEM_OWNER, product.itemclass or product.class, table.Copy(product.defaultspecs or {}))

    function product:CannotBuy(ply)
        local maxcount = (self.accessory_slot and ply:SS_AccessorySlots() * (self.perslot or 1)) or self.maxowned or 1
        if ply:SS_CountItem(self.class) >= maxcount then return self.accessory_slot and "Buy more accessory slots (in Upgrades) first." or (maxcount > 1 and SS_CANNOTBUY_OWNEDMULTI or SS_CANNOTBUY_OWNED) end
    end

    function product:OnBuy(ply)
        ply:SS_GiveNewItem(SS_GenerateItem(ply, self.itemclass or self.class, table.Copy(self.defaultspecs or {})))
    end

    SS_Product(product)
end

function SS_WeaponProduct(product)
    product.SS_WeaponProduct_OnBuy = product.OnBuy or function() end

    function product:OnBuy(ply)
        if not ply:HasWeapon(self.class) then
            ply:Give(self.class)
        end

        ply:SelectWeapon(self.class)
        self:SS_WeaponProduct_OnBuy(ply)
    end

    function product:CannotBuy(ply)
        if ply:HasWeapon(self.class) then
            -- hack to make client switch to the weapon
            if SERVER or ply:UsingWeapon(self.class) then
                ply:SelectWeapon(self.class)

                return "You already have this weapon!"
            end
        end

        return not ply:Alive() and "You're dead!"
    end

    SS_DeathKeepnotice(product)
    SS_Product(product)
end

function SS_WeaponAndAmmoProduct(product)
    -- used by buyammo system
    function product:AmmoTypeAndAmount(wep)
        local ammotype, ammogive = (self.ammotype or game.GetAmmoName(self.clip2 and wep:GetSecondaryAmmoType() or wep:GetPrimaryAmmoType())), (self.amount or math.max(1, (self.clip2 and wep:GetMaxClip2() or wep:GetMaxClip1()) or 0))
        assert(ammotype ~= nil and ammogive > 0, self.class .. " " .. ammogive .. " " .. (ammotype or "nil"))

        return ammotype, ammogive
    end

    function product:OnBuy(ply)
        local wep, new = nil, false

        if ply:HasWeapon(self.class) then
            wep = ply:GetWeapon(self.class)
        else
            wep = ply:Give(self.class)
            new = true
        end

        local ammotype, ammogive = self:AmmoTypeAndAmount(wep)

        if new then
            if (self.clip2 and wep:GetMaxClip2() or wep:GetMaxClip1()) == -1 then
                ply:SetAmmo(ammogive, ammotype)
            else
                wep:SetClip1(wep:GetMaxClip1())
                ply:SetAmmo(ammogive - wep:Clip1(), ammotype)
            end
        else
            ply:GiveAmmo(ammogive, ammotype)
        end

        ply:SelectWeapon(self.class)
        -- if wep:GetMaxClip1()>0 and wep:Clip1()==0 then wep:Reload() end
    end

    function product:CannotBuy(ply)
        return not ply:Alive() and "You're dead!"
    end

    -- if ply:HasWeapon(self.class) then
    --     local wep = ply:GetWeapon(self.class)
    --     local ammotype,ammogive = self:AmmoTypeAndAmount(wep)
    --     local limit = self.maxammo or game.GetAmmoMax(game.GetAmmoID(ammotype)) or 0
    --     if (limit != 0 and ply:GetAmmoCount(ammotype) >= limit) then return "You can't carry any more of this ammo" end
    -- end
    SS_DeathKeepnotice(product)
    SS_Product(product)
end

function SS_AmmoProduct(product)
    product.class = "ammo_" .. product.ammotype .. "_" .. tostring(product.amount)

    function product:CannotBuy(ply)
        return not ply:Alive() and "You're dead!"
    end

    function product:OnBuy(ply)
        ply:GiveAmmo(self.amount, self.ammotype)
    end

    SS_DeathKeepnotice(product)
    SS_Product(product)
end

function SS_UniqueModelProduct(product)
    product.price = product.price or 0
    product.playermodel = true
    product.SS_UniqueModelProduct_CannotBuy = product.CannotBuy or function() end

    function product:CannotBuy(ply)
        local s = self:SS_UniqueModelProduct_CannotBuy(ply)
        if s then return s end

        for k, v in pairs(player.GetAll()) do
            if v:GetNWString("uniqmodl") == self:GetName() and v:Alive() then return v == ply and SS_CANNOTBUY_OWNED or (v:Nick() .. " is using this - kill them.") end
        end
    end

    product.SS_UniqueModelProduct_OnBuy = product.OnBuy or function() end

    function product:OnBuy(ply)
        ply:SetNWString("uniqmodl", self:GetName())
        ply:SetModel(self.model)
        self:SS_UniqueModelProduct_OnBuy(ply)
    end

    SS_DeathKeepnotice(product)
    SS_Product(product)
end

SS_CANNOTBUY_AFFORD = "You can't afford this."
SS_CANNOTBUY_OWNED = "You already own this."
SS_CANNOTBUY_OWNEDMULTI = "You own the maximum number of these."

function SS_DeathKeepnotice(product)
    product.keepnotice = "This " .. ((product.price or 0) == 0 and "item" or "purchase") .. " will be lost if you die or log out."
end
