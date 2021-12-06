-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
AMMO_PURCHASE_OPTIONS = AMMO_PURCHASE_OPTIONS or {
    weapon_pistol = {500},
    weapon_357 = {500},
    weapon_smg1 = {1000},
    weapon_crossbow = {1500, 5},
}

timer.Simple(0, function()
    for k, v in ipairs(weapons.GetList()) do
        if v.GunType then
            -- defined in 2_weapons.lua
            local opt = GUNTYPE_BASE_REFILL_PRICE[v.GunType]
            assert(opt)

            AMMO_PURCHASE_OPTIONS[v.ClassName] = {opt}
        end
    end
end)

-- Return price, amount, ammotype
function GetAmmoPurchaseOption(ply)
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) then return end
    local opt = AMMO_PURCHASE_OPTIONS[wep:GetClass()]

    if not opt then
        local prod = SS_Products[wep:GetClass()]
        if not prod or not prod.AmmoTypeAndAmount then return end
        local ty, am = prod:AmmoTypeAndAmount(wep)

        return {prod.price, am, ty}
    end

    local finalopt = {}

    if opt then
        table.insert(finalopt, wep:GetNWFloat("ammo_price_override", opt[1]))
        table.insert(finalopt, opt[2] or math.max(wep:GetMaxClip1(), 1))
        table.insert(finalopt, opt[3] or wep:GetPrimaryAmmoType()) --note: could be id or string

        return finalopt
    end
end

if CLIENT then
    local function BuyAmmo()
        net.Start("BuyAmmo")
        net.SendToServer()
    end

    concommand.Add("gmod_undo", BuyAmmo)
    concommand.Add("+gmod_undo", BuyAmmo)
    concommand.Add("undo", BuyAmmo)
    concommand.Add("+undo", BuyAmmo)

    hook.Add("HUDPaint", "BuyAmmoNotification", function()
        local wep = LocalPlayer():GetActiveWeapon()

        -- note: slam uses clip2/secondary
        if IsValid(wep) and wep:Clip1() == 0 and LocalPlayer():GetAmmoCount(wep:GetPrimaryAmmoType()) == 0 then
            local opt = GetAmmoPurchaseOption(LocalPlayer())

            if opt then
                local bind = (input.LookupBinding("gmod_undo") or ""):upper()
                draw.WordBox(8, ScrW() / 2, ScrH() - 10, "Press " .. (bind == "" and "[bind Undo in options]" or bind) .. " to buy " .. tostring(opt[2]) .. " rounds for this weapon for " .. tostring(opt[1]) .. " points", "Trebuchet24", Color(0, 0, 0, 150), Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
            end
        end
    end)
else
    util.AddNetworkString("BuyAmmo")

    net.Receive("BuyAmmo", function(len, ply)
        local opt = GetAmmoPurchaseOption(ply)

        if opt then
            if not ply:SS_HasPoints(opt[1]) then
                ply:Notify("You can't afford any more ammo!")

                return
            end

            ply:SS_TryTakePoints(opt[1]) -- no callback to improve latency
            ply:GiveAmmo(opt[2], opt[3])
            ply:Notify("Bought " .. tostring(opt[2]) .. " rounds for " .. tostring(opt[1]) .. " points")

            if ply:GetActiveWeapon():Clip1() == 0 and ply:GetActiveWeapon().Reload then
                ply:GetActiveWeapon():Reload()
            end
        else
            ply:Notify("Can't buy ammo. Equip the weapon you want ammo for!")
        end
    end)
end
