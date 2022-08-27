-- This file is subject to copyright - contact swampservers@gmail.com for more information.
--NOMINIFY
-- EXAMPLE USE:
function ui_example()
    ui.DFrame({
        size = {400, 400},
        title = "HI",
        padding = {50, 50, 50, 50}
    }, function(p)
        p:Center()
        p:MakePopup()

        ui.Panel({
            width = 100,
            dock = LEFT
        }, function(p)
            function p:Paint(w, h)
                surface.SetDrawColor(255, 0, 0)
                surface.DrawRect(0, 0, w, h)
            end

            ui.DLabel({
                text = "Based",
                dock = TOP
            })

            ui.DLabel({
                text = "Redpilled",
                dock = BOTTOM
            })
        end)

        ui.Panel({
            dock = FILL,
            margin = {20, 20, 20, 20}
        }, function(p)
            function p:Paint(w, h)
                surface.SetDrawColor(0, 0, 255)
                surface.DrawRect(0, 0, w, h)
            end

            ui.Panel({
                dock = BOTTOM
            }, function(p)
                ui.DButton({
                    text = "Cringe",
                    dock = LEFT
                })

                ui.DButton({
                    text = "Bluepilled",
                    dock = RIGHT
                })
            end)
        end)
    end)
end

local panel_setup = Table.PanelSetup

local ui_stack, ui_nstack = {vgui.GetWorldPanel()}, 1

assert(IsValid(ui_stack[1]))

local function with_ui(parent, callback)
    assert(parent)
    ui_nstack = ui_nstack + 1
    ui_stack[ui_nstack] = parent

    ProtectedCall(function()
        callback(parent)
    end)

    ui_stack[ui_nstack] = nil
    ui_nstack = ui_nstack - 1
end

local function update_panel(self, args_or_constructor, constructor)
    local args = istable(args_or_constructor) and args_or_constructor or {}
    constructor = isfunction(args_or_constructor) and args_or_constructor or constructor

    for k, v in pairs(args) do
        local f = panel_setup[k]

        if f then
            f(self, v)
        else
            -- assert(isstring(k), "No positional args!")
            if isstring(k) then
                self[k] = v
            end
        end
    end

    if constructor then
        with_ui(self, constructor)
    end
end

ui = Memo(function(classname)
    return function(args_or_constructor, constructor)
        local args = istable(args_or_constructor) and args_or_constructor or {}
        constructor = isfunction(args_or_constructor) and args_or_constructor or constructor
        local parent = args.parent or ui_stack[ui_nstack]
        args.parent = nil
        assert(not args.build)
        assert(IsValid(parent))
        -- args.name 
        local initargs, i = {}, 1

        while args[i] do
            initargs[i], args[i], i = args[i], nil, i + 1
        end

        local baseclass = classname
        local metas, nmetas = {}, 0

        while true do
            local meta = vgui.GetControlTable(baseclass)
            if not meta then break end
            nmetas = nmetas + 1
            metas[nmetas] = meta
            baseclass = meta.Base
        end

        local panel = vgui.CreateX(baseclass, parent, args.name or classname)
        assert(panel)

        while nmetas > 0 do
            local meta = metas[nmetas]
            nmetas = nmetas - 1
            -- todo could this be faster with le meta tables
            table.Merge(panel:GetTable(), meta)
            panel.BaseClass = vgui.GetControlTable(meta.Base)
            panel.ClassName = meta.ThisClass

            if meta.Init then
                with_ui(panel, function()
                    meta.Init(panel, unpack(initargs))
                end)
            end

            panel:Prepare()
        end

        if not panel.Update then
            panel.Update = update_panel
        else
            print("TODO remove panel:Update from " .. classname)
        end

        update_panel(panel, args, constructor)

        return panel
    end
end)

table.Merge(panel_setup, {
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
    title = function(p, v)
        p:SetTitle(v)
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
})

------ IGNORE EVERYTHING BELOW THIS LINE ITS OLD SHIT
-- ui.Label({args}, callback(p) end)
-- function ui(classname, args_or_constructor, constructor)
--     local args = istable(args_or_constructor) and args_or_constructor or {}
--     args.build = isfunction(args_or_constructor) and args_or_constructor or constructor or args.build
--     local parent
--     if args.parent then
--         parent, args.parent = args.parent, nil
--     else
--         parent = ui_stack:Top() or vgui.GetWorldPanel() --could the world panel just always be in there    
--     end
--     return vgui.Create(classname, parent, args)
-- end
-- -- , {{Update = function(panel, args_or_constructor, constructor)
-- --     local args = merge_args_constructor(args_or_constructor, constructor)
-- -- end}}
-- function update_ui(panel, args_or_constructor, constructor)
--     local args = istable(args_or_constructor) and args_or_constructor or {}
--     args.build = isfunction(args_or_constructor) and args_or_constructor or constructor or args.build
--     if args.parent then
--         panel:SetParent(args.parent)
--         args.parent = nil
--     end
--     setup_panel_(panel, args)
--     return panel
-- end
-- function with_ui(parent, callback)
--     parent = parent or vgui.GetWorldPanel()
--     ui_stack:Push(parent)
--     ProtectedCall(function()
--         callback(parent)
--     end)
--     ui_stack:Pop()
-- end
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
-- local function formatme()
--     vgui("Panel", {
--         dock = FILL
--     }, function(p)
--         vgui("Panel", {
--             dock = TOP,
--             tall = 26,
--             padding = {0, 4, 0, 0}
--         }, function(p)
--             self.Name = vgui("DLabel", {
--                 dock = LEFT,
--                 font = Font.sans24,
--                 color = Color.white,
--                 PerformLayout = function(p)
--                     p:SizeToContentsX()
--                 end
--             })
--         end)
--         self.Location = vgui("DLabel", {
--             dock = FILL,
--             margin = {0, 0, 0, 2},
--             font = Font.sans18,
--             color = Color.fff5
--         })
--     end)
-- end
-- DEPRECATED BELOW
vgui_parent = with_ui

setmetatable(vgui, {
    __call = function(_vgui, classname_or_element, ...)
        local args, ptr = {...}, 1

        local parent, arg

        if ispanel(args[ptr]) then
            parent = args[ptr]
            ptr = ptr + 1
        else
            parent = ui_stack[ui_nstack]
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

function setup_panel_(panel, panelargs)
    --also below
    for k, v in pairs(panelargs) do
        local f = panel_setup[k]

        if f then
            f(panel, v)
        else
            -- assert(not isnumber(k), "No positional args!")
            if isstring(k) then
                panel[k] = v
            end
        end
    end
end

-- adds args which is expected to be a table - this is old shit
function vgui.Create(classname, parent, name_or_args, args)
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

-- DFRAME OVERRIDES
local function try_install_overrides()
    local DFrame = vgui.GetControlTable("DFrame")

    if DFrame then
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

        return true
    end
end

if not try_install_overrides() then
    local basefunc = vgui.Register

    function vgui.Register(...)
        local mtable = basefunc(...)

        if try_install_overrides() then
            vgui.Register = basefunc
        end

        return mtable
    end
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
