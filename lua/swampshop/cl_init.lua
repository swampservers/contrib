-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
include("sh_init.lua")
include("cl_draw.lua")
include("vgui/menu.lua")
include("vgui/panels.lua")
include("vgui/item.lua")
include("vgui/preview.lua")
include("vgui/customizer.lua")
include("vgui/givepoints.lua")
include("vgui/imgur_manager.lua")

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
    if IsValid(SS_CustomizerPanel) then
        SS_CustomizerPanel:Close()
    end

    if IsValid(SS_ShopMenu) then
        SS_ShopMenu:Remove()
    end
end

concommand.Add("ps_destroymenu", function(ply, cmd, args)
    SS_ReloadMenu()
end)

if IsValid(SS_CustomizerPanel) then
    SS_CustomizerPanel:Close()
end

if IsValid(SS_ShopMenu) then
    SS_ShopMenu:Remove()
end

function SS_ToggleMenu()
    if not IsValid(SS_ShopMenu) then
        SS_ShopMenu = vgui.Create('DPointShopMenu')
        SS_ShopMenu:SetVisible(false)
    end

    if SS_ShopMenu:IsVisible() then
        if IsValid(SS_CustomizerPanel) then
            SS_CustomizerPanel:Close()
        end

        SS_ShopMenu:Hide()
        gui.EnableScreenClicker(false)
    else
        SS_ShopMenu:Show()
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
	net.Start('SS_ModifyItem')
		net.WriteString(item_id)
		net.WriteTable(modifications)
	net.SendToServer()
end ]]
function SetLoadingPlayerProperty(pi, prop, val, callback, calls)
    calls = calls or 50
    local ply = pi == -1 and LocalPlayer() or Entity(pi)

    if IsValid(ply) then
        ply[prop] = val

        if callback then
            callback(ply)
        end
    else
        if calls < 1 then
            print("ERROR loading " .. prop .. " for " .. tostring(pi))
        else
            timer.Simple(0.5, function()
                SetLoadingPlayerProperty(pi, prop, val, callback, calls - 1)
            end)
        end
    end
end

net.Receive('SS_Items', function(length)
    local items = net.ReadTableHD()

    SetLoadingPlayerProperty(-1, "SS_Items", items, function(ply)
        ply.SS_Items = SS_MakeItems(ply, ply.SS_Items)
        SS_ValidInventory = false
    end)
end)

net.Receive('SS_ShownItems', function(length)
    local pi = net.ReadUInt(8)
    local items = net.ReadTableHD()

    SetLoadingPlayerProperty(pi, "SS_ShownItems", items, function(ply)
        ply.SS_ShownItems = SS_MakeItems(ply, ply.SS_ShownItems)
        ply:SS_ClearCSModels()
        ply.SS_PlayermodelModsClean = false
    end)
end)

net.Receive('SS_Pts', function(length)
    SetLoadingPlayerProperty(-1, "SS_Points", net.ReadUInt(32))
end)

net.Receive('SS_Row', function(length)
    SetLoadingPlayerProperty(-1, "SS_Points", net.ReadUInt(32))
    SetLoadingPlayerProperty(-1, "SS_Donation", net.ReadUInt(32))
end)

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

    -- if they have the wep and the wep is not a single-use e.g. peacekeeper
    if LocalPlayer():HasWeapon(args[1]) and not SS_Products[args[1]]['ammotype'] then
        input.SelectWeapon(LocalPlayer():GetWeapon(args[1]))

        return
    end

    SS_BuyProduct(args[1])
end)

function SS_SellItem(item_id)
    if not LocalPlayer():SS_FindItem(item_id) then return end
    net.Start('SS_SellItem')
    net.WriteUInt(item_id, 32)
    net.SendToServer()
end

-- REMOVE THIS
function SS_EquipItem(item_id, state)
    if not LocalPlayer():SS_FindItem(item_id) then return end
    net.Start('SS_EquipItem')
    net.WriteUInt(item_id, 32)
    net.WriteBool(state)
    net.SendToServer()
end

function SS_ActivateItem(item_id, args)
    if not LocalPlayer():SS_FindItem(item_id) then return end
    net.Start('SS_ActivateItem')
    net.WriteUInt(item_id, 32)
    net.WriteTable(args or {})
    net.SendToServer()
end

concommand.Add("ps_prop_autorefresh", function()
    timer.Create("ppau", 0.05, 0, function()
        LocalPlayer():SS_ClearCSModels()
    end)
end)

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

net.Receive("LootBoxAnimation", function(len)
    local mdl = net.ReadString()
    local others = net.ReadTable()
    local namedata = net.ReadTable()
    local rating = net.ReadFloat()
    LootBoxAnimation(mdl, others, namedata, rating)
end)

