-- This file is subject to copyright - contact swampservers@gmail.com for more information.
concommand.Add("vote", function()
    Vote_ShowMenu()
end)

concommand.Add("votekick", function()
    Vote_ShowMenu(true)
end)

function Vote_ShowMenu(kick)
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Vote Maker")
    frame:SetSize(240, 310)
    frame:Center()
    frame:MakePopup()
    VOTEFRAME = frame
    local sheet = vgui.Create("DPropertySheet", frame)
    sheet:Dock(FILL)
    local frame1 = vgui.Create("DPanel", sheet)
    frame1.Paint = function() end
    local rtab = sheet:AddSheet("Vote", frame1, "icon16/star.png")
    local frame2 = vgui.Create("DPanel", sheet)
    frame2.Paint = function() end
    local ktab = sheet:AddSheet("Votekick", frame2, "icon16/cross.png")
    sheet:SetActiveTab((kick and ktab or rtab).Tab)
    local stuff = {}
    local votekickreason = nil
    local votekickplayer = nil

    for k = 0, 6 do
        local framz = {frame1}

        if k == 0 then
            table.insert(framz, frame2)
        end

        for k2, fram in pairs(framz) do
            local labl = vgui.Create("DLabel", fram)
            labl:SetText(k == 0 and (fram == frame1 and "Title" or "Reason") or "Option " .. tostring(k))
            labl:SetDark(true)
            labl:SetPos(5, 6 + k * 28)
            labl:SetSize(50, 20)
            local TextEntry = vgui.Create("DTextEntry", fram)
            TextEntry:SetPos(55, 6 + k * 28)
            TextEntry:SetSize(150, 20)
            TextEntry:SetText("")

            if fram == frame1 then
                table.insert(stuff, TextEntry)
            else
                votekickreason = TextEntry
            end
        end
    end

    for k2, fram in pairs({frame1, frame2}) do
        local DermaButton = vgui.Create("DButton", fram)
        DermaButton:SetText("Create Vote")
        DermaButton:SetPos(15, 206)
        DermaButton:SetSize(190, 30)

        if fram == frame1 then
            DermaButton.DoClick = function()
                net.Start("StartVote")
                net.WriteString(stuff[1]:GetText())
                local tab = {}

                for k, v in ipairs(stuff) do
                    if k > 1 then
                        local opt = v:GetText()

                        if opt ~= "" then
                            table.insert(tab, opt)
                        end
                    end
                end

                net.WriteTable(tab)
                net.SendToServer()
            end
        else
            DermaButton.DoClick = function()
                net.Start("StartVoteKick")
                net.WriteEntity(votekickplayer)
                net.WriteString(votekickreason:GetText())
                net.SendToServer()
            end
        end
    end

    local plylist = vgui.Create("DListView", frame2)
    plylist:SetPos(10, 30)
    plylist:SetSize(195, 170)
    plylist:SetMultiSelect(false)
    plylist:AddColumn("Players")
    local plyz = {}

    for k2, v2 in pairs(player.GetAll()) do
        table.insert(plyz, {v2:Nick(), v2})
    end

    table.sort(plyz, function(a, b) return a[1]:lower() < b[1]:lower() end)

    for k2, v2 in ipairs(plyz) do
        local pn = plylist:AddLine(v2[1])
        pn.ply = v2[2]
    end

    plylist.OnRowSelected = function(lst, index, pnl)
        votekickplayer = pnl.ply
    end
end

function Vote_HideMenu()
    if IsValid(VOTEFRAME) then
        VOTEFRAME:Remove()
    end
end

for i, b in ipairs({"", "Bold"}) do
    surface.CreateFont("PlayerOptionVoteFontTitle" .. b, {
        font = "Lato",
        extended = true,
        size = 14 + math.floor(ScrH() / 100),
        weight = b == "Bold" and 1000 or 100,
    })

    surface.CreateFont("PlayerOptionVoteFont" .. b, {
        font = "Lato",
        extended = true,
        size = 9 + math.floor(ScrH() / 100),
        weight = b == "Bold" and 1000 or 100,
    })
end

-- seperate because the thing cant update
function DRAWVOTE()
    if RealTime() > ACTIVEVOTEENDTIME then return end
    local title = ACTIVEVOTETITLE
    local options = ACTIVEVOTEOPTIONS
    surface.SetFont("PlayerOptionVoteFontTitle")
    local tw, th = surface.GetTextSize("Vote")
    surface.SetFont("PlayerOptionVoteFont")
    local lw, lh = surface.GetTextSize("Vote")
    local bottom = ScrH() / 2

    if SwampChat then
        bottom = math.min(bottom, SwampChat.PosY - 16)
    end

    local p1, p2, p3, p4 = 4, 10, 2, 4
    local h = lh * #options + th + p1 + p2 + p3 + p4
    local y = bottom - h
    draw.GradientShadowRight(0, y, lw * 8, h, 0.8)
    y = y + p1

    local function drawbold(t1, t2, f1, f2, x, y)
        surface.SetFont(f1)
        local lw, lh = surface.GetTextSize(t1)
        draw.DrawText(t1, f1, x, y, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
        x = x + lw
        draw.DrawText(t2, f2, x, y, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
    end

    drawbold("Vote: ", ACTIVEVOTETITLE, "PlayerOptionVoteFontTitleBold", "PlayerOptionVoteFontTitle", 16, y)
    y = y + p2

    for i, v in ipairs(options) do
        y = y + lh
        drawbold(i .. ". ", v, "PlayerOptionVoteFontBold", "PlayerOptionVoteFont", 16, y)
        y = y + p3
    end
end

net.Receive("StartVote", function(len)
    local title = net.ReadString()
    local options = net.ReadTable()
    local duration = net.ReadFloat()
    ACTIVEVOTETITLE = title
    ACTIVEVOTEOPTIONS = options
    ACTIVEVOTESTARTTIME = RealTime()
    ACTIVEVOTEENDTIME = RealTime() + duration

    Me:AddPlayerOption(title, duration, function(id)
        if ACTIVEVOTEOPTIONS[id] then
            net.Start("DoVote")
            net.WriteUInt(id, 8)
            net.SendToServer()
        end

        return true
    end, function()
        DRAWVOTE()
    end)
end)
