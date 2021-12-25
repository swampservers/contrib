SS_Item({
    class = "prop",
    background = true,
    value = 5000,
    name = "Prop",
    description = "Haha, where did you find this one?",
    model = 'models/maxofs2d/logo_gmod_b.mdl',
    SellValue = function(self) return 250 * 2 ^ SS_GetRating(self.specs.rating).id end,
    GetName = function(self) return string.sub(table.remove(string.Explode("/", self.specs.model)), 1, -5) end,
    GetModel = function(self) return self.specs.model end,
    OutlineColor = function(self) return SS_GetRating(self.specs.rating).color end,
    SanitizeSpecs = function(self)
        local specs, ch = self.specs, false

        if specs.model == "models/props_wasteland/interior_fence001g.mdl" then
            specs.model = nil
        end

        if not specs.model then
            specs.model = GetSandboxProp()
            ch = true
        end

        if not specs.rating then
            specs.rating = math.random()
            ch = true
        end

        return ch
    end,
    actions = {
        spawnprop = {
            primary = true,
            Text = function(item) return "MAKE (-" .. tostring(item:SpawnPrice()) .. ")" end,
        }
    },
    GetSettings = function(self)
        return {
            color = SS_GetRating(self.specs.rating or 0).id >= 5 and {
                max = 5
            } or false,
            imgur = SS_GetRating(self.specs.rating or 0).id >= 7
        }
    end,
    GetColor = function(self)
        if self:GetSettings().color then return self.cfg.color end
        local r = SS_GetRating(self.specs.rating).id
        if r == 2 then return Vector(0.7, 0.7, 0.7) end
        if r == 1 then return Vector(0.5, 0.3, 0.1) end
    end,
    settings = {
        color = {
            max = 5
        },
        imgur = true
    },
    SpawnPrice = function(self) return IsModelExplosive(self.specs.model) and 2000 or 200 end,
    invcategory = "Props",
    never_equip = true
})
