-- This file is subject to copyright - contact swampservers@gmail.com for more information.
SS_Tab("Swag", "color_swatch")
SS_Heading("Accessories")
local accessoryradius = 20

SS_AccessoryModels = {
    ["models/props_halloween/jackolantern_01.mdl"] = {
        name = "Jack-O-Lantern",
        description = "Halloween 2021 unique",
        wear = {
            attach = "eyes",
            scale = 0.28,
            translate = Vector(-3.45, 0, -4.9),
            rotate = Angle(0, 0, 0),
            pony = {
                attach = "lower_body",
                scale = 0.28,
                translate = Vector(0, -1.1, 0),
                rotate = Angle(180, 0, 90)
            },
        }
    }
}

SS_Panel(function(parent)
    vgui("DSSAuctionPreview", parent, function(p)
        p:SetCategory("Accessories")
    end)
end)

-- TODO: Mark rare items (jackolantern) in description
SS_Item({
    class = 'accessory',
    GetName = function(self) return (SS_AccessoryModels[self.specs.model] or {}).name or string.sub(table.remove(string.Explode("/", self.specs.model)), 1, -5) end,
    GetDescription = function(self) return (SS_AccessoryModels[self.specs.model] or {}).description or "You can wear it." end,
    ScaleLimitOffset = function(self) return (SS_AccessoryModels[self.specs.model] or {}).scaleoffset or 12 / ((self.dspecs or {})[1] or 12) end,
    GetModel = function(self) return self.specs.model end,
    SanitizeSpecs = function(self)
        local specs, ch = self.specs, false

        if not specs.model then
            specs.model = specs[1] or SelectAccessoryModel() --GetSandboxProp(accessoryradius)
            ch = true
        end

        if specs[1] then
            specs[1] = nil
            ch = true
        end

        return ch
    end,
    color = Vector(1, 1, 1),
    maxscale = 2.0,
    settings = {
        wear = {
            scale = {
                min = Vector(0.05, 0.05, 0.05),
                max = Vector(2, 2, 2)
            },
            pos = {
                min = Vector(-16, -16, -16),
                max = Vector(16, 16, 16)
            }
        },
        color = {
            max = 5
        },
        imgur = true
    },
    accessory_slot = true,
    invcategory = "Accessories",
    wear = {
        attach = "eyes",
        scale = 1,
        translate = Vector(8, 0, 0),
        rotate = Angle(0, 0, 0),
        pony = {
            scale = 1,
            translate = Vector(8, 0, 0),
            rotate = Angle(0, 0, 0),
        }
    },
    AccessoryTransform = function(self, pone)
        local wear2 = (SS_AccessoryModels[self.specs.model] or {}).wear or self.wear
        local wear = pone and wear2.pony or wear2
        local cfg = self.cfg[pone and "wear_p" or "wear_h"] or {}
        local attach = cfg.attach or wear.attach or wear2.attach
        local translate = cfg.pos or wear.translate or wear2.translate
        local rotate = cfg.ang or wear.rotate or wear2.rotate
        local scale = cfg.scale or wear.scale or wear2.scale

        -- isnumber(scale) and Vector(scale,scale,scale) or scale
        return attach, translate, rotate, scale
    end,
    SetupCustomizer = function(item, self)
        local pone = Me:IsPony()
        local suffix = pone and "_p" or "_h"
        local itmcw = (item:GetSettings() or {}).wear
        local attach, translate, rotate, scale = item:AccessoryTransform(pone)

        vgui("DSSCustomizerSection", self.LeftColumn, function(p)
            p:SetText("Attachment (" .. (pone and "pony" or "human") .. ")")

            vgui("DPanel", function(p)
                p:Dock(TOP)
                p:SetTall(24)
                p.Paint = noop

                vgui("DComboBox", function(p)
                    p:SetValue(attach)

                    for k, v in pairs(SS_Attachments) do
                        p:AddChoice(k)
                    end

                    p:Dock(FILL)
                    p.Paint = SS_PaintBG

                    p.UpdateColours = function(pnl)
                        pnl:SetTextStyleColor(MenuTheme_TX)
                        pnl:SetTextColor(MenuTheme_TX)
                    end

                    print("ADDONSELECT", p)

                    p.OnSelect = function(panel, index, value)
                        print("SELECT", index, value)
                        item.cfg[self.wear] = item.cfg[self.wear] or {}
                        item.cfg[self.wear].attach = value
                        self:UpdateCfg()
                    end
                end)

                vgui("DLabel", function(p)
                    p:Dock(LEFT)
                    p:SetText("Attach to")

                    p.UpdateColours = function(pnl)
                        pnl:SetTextColor(MenuTheme_TX)
                    end
                end)
            end)
        end)

        self.Position = vgui('DSSCustomizerVectorSection', self.LeftColumn, function(p)
            p:SetForPosition(itmcw.pos.min, itmcw.pos.max, translate)
        end)

        self.Angle = vgui('DSSCustomizerVectorSection', self.LeftColumn, function(p)
            p:SetForAngle(rotate)
        end)

        self.Scale = vgui('DSSCustomizerVectorSection', self.LeftColumn, function(p)
            p:SetForScale(itmcw.scale.min * item:ScaleLimitOffset(), itmcw.scale.max * item:ScaleLimitOffset(), scale)
        end)

        local function transformslidersupdate()
            item.cfg[self.wear] = item.cfg[self.wear] or {}
            item.cfg[self.wear].pos = self.Position:GetValue()
            item.cfg[self.wear].ang = self.Angle:GetValueAngle()
            item.cfg[self.wear].scale = self.Scale:GetValue()
            self:UpdateCfg()
        end

        self.Position.OnValueChanged = transformslidersupdate
        self.Angle.OnValueChanged = transformslidersupdate
        self.Scale.OnValueChanged = transformslidersupdate
    end,
    SellValue = function(self) return (SS_AccessoryModels[self.specs.model] or {}).value or 25000 end
})

