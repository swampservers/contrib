-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
SS_Tab("Playermodels", "user_suit")
SS_Heading("Mods")




function SS_PlayermodelItem(item)
    item.playermodel = true

    item.PlayerSetModel = item.PlayerSetModel or function(self, ply)
        ply:SetModel(self.model)

        if self.OnPlayerSetModel then
            self:OnPlayerSetModel(ply)
        end
    end

    item.slot = "playermodel"
    item.invcategory = "Playermodels"
    SS_Item(item)
end



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
                self.item.cfg.imgur = imgur
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

-- local function sanitizebone(cfg, dirty)
--     cfg.bone_h = isstring(dirty.bone_h) and string.sub(dirty.bone_h, 1, 50) or nil
--     cfg.bone_p = isstring(dirty.bone_p) and string.sub(dirty.bone_p, 1, 50) or nil
-- end
SS_Item({
    class = "inflater",
    price = 200000,
    name = 'Inflater',
    description = "make bones fatter or skeletoner. MULTIPLE CAN STACK",
    model = 'models/Gibs/HGIBS.mdl', --'models/Gibs/HGIBS_rib.mdl',
    material = 'models/debug/debugwhite',
    invcategory = "Mods",
    maxowned = 25,
    playermodelmod = true,
    bonemod = true,
    settings = {
        scale = {
            min = Vector(0.5, 0.5, 0.5),
            max = Vector(1.5, 1.5, 1.5)
        },
        bone = true,
        scale_children = true
    }
})

-- defaultcfg = {
--     bone_h = "ValveBiped.Bip01_Head1",
--     bone_p = "LrigScull",
--     scale_h = Vector(1,1.5,1),
--     scale_p = Vector(1,1.5,1),
-- },
-- SetupCustomizer = function(self, cust)
--     local pone = LocalPlayer():IsPony()
--     vgui("DSSCustomizerSection", cust.LeftColumn, function(p)
--         p:SetText("Skin ID")
--         vgui("DSSCustomizerCheckBox", function(p)
--         end)
--     end)
--     vgui("DSSCustomizerVectorSection", cust.LeftColumn, function(p)
--         p:SetForScale(0.5,1.5,self.cfg[pone and "scale_p" or "scale_h"] or self.defaultcfg[pone and "scale_p" or "scale_h"])
--         p.OnValueChanged = function(pnl, vec)
--             self.cfg[pone and "scale_p" or "scale_h"] = vec
--             cust:UpdateCfg()
--         end
--     end)
--     vgui("DSSCustomizerImgur", cust.RightColumn, function(p)
--         p:SetValue(self.cfg.imgur)
--         p.OnValueChanged = function(pnl, imgur)
--             self.item.cfg.imgur = imgur
--             cust:UpdateCfg()
--         end
--     end)
-- end,
-- SanitizeCfg = function(self, dirty)
--     sanitizebone(self.cfg, dirty)
--     self.cfg.scale_h = SS_SanitizeVector(dirty.scale_h, 0.5, 1.5)
--     self.cfg.scale_p = SS_SanitizeVector(dirty.scale_p, 0.5, 1.5)
--     self.cfg.scale_children_h = dirty.scale_children_h and true or nil
--     self.cfg.scale_children_p = dirty.scale_children_p and true or nil
-- end,
SS_Item({
    class = "offsetter",
    price = 100000,
    name = 'Offsetter',
    description = "moves bones around by using advanced genetic modification",
    model = 'models/Gibs/HGIBS_rib.mdl',
    material = 'models/debug/debugwhite',
    invcategory = "Mods",
    maxowned = 25,
    playermodelmod = true,
    bonemod = true,
    settings = {
        pos = {
            min = Vector(-8, -8, -8),
            max = Vector(8, 8, 8),
        },
        bone = true
    }
})

-- SS_Item({
--     class = "contorter",
--     price = 300000,
--     name = 'Contorter',
--     description = "twists bones unnaturally using advanced genetic modification",
--     model = 'models/Gibs/HGIBS_spine.mdl',
--     material = 'models/debug/debugwhite',
--     invcategory = "Mods",
--     maxowned = 25,
--     playermodelmod = true,
--     bonemod = true,
--     settings = {
--         ang = true,
--         bone = true
--     }
-- })
SS_Heading("Permanent")



