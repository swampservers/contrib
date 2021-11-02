-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

print("blackpeople")

vgui.Register('DSSInventoryMode', {

    SetCategories = function(self, categories)
        self.categories = categories

    end,
    Think = function(self)
        if self.validtick ~= SS_ValidInventoryTick then
            -- if #self:GetCanvas():GetChildren() > 0 then
            local scroll2 = self:GetVBar():GetScroll()

            for k, v in pairs(self:GetCanvas():GetChildren()) do
                v:Remove()
            end

            -- Pad(self)
            -- TODO sort the items on recipt, then store sortedindex on them
            local itemstemp = table.Copy(LocalPlayer().SS_Items or {}) --GetInventory())

            table.sort(itemstemp, function(a, b)
                local ar, br = SS_GetRatingID(a.specs.rating), SS_GetRatingID(b.specs.rating)

                if ar == br then
                    local an, bn = a:GetName(), b:GetName()
                    local i = 0
                    local ml = math.min(string.len(an), string.len(bn))

                    while i < ml do
                        i = i + 1
                        local a1 = string.byte(an, i)
                        local b1 = string.byte(bn, i)
                        if a1 ~= b1 then return a1 < b1 end
                    end

                    if string.len(an) == string.len(bn) then return a.id < b.id end

                    return string.len(an) > string.len(bn)
                else
                    return ar > br
                end
            end)

            for k, v in pairs(SS_Items) do
                if v.clientside_fake then
                    table.insert(itemstemp, SS_GenerateItem(LocalPlayer(), v.class))
                end
            end

            local categorizeditems = {}

            for _, item in pairs(itemstemp) do
                local invcategory = item.invcategory or "Other"
                categorizeditems[invcategory] = categorizeditems[invcategory] or {}
                table.insert(categorizeditems[invcategory], item)
            end


            for _, cat in ipairs(self.categories) do
                if categorizeditems[cat] and table.Count(categorizeditems[cat]) > 0 then

                    vgui("DSSSubtitle", self, function(p)
                        p:SetText(cat)
                    end)

                    vgui("DSSTileGrid", self, function(p)
                        for _, item in pairs(categorizeditems[cat]) do
                            p:AddItem(item)
                        end
                    end)
                end
            end

            -- Pad(self)
            self:InvalidateLayout()
            self.validtick = SS_ValidInventoryTick

            timer.Simple(0, function()
                self:GetVBar():SetScroll(scroll2)
            end)

            timer.Simple(0.1, function()
                self:GetVBar():SetScroll(scroll2)
            end)
        end
    end

}, 'DSSScrollableMode')