if SERVER then
    timer.Simple(0, function()
        local props={}
        for i=1,30 do table.insert(props,SelectAccessoryModel()) end
        NWGlobal.accessoryprops = props
    end)
end

SS_Product({
    class = 'hatbox',
    price = 100000,
    name = 'Random Accessory',
    description = "A random prop that you can WEAR. No ratings - all props fully customizable.",
    GetModel = function(self) return NWGlobal.accessoryprops and NWGlobal.accessoryprops[math.floor(SysTime() * 2.5) % #NWGlobal.accessoryprops + 1] or "models/error.mdl" end,
    CannotBuy = function(self, ply) end,
    -- if ply:SS_CountItem("prop") >= 200 then return "Max 200 props, please sell some!" end
    OnBuy = function(self, ply)
        -- if ply.CANTSANDBOX then return end
        local item = SS_GenerateItem(ply, "accessory")

        ply:SS_GiveNewItem(item, function(item)
            local others = {}

            for i = 1, 15 do
                table.insert(others, SelectAccessoryModel()) --GetSandboxProp(accessoryradius))
            end

            net.Start("LootBoxAnimation")
            net.WriteUInt(item.id, 32)
            net.WriteTable(others)
            net.Send(ply)
        end, 4)
    end
})

function SS_AccessoryProduct(data)
    SS_AccessoryModels[data.model] = {
        name = data.name,
        description = data.description,
        value = math.floor((data.price or data.value) * 0.8),
        scaleoffset = data.maxscale and data.maxscale / 2 or nil,
        wear = data.wear
    }

    function data:SanitizeSpecs()
        self.specs = {
            model = self.model
        }

        self.class = "accessory"

        return true
    end

    data.defaultspecs = {
        model = data.model
    }

    data.itemclass = "accessory"
    SS_ItemProduct(data)
end

SS_AccessoryProduct({
    class = 'trumphatfree',
    price = 0,
    name = 'Unstumpable',
    description = "Bold, vibrant, and exuberates power, much like Trump himself. Does not show blood.",
    model = 'models/swamponions/colorabletrumphat.mdl',
    color = Vector(1.0, 0.1, 0.1),
    maxscale = 2.0,
    wear = {
        attach = "eyes",
        scale = 0.76,
        translate = Vector(-1.5, 0, 2.8),
        rotate = SS_AngleGen(function(ang)
            ang:RotateAroundAxis(ang:Up(), -90)
            ang:RotateAroundAxis(ang:Forward(), -20)
            ang:RotateAroundAxis(ang:Right(), 5)
        end),
        pony = {
            scale = 1.0,
            translate = Vector(-4, 0, 13),
            rotate = SS_AngleGen(function(ang)
                ang:RotateAroundAxis(ang:Up(), -90)
                ang:RotateAroundAxis(ang:Forward(), -20)
                ang:RotateAroundAxis(ang:Right(), 5)
            end),
        }
    }
})

