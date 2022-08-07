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

-- see if this formats well then decide whether to use build= or a seperate argument
local function formatme()
    vgui("Panel", {
        dock = FILL,
     build=function(p)
        vgui("Panel", {
            dock = TOP,
            tall = 26,
            padding = {0, 4, 0, 0},
            build= function(p)
            self.Name = vgui("DLabel", {
                dock = LEFT,
                font = Font.sans24,
                color = Color.white,
                PerformLayout = function(p)
                    p:SizeToContentsX()
                end
            })
        end})

        self.Location = vgui("DLabel", {
            dock = FILL,
            margin = {0, 0, 0, 2},
            font = Font.sans18,
            color = Color.fff5
        })
    end})
end



local ui_stack = list()

print( IsValid(vgui.GetWorldPanel()) and "WORLDPANEL" or "NOWORLDPANEL!!") -- TODO see if it prints when you join, if so put it in the ui_stack

function ui(classname, args_or_constructor, constructor) 
    local args = istable(args_or_constructor) and args_or_constructor or {}
    args.build = isfunction(args_or_constructor) and args_or_constructor or constructor or args.build

    local parent
    if args.parent then
        parent,args.parent = args.parent,nil
    else
        parent = ui_stack:Top() or vgui.GetWorldPanel() --could the world panel just always be in there    
    end

    return vgui.Create(classname, parent, args)

end

function update_ui(panel, args_or_constructor, constructor)
    local args = istable(args_or_constructor) and args_or_constructor or {}
    args.build = isfunction(args_or_constructor) and args_or_constructor or constructor or args.build

    if args.parent then
        panel:SetParent(args.parent)
        args.parent = nil
    end

    setup_panel_(panel, args)

    return panel
end



function with_ui(parent, callback)
    parent = parent or vgui.GetWorldPanel()
    ui_stack:Push(parent)
    
    ProtectedCall(function()
        callback(parent)
    end)

    ui_stack:Pop()
end

-- strip these
vgui_parent = with_ui


setmetatable(vgui, {
    __call = function(_vgui, classname_or_element, ...)
        local args, ptr = {...}, 1

        local parent, arg

        if ispanel(args[ptr]) then
            parent = args[ptr]
            ptr = ptr + 1
        else
            parent = ui_stack:Top()
        end

        if istable(args[ptr]) then
            arg = args[ptr]
            ptr = ptr + 1
        else
            arg = {}
        end

        local constructor = isfunction(args[ptr]) and args[ptr] or nil
        -- assert(not (ispanel(classname_or_element) and ispanel(parent_or_constructor)), "Can't specify parent with already created element")
        local p = isstring(classname_or_element) and vgui.Create(classname_or_element, parent, arg) or classname_or_element

        if constructor then
            with_ui(p, constructor)
        end

        return p
    end
})


local panelsetup = {
    dock = function(p, v)
        p:Dock(v)
    end,
    padding = function(p, v)
        p:DockPadding(unpack(v))
    end,
    margin = function(p, v)
        p:DockMargin(unpack(v))
    end,
    pos = function(p, v)
        p:SetPos(unpack(v))
    end,
    zpos = function(p, v)
        p:SetZPos(v)
    end,
    wide = function(p, v)
        p:SetWide(v)
    end,
    tall = function(p, v)
        p:SetTall(v)
    end,
    size = function(p, v)
        p:SetSize(unpack(v))
    end,
    font = function(p, v)
        p:SetFont(v)
    end,
    text = function(p, v)
        p:SetText(v)
    end,
    color = function(p, v)
        local f = p.SetColor or p.SetImageColor
        f(p, v)
    end,
    image = function(p, v)
        p:SetImage(v)
    end,
    tooltip = function(p, v)
        p:SetTooltip(v)
    end,
    mouse = function(p, v)
        p:SetMouseInputEnabled(v)
    end,
    keyboard = function(p, v)
        p:SetKeyboardInputEnabled(v)
    end,
}

function setup_panel_(panel, panelargs)

    local build = panelargs.build
    panelargs.build = nil

    --also below
    for k, v in pairs(panelargs) do
        local f = panelsetup[k]

        if f then
            f(panel, v)
        else
            assert(not isnumber(k), "No positional args!")
            panel[k] = v
        end
    end

    if build then
        with_ui(panel, function()
            build(panel)
        end)
    end
end

-- adds args which is expected to be a table
function MyVguiCreate(classname, parent, name_or_args, args)
    local metatable = vgui.GetControlTable(classname)

    if metatable then
        args = istable(name_or_args) and name_or_args or args or {}
        -- strip these before so baseclass can't call them before the panel table is setup
        local panelargs = {}

        for k, v in pairs(args) do
            if isstring(k) then
                args[k] = nil
                panelargs[k] = v
            end
        end

        local panel = vgui.Create(metatable.Base, parent, isstring(name_or_args) and name_or_args or classname, args)

        if not panel then
            Error("Tried to create panel with invalid base '" .. metatable.Base .. "'\n")
        end

        table.Merge(panel:GetTable(), metatable)
        panel.BaseClass = vgui.GetControlTable(metatable.Base)
        panel.ClassName = classname

        -- Call the Init function if we have it
        if panel.Init then
            with_ui(panel, function()
                panel:Init(unpack(args))
            end)
        end

        -- what if we set these before prepare?
        panel:Prepare()

        setup_panel_(panel, panelargs)

        return panel
    end

    local panel = vgui.CreateX(classname, parent, isstring(name_or_args) and name_or_args or classname)

    setup_panel_(panel, istable(name_or_args) and name_or_args or args or {})

    return panel
end

-- DFrame isnt registered yet, so add the new function when we try to create something
vgui.Create = function(...)
    local DFrame = vgui.GetControlTable("DFrame")

    --- Call this to make a DFrame dissapear if the user hits escape
    function DFrame:CloseOnEscape()
        VGUI_CLOSE_ON_ESCAPE = (VGUI_CLOSE_ON_ESCAPE or 0) + 1
        local p = self
        local hookname = "CloseOnEscape" .. tostring(VGUI_CLOSE_ON_ESCAPE)

        if gui.IsGameUIVisible() then
            gui.HideGameUI()
        end

        timer.Simple(0.1, function()
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
        end)
    end

    vgui.Create = MyVguiCreate

    return vgui.Create(...)
end
-- timer.Simple(0, function()
--     --- Makes the DFrame :Close() if escape is pressed
--     --- function DFrame:CloseOnEscape()
-- end)
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
