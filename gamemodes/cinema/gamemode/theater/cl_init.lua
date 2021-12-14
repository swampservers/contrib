-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
module("theater", package.seeall)
CurrentVideo = CurrentVideo or nil -- Most recent video loaded
Fullscreen = Fullscreen or false
NumVoteSkips = NumVoteSkips or 0
ReqVoteSkips = ReqVoteSkips or 0
ActivePanel = ActivePanel or nil
Queue = Queue or {}
local _Volume = -1

hook.Add("Tick", "TheaterPanelRemover", function()
    if IsValid(Me) then
        if not Me:GetTheater() then
            RemovePanels()
        end

        if Fullscreen and not IsValid(ActivePanel) then
            ToggleFullscreen()
        end
    end
end)

function CreatePanel()
    if not Me:GetTheater() then
        error("Not in a theater")
    end

    if Fullscreen then
        RunConsoleCommand("cinema_fullscreen_freeze", "0")
    end

    Fullscreen = false
    -- There should only be one panel playing
    RemovePanels()
    ActivePanel = vgui.Create("TheaterHTML", vgui.GetWorldPanel(), "TheaterScreen")

    ActivePanel.GetUVMax = function(self)
        local pw, ph = self:GetSize()

        return pw / math.power2(pw), ph / math.power2(ph)
    end

    --[[
	timer.Simple(0.1, function()
		if IsValid(ActivePanel) then
			local js = string.format(
				"if(window.theater) theater.setVolume(%s);", GetVolume() )
			ActivePanel:QueueJavascript(js)

			if GetConVar("cinema_hd"):GetBool() then
				panel:QueueJavascript( "if(window.theater) theater.enableHD();" )
			end

			if GetConVar("cinema_cc"):GetBool() then
				panel:QueueJavascript( "if(window.theater) theater.enableCC();" )
			end
		end
	end)]]
    RefreshPanel()
end

function RefreshPanel(reload)
    if reload then
        RemovePanels()
        LoadVideo(CurrentVideo)
    elseif IsValid(ActivePanel) then
        ActivePanel:SetPaintedManually(true)
        ActivePanel:SetScrollbars(false)
        ActivePanel:SetAllowLua(true)
        ActivePanel:SetKeyBoardInputEnabled(Fullscreen)
        ActivePanel:SetMouseInputEnabled(Fullscreen)
    end

    ResizePanel()
end

function ResizePanel()
    if not IsValid(ActivePanel) then return end

    if Fullscreen then
        ActivePanel:SetSize(ScrW(), ScrH())
    else
        local Theater = Me:GetTheater()
        local tw, th = Theater:GetSize()
        local aspect = tw / th
        local q = GetConVar("cinema_quality"):GetInt()
        local h, w = 256, 512

        if q == 1 then
            h, w = 512, 1024
        elseif q == 2 then
            h, w = 1024, 2048
        elseif q >= 3 then
            h, w = 2048, 4096
        end

        if aspect >= 2 then
            h, w = math.ceil(w / aspect), w
        else
            h, w = h, math.ceil(h * aspect)
        end

        ActivePanel:SetSize(w, h)
    end
end

function RemovePanels()
    if IsValid(ActivePanel) then
        ActivePanel:Remove()
    end

    -- Remove any remaining panels that might exist
    --[[local panels = {}
	table.Add( panels, vgui.GetWorldPanel():GetChildren() )
	table.Add( panels, GetHUDPanel():GetChildren() )

	for _, p in pairs(panels) do
		if ValidPanel(p) and p.ClassName == "TheaterHTML" then
			p:Remove()
		end
	end]]
    -- Remove admin panel between theater transitions
    if ValidPanel(GuiAdmin) then
        GuiAdmin:Remove()
    end
end

--theater.RemovePanels
hook.Add("OnReloaded", "RemoveAllPanels", function()
    print("RELOAD")
end)

hook.Add("OnGamemodeLoaded", "RemoveAllPanels2", theater.RemovePanels)

function ToggleFullscreen()
    Fullscreen = not Fullscreen

    if IsValid(ActivePanel) then
        RefreshPanel()

        -- Toggle fullscreen
        if Fullscreen then
        else --ActivePanel:ParentToHUD() -- Render before the HUD
        end
        --ActivePanel:SetParent(vgui.GetWorldPanel())
    end

    RunConsoleCommand("cinema_fullscreen_freeze", tostring(Fullscreen))
end

function GetQueue()
    if Me:GetTheater() then
        return Queue
    else
        return {}
    end
end

function GetVolume()
    if _Volume < 0 then
        _Volume = GetConVar("cinema_volume"):GetInt()
    end

    return _Volume
end

function SetVolume(fVolume)
    fVolume = tonumber(fVolume)
    if not fVolume then return end

    if IsValid(ActivePanel) and CurrentVideo then
        CurrentVideo:Service():SetVolume(fVolume, ActivePanel)
    end

    _Volume = fVolume
    LastInfoDraw = CurTime()
end

function PollServer()
    -- Prevent spamming requests
    if Me.LastTheaterRequest and Me.LastTheaterRequest + 0.5 > CurTime() then return end
    net.Start("TheaterInfo")
    net.SendToServer()
    Me.LastTheaterRequest = CurTime()
end

