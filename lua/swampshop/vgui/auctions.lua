-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
-- todo make it show stuff!
vgui.Register("DSSAuctionPreview", {
    Init = function(self)
        self:Dock(TOP)
        self:DockMargin(0, 0, SS_COMMONMARGIN, SS_COMMONMARGIN)
        self:SetText("")
        self:SetTall(SS_SUBCATEGORY_HEIGHT)

        self.Paint = function(p, w, h)
            SS_PaintFG(p, w, h)
            SS_PaintDarkenOnHover(p, w, h)
        end

        self.subtitle = vgui("DLabel", self, function(p)
            p:SetText("")
            p:SetFont('SS_SubCategory')
            p:Dock(FILL)
            p:SetContentAlignment(6)
            p:DockMargin(SS_COMMONMARGIN, 0, SS_COMMONMARGIN, 0)
            p:SetColor(color_white) --MenuTheme_TX)
            p:SizeToContentsY()
        end)
    end,
    SetCategory = function(self, txt)
        self.Category = txt

        self.subtitle:SetText("★ View " .. (({
            Weapons = "Gun",
            Accessories = "Accessory",
            Props = "Prop",
            Playermodels = "Playermodel"
        })[txt] or txt) .. " Auctions ➤")
    end,
    DoClick = function(self)
        SS_AuctionPanel.DesiredSearch = 1
        SS_AuctionPanel.CategorySelect:SetValue(self.Category)
        SS_AuctionPanel:Open()
    end
}, "DButton")

-- name is because of alphabetical include sorting, baseclass has to come first
vgui.Register('DSSAuctionMode', {
    Init = function(self)
        SS_AuctionPanel = self
        self.DesiredSearch = 1

        self.controls = vgui("DSSSubtitle", self, function(p)
            p:SetText("Auctions")

            vgui("DButton", function(p)
                p:Dock(RIGHT)
                p:SetText(">")
                p:SetColor(MenuTheme_TX)
                p:SetFont("SS_SubCategory")
                p.Paint = SS_PaintDarkenOnHover

                p.DoClick = function()
                    SS_AuctionPanel.DesiredSearch = SS_AuctionPanel.DesiredSearch + 1
                end
            end)

            p.pagenumber = vgui("DLabel", function(p)
                p:SetText("1")
                p:SetFont('SS_SubCategory')
                p:Dock(RIGHT)
                p:SetWide(30)
                p:SetContentAlignment(5)
                -- p:DockMargin(SS_COMMONMARGIN, 0, SS_COMMONMARGIN, 0)
                p:SetColor(MenuTheme_TX)
            end)

            vgui("DButton", function(p)
                p:Dock(RIGHT)
                p:SetText("<")
                p:SetColor(MenuTheme_TX)
                p:SetFont("SS_SubCategory")
                p.Paint = SS_PaintDarkenOnHover

                p.DoClick = function()
                    SS_AuctionPanel.DesiredSearch = math.max(1, SS_AuctionPanel.DesiredSearch - 1)
                end
            end)

            self.CategorySelect = vgui("DComboBox", function(p)
                p:Dock(RIGHT)
                p:SetWide(150)
                p:SetSortItems(false)
                p:SetValue("Everything")
                p:AddChoice("Accessories")
                p:AddChoice("Playermodels")
                p:AddChoice("Props")
                p:AddChoice("Weapons")
                p:AddChoice("Misc")
                p:AddChoice("Everything")
                p:SetColor(MenuTheme_TX)
                p:SetFont("SS_Donate2")
                p.Paint = SS_PaintDarkenOnHover

                p.OnSelect = function(self, index, value)
                    SS_AuctionPanel.DesiredSearch = 1
                end
            end)
        end)

        self.results = vgui("DSSTileGrid", self)
    end,
    Think = function(self)
        -- only runs when visible
        if self.LatestSearch ~= self.DesiredSearch or self.LatestCategory ~= self.CategorySelect:GetValue() then
            net.Start('SS_SearchAuctions')
            net.WriteUInt(self.DesiredSearch, 16) --page
            net.WriteUInt(0, 32) -- minprice
            net.WriteUInt(0, 32) --maxprice
            net.WriteString(self.CategorySelect:GetValue())
            net.WriteBool(false) --mineonly
            net.SendToServer()
            self.LatestSearch = self.DesiredSearch
            self.LatestCategory = self.CategorySelect:GetValue()
        end
    end,
    ReceiveSearch = function(self, items, totalitems, page)
        for i, v in ipairs(self.results:GetChildren()) do
            v:Remove()
        end

        self.controls:SetText("Auctions - " .. tostring(totalitems) .. " results")
        self.controls.pagenumber:SetText(tostring(page))
        -- self.controls.results:SizeToContents()
        items = SS_MakeItems(SS_SAMPLE_ITEM_OWNER, items)

        for _, item in pairs(items) do
            local mine = (item.seller == LocalPlayer():SteamID64())
            local mybid = (item.auction_bidder == LocalPlayer():SteamID64())
            local sn = item.seller_name
            local bn = item.bidder_name

            if mine then
                sn = sn .. " (You)"
            end

            if mybid then
                bn = bn .. " (You)"
            end

            -- Hmm, lets override metatable keys on the item instance
            item.primaryaction = false
            local desc = item:GetDescription() or ""
            desc = desc .. "\n(Item class: " .. item.class .. ")"
            desc = desc .. "\n\nSold by " .. sn

            if item.auction_bidder == "0" then
                desc = desc .. "\nNo bidders"
            else
                desc = desc .. "\nHighest bidder is " .. bn .. " (" .. item.auction_price .. ")"
            end

            -- if item.seller == LocalPlayer():SteamID64() then
            if mine then
                if item.auction_bidder == "0" then
                    item.actions = {
                        cancel = {
                            Text = function(item) return "Cancel Auction" end,
                            OnClient = function(item)
                                net.Start("SS_CancelAuction")
                                net.WriteUInt(item.id, 32)
                                net.SendToServer()
                            end
                        }
                    }
                else
                    desc = desc .. "\n\nCan't cancel a bidded auction."
                    item.actions = {}
                end
            else
                if mybid then
                    item.actions = {}
                else
                    item.actions = {
                        bid = {
                            Text = function(item) return "Bid (" .. tostring(item.bid_price) .. " minimum)" end,
                            OnClient = function(item)
                                Derma_StringRequest("Bid on this " .. item:GetName(), "Enter your bid - minimum is " .. tostring(item.bid_price), tostring(item.bid_price), function(text)
                                    text = tonumber(text)

                                    if text then
                                        net.Start("SS_BidAuction")
                                        net.WriteUInt(item.id, 32)
                                        net.WriteUInt(math.max(0, text), 32)
                                        net.SendToServer()
                                    end
                                end, function(text) end, "Bid", "Cancel")
                            end
                        }
                    }
                end
            end

            item.GetDescription = function() return desc end
            SS_AuctionPanel.results:AddItem(item)
        end
    end
}, 'DSSScrollableMode')

net.Receive("SS_SearchAuctions", function(len)
    if len == 0 then
        if IsValid(SS_AuctionPanel) then
            SS_AuctionPanel.LatestSearch = nil
        end

        return
    end

    local items = net.ReadTable()
    local total = net.ReadUInt(32)
    local page = net.ReadUInt(16)

    if IsValid(SS_AuctionPanel) then
        SS_AuctionPanel:ReceiveSearch(items, total, page)
    end
end)
