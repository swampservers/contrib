-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
SS_Tab("Playermodels", "user_suit")
SS_Heading("Mods")

--NOMINIFY
-- TODO: use .settings/:GetSettings for commonly used elements
-- AND add SetupCustomizer/SanitizeCfg which by default have behavior defined by GetSettings's return
-- (er, make GetSettings always run its version of SetupCustomizer/SanitizeCfg before calling SetupCustomizer/SanitizeCfg)
-- also make .cfg have a metatable, and if missing it calls item:DefaultCfg(key)
SS_Item({
    class = "skinner",
    price = 1000000,
    name = 'Skinner',
    description = "attach a new skin to your body",
    model = 'models/maxofs2d/gm_painting.mdl',
    invcategory = "Mods",
    maxowned = 5,
    playermodelmod = true,
    SetupCustomizer = function(self, cust)
        vgui("DSSCustomizerSection", cust.LeftColumn, function(p)
            p:SetText("Skin ID")

            vgui("DSSCustomizerComboBox", function(p)
                local mats = LocalPlayer():GetMaterials()

                for i = 1, math.min(31, #mats) do
                    p:AddChoice(tostring(i) .. " (" .. table.remove(string.Explode("/", mats[i] or "")) .. ")", tostring(i - 1), tonumber(self.cfg.submaterial or 0) == i - 1)
                end

                p.OnSelect = function(panel, index, word, value)
                    self.cfg.submaterial = tonumber(value)
                    cust:UpdateCfg()
                end
            end)
        end)

        vgui("DSSCustomizerColor", cust.RightColumn, function(p)
            p:SetValue(self.cfg.color or self.color or Vector(1, 1, 1))

            p.OnValueChanged = function(pnl, vec)
                self.cfg.color = vec
                cust:UpdateCfg()
            end
        end)

        vgui("DSSCustomizerImgur", cust.RightColumn, function(p)
            p:SetValue(self.cfg.imgur)

            p.OnValueChanged = function(pnl, imgur)
                self.cfg.imgur = imgur
                cust:UpdateCfg()
            end
        end)
    end,
    SanitizeCfg = function(self, dirty)
        self.cfg.color = SS_SanitizeColor(dirty.color)
        self.cfg.imgur = SS_SanitizeImgur(dirty.imgur)
        self.cfg.submaterial = isnumber(dirty.submaterial) and math.Clamp(math.floor(dirty.submaterial), 0, 31) or nil
    end,
})

function SS_BoneModItem(item)
    item.GetBoneID = function(self, ent)
        local bn = self.cfg[ent:PMCS"bone"] or (ent:IsPony() and "LrigScull" or "ValveBiped.Bip01_Head1")
        local x = ent:LookupBone(bn)

        return x
    end

    item.bonemod = true

    function item:AddBoneSelector(cust)
        vgui('DSSCustomizerBone', cust.LeftColumn, function(p)
            p:SetValue(self.cfg[PMCS"bone"] or (LocalPlayer():IsPony() and "Scull" or "Head1"))

            p.OnValueChanged = function(pnl, val)
                self.cfg[PMCS"bone"] = val
                cust:UpdateCfg()
            end
        end)
    end

    SS_Item(item)
end

SS_BoneModItem({
    class = "offsetter",
    price = 100000,
    name = 'Offsetter',
    description = "moves bones around by using advanced genetic modification",
    model = 'models/Gibs/HGIBS_rib.mdl',
    material = 'models/debug/debugwhite',
    invcategory = "Mods",
    maxowned = 25,
    playermodelmod = true,
    pos_range = Vector(8, 8, 8),
    SetupCustomizer = function(self, cust)
        self:AddBoneSelector(cust)

        cust.Scale = vgui('DSSCustomizerVectorSection', cust.LeftColumn, function(p)
            p:SetForPosition(-self.pos_range, self.pos_range, self.cfg[PMCS"pos"] or Vector(0, 0, 0))

            p.OnValueChanged = function(p, vec)
                self.cfg[PMCS"pos"] = vec
                cust:UpdateCfg()
            end
        end)
    end,
    SanitizeCfg = function(self, dirty)
        ForEachPMCS(function()
            self.cfg[PMCS"bone"] = isstring(dirty[PMCS"bone"]) and string.sub(dirty[PMCS"bone"], 1, 50) or nil
            self.cfg[PMCS"pos"] = SS_SanitizeVector(dirty[PMCS"pos"], -self.pos_range, self.pos_range)
        end)
    end,
    ApplyBoneMod = function(self, ent)
        local boneid = self:GetBoneID(ent)
        if not boneid then return end
        local psn = self.cfg[ent:PMCS"pos"] or Vector(8, 0, 0)

        --don't allow moving the root bone except up and down
        if ent:GetBoneParent(boneid) == -1 then
            psn = Vector(0, 0, psn.z)
        end

        local pso = ent:GetManipulateBonePosition(boneid)
        pso = pso + psn
        ent:ManipulateBonePosition(boneid, pso)
    end
})

-- TODO make this not break with things like vape
SS_BoneModItem({
    class = "contorter",
    price = 200000,
    name = 'Contorter',
    description = "breaks your bones and then heals them in a different shape",
    model = 'models/gibs/hgibs_scapula.mdl',
    material = 'models/debug/debugwhite',
    invcategory = "Mods",
    maxowned = 25,
    playermodelmod = true,
    pos_range = Vector(8, 8, 8),
    SetupCustomizer = function(self, cust)
        self:AddBoneSelector(cust)

        cust.Angle = vgui('DSSCustomizerVectorSection', cust.LeftColumn, function(p)
            p:SetForAngle(self.cfg[PMCS"ang"] or Angle(0, 0, 0))

            p.OnValueChanged = function(p, vec)
                self.cfg[PMCS"ang"] = p:GetValueAngle()
                cust:UpdateCfg()
            end
        end)
    end,
    SanitizeCfg = function(self, dirty)
        ForEachPMCS(function()
            self.cfg[PMCS"bone"] = isstring(dirty[PMCS"bone"]) and string.sub(dirty[PMCS"bone"], 1, 50) or nil
            self.cfg[PMCS"ang"] = isangle(dirty[PMCS"ang"]) and dirty[PMCS"ang"] or nil
        end)
    end,
    ApplyBoneMod = function(self, ent)
        local boneid = self:GetBoneID(ent)
        if not boneid then return end
        local psn = self.cfg[ent:PMCS"ang"] or Angle(-40, 0, 0)
        --don't allow moving the root bone
        if ent:GetBoneParent(boneid) == -1 then return end
        -- local pso = ent:GetManipulateBonePosition(boneid)
        -- pso = pso + psn
        ent:ManipulateBoneAngles(boneid, psn)
    end
})

SS_BoneModItem({
    class = "inflater",
    price = 300000,
    name = 'Inflater',
    description = "reforms the body through the use of an exotic dieting program (STACKABLE)",
    model = 'models/Gibs/HGIBS.mdl', --'models/Gibs/HGIBS_rib.mdl',
    material = 'models/debug/debugwhite',
    invcategory = "Mods",
    maxowned = 25,
    playermodelmod = true,
    scale_min = Vector(0.5, 0.5, 0.5),
    scale_max = Vector(1.5, 1.5, 1.5),
    SetupCustomizer = function(self, cust)
        self:AddBoneSelector(cust)

        cust.Scale = vgui('DSSCustomizerVectorSection', cust.LeftColumn, function(p)
            p:SetForScale(self.scale_min, self.scale_max, self.cfg[PMCS"scale"] or Vector(1.5, 1.5, 1.5))

            p.OnValueChanged = function(p, vec)
                self.cfg[PMCS"scale"] = vec
                cust:UpdateCfg()
            end

            vgui('DSSCustomizerCheckBox', function(p)
                p:SetText("Scale child bones")
                p:SetValue(self.cfg[PMCS"scale_children"] and 1 or 0)

                p.OnValueChanged = function(checkboxself, ch)
                    self.cfg[PMCS"scale_children"] = ch
                    cust:UpdateCfg()
                end
            end)
        end)
    end,
    SanitizeCfg = function(self, dirty)
        ForEachPMCS(function()
            self.cfg[PMCS"bone"] = isstring(dirty[PMCS"bone"]) and string.sub(dirty[PMCS"bone"], 1, 50) or nil
            self.cfg[PMCS"scale"] = SS_SanitizeVector(dirty[PMCS"scale"], self.scale_min, self.scale_max)
            self.cfg[PMCS"scale_children"] = dirty[PMCS"scale_children"] and true or nil
        end)
    end,
    ApplyBoneMod = function(self, ent)
        local boneid = self:GetBoneID(ent)
        if not boneid then return end
        local scn = self.cfg[ent:PMCS"scale"] or Vector(1.5, 1.5, 1.5)

        local function AddScaleRecursive(ent, b, scn, recurse, safety)
            if safety[b] then
                error("BONE LOOP!")
            end

            safety[b] = true
            local sco = ent:GetManipulateBoneScale(b)
            sco.x = sco.x * scn.x
            sco.y = sco.y * scn.y
            sco.z = sco.z * scn.z
            ent:ManipulateBoneScale(b, sco)

            if recurse then
                for i, v in ipairs(ent:GetChildBones(b)) do
                    AddScaleRecursive(ent, v, scn, recurse, safety)
                end
            end
        end

        AddScaleRecursive(ent, boneid, scn, self.cfg[PMCS"scale_children"], {})
    end
})

-- TODO make it so you can pick exactly which bones it affects
SS_BoneModItem({
    class = "jellifier",
    price = 5000000,
    name = 'Jellifier',
    description = "expensive medical treatments which breaks down your bone structure",
    model = 'models/gibs/hgibs_spine.mdl',
    material = 'models/debug/debugwhite',
    invcategory = "Mods",
    maxowned = 1,
    playermodelmod = true,
    pos_range = Vector(8, 8, 8),
    SetupCustomizer = function(self, cust)
        -- vgui('DSSCustomizerBone', cust.LeftColumn, function(p)
        --     p:SetValue(self.cfg[PMCS"bone"] or (LocalPlayer():IsPony() and "Scull" or "Head1"))
        --     p.OnValueChanged = function(pnl, val)
        --         self.cfg[PMCS"bone"] = val
        --         cust:UpdateCfg()
        --     end
        -- end)
        -- make sure the bones dont like change or something idk
        local allthebones = {}

        for x = 0, (LocalPlayer():GetBoneCount() - 1) do
            if LocalPlayer():GetBoneParent(x) ~= -1 then
                local bn = LocalPlayer():GetBoneName(x)

                if SS_CleanBoneName(bn) then
                    table.insert(allthebones, bn)
                end
            end
        end

        vgui('DSSCustomizerSection', cust.LeftColumn, function(p)
            p:SetText("Select Bones")

            for i, v in ipairs(allthebones) do
                local bonename = v

                vgui('DSSCustomizerCheckBox', function(p)
                    local parentbox = p
                    local childbox

                    -- kinda goofy hack, checkbox inside checkbox
                    childbox = vgui('DSSCustomizerCheckBox', function(p)
                        p:DockMargin(0, 0, 0, 0)
                        p:Dock(RIGHT)
                        p:SetWide(100)
                        p:SetText("children")
                        p:SetValue(not ((self.cfg[PMCS"bones"] or {})[v] == false))

                        p.OnValueChanged = function(checkboxself, ch)
                            self.cfg[PMCS"bones"] = self.cfg[PMCS"bones"] or {}
                            local v = nil

                            if parentbox:GetValue() then
                                v = childbox:GetValue()
                            end

                            self.cfg[PMCS"bones"][bonename] = v
                            cust:UpdateCfg()
                        end
                    end)

                    p:SetText(v)
                    p:SetValue((self.cfg[PMCS"bones"] or {})[v] ~= nil)
                    p.OnValueChanged = childbox.OnValueChanged
                end)
            end
        end)
    end,
    -- vgui("DPanel", function(p) --     -- p:Dock(RIGHT) --     p:SetWide(100) --     p.Paint = noop --     for i,v in ipairs(allthebones) do --         vgui('DSSCustomizerCheckBox',function(p) --             p:SetText("children") --             p:SetValue(true) -- (self.cfg[PMCS"bones"] or {})[v] ~=nil) --             p.OnValueChanged = function(checkboxself, ch) --                 -- self.cfg[PMCS"scale_children"] = ch --                 cust:UpdateCfg() --             end --         end) --     end --     p.PerformLayout = function(self) --         self:SizeToChildren(false, true) --     end --     p:SetTall(1000) -- end)
    SanitizeCfg = function(self, dirty)
        ForEachPMCS(function()
            -- self.cfg[PMCS"bone"] = isstring(dirty[PMCS"bone"]) and string.sub(dirty[PMCS"bone"], 1, 50) or nil
            local d = dirty[PMCS"bones"]

            if istable(d) then
                self.cfg[PMCS"bones"] = {}
                local c = 0

                for k, v in pairs(d) do
                    if isstring(k) and k:len() <= 50 then
                        c = c + 1
                        if c > 20 then break end
                        self.cfg[PMCS"bones"][k] = v
                    end
                end
            end
        end)
    end,
    ApplyBoneMod = function(self, ent)
        local bones = self.cfg[ent:PMCS"bones"] or {
            ["LrigScull"] = true,
            ["ValveBiped.Bip01_Head1"] = true
        }

        for k, v in pairs(bones) do
            local boneid = ent:LookupBone(k)

            --don't allow this on the root bone
            if boneid and ent:GetBoneParent(boneid) ~= -1 then
                if v then
                    local function recurse(ent, b)
                        ent:ManipulateBoneJiggle(b, 1)

                        for i, v in ipairs(ent:GetChildBones(b)) do
                            recurse(ent, v)
                        end
                    end

                    recurse(ent, boneid)
                else
                    ent:ManipulateBoneJiggle(boneid, 1)
                end
            end
        end
    end
})

