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
local wasf3down = false

hook.Add("Think", "PSToggler", function()
    local isf3down = input.IsKeyDown(KEY_F3)

    if isf3down and not wasf3down then
        SS_ToggleMenu()
    end

    wasf3down = isf3down
end)

concommand.Add("ps_togglemenu", function(ply, cmd, args)
    SS_ToggleMenu()
end)

CreateClientConVar("ps_darkmode", "0", true)

function SetPointshopTheme(dark)
    SS_DarkMode = dark

    if SS_DarkMode then
        SS_TileBGColor = Color(37, 37, 37)
        SS_GridBGColor = Color(33, 33, 33)
        SS_BotBGColor = Color(33, 33, 33)
        SS_SwitchableColor = Color(200, 200, 200)
    else
        SS_TileBGColor = Color(234, 234, 234)
        SS_GridBGColor = Color(200, 200, 200)
        SS_BotBGColor = Color(64, 64, 64)
        SS_SwitchableColor = Color(0, 0, 0)
    end

    if IsValid(SS_CustomizerPanel) then
        SS_CustomizerPanel:Remove()
    end

    if IsValid(SS_ShopMenu) then
        if SS_ShopMenu:IsVisible() then
            SS_ShopMenu:Remove()
            SS_ShopMenu = vgui.Create('DPointShopMenu')
            SS_ShopMenu:Show()
        else
            SS_ShopMenu:Remove()
            SS_ShopMenu = vgui.Create('DPointShopMenu')
            SS_ShopMenu:SetVisible(false)
        end
    end
end

SetPointshopTheme(GetConVar("ps_darkmode"):GetBool())

cvars.AddChangeCallback("ps_darkmode", function(cvar, old, new)
    SetPointshopTheme(tobool(new))
end)

concommand.Add("ps_destroymenu", function(ply, cmd, args)
    if IsValid(SS_CustomizerPanel) then
        SS_CustomizerPanel:Close()
    end

    if IsValid(SS_ShopMenu) then
        SS_ShopMenu:Remove()
    end
end)

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

SS_CSModels = SS_CSModels or {}

hook.Add('Think', 'SS_Cleanup', function()
    for ply, mdls in pairs(SS_CSModels) do
        if not IsValid(ply) then
            for k, v in pairs(mdls) do
                v.mdl:Remove()
            end

            SS_CSModels[ply] = nil
        end
    end
end)

--makes a CSModel for a worn item
function SS_CreateWornCSModel(itm, cfg)
    if itm == nil or itm.wear == nil then return end

    return SS_CreateCSModel(itm, cfg)
end

--makes a CSModel for a product or item
function SS_CreateCSModel(itm, cfg)
    if itm == nil then return end
    local mdlname = itm.model or (cfg or {}).model
    if mdlname == nil then return end
    local mdl = ClientsideModel(mdlname, RENDERGROUP_OPAQUE)

    if IsValid(mdl) then
        mdl:SetNoDraw(true)

        return mdl
    end
end

SS_MaterialCache = {}

function SS_GetMaterial(nam)
    local cur = SS_MaterialCache[nam]
    if cur then return cur end
    SS_MaterialCache[nam] = Material(nam)

    return SS_MaterialCache[nam]
end

function SS_PreRender(data, cfg, ent)
    cfg = (cfg or {})
    local imgur = cfg.imgur

    if imgur then
        local imat = ImgurMaterial(imgur.url, ent, IsValid(ent) and ent:IsPlayer() and ent:GetPos(), false, "VertexLitGeneric", {
            ["$alphatest"] = 1
        })

        render.MaterialOverride(imat)
        --render.OverrideDepthEnable(true,true)
    else
        local mat = cfg.material or data.material

        if mat then
            render.MaterialOverride(SS_GetMaterial(mat))
        end
    end

    local col = cfg.color or data.color

    if col then
        render.SetColorModulation(col.x, col.y, col.z)
    end
end

function SS_PostRender()
    render.SetColorModulation(1, 1, 1)
    render.MaterialOverride()
    --render.OverrideDepthEnable(false)
end

hook.Add("PrePlayerDraw", "SS_BoneMods", function(ply)
    -- will be "false" if the model is not mounted yet
    local mounted_model = require_workshop_model(ply:GetModel()) and ply:GetModel()

    if ply.SS_PlayermodelModsLastModel ~= mounted_model then
        ply.SS_PlayermodelModsClean = false
        --seems to have issues if you apply the bone mods as soon as the model changes...
        --timer.Simple(1, function() if IsValid(ply) then ply.SS_PlayermodelModsClean = false end end)
    end

    if not ply.SS_PlayermodelModsClean then
        ply.SS_PlayermodelModsClean = SS_ApplyBoneMods(ply, ply:SS_GetActiveBonemods())
        ply.SS_PlayermodelModsLastModel = mounted_model
    end

    SS_ApplyMaterialMods(ply, ply:SS_GetActiveMaterialMods())
end)

