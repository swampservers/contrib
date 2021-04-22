

MVIS_LAST_REQUESTED_VIDEO = MVIS_LAST_REQUESTED_VIDEO or ""
LOUNGE_DOORS = {}
util.AddNetworkString("SetMusicVis")

net.Receive("SetMusicVis", function(len, ply)
    local st = net.ReadString()
    if st:len() > 30 then return end    
    if ply:GetTheater() and ply:GetTheater():Name()=="Vapor Lounge" and (ply:GetTheater():GetOwner()==ply or ply:IsAdmin()) then
        if st=="ignite" then
            if (MUSIC_LAST_SFX or 0) < CurTime()-30 then
                for _,v in ipairs(ents.FindByClass("prop_physics")) do
                    if v:GetModel()=="models/sunabouzu/speaker.mdl" then -- or v:GetModel()=="models/props_combine/breenconsole.mdl" then
                        v:Ignite(8)
                    end
                end 
                MUSIC_LAST_SFX=CurTime()
            end
            return
        end
        SetG("musicvis", st:lower()) 
    else
        ply:Notify("You must own the theater to do this.")
    end
end)

timer.Create("musicvis_resetter",0.5,0,function()
    local th =theater.GetByLocation(Location.GetLocationIndexByName("Vapor Lounge"))

    if th:VideoType()=="youtube" and MVIS_LAST_REQUESTED_VIDEO~=th:VideoKey() then
        print("MAKEREQUEST") 
        http.Fetch("http://127.0.0.1/fft/?v="..th:VideoKey(),function(b,l,h,c) print(b) end, function(msg) print(msg) end) --tell the server to prepare it, hopefully it works
        MVIS_LAST_REQUESTED_VIDEO = th:VideoKey()
    end

    if not th then return end
    local o = th:GetOwner()
    if o~=MUSICVISLASTOWNER then
        MUSICVISLASTOWNER=o
        SetG("musicvis", "rave")
    end

    if #LOUNGE_DOORS==0 then
        for _,v in ipairs(ents.GetAll()) do if v.LOUNGEDOOR then v:Remove() end end
        for _,side in ipairs({-1,1}) do
        e = ents.Create("prop_door_rotating")
        e.LOUNGEDOOR=true
        table.insert(LOUNGE_DOORS, e)
        e:SetModel("models/props_c17/door01_left.mdl")
        e:SetSkin(2)
        e:SetPos(Vector(2050, 768+side*46, 54))
        e:SetAngles(Angle(0,90+90*side,0))
        e.INNER_OPEN = side==1 and 2 or 1
        e.OUTER_OPEN = side==1 and 1 or 2
        e:SetKeyValue("opendir",e.INNER_OPEN)
        e:SetKeyValue("returndelay",4)
        e:SetKeyValue("forceclosed",1)
        -- e:SetKeyValue( "spawnflags", 8192 ) --use closes
        e:SetColor(Color(128,128,128))
        e:Spawn()
        e:Activate()
        e.WASCLOSED = true
        e.IsOpen = function(ent) return math.abs(ent:GetAngles():Forward().y) > 0.9 end
        end
    end

    for _,v in ipairs(LOUNGE_DOORS) do
        if (v.UseTime or 0) < CurTime() - 4 then
            local op = v:IsOpen()
            if th:IsPlaying() == op then
                v:Fire(op and "Close" or "Open")
            end
        end
    end
end)

hook.Add("PlayerUse", "LoungeDoorOpener", function(ply, ent)
    if ent.LOUNGEDOOR then
        local tofire = ent:IsOpen() and "Close" or "Open"
        for _,v in ipairs(LOUNGE_DOORS) do
            v:SetKeyValue("opendir", ply:GetPos().x<v:GetPos().x and v.OUTER_OPEN or v.INNER_OPEN)
            v:Fire(tofire)
            v.UseTime = CurTime()
        end
        return false
    end
end)