function LootBoxAnimation(mdl, othermdls, namedata, rating)
    if IsValid(LOOTBOXPANEL) then
        LOOTBOXPANEL:Remove()
    end

    surface.PlaySound("lootbox.ogg")
    local delay = 4
    local size = 600

    LOOTBOXPANEL = vgui("DFrame", function(p)
        p:SetSize(size, size)
        p:Center()
        p:MakePopup()
        p:SetZPos(10000)
        -- p:SetBackgroundBlur(true)
        p:SetTitle("")
        p:ShowCloseButton(false)
        p:CloseOnEscape()

        function p:Paint(w, h)
            render.ClearDepth()
            DisableClipping(true)
            surface.SetDrawColor(0, 0, 0, 150)
            surface.DrawRect(-3000, -3000, 8000, 8000)
            DisableClipping(false)
            draw.BoxShadow(150, 150, w - 300, h - 300, 300, 1)
        end

        vgui("Panel", function(p)
            p:Dock(FILL)

            local infopanel = vgui("DButton", function(p)
                p:SetText("Close (esc)")

                function p:DoClick()
                    LOOTBOXPANEL:Remove()
                end

                p:DockMargin(200, 10, 200, 10)
                p:Dock(BOTTOM)
            end)

            infopanel:SetAlpha(0)

            vgui("DModelPanel", function(p)
                p:Dock(FILL)
                local otheri = 1
                p:SetModel(othermdls[otheri])
                local boxmodel = ClientsideModel("models/Items/ammocrate_smg1.mdl")
                boxmodel:SetNoDraw(true)

                timer.Simple(0.2, function()
                    if not IsValid(boxmodel) then return end
                    local id, dur = boxmodel:LookupSequence("Close") --Open doesn't work???
                    boxmodel:ResetSequence(id)
                    boxmodel:SetPlaybackRate(0.1) -- doesn't work???
                end)

                function p:OnRemove()
                    if IsValid(boxmodel) then
                        boxmodel:Remove()
                    end
                end

                local t1 = SysTime()

                function p:PreDrawModel(ent)
                    boxmodel:SetPos(Vector(0, 0, ((SysTime() - t1) ^ 2) * -40))
                    boxmodel:SetAngles(Angle(0, 90, 0))
                    -- render.ModelM
                    boxmodel:DrawModel()
                end

                local t1 = SysTime()

                function p:LayoutEntity(ent)
                    local min, max = self.Entity:GetRenderBounds()
                    local center, radius = (min + max) / 2, min:Distance(max) / 2

                    if self.Entity.ScaledToModel ~= self.Entity:GetModel() then
                        self.Entity.ScaledToModel = self.Entity:GetModel()
                        self.Entity:SetModelScale(20 / radius)
                        -- self.Entity:InvalidateBoneCache()
                        -- self.Entity:SetupBones()
                        min, max = self.Entity:GetRenderBounds()
                        center, radius = (min + max) / 2, min:Distance(max) / 2
                    end

                    self.Entity:SetPos(self.Entity:GetPos() - self.Entity:LocalToWorld(center))
                    -- self.Entity:SetModelScale(0.5)
                    -- print(radius)
                    -- (radius + 1)
                    self:SetCamPos((60 * Vector(math.cos((SysTime() - t1) * 1.5) * 0.2, 1, 0.2))) --(radius + 1) *
                    self:SetLookAt(Vector(0, 0, 0))
                end

                namedata = table.Reverse(namedata)
                local appeartime = nil

                function p:PaintOver(w, h)
                    if appeartime then
                        local alpha = math.Clamp((SysTime() - appeartime) * 2, 0, 1)
                        y = h

                        for i, v in ipairs(namedata) do
                            local font = "DermaDefault"

                            if i == #namedata then
                                local bw = 100
                                h = h - 20
                                surface.SetDrawColor(0, 0, 0, 255 * alpha)
                                surface.DrawRect(w / 2 - bw, h, bw * 2, 16)
                                local r = SS_GetRating(rating)
                                surface.SetDrawColor(r.color.r, r.color.g, r.color.b, 255 * alpha)
                                surface.DrawRect(w / 2 - bw + 1, h + 1, (bw * 2 - 2) * rating, 14)
                                draw.SimpleText("Rating: " .. r.name, "DermaDefault", w / 2, h + 8, Color(255, 255, 255, 255 * alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                                font = "Trebuchet24"
                            end

                            draw.WordBox(8, w / 2, h, v, font, Color(0, 0, 0, 150 * alpha), Color(255, 255, 255, 255 * alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
                            h = h - 32
                        end
                    end
                end

                local rollspeed = 0.3
                local lastarg

                for i = rollspeed, delay, rollspeed do
                    local arg = {}
                    lastarg = arg

                    timer.Simple(i, function()
                        if not IsValid(p) then return end

                        if arg[1] then
                            p:SetModel(mdl)

                            timer.Simple(0.5, function()
                                if IsValid(infopanel) then
                                    infopanel:SetAlpha(255)
                                end
                            end)

                            appeartime = SysTime()
                        else
                            otheri = (otheri % (#othermdls)) + 1
                            p:SetModel(othermdls[otheri])
                        end
                    end)
                end

                lastarg[1] = true
            end)
        end)
    end)
end

function CSSWEAPONMODELS()
    local t = {}

    for k, v in pairs(weapons.GetList()) do
        if v.Base == "weapon_csbasegun" then
            table.insert(t, v.WorldModel)
        end
    end

    return t
end
--NOMINIFY