local function AddScaleRecursive(ent, b, scn, recurse, safety)
    if safety[b] then
        error("BONE LOOP!")
    end

    safety[b] = true
    local sco = ent:GetManipulateBoneScale(b)
    sco.x = sco.x * scn.x
    sco.y = sco.y * scn.y
    sco.z = sco.z * scn.z

    if ent:GetModel() == "models/milaco/minecraft_pm/minecraft_pm.mdl" then
        sco.x = math.min(sco.x, 1)
        sco.y = math.min(sco.y, 1)
        sco.z = math.min(sco.z, 1)
    end

    ent:ManipulateBoneScale(b, sco)

    if recurse then
        for i, v in ipairs(ent:GetChildBones(b)) do
            AddScaleRecursive(ent, v, scn, recurse, safety)
        end
    end
end

--only bone scale right now...
--if you do pos/angles, must do a combination override to make it work with emotes, vape arm etc
function SS_ApplyBoneMods(ent, mods)
    for x = 0, (ent:GetBoneCount() - 1) do
        ent:ManipulateBoneScale(x, Vector(1, 1, 1))
        ent:ManipulateBonePosition(x, Vector(0, 0, 0))
    end

    if ent:GetModel() == HumanTeamModel or ent:GetModel() == PonyTeamModel then return end
    local pone = isPonyModel(ent:GetModel())
    local suffix = pone and "_p" or "_h"
    --if pelvis has no children, its not ready!
    local pelvis = ent:LookupBone(pone and "LrigPelvis" or "ValveBiped.Bip01_Pelvis")

    if pelvis then
        if #ent:GetChildBones(pelvis) == 0 then return false end
    end

    for _, v in ipairs(mods) do
        local bn = v.cfg["bone" .. suffix] or (pone and "LrigScull" or "ValveBiped.Bip01_Head1")
        local x = ent:LookupBone(bn)

        if x then
            if (v.itm.configurable or {}).scale then
                local scn = v.cfg["scale" .. suffix] or Vector(1, 1, 1.5)
                AddScaleRecursive(ent, x, scn, v.cfg["scale_children" .. suffix], {})
            end

            if (v.itm.configurable or {}).pos then
                local psn = v.cfg["pos" .. suffix] or Vector(10, 0, 0)

                --don't allow moving the root bone
                if ent:GetBoneParent(x) == -1 then
                    psn.x = 0
                    psn.y = 0
                end

                local pso = ent:GetManipulateBonePosition(x)
                pso = pso + psn
                ent:ManipulateBonePosition(x, pso)
            end
        end
    end

    --clamp the amount of stacking
    for x = 0, (ent:GetBoneCount() - 1) do
        local old = ent:GetManipulateBoneScale(x)
        local mn = 0.125 --0.5*0.5*0.5
        local mx = 3.375 --1.5*1.5*1.5

        if ent.GetNetData and ent:GetNetData('OF') ~= nil then
            mx = 1.5
        end

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
function SS_DrawWornCSModel(itm, cfg, mdl, ent, dontactually)
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

    if attach == "eyes" then
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
        local bone_id = ent:LookupBone(SS_Attachments[attach][pone and 2 or 1])

        if bone_id then
            pos, ang = ent:GetBonePosition(bone_id)
        end
    end

    if not pos then
        pos = ent:GetPos()
        ang = ent:GetAngles()
    end

    pos, ang = LocalToWorld(translate, rotate, pos, ang)

    if mdl.scaleapplied ~= scale then
        mdl.scaleapplied = scale

        if isnumber(scale) then
            mdl.matrix = Matrix({
                {scale, 0, 0, 0},
                {0, scale, 0, 0},
                {0, 0, scale, 0},
                {0, 0, 0, 1}
            })
        else
            mdl.matrix = Matrix({
                {scale.x, 0, 0, 0},
                {0, scale.y, 0, 0},
                {0, 0, scale.z, 0},
                {0, 0, 0, 1}
            })
        end

        mdl:EnableMatrix("RenderMultiply", mdl.matrix)
    end

    mdl:SetPos(pos)
    mdl:SetAngles(ang)
    mdl:SetupBones()

    if not dontactually then
        SS_PreRender(itm, cfg, ent)
        mdl:DrawModel()
        SS_PostRender()
    end
end

hook.Add("DrawOpaqueAccessories", 'SS_DrawPlayerAccessories', function(ply)
    if ply.SS_Items == nil and ply.SS_ShownItems == nil then return end
    if not ply:Alive() then return end
    --if EyePos():DistToSqr(ply:GetPos()) > 2000000 then return end
    -- and (GetConVar('thirdperson') and GetConVar('thirdperson'):GetInt() == 0)
    --if ply == LocalPlayer() and GetViewEntity():GetClass() == 'player' then return end
    if GAMEMODE.FolderName == "fatkid" and ply:Team() ~= TEAM_HUMAN then return end

    --in SPADES, the renderboost.lua is disabled!
    for _, prop in ipairs(ply:SS_GetCSModels()) do
        SS_DrawWornCSModel(prop.itm, prop.cfg, prop.mdl, ply)
    end
end)

SS_GibProps = {}