SS_AccessoryProduct({
    class = "clownshoe",
    price = 50000,
    name = 'Clown Shoe',
    description = "Goofy clown shoe! Yes, just the one.",
    model = 'models/rockyscroll/clownshoes.mdl',
    color = Vector(0.8, 0.1, 0.1),
    maxscale = 1.4,
    wear = {
        attach = "right_foot",
        scale = 1,
        translate = Vector(4, -1, 0),
        rotate = Angle(0, -30, 90),
        pony = {
            attach = "right_hand",
            scale = 1,
            translate = Vector(-1, 3, 0),
            rotate = Angle(0, 90, -90),
        }
    }
})

SS_AccessoryProduct({
    class = "bigburger",
    price = 100000,
    name = 'Burger',
    description = "Staple food of the American diet.",
    model = 'models/swamponions/bigburger.mdl',
    maxscale = 1,
    wear = {
        attach = "left_hand",
        scale = 0.25,
        translate = Vector(5, -3.5, 0),
        rotate = Angle(0, -40, -90),
        pony = {
            attach = "lower_body",
            scale = 0.3,
            translate = Vector(-3, -5, 0),
            rotate = Angle(0, 0, 90),
        }
    }
})

SS_AccessoryProduct({
    class = "bicyclehelmet",
    price = 120000,
    name = 'Safety Helmet',
    description = "Protection from all threats: internal, external, or autismal.",
    model = 'models/swamponions/bicycle_helmet.mdl',
    color = Vector(0.2, 0.3, 1.0),
    maxscale = 2.0,
    wear = {
        attach = "eyes",
        scale = 1,
        translate = Vector(-3.5, 0, 2),
        rotate = Angle(0, 0, 0),
        pony = {
            scale = 1.75,
            translate = Vector(-9, 0, 9),
            rotate = Angle(0, 0, 0),
        }
    }
})

SS_AccessoryProduct({
    class = "buckethat",
    price = 10000,
    name = 'Bucket Head',
    description = "Did you get this out of the trash?",
    model = 'models/props_junk/MetalBucket01a.mdl',
    maxscale = 1.2,
    wear = {
        attach = "eyes",
        scale = 0.5,
        translate = Vector(-3.3, -1, 6),
        rotate = SS_AngleGen(function(ang)
            ang:RotateAroundAxis(ang:Right(), 180)
            ang:RotateAroundAxis(ang:Up(), 195)
            ang:RotateAroundAxis(ang:Forward(), 10)
        end),
        pony = {
            scale = 0.9,
            translate = Vector(-11.1, -3.5, 15.5),
            rotate = SS_AngleGen(function(ang)
                ang:RotateAroundAxis(ang:Right(), 190)
                ang:RotateAroundAxis(ang:Up(), 195)
                ang:RotateAroundAxis(ang:Forward(), 14)
            end),
        }
    }
})

SS_AccessoryProduct({
    class = "combinehelmet",
    price = 150000,
    name = 'Combine Helmet',
    description = "Hide your identity while upholding the law.",
    model = 'models/nova/w_headgear.mdl',
    color = Vector(1, 1, 1),
    maxscale = 2.7,
    wear = {
        attach = "head",
        scale = 1,
        translate = Vector(0, 0, 0),
        rotate = Angle(0, 0, 0),
        pony = {
            attach = "head",
            scale = 2,
            translate = Vector(0, 0, 0),
            rotate = Angle(0, 0, 0),
        }
    }
})

SS_AccessoryProduct({
    class = "graduationhat",
    price = 900000,
    name = 'Graduation Cap',
    description = "Degree: Master of Gaming",
    model = 'models/player/items/humans/graduation_cap.mdl',
    color = Vector(1, 1, 1),
    maxscale = 1.5,
    wear = {
        attach = "eyes",
        scale = 1,
        translate = Vector(-3, 0, -3),
        rotate = Angle(0, 0, 0),
        pony = {
            attach = "eyes",
            scale = 1,
            translate = Vector(0, 0, 0),
            rotate = Angle(0, 0, 0),
        }
    }
})