SS_Heading("Models of the Day")

for i = 1, 5 do
    local mi = i

    SS_Product({
        class = 'modeloftheday' .. mi,
        price = 150000,
        GetName = function(self)
            local m = GetG("ModelsOfTheDay")[mi]

            return m and SS_PrettyMDLName(m[2]) or "Nothing (DONT BUY)"
        end,
        description = "A different playermodel will be here every day!",
        GetModel = function(self) return (GetG("ModelsOfTheDay")[mi] or {})[2] or "models/player/skeleton.mdl" end,
        GetWorkshop = function(self) return (GetG("ModelsOfTheDay")[mi] or {})[1] end,
        OnBuy = function(self, ply)
            local m = GetG("ModelsOfTheDay")[mi]

            if m then
                local item = SS_GenerateItem(ply, "playermodel", {
                    wsid = m[1],
                    model = m[2]
                })

                ply:SS_GiveNewItem(item)
            end
        end
    })
end

SS_Panel(function(parent)
    vgui("DSSAuctionPreview", parent, function(p)
        p:SetCategory("Playermodels")
    end)
end)

SS_Heading("Permanent")

local previews = {"models/odessa.mdl", "models/Combine_Strider.mdl", "models/crow.mdl", "models/Combine_Soldier.mdl", "models/player/gasmask.mdl", "models/gman_high.mdl", "models/alyx.mdl", "models/vortigaunt.mdl", "models/antlion_guard.mdl", "models/Combine_Super_Soldier.mdl", "models/Items/hevsuit.mdl", "models/balloons/balloon_dog.mdl", "models/Combine_Scanner.mdl", "models/player/kleiner.mdl", "models/props_lab/huladoll.mdl", "models/headcrab.mdl", "models/AntLion.mdl", "models/dog.mdl", "models/Zombie/Fast.mdl", "models/player/soldier_stripped.mdl", "models/pigeon.mdl", "models/Advisor.mdl", "models/Lamarr.mdl", "models/manhack.mdl"}