SS_PlayermodelItem({
    class = "playermodel",
    price=1000000,
    maxowned=5,
    GetName = function(self)
        --fix product
        if self.specs then
            if self.specs.model then
                return string.sub(table.remove(string.Explode("/", self.specs.model)), 1, -5)
            end

            if self.cfg.model and self.cfg.wsid then
                return string.sub(table.remove(string.Explode("/", self.cfg.model)), 1, -5).." (UNFINALIZED)"
            end
        end
        return 'Workshop Outfit (WIP)'
    end,
    GetDescription = function(self)
        if self.specs then
        if self.specs.model then
            local d = "A playermodel."
            if self.specs.wsid then
                d = d .. "\nWorkshop: "..self.specs.wsid.."\n"..self.specs.model
            end
            return d
        end
        if self.cfg.model and self.cfg.wsid then
            return "Finalize this model to wear it.\n("..self.cfg.wsid .. "/"..self.cfg.model ..")"
        end
    end
        return "Use any playermodel from workshop! Once the model is finalized, it can't be changed."
    end,
    GetModel = function(self)
        
        if CLIENT and self.specs and (self.specs.model or (self.cfg.model and self.cfg.wsid)) then

            if self.specs.wsid or self.cfg.wsid then
                -- so the callback when downloaded makes the model refresh
                register_workshop_model(self.specs.model or self.cfg.model, self.specs.wsid or self.cfg.wsid )
                -- makes sure we download this addon when the item is viewed in shop, see autorun/sh_workshop.lua
                require_workshop(self.specs.wsid or self.cfg.wsid )
            end
            
            return self.specs.model or self.cfg.model
        end
        return "models/player/skeleton.mdl"
    end,
    invcategory = "Playermodels",
    playermodel = true,
    PlayerSetModel = function(self, ply)
        
        if self.specs.model then
            if self.specs.wsid then
                --what to display if unloaded or whatever
                ply:SetModel("models/player/skeleton.mdl")


                -- print("SETTING", ply, self.specs.model, self.specs.wsid)
                outfitter.SHNetworkOutfit(ply, self.specs.model, tonumber(self.specs.wsid))
            else
                ply:SetModel(self.specs.model)
            end
        end
    end,
    SetupCustomizer = function(self, cust)
        HeyNozFillThisIn(self, cust)
    end,
    SanitizeSpecs = function(self)
        -- print("SSPECS", self.specs.model, self.cfg.model , self.cfg.wsid , self.cfg.finalize)
        if SERVER and not self.specs.model and self.cfg.model and self.cfg.wsid and self.cfg.finalize then
            self.specs.model = self.cfg.model 
            self.specs.wsid = self.cfg.wsid
            -- print("FINALIZE PLAYERMODEL")
            return true
        end
    end,
    SanitizeCfg = function(self, dirty)
        if self.specs.model == nil then
            self.cfg.wsid = tonumber(dirty.wsid) and tostring(tonumber(dirty.wsid)) or nil
            self.cfg.model = isstring(dirty.model) and dirty.model:sub(1,200):Trim() or nil
            self.cfg.finalize = dirty.finalize and true or nil
        end
    end,

})