net.Receive("TheaterVideo", function()
    local Video = nil
    local info = {}
    info.type = net.ReadString()

    if info.type ~= "" then
        info.key = net.ReadString()
        info.title = net.ReadString()
        info.duration = net.ReadInt(32)
        info.data = net.ReadString()
        info.start = net.ReadFloat()
        info.OwnerName = net.ReadString()
        info.OwnerSteamID = net.ReadString()
        Video = VIDEO:Init(info)
        NumVoteSkips = net.ReadUInt(8)
    else
        NumVoteSkips = 0
    end

    -- Private theater owner
    local Theater = Me.GetTheater and Me:GetTheater()

    if Theater then
        Theater:SetVideo(Video)
        LoadVideo(Video)
    else
        timer.Simple(0.1, function()
            Theater = Me.GetTheater and Me:GetTheater()

            if Theater then
                Theater:SetVideo(Video)
                LoadVideo(Video)
            else
                print("Error receiving video")
            end
        end)
    end

    LastInfoDraw = CurTime()
end)

--NOMINIFY
net.Receive("TheaterSeek", function()
    local seconds = net.ReadFloat()
    local Video = CurrentVideo
    local Theater = Me:GetTheater()
    if not Video or not Theater then return end
    Video._VideoStart = seconds
    Theater._VideoStart = seconds

    if IsValid(ActivePanel) and CurrentVideo then
        CurrentVideo:Service():SeekTo(CurTime() - seconds, ActivePanel)
    end
end)

net.Receive("TheaterInfo", function()
    local v = net.ReadTable()
    Queue = net.ReadTable()
    local Video = Theaters[v.Location] and Theaters[v.Location]._Video
    table.Empty(Theaters)
    local Theater = nil
    -- Merge shared theater data
    local loc = Locations[v.Location]

    if loc and loc.Theater then
        -- puts the received values OVER the location
        v = table.Merge(loc.Theater, v)
    end

    Theater = THEATER:Init(v.Location, v)
    Theater._Video = Video

    if Theater:IsPrivate() and v.Owner then
        Theater._Owner = v.Owner
    end

    if v.NumPlayers then
        Theater._NumPlayers = v.NumPlayers
    end

    --[[
	if v.OriginalName then
		Theater._OriginalName = v.OriginalName
	end]]
    Theaters[v.Location] = Theater

    if ValidPanel(GuiQueue) then
        GuiQueue:UpdateList()
    end
end)

net.Receive("TheaterVoteSkips", function()
    local name = net.ReadString()
    local skips = net.ReadInt(7)
    local required = net.ReadInt(7)

    AddAnnouncement({'Theater_PlayerVoteSkipped', name, skips, required})

    NumVoteSkips = skips
    ReqVoteSkips = required
end)

function LoadVideo(Video, force)
    -- refresh panels on service change to fix bugs
    if CurrentVideo and Video and CurrentVideo:Type() ~= Video:Type() or force then
        RemovePanels()
    end

    CurrentVideo = Video

    if not Video or not Video:ShouldTrust() then
        if IsValid(ActivePanel) then
            ActivePanel:Remove()
        end

        return
    end

    if not IsValid(ActivePanel) then
        CreatePanel()
    end

    ActivePanel.OnFinishLoading = function() end
    Me.theaterPanel = ActivePanel

    if Me.videoDebug and not force then
        print("KEY: " .. Video:Key(), string.len(Video:Key()))
        print("DATA: " .. Video:Data(), string.len(Video:Data()))
    end

    local svc = Video:Service()
    svc:LoadVideo(Video, ActivePanel)
    svc:SetVolume(theater.GetVolume(), ActivePanel)

    if Video:IsTimed() then
        local seektime = CurTime() - Video:StartTime()

        if seektime > 0.5 then
            svc:SeekTo(seektime, ActivePanel)
        end
    end

    if force then return end
    -- Output debug information
    Msg("Loaded Video\n")
    Msg("\tTitle:\t\t" .. tostring(Video:Title()) .. "\n")
    Msg("\tType:\t\t" .. tostring(Video:Type()) .. "\n")
    local vkey = tostring(Video:Key())
    local t = util.JSONToTable(vkey)

    if t and t["referer"] then
        vkey = t["referer"]
    end

    if string.find(vkey, "horatio.tube") then
        vkey = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
    end

    Msg("\tKey:\t\t" .. vkey .. "\n")
    Msg("\tDuration:\t" .. tostring(Video:Duration()) .. "\n")
    Msg(string.format("\tRequested by %s (%s)", Video:GetOwnerName(), Video:GetOwnerSteamID()) .. "\n")
end

net.Receive("GetVideoInfoClientside", function(len)
    local Type = net.ReadString()
    local key = net.ReadString()
    print("Getting data for " .. Type .. " / " .. key)

    GetServiceByClass(Type):GetVideoInfoClientside(key, function(info)
        net.Start("GetVideoInfoClientside")
        net.WriteString(Type)
        net.WriteString(key)

        if info then
            net.WriteBool(true)
            net.WriteString(info.title or "")
            net.WriteUInt(tonumber(info.duration) or 0, 32)
            net.WriteString(info.thumb or "")
            net.WriteString(info.data or "")
        else
            net.WriteBool(false)
        end

        net.SendToServer()
    end)
end)
