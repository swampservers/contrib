-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
-- name is because of alphabetical include sorting, baseclass has to come first
vgui.Register('DSSTileGrid', {
    Init = function(self)
        self:SetSpaceX(SS_COMMONMARGIN)
        self:SetSpaceY(SS_COMMONMARGIN)
        self:SetBorder(0)
        self:DockMargin(0, 0, 0, SS_COMMONMARGIN)
        self:Dock(TOP)
    end,
    AddItem = function(self, item)
        vgui('DSSTile', self, function(p)
            p:SetItem(item)
        end)
    end,
    AddProduct = function(self, product)
        vgui('DSSTile', self, function(p)
            p:SetProduct(product)
        end)
    end
}, 'DIconLayout')

vgui.Register("DSSSubtitle", {
    Init = function(self)
        self:Dock(TOP)
        self:DockMargin(0, 0, SS_COMMONMARGIN, SS_COMMONMARGIN)
        self:SetPaintBackground(true)
        self:SetTall(SS_SUBCATEGORY_HEIGHT)
        self.Paint = SS_PaintFG

        self.subtitle = vgui("DLabel", self, function(p)
            p:SetText("")
            p:SetFont('SS_SubCategory')
            p:Dock(FILL)
            p:SetContentAlignment(4)
            p:DockMargin(SS_COMMONMARGIN, 0, SS_COMMONMARGIN, 0)
            p:SetColor(MenuTheme_TX)
            p:SizeToContentsY()
        end)
    end,
    SetText = function(self, txt)
        self.subtitle:SetText(txt)
    end
}, "DPanel")