function HeyNozFillThisIn(self,cust)

    if self.specs.model then
        vgui("DSSCustomizerSection", cust.RightColumn, function(p)

            p:SetText("Model is already finalized!")
        end)

        return
    end

    vgui("DSSCustomizerSection", cust.LeftColumn, function(p)

        p:SetText("Select Model (WIP)")

        vgui("DTextEntry", function(p) 
            p:Dock(TOP)
            p:SetValue(self.cfg.wsid or "")
            p:SetPlaceholderText( "Workshop ID, like: 13376969" )
            p:SetUpdateOnType(true)
            p.OnValueChange = function(pnl, txt)
                self.cfg.wsid = txt
                cust:UpdateCfg()
            end
        end)

        vgui("DTextEntry", function(p) 
            p:Dock(TOP)
            p:SetValue(self.cfg.model or "")
            p:SetPlaceholderText( "Model path, like: models/player/kleiner.mdl" )
            p:SetUpdateOnType(true)
            p.OnValueChange = function(pnl, txt)
                self.cfg.model = txt
                cust:UpdateCfg()
            end
        end)

    end)

    vgui("DSSCustomizerSection", cust.RightColumn, function(p)
        
        p:SetText("Finalize? (check preview!)")
    

        vgui("DPanel", function(p)
            p:SetTall(16)
            p:Dock(TOP)
            p.Paint = noop
            vgui("DSSCustomizerCheckBox", function(p)
                p:DockMargin(180,0,0,0)
                p:Dock(LEFT)
                p:SetWide(16)
                -- p:SetText("Finalize (make sure preview looks right!)")
                p.OnChange = function(pnl, val)
                    print(val)
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

SS_Item({
    class = "outfitter2",
    price = 2000000,
    name = 'Outfitter',
    description = "Allows wearing any playermodel from workshop (under 30,000 vertices)",
    model = 'models/maxofs2d/logo_gmod_b.mdl',
    actions = {
        customize = {
            Text = function() return "Change Model" end,
            OnClient = function()
                RunConsoleCommand("outfitter")
                SS_ToggleMenu()
            end
        }
    },
    invcategory = "Playermodels",
    never_equip = true
})

SS_Item({
    class = "outfitter3",
    price = 8000000,
    name = 'Outfitter+',
    description = "Allows a higher vertex limit for outfitter models. Requires outfitter. High price is because it causes lag.",
    model = 'models/props_phx/facepunch_logo.mdl',
    actions = {
        customize = {
            Text = function() return "Change Model" end,
            OnClient = function()
                RunConsoleCommand("outfitter")
                SS_ToggleMenu()
            end
        }
    },
    invcategory = "Playermodels",
    never_equip = true
})


if SERVER then
    hook.Add("SS_UpdateItems", "outfitterbools", function(v)
        local has2, has3 = v:SS_HasItem("outfitter2"), v:SS_HasItem("outfitter3")

        if v:GetNWBool("oufitr") ~= has2 then
            v:SetNWBool("oufitr", has2)
        end

        if v:GetNWBool("oufitr+") ~= has3 then
            v:SetNWBool("oufitr+", has3)
        end
    end)
end

hook.Add("CanOutfit", "ps_outfitter", function(ply, mdl, wsid) return ply:GetNWBool("oufitr") end)

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

SS_PlayermodelItem({
    class = 'ogremodel',
    price = 100000,
    name = 'Ogre',
    description = "IT CAME FROM THE SWAMP",
    model = 'models/player/pyroteknik/shrek.mdl',
    workshop = '314261589'
})

SS_Heading("One-Life, Unique")

SS_UniqueModelProduct({
    class = 'celestia',
    name = 'Sun Princess',
    model = 'models/mlp/player_celestia.mdl',
    workshop = '419173474',
    CanBuyStatus = function(self, ply)
        if not ply:SS_HasItem("ponymodel") then return "You must own the ponymodel to buy this." end
    end
})

SS_UniqueModelProduct({
    class = 'luna',
    name = 'Moon Princess',
    model = 'models/mlp/player_luna.mdl',
    workshop = '419173474',
    CanBuyStatus = function(self, ply)
        if not ply:SS_HasItem("ponymodel") then return "You must own the ponymodel to buy this." end
    end
})

SS_UniqueModelProduct({
    class = 'billyherrington',
    name = 'Billy Herrington',
    description = "Rest in peace Billy Herrington, you will be missed.",
    model = 'models/vinrax/player/billy_herrington.mdl',
    workshop = '1422933575',
    OnBuy = function(self, ply)
        if SERVER then
            ply:Give("weapon_billyh")
            ply:SelectWeapon("weapon_billyh")
        end
    end
})

SS_UniqueModelProduct({
    class = 'doomguy',
    name = 'Doomslayer',
    description = "They are rage, brutal, without mercy. But you. You will be worse. Rip and tear, until it is done.",
    model = 'models/pechenko_121/doomslayer.mdl',
    workshop = '2041292605', --This one didn't use a bin file...
    OnBuy = function(self, ply) end
})

-- SS_UniqueModelProduct({
-- 	class = 'ketchupdemon',
-- 	name = 'Mortally Challenged',
-- 	description = '"Demon" is an offensive term.',
-- 	model = 'models/momot/momot.mdl'
-- })
SS_UniqueModelProduct({
    class = 'fatbastard',
    name = 'Fat Kid',
    description = "YEAR OF FAT KID",
    model = 'models/obese_male.mdl',
    workshop = '2467219933'
})

SS_UniqueModelProduct({
    class = 'fox',
    name = 'Furball',
    description = "Furries are proof that God has abandoned us.",
    model = 'models/player/ztp_nickwilde.mdl',
    workshop = '663489035'
})

SS_UniqueModelProduct({
    class = 'garfield',
    name = 'Lasagna Cat',
    description = "I gotta have a good meal.",
    model = 'models/garfield/garfield.mdl'
})

SS_UniqueModelProduct({
    class = 'realgarfield',
    name = 'Real Cat',
    description = "Garfield gets real.",
    model = 'models/player/yevocore/garfield/garfield.mdl',
    workshop = '905415234',
})

SS_UniqueModelProduct({
    class = 'hitler',
    name = 'Der Fuhrer',
    model = 'models/minson97/hitler/hitler.mdl',
    workshop = '1983866955',
})

SS_UniqueModelProduct({
    class = 'kermit',
    name = 'Frog',
    model = 'models/player/kermit.mdl',
    workshop = '485879458',
})

SS_UniqueModelProduct({
    class = 'darthkermit',
    name = 'Darth Frog',
    model = 'models/gonzo/lordkermit/lordkermit.mdl',
    workshop = '1408171201',
})

-- SS_UniqueModelProduct({
-- 	class = 'kim',
-- 	name = 'Rocket Man',
-- 	description = "Won't be around much longer.",
-- 	model = 'models/player/hhp227/kim_jong_un.mdl'
-- })
SS_UniqueModelProduct({
    class = 'minion',
    name = 'Comedy Pill',
    model = 'models/player/minion/minion5/minion5.mdl',
    workshop = '518592494',
})

-- SS_UniqueModelProduct({
-- 	class = 'moonman',
-- 	name = 'Mac Tonight',
-- 	model = 'models/player/moonmankkk.mdl'
-- })
SS_UniqueModelProduct({
    class = 'nicestmeme',
    name = 'Thanks, Lori.',
    description = 'John, haha. Where did you find this one?',
    model = 'models/player/pyroteknik/banana.mdl',
    workshop = '558307075',
})

SS_UniqueModelProduct({
    class = 'pepsiman',
    name = 'Pepsiman',
    description = 'DRINK!',
    model = 'models/player/real/prawnmodels/pepsiman.mdl',
    workshop = '1083310915',
})

SS_UniqueModelProduct({
    class = 'rick',
    name = 'Intellectual',
    description = 'To be fair, you have to have a very high IQ to understand Rick and Morty.',
    model = 'models/player/rick/rick.mdl',
    workshop = '557711922',
})

SS_UniqueModelProduct({
    class = 'trump',
    name = 'God Emperor',
    description = "Donald J. Trump is the President-for-life of the United States of America, destined savior of Kekistan, and slayer of Hillary the Crooked.",
    model = 'models/omgwtfbbq/the_ship/characters/trump_playermodel.mdl',
    workshop = '725320580'
})

--cant find workshop for it
-- SS_UniqueModelProduct({
--     class = 'weeaboo',
--     name = 'Weeaboo Trash',
--     description = "Anime is proof that God has abandoned us.",
--     model = 'models/tsumugi.mdl'
-- })
-- TODO: make them download/mount on the server, make sure there is not a lua backdoor!
SS_UniqueModelProduct({
    class = 'jokerjoker',
    name = 'Joker from JOKER',
    description = "Joker from JOKER",
    model = 'models/kemot44/models/joker_pm.mdl',
    workshop = "1899345304",
})
-- SS_UniqueModelProduct({
--     class = 'sans',
--     name = 'Sans Undertale',
--     description = "haha",
--     model = 'models/sirsmurfzalot/undertale/smh.mdl',
--     workshop = "1591120487",
-- })
