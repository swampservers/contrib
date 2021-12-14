-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
local ALL_ITEMS = 1
local OWNED_ITEMS = 2
local UNOWNED_ITEMS = 3
local wasf3down = false
local wascontextdown = false
OLDBINDSCONVAR = CreateClientConVar("swamp_old_binds", "0", true, false)

concommand.Add("menu_context", function()
    if not OLDBINDSCONVAR:GetBool() then
        SS_ToggleMenu()
    end
end)

concommand.Add("+menu_context", function()
    if not OLDBINDSCONVAR:GetBool() then
        SS_ToggleMenu()
    end
end)

concommand.Add("swamp_shop", function()
    SS_ToggleMenu()
end)

hook.Add("Think", "PSToggler", function()
    local isf3down = input.IsKeyDown(KEY_F3)

    if isf3down and not wasf3down then
        if OLDBINDSCONVAR:GetBool() then
            SS_ToggleMenu()
        else
            LocalPlayerNotify("The shop binding is now " .. tostring(input.LookupBinding("menu_context") or "unbound"):upper() .. " (bind +menu_context, or bind swamp_shop, or set swamp_old_binds 1)")
        end
    end

    wasf3down = isf3down
end)

concommand.Add("ps_togglemenu", function(ply, cmd, args)
    SS_ToggleMenu()
end)

function SS_ReloadMenu()
    if IsValid(SS_ShopMenu) then
        SS_ShopMenu:Remove()
    end
end

concommand.Add("ps_destroymenu", function(ply, cmd, args)
    for _, v in ipairs(vgui.GetWorldPanel():GetChildren()) do
        if v:GetClassName() == "DSSMenu" then
            v:Remove()
        end
    end

    SS_ReloadMenu()
end)

SS_ReloadMenu()

if IsValid(SS_CustomizerPanel) then
    SS_CustomizerPanel:Close()
end

if IsValid(SS_ShopMenu) then
    SS_ShopMenu:Remove()
end

function SS_ToggleMenu()
    if not IsValid(SS_ShopMenu) then
        SS_ShopMenu = vgui.Create('DSSMenu')
        SS_ShopMenu:SetVisible(false)
    end

    if SS_ShopMenu:IsVisible() then
        -- if IsValid(SS_CustomizerPanel) then
        --     SS_CustomizerPanel:Close()
        -- end
        SS_ShopMenu:Hide()
        gui.EnableScreenClicker(false)
    else
        SS_ShopMenu:Show()
        gui.EnableScreenClicker(true)
    end
end

local function OnPlayerLoad(pi, callback, ready_check, calls)
    calls = calls or 50
    local ply = pi == -1 and Me or Entity(pi)

    if IsValid(ply) and (ready_check == nil or ready_check(ply)) then
        callback(ply)
    else
        if calls < 1 then
            print("Load timed out for " .. tostring(pi))
        else
            timer.Simple(0.5, function()
                OnPlayerLoad(pi, callback, ready_check, calls - 1)
            end)
        end
    end
end

function SS_RemoveItemID(tab, id)
    for i, v in ipairs(tab) do
        if v.id == id then
            table.remove(tab, i)

            return
        end
    end
end

function SS_BuyProduct(id)
    if not SS_Products[id] then
        LocalPlayerNotify("Unknown product '" .. tostring(id) .. "'. You may need to update your binds.")

        return
    end

    print('To quickbuy this product, run: bind <key> "ps_buy ' .. id .. '"')
    net.Start('SS_BuyProduct')
    net.WriteString(id)
    net.SendToServer()
end

concommand.Add("ps_buy", function(ply, cmd, args)
    if #args < 1 then
        print("usage: ps_buy product")

        return
    end

    SS_BuyProduct(args[1])
end)

concommand.Add("ps", function(ply, cmd, args)
    local action, itemid = args[1], tonumber(args[2] or "")
    if not action or not itemid then return end
    local item = Me:SS_FindItem(itemid)
    if not item then return end
    local act = item.actions[action]
    if not act then return end
    print('You can bind this action like this: bind <key> "ps ' .. action .. ' ' .. itemid .. '"')
    act.OnClient(item)
end)

function SS_ItemServerAction(item_id, action_id, args)
    if not Me:SS_FindItem(item_id) then return end
    net.Start('SS_ItemAction')
    net.WriteUInt(item_id, 32)
    net.WriteString(action_id)
    net.WriteTableHD(args or {})
    net.SendToServer()
end

function SendPointsCmd(cmd)
    cmd = string.Explode(" ", cmd)
    local fail = true

    if #cmd >= 2 then
        local amt = tonumber(cmd[#cmd])

        if amt ~= nil then
            table.remove(cmd)
            local ply, cnt = PlyCount(string.Implode(" ", cmd))
            fail = false

            if cnt == 0 then
                chat.AddText("[orange]No player found")
            else
                if cnt == 1 then
                    net.Start("SS_TransferPoints")
                    net.WriteEntity(ply)
                    net.WriteInt(amt, 32)
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
