// Components for menus and panels done by Ross;

local PLUGIN = PLUGIN;
local sw, sh = ScrW(), ScrH();

local PANEL = {}

function PANEL:Init()
    self:SetAlpha(0)
    self:AlphaTo(255, .3, 0, function(alpha, pnl)
        pnl:SetAlpha(255)
        _G.CLOSEDEBUG = true;
    end);
end

vgui.Register( "CPanel", PANEL, "EditablePanel" )

local PANEL = {}
function PANEL:Init()
    local ConVas, ScrollBar = self:GetCanvas(), self:GetVBar()
    ScrollBar:SetWidth(5)
    ScrollBar:DockMargin(5, 5, 5, 5)
    ScrollBar:SetHideButtons( true )
    function ScrollBar:Paint(w, h) draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50, 50)) end
    function ScrollBar.btnGrip:Paint(w, h) draw.RoundedBox(0, 0, 0, w, h, Color(20, 20, 20, 100)) end
end
vgui.Register( "CScrollPanel", PANEL, "DScrollPanel" )