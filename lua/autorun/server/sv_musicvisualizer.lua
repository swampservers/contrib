-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
MVIS_LAST_REQUESTED_VIDEO = MVIS_LAST_REQUESTED_VIDEO or ""
LOUNGE_DOORS = {}
util.AddNetworkString("SetMusicVis")

net.Receive("SetMusicVis", function(len, ply)
    local st = net.ReadString()
    if st:len() > 30 then return end

    if ply:GetTheater() and ply:GetTheater():Name() == "Vapor Lounge" and (ply:GetTheater():GetOwner() == ply or ply:IsAdmin()) then
        if st == "ignite" then
            if (MUSIC_LAST_SFX or 0) < CurTime() - 30 then
                for _, v in ipairs(ents.FindByClass("prop_physics")) do
                    -- or v:GetModel()=="models/props_combine/breenconsole.mdl" then
                    if v:GetModel() == "models/sunabouzu/speaker.mdl" then
                        v:Ignite(8)
                    end
                end

                MUSIC_LAST_SFX = CurTime()
            end

            return
        end

        if st == "clearstage" then
            MVIS_CLEAR_STAGE = not MVIS_CLEAR_STAGE
            ply:Notify(MVIS_CLEAR_STAGE and "Enabled" or "Disabled")

            return
        end

        SetG("musicvis", st:lower())
    else
        ply:Notify("You must own the theater to do this.")
    end
end)

timer.Create("musicvis_resetter", 0.5, 0, function()
    if not theater then return end
    local th = theater.GetByLocation(Location.GetLocationIndexByName("Vapor Lounge"))

    if th:VideoType() == "youtube" and th:VideoDuration() > 0 and th:VideoDuration() < 10000 and MVIS_LAST_REQUESTED_VIDEO ~= th:VideoKey() and not HumanTeamName then
        --tell the server to prepare it, hopefully it works
        -- http.Fetch("http://127.0.0.1/fft/?v=" .. th:VideoKey(), function(b, l, h, c)
        --     print(b)
        -- end, function(msg)
        --     print(msg)
        -- end)
        print("TRY2")

        if MVIS_KILL_PREV then
            print("KILLL")
            MVIS_KILL_PREV()
        end

        if not Shell then
            print("IMPORT SHELL")
            require("shell")
            print("OK")
        end

        MVIS_KILL_PREV = Shell.Execute({"/swamp/gm_shell/fft.sh", th:VideoKey()}, function(c, a, b)
            print("STDOUT", a)
            print("STDERR", b)
            print("CODE", c)
        end)

        -- MVIS_KILL_PREV = nil
        MVIS_LAST_REQUESTED_VIDEO = th:VideoKey()
    end

    if not th then return end
    local o = th:GetOwner()

    if o ~= MUSICVISLASTOWNER then
        MUSICVISLASTOWNER = o
        MVIS_CLEAR_STAGE = false
        SetG("musicvis", "rave")
    end

    if IsValid(o) and MVIS_CLEAR_STAGE then
        for k, v in pairs(player.GetAll()) do
            if v:GetTheater() == th and v ~= o and not v:InVehicle() and v:Alive() then
                if v:GetPos().y < 606 then
                    v:SetPos(Vector(v:GetPos().x, 606, v:GetPos().z))
                    v:Notify("Get off the stage!")
                end
            end
        end
    end

    if #LOUNGE_DOORS == 0 then
        for _, v in ipairs(ents.GetAll()) do
            if v.LOUNGEDOOR then
                v:Remove()
            end
        end

        for _, side in ipairs({-1, 1}) do
            e = ents.Create("prop_door_rotating")
            e.LOUNGEDOOR = true
            table.insert(LOUNGE_DOORS, e)
            e:SetModel("models/props_c17/door01_left.mdl")
            e:SetSkin(2)
            e:SetPos(Vector(2048, 768 + side * 46, 54))
            e:SetAngles(Angle(0, 90 + 90 * side, 0))
            e.INNER_OPEN = side == 1 and 2 or 1
            e.OUTER_OPEN = side == 1 and 1 or 2
            e:SetKeyValue("opendir", e.INNER_OPEN)
            e:SetKeyValue("returndelay", 4)
            e:SetKeyValue("forceclosed", 1)
            -- e:SetKeyValue( "spawnflags", 8192 ) --use closes
            e:SetColor(Color(128, 128, 128))
            e:Spawn()
            e:Activate()
            e.WASCLOSED = true
            e.IsOpen = function(ent) return math.abs(ent:GetAngles():Forward().y) > 0.9 end
        end
    end
end)

-- for _, v in ipairs(LOUNGE_DOORS) do
--     if (v.UseTime or 0) < CurTime() - 4 then
--         local op = v:IsOpen()
--         if th:IsPlaying() == op then
--             v:Fire(op and "Close" or "Open")
--         end
--     end
-- end
hook.Add("PlayerUse", "LoungeDoorOpener", function(ply, ent)
    if ent.LOUNGEDOOR then
        local tofire = ent:IsOpen() and "Close" or "Open"

        for _, v in ipairs(LOUNGE_DOORS) do
            v:SetKeyValue("opendir", ply:GetPos().x < v:GetPos().x and v.OUTER_OPEN or v.INNER_OPEN)
            v:Fire(tofire)
            v.UseTime = CurTime()
        end

        return false
    end
end)