SS_AccessoryProduct({
    class = "conehattest",
    price = 1000,
    name = 'Cone Head',
    description = "You put a traffic cone on your head. Very funny.",
    model = 'models/props_junk/TrafficCone001a.mdl',
    maxscale = 1.0,
    wear = {
        attach = "eyes",
        scale = 0.7,
        translate = Vector(-7, 0, 11),
        rotate = SS_AngleGen(function(ang)
            ang:RotateAroundAxis(ang:Right(), 20)
        end),
        pony = {
            scale = 0.7,
            translate = Vector(-7, 0, 22),
            rotate = SS_AngleGen(function(ang)
                ang:RotateAroundAxis(ang:Right(), 20)
            end),
        }
    }
})

SS_AccessoryProduct({
    class = "kleinerglasses",
    price = 1000000,
    name = "Kleiner's Glasses",
    description = "Sublime and sophisticated. A must-have piece of Garry's Mod fashion.",
    model = 'models/swamponions/kleiner_glasses.mdl',
    maxscale = 3.0,
    wear = {
        attach = "eyes",
        scale = 1,
        translate = Vector(-1.5, 0, -0.5),
        rotate = Angle(0, 0, 0),
        pony = {
            scale = 2.3,
            translate = Vector(-5.5, 0, 2.5),
            rotate = Angle(0, 0, 0),
            nose = true,
        }
    }
})

SS_AccessoryProduct({
    class = "santahat",
    price = 25000,
    name = 'Christmas Hat',
    --description = "",
    model = 'models/cloud/kn_santahat.mdl',
    maxscale = 2.0,
    wear = {
        attach = "eyes",
        scale = 1,
        translate = Vector(-3.8, 0, -3),
        rotate = SS_AngleGen(function(ang)
            ang:RotateAroundAxis(ang:Up(), -90)
            ang:RotateAroundAxis(ang:Forward(), 90)
            ang:RotateAroundAxis(ang:Right(), 15)
        end),
        pony = {
            scale = 1.5,
            translate = Vector(-8, 0, 2),
            rotate = SS_AngleGen(function(ang)
                ang:RotateAroundAxis(ang:Up(), -90)
                ang:RotateAroundAxis(ang:Forward(), 90)
                ang:RotateAroundAxis(ang:Right(), 15)
            end),
        }
    }
})

SS_AccessoryProduct({
    class = "shrunkenhead",
    price = 150000,
    name = 'Conjoined Twin',
    --description = "",
    model = 'models/Gibs/HGIBS.mdl',
    maxscale = 2.2,
    wear = {
        attach = "eyes",
        scale = 0.6,
        translate = Vector(-3, -4, 0),
        rotate = Angle(0, 0, -20),
        pony = {
            scale = 1,
            translate = Vector(-8, -7, 0),
            rotate = Angle(0, 0, -20),
        }
    }
})

SS_AccessoryProduct({
    class = "spikecollar",
    price = 200000,
    name = 'Spike Collar',
    --description = "",
    model = 'models/oldbill/spike_collar.mdl',
    maxscale = 3.0,
    wear = {
        attach = "neck",
        scale = 1.05,
        translate = Vector(2.5, -2.1, 0),
        rotate = SS_AngleGen(function(ang)
            ang:RotateAroundAxis(ang:Up(), 52)
            ang:RotateAroundAxis(ang:Forward(), 90)
        end),
        pony = {
            scale = 1.56,
            translate = Vector(0, -1.25, 0),
            rotate = SS_AngleGen(function(ang)
                ang:RotateAroundAxis(ang:Up(), 52)
                ang:RotateAroundAxis(ang:Forward(), 90)
            end),
        }
    }
})

SS_AccessoryProduct({
    class = "tinfoilhat",
    price = 40000,
    name = "InfoWarrior's Hat",
    description = "Block out the globalist's mind control gay-rays with this fashionable foil headgear.",
    model = 'models/dav0r/thruster.mdl',
    material = 'models/swamponions/tinfoil',
    maxscale = 2.2,
    wear = {
        attach = "eyes",
        scale = 1,
        translate = Vector(-5, 0, 4.8),
        rotate = SS_AngleGen(function(ang)
            ang:RotateAroundAxis(ang:Forward(), 180)
            ang:RotateAroundAxis(ang:Right(), -30)
        end),
        pony = {
            scale = 1.75,
            translate = Vector(-11, 0, 14),
            rotate = SS_AngleGen(function(ang)
                ang:RotateAroundAxis(ang:Forward(), 180)
                ang:RotateAroundAxis(ang:Right(), -25)
            end),
        }
    }
})

