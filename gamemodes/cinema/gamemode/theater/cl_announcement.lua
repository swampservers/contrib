-- This file is subject to copyright - contact swampservers@gmail.com for more information.
module("theater", package.seeall)

function AddAnnouncement(tbl)
    if type(tbl) ~= 'table' then return end
    chat.AddText(ColDefault, unpack(translations.FormatChat(table.remove(tbl, 1), unpack(tbl))))
end

net.Receive("TheaterAnnouncement", function()
    AddAnnouncement(net.ReadTable())
end)
