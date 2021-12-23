-- This file is subject to copyright - contact swampservers@gmail.com for more information.
--- This defines the function vgui(classname, parent (optional), constructor) which creates and returns a panel.
--
-- The parent should only be passed when creating a root element (eg. a DFrame) which need a parent.
-- Child elements should be constructed using vgui() from within the parent's constructor, and their parent will be set automatically.
--
-- This is helpful for creating complex guis as the hierarchy of the layout is clearly reflected in the code structure.
--
-- Example: (a better example is in the file)
-- ```
-- vgui("Panel", function(p)
--     -- p is the panel, set it up here
--     vgui("DLabel", function(p)
--         -- p is the label here
--     end)
-- end)
-- ```
--- function vgui(classname, parent (optional), constructor)
local vgui_stack = {}

setmetatable(vgui, {
    __call = function(_vgui, classname_or_element, parent_or_constructor, constructor)
        parent_or_constructor = parent_or_constructor or function() end

        if isfunction(parent_or_constructor) then
            constructor = parent_or_constructor
            parent_or_constructor = vgui_stack[#vgui_stack] --nil if empty
            -- else
            --     assert(table.IsEmpty(vgui_stack), "Expect empty vgui stack with specified parent")
        end

        assert(parent_or_constructor == nil or ispanel(parent_or_constructor))
        assert(not (ispanel(classname_or_element) and ispanel(parent_or_constructor)), "Can't specify parent with already created element")
        local p = isstring(classname_or_element) and vgui.Create(classname_or_element, parent_or_constructor) or classname_or_element

        if constructor then
            table.insert(vgui_stack, p)

            ProtectedCall(function()
                constructor(p)
            end)

            table.remove(vgui_stack)
        end

        return p
    end
})

print("CONTROLTABLE", vgui.GetControlTable("DFrame"))

timer.Simple(0, function()
    --- Makes the DFrame :Close() if escape is pressed
    --- function DFrame:CloseOnEscape()
    vgui.GetControlTable("DFrame").CloseOnEscape = function(self)
        VGUI_CLOSE_ON_ESCAPE = (VGUI_CLOSE_ON_ESCAPE or 0) + 1
        local p = self
        local hookname = "CloseOnEscape" .. tostring(VGUI_CLOSE_ON_ESCAPE)

        if gui.IsGameUIVisible() then
            gui.HideGameUI()
        end

        hook.Add("Think", hookname, function()
            -- and p:HasHierarchicalFocus() then
            if IsValid(p) then
                if gui.IsGameUIVisible() then
                    gui.HideGameUI()
                    p:Close()
                end
            else
                hook.Remove("Think", hookname)
            end
        end)
    end
end)
-- function vgui_example()
--     vgui("DFrame", function(p)
--         p:SetSize(400, 400)
--         p:Center()
--         p:MakePopup()
--         p:SetTitle("Hi")
--         p:DockPadding(50, 50, 50, 50)
--         vgui("Panel", function(p)
--             p:SetWidth(100)
--             p:Dock(LEFT)
--             function p:Paint(w, h)
--                 surface.SetDrawColor(255, 0, 0)
--                 surface.DrawRect(0, 0, w, h)
--             end
--             vgui("DLabel", function(p)
--                 p:SetText("Based")
--                 p:Dock(TOP)
--             end)
--             vgui("DLabel", function(p)
--                 p:SetText("Redpilled")
--                 p:Dock(BOTTOM)
--             end)
--         end)
--         vgui("Panel", function(p)
--             p:DockMargin(20, 20, 20, 20)
--             p:Dock(FILL)
--             function p:Paint(w, h)
--                 surface.SetDrawColor(0, 0, 255)
--                 surface.DrawRect(0, 0, w, h)
--             end
--             vgui("Panel", function(p)
--                 p:Dock(BOTTOM)
--                 vgui("DButton", function(p)
--                     p:SetText("Cringe")
--                     p:Dock(LEFT)
--                 end)
--                 vgui("DButton", function(p)
--                     p:SetText("Bluepilled")
--                     p:Dock(RIGHT)
--                 end)
--             end)
--         end)
--     end)
-- end