SS_AccessoryProduct({
    class = "trashhattest",
    price = 10000000,
    name = 'Party Hat',
    description = "It's just a paper hat.",
    model = 'models/noz/partyhat3d.mdl',
    color = Vector(0, 0.06, 0.94),
    maxscale = 3.0,
    wear = {
        attach = "eyes",
        scale = 1.1,
        translate = Vector(-3.3, -0.3, 2.5),
        rotate = SS_AngleGen(function(ang)
            ang:RotateAroundAxis(ang:Up(), -60)
            ang:RotateAroundAxis(ang:Forward(), 15)
        end),
        pony = {
            scale = 1.6,
            translate = Vector(-6.3, -0.2, 10),
            rotate = SS_AngleGen(function(ang)
                ang:RotateAroundAxis(ang:Up(), 40)
                ang:RotateAroundAxis(ang:Forward(), 10)
            end),
        }
    }
})

SS_AccessoryProduct({
    class = "turtleplush",
    price = 1000,
    name = 'Turtle Plush',
    --	description = "It's just a paper hat.",
    model = 'models/props/de_tides/Vending_turtle.mdl',
    material = 'plushturtlehat',
    maxscale = 2.0,
    wear = {
        attach = "eyes",
        scale = 1,
        translate = Vector(-3.2, 0, 2),
        rotate = SS_AngleGen(function(ang)
            ang:RotateAroundAxis(ang:Up(), -90)
        end),
        pony = {
            scale = 1,
            translate = Vector(-5, 0, 9),
            rotate = SS_AngleGen(function(ang)
                ang:RotateAroundAxis(ang:Up(), -90)
                ang:RotateAroundAxis(ang:Forward(), -10)
            end),
        }
    }
})

SS_AccessoryProduct({
    class = "pickelhaube",
    price = 250000,
    name = 'Pickelhaube',
    model = 'models/noz/pickelhaube.mdl',
    maxscale = 2.0,
    wear = {
        attach = "eyes",
        scale = 1.05,
        translate = Vector(-3.5, .1, 2.3),
        rotate = SS_AngleGen(function(ang)
            ang:RotateAroundAxis(ang:Right(), 17)
        end),
        pony = {
            attach = "head",
            scale = 1.8,
            translate = Vector(-4, -9, .3),
            rotate = SS_AngleGen(function(ang)
                ang:RotateAroundAxis(ang:Up(), -20)
                ang:RotateAroundAxis(ang:Forward(), 90)
            end),
        }
    }
})

SS_AccessoryProduct({
    class = "horsemask",
    price = 500,
    name = 'Poverty Pony',
    --	description = "It's just a paper hat.",
    model = 'models/horsie/horsiemask.mdl',
    maxscale = 1.85,
    wear = {
        attach = "eyes",
        scale = 1.0,
        translate = Vector(.6, 0, -1),
        rotate = SS_AngleGen(function(ang)
            ang:RotateAroundAxis(ang:Up(), 90)
        end),
        pony = {
            scale = 1.85,
            translate = Vector(-2, 0, 2),
            rotate = SS_AngleGen(function(ang)
                ang:RotateAroundAxis(ang:Up(), 90)
            end),
        }
    }
})

SS_AccessoryProduct({
    class = 'sombrero',
    price = 30000,
    name = 'Sombrero',
    description = "Worn by criminals, rapists, and good people.",
    model = 'models/swamponions/swampcinema/sombrero.mdl',
    maxscale = 1.5,
    wear = {
        attach = "eyes",
        scale = 0.9,
        translate = Vector(-2.5, 0, 3),
        rotate = Angle(0, 0, 0),
        pony = {
            scale = 1.0,
            translate = Vector(-6.5, 0, 11.5),
            rotate = Angle(5, 0, 0),
        }
    }
})

SS_AccessoryProduct({
    class = 'headcrabhat',
    price = 600000,
    name = 'Headcrab',
    description = "Llamar! Get down from there!",
    model = 'models/swamponions/swampcinema/headcrabhat.mdl',
    maxscale = 2.0,
    wear = {
        attach = "eyes",
        scale = 0.8,
        translate = Vector(-2, 0, 3),
        rotate = Angle(0, -90, 10),
        pony = {
            scale = 1.2,
            translate = Vector(-7.5, 0, 11.5),
            rotate = Angle(0, -90, 10),
        }
    }
})

