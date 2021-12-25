-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- name is because of alphabetical include sorting, baseclass has to come first
vgui.Register('DScrollPanelPaddable', {
    PerformLayoutInternal = function(self)
        local Tall = self.pnlCanvas:GetTall()
        local Wide = self:GetWide()
        local YPos = 0
        self:Rebuild()
        self.VBar:SetUp(self:GetTall(), self.pnlCanvas:GetTall())
        YPos = self.VBar:GetOffset()

        if self.VBar.Enabled then
            Wide = Wide - self.VBar:GetWide()
        end

        self.pnlCanvas:SetPos(0, YPos + self:GetPadding())
        self.pnlCanvas:SetWide(Wide)
        self:Rebuild()

        if Tall ~= self.pnlCanvas:GetTall() then
            self.VBar:SetScroll(self.VBar:GetScroll())
        end
    end,
    Rebuild = function(self)
        self:GetCanvas():SizeToChildren(false, true)
        self:GetCanvas():SetTall(self:GetCanvas():GetTall() + self:GetPadding() * 2)

        if self.m_bNoSizing and self:GetCanvas():GetTall() < self:GetTall() then
            self:GetCanvas():SetPos(0, (self:GetTall() - self:GetCanvas():GetTall()) * 0.5)
        end
    end
}, 'DScrollPanel')

-- MODE BASES
SS_ActiveMode = SS_ActiveMode or nil
SS_ModeStack = SS_ModeStack or {}

local PANEL = {
    Init = function(self)
        self:SetVisible(false)
        self:Dock(FILL)
        self:DockPadding(0, 0, 0, 0)
    end,
    Open = function(self)
        while SS_ActiveMode do
            if IsValid(SS_ActiveMode) then
                SS_ActiveMode:Close()
            else
                table.remove(SS_ModeStack)
                SS_ActiveMode = SS_ModeStack[#SS_ModeStack]
            end
        end

        --patch
        -- if IsValid(SS_CustomizerPanel) then SS_CustomizerPanel:Close() end
        -- if IsValid(SS_SelectedTile) then
        --     SS_SelectedTile:Deselect()
        -- end
        self:OpenOver()
    end,
    OpenOver = function(self)
        if IsValid(SS_ActiveMode) then
            SS_ActiveMode:Cover()
        end

        table.insert(SS_ModeStack, self)
        SS_ActiveMode = SS_ModeStack[#SS_ModeStack]
        self:Uncover()
    end,
    Uncover = function(self)
        if self.NeedsKeyboard then
            SS_ShopMenu:MakePopup()
        else
            SS_ShopMenu:KillFocus()
            SS_ShopMenu:SetKeyboardInputEnabled(false)
        end

        self:SetVisible(true)
    end,
    Cover = function(self)
        self:SetVisible(false)
    end,
    Close = function(self)
        assert(SS_ActiveMode == self)
        table.remove(SS_ModeStack)
        SS_ActiveMode = SS_ModeStack[#SS_ModeStack]
        self:SetVisible(false)

        if IsValid(SS_ActiveMode) then
            SS_ActiveMode:Uncover()
        end
    end
}

local SCROLLPANEL = table.Copy(PANEL)

function SCROLLPANEL:Init()
    self:SetVisible(false)
    self:Dock(FILL)
    self:DockPadding(0, 0, 0, 0)
    self:SetPadding(SS_COMMONMARGIN)
    self.VBar:SetWide(SS_SCROLL_WIDTH)
    SS_SetupVBar(self.VBar)
    self.VBar:DockMargin(SS_COMMONMARGIN, SS_COMMONMARGIN, 0, SS_COMMONMARGIN)

    -- force the scrollbar to stay there
    function self.VBar:SetUp(_barsize_, _canvassize_)
        self.BarSize = _barsize_
        self.CanvasSize = math.max(_canvassize_ - _barsize_, 0)
        self:SetEnabled(true)
        self.btnGrip:SetEnabled(_canvassize_ > _barsize_)
        self:InvalidateLayout()
    end
end

vgui.Register('DSSMode', PANEL, 'DPanel')
vgui.Register('DSSScrollableMode', SCROLLPANEL, 'DScrollPanelPaddable')