hook.Add('CreateClientsideRagdoll', 'SS_CreateClientsideRagdoll', function(ply, rag)
    if IsValid(ply) and ply:IsPlayer() then
        --print(rag:GetPhysicsObjectNum(0):GetVelocity())
        local counter = 0

        for k, v in pairs(SS_CSModels[ply] or {}) do
            counter = counter + 1
            if counter > 8 then return end
            vm = v.mdl
            local gib = GibClientProp(vm:GetModel(), vm:GetPos(), vm:GetAngles(), ply:GetVelocity(), 1, 6)

            if vm.matrix then
                gib:EnableMatrix("RenderMultiply", vm.matrix)
            end

            gib.csmodel = v
            gib:SetNoDraw(true)
            table.insert(SS_GibProps, gib)
        end
    end
end)

concommand.Add("ps_proptest", function()
    for j, itm in pairs(SS_Items) do
        local mdl = itm.model
        local gib = GibClientProp(mdl, LocalPlayer():EyePos(), Angle(0, 0, 0), LocalPlayer():GetVelocity(), 1, 6)
        gib = gib:GetPhysicsObject():GetMesh()
        local mins = nil
        local maxs = nil

        for k, v in pairs(gib) do
            local p = v.pos

            if mins then
                mins = Vector(math.min(mins.x, p.x), math.min(mins.y, p.y), math.min(mins.z, p.z))
                maxs = Vector(math.max(maxs.x, p.x), math.max(maxs.y, p.y), math.max(maxs.z, p.z))
            else
                mins = p
                maxs = p
            end
        end

        print(mdl)
        maxs = (maxs - mins)
        print("Vector(" .. tostring(math.Round(maxs.x, 0)) .. ", " .. tostring(math.Round(maxs.y, 0)) .. ", " .. tostring(math.Round(maxs.z, 0)) .. ")")
    end
end)

hook.Add("PostDrawOpaqueRenderables", "SS_RenderGibs", function(depth, sky)
    local nextgibs = {}

    while #SS_GibProps > 0 do
        local gib = table.remove(SS_GibProps)

        if IsValid(gib) then
            SS_PreRender(gib.csmodel.itm, gib.csmodel.cfg)
            gib:DrawModel()
            SS_PostRender()
            table.insert(nextgibs, gib)
        end
    end

    SS_GibProps = nextgibs
end)

function SS_BuyProduct(id)
    if not SS_Products[id] then
        LocalPlayerNotify("Unknown product '" .. tostring(id) .. "'. Many products have new codes, update your binds.")

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

function SS_EquipItem(item_id, state)
    if not LocalPlayer():SS_FindItem(item_id) then return end
    net.Start('SS_EquipItem')
    net.WriteUInt(item_id, 32)
    net.WriteBool(state)
    net.SendToServer()
end

function SS_ConfigureItem(item_id, cfg)
    if not LocalPlayer():SS_FindItem(item_id) then return end
    net.Start('SS_ConfigureItem')
    net.WriteUInt(item_id, 32)
    net.WriteTableHD(cfg)
    net.SendToServer()
end

local Player = FindMetaTable('Player')

function Player:SS_ClearCSModels()
    for k, v in pairs(SS_CSModels[self] or {}) do
        v.mdl:Remove()
    end

    SS_CSModels[self] = nil
end

function Player:SS_GetCSModels()
    if SS_CSModels[self] == nil then
        SS_CSModels[self] = {}

        for k, v in pairs(self.SS_Items or self.SS_ShownItems or {}) do
            --eq is nil in ShownItems table
            if v.eq == false then continue end
            local itm = SS_Items[v.class]
            if not itm then continue end
            local mdl = SS_CreateWornCSModel(itm, v.cfg)

            if mdl then
                table.insert(SS_CSModels[self], {
                    mdl = mdl,
                    itm = itm,
                    cfg = v.cfg,
                    id = v.id
                })
            end
        end
    end

    return SS_CSModels[self]
end

function Player:SS_GetActiveBonemods()
    local mods = {}

    for k, v in pairs(self.SS_Items or self.SS_ShownItems or {}) do
        --eq is nil in ShownItems table
        if v.eq == false then continue end
        local itm = SS_Items[v.class]
        if not itm then continue end

        if itm.bonemod then
            table.insert(mods, {
                itm = itm,
                cfg = v.cfg,
                id = v.id
            })
        end
    end

    return mods
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

function SS_ApplyMaterialMods(ent, mods)
    ent:SetSubMaterial()

    for idx, mod in pairs(mods) do
        local mat = ImgurMaterial(mod, ent, IsValid(ent) and ent:IsPlayer() and ent:GetPos(), false, "VertexLitGeneric", {})
        ent:SetSubMaterial(idx, "!" .. mat:GetName())
    end
end

function Player:SS_GetActiveMaterialMods()
    --{[5]="https://i.imgur.com/Ue1qUPf.jpg"}
    return {}
end

function thinga()
    TTT1 = FindMetaTable("Entity")
    TTT2 = FindMetaTable("Player")

    TTT2.SetMaterial = function(a, b)
        TTT1.SetMaterial(a, b)
        print(a, b)
    end
end