SS_AccessoryProduct({
    class = 'catears',
    price = 1450,
    name = 'Cat Ears',
    description = "Become your favorite neko e-girl gamer!",
    model = 'models/milaco/catears/catears.mdl',
    maxscale = 2.0,
    wear = {
        attach = "eyes",
        scale = 1.0,
        translate = Vector(-2.859, 0, -2.922),
        rotate = Angle(0, 90, 0),
        pony = {
            scale = 1.0,
            translate = Vector(-16, 0, -4),
            rotate = Angle(0, 90, 0),
        }
    }
})

SS_AccessoryProduct({
    class = 'uwumask',
    price = 50000,
    name = 'Mask',
    description = "No one cared who I was until I put on the mask.",
    model = 'models/milaco/owomask/owomask.mdl',
    maxscale = 2.0,
    wear = {
        attach = "eyes",
        scale = 0.4,
        translate = Vector(0, 0, -3.665),
        rotate = Angle(0, 0, 0),
        pony = {
            scale = 1.025,
            translate = Vector(-12, 0, -2),
            rotate = Angle(10, 0, 0),
        }
    }
})

SS_AccessoryProduct({
    class = 'tophat',
    price = 300000,
    name = 'Top Hat',
    description = "Feel like a sir",
    model = 'models/quattro/tophat/tophat.mdl',
    maxscale = 2.0,
    wear = {
        attach = "eyes",
        scale = 1.0,
        translate = Vector(-2, 0, 6),
        rotate = Angle(0, 0, 0),
        pony = {
            scale = 1.0,
            translate = Vector(-15.299, 0.008, 16.79),
            rotate = Angle(0, 0, 0),
        }
    }
})

SS_AccessoryProduct({
    class = 'swampyhat',
    price = 25000,
    name = 'Krusty Hat',
    description = "Crubsty fcrab beemschugger fri",
    model = 'models/milaco/swampyhat/swampyhat.mdl',
    maxscale = 2.0,
    wear = {
        attach = "eyes",
        scale = 1.0,
        translate = Vector(0, 0, 0),
        rotate = Angle(0, -90, 0),
        pony = {
            scale = 1.0,
            translate = Vector(0, 0, 0),
            rotate = Angle(0, 0, 0),
        }
    }
})

SS_AccessoryProduct({
    class = "commandercap",
    price = 1933000,
    name = 'Commander Hat',
    description = "Look like a real commander",
    model = 'models/ccap/ccap.mdl',
    color = Vector(0.5, 0, 0),
    maxscale = 1.25,
    wear = {
        attach = "eyes",
        scale = 0.39,
        translate = Vector(-2.2, -0, 4.),
        rotate = Angle(180, 90, 188),
        pony = {
            scale = 0.69,
            translate = Vector(-4.9, -0, 13),
            rotate = Angle(180, 90, 190),
        }
    }
})

-- SS_AccessoryProduct({
--     class = "woolcap",
--     price = 50000,
--     name = 'Wool Cap with Brim',
--     description = "Perfect accessory for concealing a receding hairline.",
--     model = 'models/pyroteknik/hats/woolbrim.mdl',
--     color = Vector(1, 1, 1),
--     maxscale = 3.7,
--     wear = {
--         attach = "eyes",
--         scale = 1,
--         translate = Vector(-3, 0, 0),
--         rotate = Angle(-10, 0, 0),
--         pony = {
--             attach = "eyes",
--             scale = 2,
--             translate = Vector(-8, 0, 4),
--             rotate = Angle(0, 0, 0),
--         }
--     }
-- })
SS_AccessoryProduct({
    class = "gasmask",
    price = 600000,
    name = 'Gas Mask',
    description = "Protect yourself from the ambient stink of your average movie theater.",
    model = 'models/pyroteknik/hats/gasmask.mdl',
    color = Vector(1, 1, 1),
    maxscale = 3.7,
    wear = {
        attach = "eyes",
        scale = 1,
        translate = Vector(-2, 0, -1),
        rotate = Angle(-10, 0, 0),
        pony = {
            attach = "eyes",
            scale = 2.2,
            translate = Vector(-7, 0, 2),
            rotate = Angle(0, 0, 0),
        }
    }
})