SS_Product({
    class = 'playerbox',
    price = 100000,
    name = 'Random Playermodel',
    description = "There are a lot of possibilities.",
    GetModel = function(self) return previews[(math.floor(SysTime() * 2.5) % #previews) + 1] end,
    CannotBuy = function(self, ply) end,
    OnBuy = function(self, ply)
        local m = SS_ValidRandomPlayermodels[math.random(#SS_ValidRandomPlayermodels)]
        if not m then return end

        local item = SS_GenerateItem(ply, "playermodel", {
            wsid = m[1],
            model = m[2]
        })

        ply:SS_GiveNewItem(item, function(item)
            local others = {}

            for i = 1, 15 do
                table.insert(others, previews[i])
            end

            net.Start("LootBoxAnimation")
            net.WriteUInt(item.id, 32)
            net.WriteTable(others)
            net.Send(ply)
        end, 4)
    end
})

function SS_PlayermodelItem(item)
    item.playermodel = true

    item.PlayerSetModel = item.PlayerSetModel or function(self, ply)
        if self.workshop then
            ply:SetDisplayModel(self.model, tonumber(self.workshop))
        else
            ply:SetModel(self.model)
        end

        if self.OnPlayerSetModel then
            self:OnPlayerSetModel(ply)
        end
    end

    item.slot = "playermodel"
    item.invcategory = "Playermodels"
    SS_Item(item)
end

SS_PlayermodelItem({
    class = "playermodel",
    price = 1000000,
    maxowned = 100,
    GetName = function(self)
        --fix product
        if self.specs then
            if self.specs.model then return SS_PrettyMDLName(self.specs.model) end
            if self.cfg.model and self.cfg.wsid then return SS_PrettyMDLName(self.cfg.model) .. " (UNFINALIZED)" end
        end

        return 'Any Workshop Outfit'
    end,
    GetDescription = function(self)
        if self.specs then
            if self.specs.model then
                local d = "A playermodel."
                -- if self.specs.wsid then
                --     d = d .. "\nWorkshop: "..self.specs.wsid.."\n"..self.specs.model
                -- end

                return d
            end

            if self.cfg.model and self.cfg.wsid then return "Finalize this model to wear it.\n(" .. self.cfg.wsid .. "/" .. self.cfg.model .. ")" end

            return "Customize this item to set your playermodel."
        end

        return "Use any playermodel from workshop! Once the model is finalized, it can't be changed."
    end,
    GetModel = function(self) --     --     -- so the callback when downloaded makes the model refresh
--     --     register_workshop_model(self.specs.model or self.cfg.model, self.specs.wsid or self.cfg.wsid)
--     --     -- makes sure we download this addon when the item is viewed in shop, see autorun/sh_workshop.lua
--     --     -- if self.Owner == LocalPlayer() then
--     --     --     require_workshop(self.specs.wsid or self.cfg.wsid )
--     --     -- end
--     -- end
--     return 
-- end
return self.specs and (self.specs.model or self.cfg.model) or "models/maxofs2d/logo_gmod_b.mdl" -- if CLIENT and self.specs and (self.specs.model or (self.cfg.model and self.cfg.wsid)) then end, --     -- if self.specs.wsid or self.cfg.wsid then
    GetWorkshop = function(self) return self.specs and (self.specs.wsid or self.cfg.wsid) end,
    invcategory = "Playermodels",
    playermodel = true,
    PlayerSetModel = function(self, ply)
        if self.specs.model then
            if self.specs.wsid then
                ply:SetDisplayModel(self.specs.model, tonumber(self.specs.wsid))
            else
                ply:SetModel(self.specs.model)
            end
        end

        if self.cfg.bodygroups then
            ply:SetBodyGroups(self.cfg.bodygroups)
        end
    end,
    SetupCustomizer = function(self, cust)
        HeyNozFillThisIn(self, cust)
    end,
    SanitizeSpecs = function(self)
        if SERVER and not self.specs.model and self.cfg.model and self.cfg.wsid and self.cfg.finalize then
            self.specs.model = self.cfg.model
            self.specs.wsid = self.cfg.wsid

            return true
        end
    end,
    SanitizeCfg = function(self, dirty)
        if self.specs.model == nil then
            self.cfg.wsid = tonumber(dirty.wsid) and tostring(tonumber(dirty.wsid)) or nil
            self.cfg.model = isstring(dirty.model) and dirty.model:sub(1, 200):Trim() or nil
            self.cfg.finalize = dirty.finalize and true or nil
        end

        if dirty.bodygroups then
            local chars = {string.byte(dirty.bodygroups, 1, math.min(dirty.bodygroups:len(), 10))}

            local ok = true

            -- ensure all chars numeric - tonumber() wont work because of leading zeroes
            for i, v in ipairs(chars) do
                if v < 48 or v > 57 then
                    ok = false
                end
            end

            if ok then
                self.cfg.bodygroups = chars
            end
        end
    end,
    SellValue = function(self) return 25000 end
})

function HeyNozFillThisIn(self, cust)
    if self.specs.model then
        vgui("DSSCustomizerSection", cust.RightColumn, function(p)
            p:SetText("Model is already finalized!")
        end)
        -- TODO: bodygroup chooser even if model is finalized

        return
    end

    local label
    local _self = self
    _self.wsid = nil

    vgui("DSSCustomizerSection", cust.LeftColumn, function(p)
        p:DockPadding(0, 0, 0, 0)

        vgui("DLabel", function(p)
            p:SizeToContents()
            p:SetContentAlignment(5)
            p:DockMargin(0, 0, 0, SS_COMMONMARGIN)
            p:SetTall(32)
            p:Dock(TOP)
            p:SetFont("DermaLarge")
            p:SetText("Open the Workshop")
            label = p
        end)

        vgui("DButton", function(p)
            p:Dock(TOP)
            p:SetText("#open_workshop")
            p:SetImage('icon16/folder_user.png')
            p:DockMargin(0, 4, 1, 8)

            p.DoClick = function()
                local wb = vgui.Create('workshopbrowser')
                wb:Show()

                function wb:GetWSID(data)
                    _self.wsid = data

                    if IsValid(wsidentry) then
                        wsidentry:SetValue(data)
                        modelentry:SetValue("")
                    end

                    label:SetText("Loading...")
                end
            end
        end)

        vgui("DListView", function(p)
            p:SetMultiSelect(false)
            p:AddColumn("#gameui_playermodel")
            p:DockMargin(0, 4, 0, 0)
            p:Dock(TOP)
            p:SetTall(256)

            p.OnRowSelected = function(pnl, n, itm)
                if _self.wsid then
                    local models = require_playermodel_list(_self.wsid)

                    if models then
                        self.cfg.model = models[n]
                        self.cfg.wsid = _self.wsid
                    end
                end
            end

            local old = nil

            p.Think = function(b, w, h)
                if _self.wsid then
                    local models = require_playermodel_list(_self.wsid)

                    if models and old ~= _self.wsid then
                        old = _self.wsid
                        p:Clear()

                        for k, v in pairs(models) do
                            p:AddLine(v)
                        end

                        if #models > 0 then
                            label:SetText("Select a Playermodel")
                        else
                            label:SetText("No Valid Playermodels Found")
                        end

                        if p:GetLine(1) then
                            p:SelectItem(p:GetLine(1))
                        end
                    end
                end
            end
        end)
    end)

    vgui("DSSCustomizerSection", cust.RightColumn, function(p)
        p:SetText("Finalize?")

        vgui("DPanel", function(p)
            p:SetTall(32)
            p:Dock(TOP)
            p.Paint = noop

            vgui("DSSCustomizerCheckBox", function(p)
                p:SetText("Make sure the preview looks right!")

                p.OnValueChanged = function(pnl, val)
                    self.cfg.finalize = val
                    cust:UpdateCfg()
                end
            end)
        end)
    end)
end

SS_PlayermodelItem({
    class = 'ponymodel',
    price = 500000,
    name = 'Pony',
    description = "*boop*",
    model = 'models/ppm/player_default_base.mdl',
    actions = {
        customize = {
            Text = function() return "Customize Pony" end,
            OnClient = function()
                RunConsoleCommand("ppm_chared3")
            end
        }
    },
    OnPlayerSetModel = function(self, ply)
        ply:Give("weapon_squee")
        ply:SelectWeapon("weapon_squee")
    end
})

SS_PlayermodelItem({
    class = 'ogremodel',
    price = 100000,
    name = 'Ogre',
    description = "IT CAME FROM THE SWAMP",
    model = 'models/player/pyroteknik/shrek.mdl',
    workshop = '314261589'
})

SS_PlayermodelItem({
    class = 'minecraftmodel',
    price = 400064,
    name = 'Block Man',
    description = "A Minecraft player model capable of applying custom skins.",
    actions = {
        customize = {
            Text = function() return "Change Skin" end,
            OnClient = function()
                local mderma = Derma_StringRequest("Minecraft Skin Picker", "Enter an Imgur URL to change your Minecraft skin.", "", function(text)
                    RunConsoleCommand("say", "!minecraftskin " .. text)
                end, function() end, "Change Skin", "Cancel")

                local srdx, srdy = mderma:GetSize()
                local mdermacredits = Label("Minecraft Skins by Chev for Swamp Servers", mderma)
                mdermacredits:Dock(BOTTOM)
                mdermacredits:SetContentAlignment(2)
                mderma:SetSize(srdx, srdy + 15)
                mderma:SetIcon("icon16/user.png")
            end
        }
    },
    model = 'models/milaco/minecraft_pm/minecraft_pm.mdl'
})

--cant find workshop plus i think it needs to be colorable
SS_PlayermodelItem({
    class = 'crusadermodel',
    price = 300000,
    name = 'Crusader',
    model = 'models/player/crusader.mdl',
    OnPlayerSetModel = function(self, ply)
        ply:Give("weapon_deusvult")
        ply:SelectWeapon("weapon_deusvult")
    end
})

SS_PlayermodelItem({
    class = 'jokermodel',
    price = 180000,
    name = 'The Joker',
    description = "Now yuo see...",
    model = 'models/player/bobert/aojoker.mdl',
    workshop = '400762901',
    OnPlayerSetModel = function(self, ply) end
})

SS_PlayermodelItem({
    class = 'neckbeardmodel',
    price = 240000,
    name = 'Athiest',
    model = 'models/player/neckbeard.mdl',
    -- workshop = '853155677', -- Not using workshop because of pony editor built in neckbeard
    OnPlayerSetModel = function(self, ply)
        ply:Give("weapon_clopper")
        ply:SelectWeapon("weapon_clopper")
    end
})

-- SS_Heading("Legacy")
SS_Item({
    class = "outfitter2",
    value = 2000000,
    SellValue = function() return 2000000 end,
    name = 'Outfitter (LEGACY, SELL THIS)',
    description = "Allows wearing any playermodel from workshop (under 30,000 vertices)",
    model = 'models/maxofs2d/logo_gmod_b.mdl',
    -- actions = { --     customize = { --         Text = function() return "Change Model" end, --         OnClient = function() --             RunConsoleCommand("outfitter") --             SS_ToggleMenu() --         end --     } -- },
    invcategory = "Playermodels",
    never_equip = true
})

SS_Item({
    class = "outfitter3",
    value = 8000000,
    SellValue = function() return 8000000 end,
    name = 'Outfitter+ (LEGACY, SELL THIS)',
    description = "Allows a higher vertex limit for outfitter models. Requires outfitter. High price is because it causes lag.",
    model = 'models/props_phx/facepunch_logo.mdl',
    -- actions = { --     customize = { --         Text = function() return "Change Model" end, --         OnClient = function() --             RunConsoleCommand("outfitter") --             SS_ToggleMenu() --         end --     } -- },
    invcategory = "Playermodels",
    never_equip = true
})
-- if SERVER then
--     hook.Add("SS_UpdateItems", "outfitterbools", function(v)
--         local has2, has3 = v:SS_HasItem("outfitter2"), v:SS_HasItem("outfitter3")
--         if v:GetNWBool("oufitr") ~= has2 then
--             v:SetNWBool("oufitr", has2)
--         end
--         if v:GetNWBool("oufitr+") ~= has3 then
--             v:SetNWBool("oufitr+", has3)
--         end
--     end)
-- end
-- hook.Add("CanOutfit", "ps_outfitter", function(ply, mdl, wsid) return ply:GetNWBool("oufitr") end)
-- SS_Heading("One-Life, Unique")
-- SS_UniqueModelProduct({
--     class = 'celestia',
--     name = 'Sun Princess',
--     model = 'models/mlp/player_celestia.mdl',
--     workshop = '419173474',
--     CanBuyStatus = function(self, ply)
--         if not ply:SS_HasItem("ponymodel") then return "You must own the ponymodel to buy this." end
--     end
-- })
-- SS_UniqueModelProduct({
--     class = 'luna',
--     name = 'Moon Princess',
--     model = 'models/mlp/player_luna.mdl',
--     workshop = '419173474',
--     CanBuyStatus = function(self, ply)
--         if not ply:SS_HasItem("ponymodel") then return "You must own the ponymodel to buy this." end
--     end
-- })
-- SS_UniqueModelProduct({
--     class = 'billyherrington',
--     name = 'Billy Herrington',
--     description = "Rest in peace Billy Herrington, you will be missed.",
--     model = 'models/vinrax/player/billy_herrington.mdl',
--     workshop = '1422933575',
--     OnBuy = function(self, ply)
--         if SERVER then
--             ply:Give("weapon_billyh")
--             ply:SelectWeapon("weapon_billyh")
--         end
--     end
-- })
-- SS_UniqueModelProduct({
--     class = 'doomguy',
--     name = 'Doomslayer',
--     description = "They are rage, brutal, without mercy. But you. You will be worse. Rip and tear, until it is done.",
--     model = 'models/pechenko_121/doomslayer.mdl',
--     workshop = '2041292605', --This one didn't use a bin file...
--     OnBuy = function(self, ply) end
-- })
-- -- SS_UniqueModelProduct({
-- -- 	class = 'ketchupdemon',
-- -- 	name = 'Mortally Challenged',
-- -- 	description = '"Demon" is an offensive term.',
-- -- 	model = 'models/momot/momot.mdl'
-- -- })
-- SS_UniqueModelProduct({
--     class = 'fatbastard',
--     name = 'Fat Kid',
--     description = "YEAR OF FAT KID",
--     model = 'models/obese_male.mdl',
--     workshop = '2467219933'
-- })
-- SS_UniqueModelProduct({
--     class = 'fox',
--     name = 'Furball',
--     description = "Furries are proof that God has abandoned us.",
--     model = 'models/player/ztp_nickwilde.mdl',
--     workshop = '663489035'
-- })
-- SS_UniqueModelProduct({
--     class = 'garfield',
--     name = 'Lasagna Cat',
--     description = "I gotta have a good meal.",
--     model = 'models/garfield/garfield.mdl'
-- })
-- SS_UniqueModelProduct({
--     class = 'realgarfield',
--     name = 'Real Cat',
--     description = "Garfield gets real.",
--     model = 'models/player/yevocore/garfield/garfield.mdl',
--     workshop = '905415234',
-- })
-- SS_UniqueModelProduct({
--     class = 'hitler',
--     name = 'Der Fuhrer',
--     model = 'models/minson97/hitler/hitler.mdl',
--     workshop = '1983866955',
-- })
-- SS_UniqueModelProduct({
--     class = 'kermit',
--     name = 'Frog',
--     model = 'models/player/kermit.mdl',
--     workshop = '485879458',
-- })
-- SS_UniqueModelProduct({
--     class = 'darthkermit',
--     name = 'Darth Frog',
--     model = 'models/gonzo/lordkermit/lordkermit.mdl',
--     workshop = '1408171201',
-- })
-- -- SS_UniqueModelProduct({
-- -- 	class = 'kim',
-- -- 	name = 'Rocket Man',
-- -- 	description = "Won't be around much longer.",
-- -- 	model = 'models/player/hhp227/kim_jong_un.mdl'
-- -- })
-- SS_UniqueModelProduct({
--     class = 'minion',
--     name = 'Comedy Pill',
--     model = 'models/player/minion/minion5/minion5.mdl',
--     workshop = '518592494',
-- })
-- -- SS_UniqueModelProduct({
-- -- 	class = 'moonman',
-- -- 	name = 'Mac Tonight',
-- -- 	model = 'models/player/moonmankkk.mdl'
-- -- })
-- SS_UniqueModelProduct({
--     class = 'nicestmeme',
--     name = 'Thanks, Lori.',
--     description = 'John, haha. Where did you find this one?',
--     model = 'models/player/pyroteknik/banana.mdl',
--     workshop = '558307075',
-- })
-- SS_UniqueModelProduct({
--     class = 'pepsiman',
--     name = 'Pepsiman',
--     description = 'DRINK!',
--     model = 'models/player/real/prawnmodels/pepsiman.mdl',
--     workshop = '1083310915',
-- })
-- SS_UniqueModelProduct({
--     class = 'rick',
--     name = 'Intellectual',
--     description = 'To be fair, you have to have a very high IQ to understand Rick and Morty.',
--     model = 'models/player/rick/rick.mdl',
--     workshop = '557711922',
-- })
-- SS_UniqueModelProduct({
--     class = 'trump',
--     name = 'God Emperor',
--     description = "Donald J. Trump is the President-for-life of the United States of America, destined savior of Kekistan, and slayer of Hillary the Crooked.",
--     model = 'models/omgwtfbbq/the_ship/characters/trump_playermodel.mdl',
--     workshop = '725320580'
-- })
-- --cant find workshop for it
-- -- SS_UniqueModelProduct({
-- --     class = 'weeaboo',
-- --     name = 'Weeaboo Trash',
-- --     description = "Anime is proof that God has abandoned us.",
-- --     model = 'models/tsumugi.mdl'
-- -- })
-- -- TODO: make them download/mount on the server, make sure there is not a lua backdoor!
-- SS_UniqueModelProduct({
--     class = 'jokerjoker',
--     name = 'Joker from JOKER',
--     description = "Joker from JOKER",
--     model = 'models/kemot44/models/joker_pm.mdl',
--     workshop = "1899345304",
-- })
-- -- SS_UniqueModelProduct({
-- --     class = 'sans',
-- --     name = 'Sans Undertale',
-- --     description = "haha",
-- --     model = 'models/sirsmurfzalot/undertale/smh.mdl',
-- --     workshop = "1591120487",
-- -- })
