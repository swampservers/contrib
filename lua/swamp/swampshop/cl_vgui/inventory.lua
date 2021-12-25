-- This file is subject to copyright - contact swampservers@gmail.com for more information.
vgui.Register('DSSInventoryMode', {
    SetCategories = function(self, categories)
        self.categories = categories
        self.validversion = nil
    end,
    Think = function(self)
        -- only runs when visible
        if self.validversion ~= SS_InventoryVersion then
            self.validversion = SS_InventoryVersion
            local scroll2 = self:GetVBar():GetScroll()

            for k, v in pairs(self:GetCanvas():GetChildren()) do
                v:Remove()
            end

            local itemstemp = {}

            for _, item in ipairs(Me.SS_Items or {}) do
                table.insert(itemstemp, item)
            end

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
                    table.insert(itemstemp, SS_GenerateItem(Me, v.class))
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

            self:InvalidateLayout()

            timer.Simple(0, function()
                if self.VBar then self.VBar:SetScroll(scroll2) end
            end)

            timer.Simple(0.1, function()
                if self.VBar then self.VBar:SetScroll(scroll2) end
            end)
        end
    end
}, 'DSSScrollableMode')