SS_AccessoryProduct({
    class = "ushanka",
    price = 275000,
    name = 'Ushanka',
    description = "Iconic hat from that video you saw of someone doing something dangerous in the arctic",
    model = 'models/pyroteknik/hats/ushanka.mdl',
    color = Vector(1, 1, 1),
    maxscale = 3.7,
    wear = {
        attach = "eyes",
        scale = 1.04,
        translate = Vector(-2.7, 0, 0),
        rotate = Angle(-10, 0, 0),
        pony = {
            attach = "eyes",
            scale = 2.2,
            translate = Vector(-8, 0, 5),
            rotate = Angle(0, 0, 0),
        }
    }
})

SS_AccessoryProduct({
    class = "americanhelmet",
    price = 19450,
    name = 'WWII American Army Helmet',
    description = "Perfect for re-enacting horrifying war scenarios. Smells faintly of the beach.",
    model = 'models/pyroteknik/hats/american.mdl',
    color = Vector(1, 1, 1),
    maxscale = 3.7,
    wear = {
        attach = "eyes",
        scale = 1,
        translate = Vector(-3, 0, 0),
        rotate = Angle(-10, 0, 0),
        pony = {
            attach = "eyes",
            scale = 2,
            translate = Vector(-8, 0, 5),
            rotate = Angle(0, 0, 0),
        }
    }
})

SS_AccessoryProduct({
    class = "germanhelmet",
    price = 88000,
    name = 'WWII German Army Helmet',
    description = "Perfect for re-enacting horrifying war scenarios. Smells faintly of sausage",
    model = 'models/pyroteknik/hats/german.mdl',
    color = Vector(1, 1, 1),
    maxscale = 3.7,
    wear = {
        attach = "eyes",
        scale = 1,
        translate = Vector(-3, 0, 0),
        rotate = Angle(-10, 0, 0),
        pony = {
            attach = "eyes",
            scale = 2,
            translate = Vector(-10, 0, 5),
            rotate = Angle(0, 0, 0),
        }
    }
})

SS_AccessoryProduct({
    class = "bone",
    price = 9000,
    name = 'Bone',
    description = "A staple of modern fashion. The perfect accessory.",
    model = 'models/pyroteknik/hats/femur.mdl',
    color = Vector(1, 1, 1),
    maxscale = 2.7,
    wear = {
        attach = "eyes",
        scale = 1,
        translate = Vector(-3, 0, 0),
        rotate = Angle(0, 90, 90),
        pony = {
            attach = "eyes",
            scale = 1.8,
            translate = Vector(-9, 0, 5),
            rotate = Angle(0, 90, 90),
        }
    }
})

SS_Heading("Primitives")

local primitives = {
    Plane = 10000,
    Tetrahedron = 10000,
    Angle = 15000,
    Cube = 20000,
    Icosahedron = 30000,
    Dome = 40000,
    Cone = 50000,
    Cylinder = 60000,
    Sphere = 80000,
    Torus = 100000
}

for k, v in pairs(primitives) do
    local kl = k:lower()

    local itm = {
        class = 'primitive_' .. kl,
        price = v,
        name = k,
        description = "Select these primitives in your inventory and click 'customize' to build more interesting outfits!",
        model = 'models/swamponions/primitives/' .. kl .. '.mdl',
        maxscale = kl == "plane" and 3 or 2.5,
        wear = {
            attach = "eyes",
            scale = kl == "plane" and 1.5 or 2.0,
            translate = kl == "plane" and Vector(2, 0, 0) or Vector(0, 0, 0),
            rotate = kl == "plane" and Angle(90, 0, 0) or Angle(0, 0, 0),
            pony = {
                --copy of above
                scale = kl == "plane" and 1.5 or 2.0,
                translate = kl == "plane" and Vector(2, 0, 0) or Vector(0, 0, 0),
                rotate = kl == "plane" and Angle(90, 0, 0) or Angle(0, 0, 0),
            }
        }
    }

    if kl == "torus" then
        itm.settings = {
            wear = {
                xs = {
                    max = 10.0
                }
            }
        }
    end

    if kl == "cone" then
        itm.maxscale = 3.0
    end

    if kl == "plane" then
        itm.description = "Two per slot! Lots can be used."
        itm.perslot = 2
    end

    SS_AccessoryProduct(itm)
end
