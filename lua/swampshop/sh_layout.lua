-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
AddCSLuaFile()
SS_Layout = SS_Layout or {}

-- add custom paint funcs here
function SS_Tab(name, icon)
    _SS_TABADDTARGET = nil

    for _, tab in pairs(SS_Layout) do
        if tab.name == name then
            _SS_TABADDTARGET = tab
        end
    end

    if _SS_TABADDTARGET == nil then
        table.insert(SS_Layout, {})
        _SS_TABADDTARGET = SS_Layout[#SS_Layout]
    end

    _SS_TABADDTARGET.name = name
    _SS_TABADDTARGET.icon = icon

    _SS_TABADDTARGET.layout = {
        {
            name = "",
            products = {}
        }
    }
end

function SS_Panel(constructor)
    table.insert(_SS_TABADDTARGET.layout, {
        constructor = constructor,
        products = {}
    })
end

function SS_Heading(title)
    table.insert(_SS_TABADDTARGET.layout, {
        title = title,
        products = {}
    })
end

