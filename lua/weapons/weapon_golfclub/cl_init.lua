include("shared.lua")

SWEP.Purpose = "Wage jihad against the infidel"

GOLFSWINGFRAMES = {}
function ADDGOLFFRAME()
    while #GOLFSWINGFRAMES > 1 and GOLFSWINGFRAMES[1][3] < SysTime()-0.1 do
        table.remove(GOLFSWINGFRAMES, 1)
    end
    table.insert(GOLFSWINGFRAMES, {GOLFSWINGX,GOLFSWINGY,SysTime()})
end


-- net.Receive("GolfShot",function(len)
--     if net.ReadBool() then
--         GOLFCAMVECTOR = net.ReadVector():GetNormalized()
--         GOLFSWINGFRAMES = {}
--         GOLFSWINGX = -5
--         GOLFSWINGY = 0
--         LocalPlayer():SetEyeAngles(GOLFCAMVECTOR:Angle())
--         ADDGOLFFRAME()
--     else
--         GOLFCAMVECTOR = nil
--     end
-- end)

function STARTGOLFSHOT(dir)
    GOLFCAMVECTOR = dir
    GOLFSWINGFRAMES = {}
    GOLFSWINGX = -5
    GOLFSWINGY = 0

    GOLFCAMINTTIME = SysTime()
    GOLFCAMINTPOS = LocalPlayer():EyePos()
    GOLFCAMINTANG = LocalPlayer():EyeAngles()

    LocalPlayer():SetEyeAngles(GOLFCAMVECTOR:Angle())
    ADDGOLFFRAME()
end

function ENDGOLFSHOT()
    OLDGOLFCAMVECTOR = GOLFCAMVECTOR
    GOLFCAMINTTIME = SysTime()
    GOLFCAMVECTOR = nil
end


GOLFCAMLERPTIME = 0.6
function SWEP:GolfCamViewTargets(vec)
    local p = self:GetBall()
    if not IsValid(p) then return end

    p,a = LocalToWorld(Vector(0,24,64), Angle(60,-80,0), p:GetPos(), vec:Angle())

    a:RotateAroundAxis(a:Up(),20)

    return p,a
end

GOLFCAMFOV = 90
function SWEP:CalcView(ply, pos, ang, fov)
    if GOLFCAMVECTOR and self:GetStage() ~= 2 then 
        ENDGOLFSHOT()
    end

    if GOLFCAMVECTOR then
        p,a = self:GolfCamViewTargets(GOLFCAMVECTOR)
        if not p then return end

        local lerp = math.Clamp( (SysTime()-GOLFCAMINTTIME)/GOLFCAMLERPTIME, 0, 1)

        p = LerpVector(lerp, GOLFCAMINTPOS, p)
        a = LerpAngle(lerp, GOLFCAMINTANG, a)

        return p,a,Lerp(lerp, fov, GOLFCAMFOV)
    elseif OLDGOLFCAMVECTOR then
        p,a = self:GolfCamViewTargets(OLDGOLFCAMVECTOR)
        if not p then return end

        local lerp = math.Clamp( (SysTime()-GOLFCAMINTTIME)/GOLFCAMLERPTIME, 0, 1)

        p = LerpVector(lerp, p, pos)
        a = LerpAngle(lerp, a, ang)

        return p,a,Lerp(lerp, GOLFCAMFOV, fov) 
    end
end


hook.Add("CreateMove","golfswinger",function( cmd)
    -- if GOLFCAMVECTOR then
    --     chat.AddText(tostring(cmd:GetMouseX()))

    --     GOLFSWINGX = math.Clamp(GOLFSWINGX+cmd:GetMouseX()*-0.0005,-1,1)
    --     GOLFSWINGY = math.Clamp(GOLFSWINGY+cmd:GetMouseY()*0.0005,-1,1)

    --     cmd:SetViewAngles(GOLFCAMVECTOR:Angle())
    --     cmd:SetForwardMove(0)
    --     cmd:SetSideMove(0)
    -- end
end)



hook.Add("Think","golfswinger2",function()
    if GOLFCAMVECTOR then
        if not IsValid(LocalPlayer()) or not IsValid(LocalPlayer():GetActiveWeapon()) or LocalPlayer():GetActiveWeapon():GetClass()~="weapon_golfclub" then GOLFCAMVECTOR=nil return end

        local target = GOLFCAMVECTOR:Angle()
        local a = LocalPlayer():EyeAngles()

        local xm = math.AngleDifference(a.yaw, target.yaw)
        local ym = math.AngleDifference(a.pitch, target.pitch)

        GOLFSWINGX = GOLFSWINGX+xm*0.3
        GOLFSWINGY = GOLFSWINGY+ym*0.3

        local scale = GOLFMAXDIST/math.max(GOLFMAXDIST, math.sqrt(GOLFSWINGX*GOLFSWINGX + GOLFSWINGY*GOLFSWINGY))
        GOLFSWINGX = GOLFSWINGX*scale
        GOLFSWINGY = GOLFSWINGY*scale

        ADDGOLFFRAME()

        LocalPlayer():SetEyeAngles(target)

        local strike_offset = math.Clamp(-GOLFSWINGY, -GOLFCLUBRADIUS, GOLFCLUBRADIUS)
        local v1 = Vector(GOLFSWINGFRAMES[1][1], GOLFSWINGFRAMES[1][2] + strike_offset, 0)
        local v2 = Vector(GOLFSWINGX, GOLFSWINGY + strike_offset, 0)
        local v3 = Vector(0,0,0)

        local v1v2 = v2-v1
        local v1v2l = v1v2:Length()
        local v1v2n = v1v2/v1v2l
        local closestdist = v1v2n:Dot(v3-v1)
        local closestpoint = v1 + closestdist * v1v2n

        if (v1-v3):Length()>GOLFBALLRADIUS then
            local hit1 = (v2-v3):Length()<=GOLFBALLRADIUS
            local hit2 = ((closestpoint-v3):Length()<GOLFBALLRADIUS and closestdist > 0 and closestdist < v1v2l)
            
            if hit1 or hit2 then
                local localvel = v1v2 / (SysTime()-GOLFSWINGFRAMES[1][3])

                local angg = localvel:Angle().yaw
                if angg>180 then angg=angg-360 end

                chat.AddText(string.format("Hit power: %G, angle %G", localvel:Length(), angg))
                local speed = localvel.x * GOLFCAMVECTOR - localvel.y * GOLFCAMVECTOR:Angle():Right()

                local realclub = LocalPlayer():GetActiveWeapon()
                local realball = realclub:GetBall()
                realball:InterpolateHit(speed)

                net.Start("GolfShot")
                net.WriteVector(speed)
                net.SendToServer()
                ENDGOLFSHOT()

                --local p,a = realclub:GolfCamViewTargets(OLDGOLFCAMVECTOR)
                local p = LocalPlayer():EyePos()
                -- local a = OLDGOLFCAMVECTOR:Angle()
                -- a:RotateAroundAxis(Vector(0,0,1),-10)
                -- a:RotateAroundAxis(a:Right(),-20)
                -- POSTGOLFVIEWANGLE = a

                POSTGOLFVIEWANGLE = ((realball:GetPos() + speed*1.5) - p):Angle()
                LocalPlayer():SetEyeAngles(POSTGOLFVIEWANGLE)
            end
        end
    elseif POSTGOLFVIEWANGLE and SysTime()-GOLFCAMINTTIME < 0.5 then
        LocalPlayer():SetEyeAngles(POSTGOLFVIEWANGLE)
    end
end)


function SWEP:DrawWorldModel()
    local ply = self:GetOwner()

    if (IsValid(ply)) then
        local bn = ply:IsPony() and "LrigScull" or "ValveBiped.Bip01_L_Hand"
        local bon = ply:LookupBone(bn) or 0

        local opos = self:GetPos()
        local oang = self:GetAngles()
        local bp, ba = ply:GetBonePosition(bon)
        if (bp) then
            opos = bp
        end
        if (ba) then
            oang = ba
        end
        if ply:IsPony() then
            oang:RotateAroundAxis(oang:Up(), -90)
            opos = opos + (oang:Up() * -9) + (oang:Right() * -6.7) + (oang:Forward() * -1.9)
        else
            oang:RotateAroundAxis(oang:Up(), 150)
            oang:RotateAroundAxis(oang:Forward(), 25)
            oang:RotateAroundAxis(oang:Right(), 30)
            opos = opos + oang:Forward() * -2.6 + oang:Right() * 0 + oang:Up() * -10
        end
        self:SetupBones()

        --self:SetModelScale(0.8,0)
        local mrt = self:GetBoneMatrix(0)
        if (mrt) then
            mrt:SetTranslation(opos)
            mrt:SetAngles(oang)

            self:SetBoneMatrix(0, mrt)
        end
    end

    self:DrawModel()
end

GolfClubPositionLerp = 0

GOLFMAXDIST = 50
GOLFCLUBRADIUS = 2
GOLFBALLRADIUS = 2


function SWEP:GetViewModelPosition(pos, ang)
    if self:GetHoldType() == "passive" then
        GolfClubPositionLerp = math.min(1, GolfClubPositionLerp + (FrameTime() * 0.5))
    else
        GolfClubPositionLerp = math.max(0, GolfClubPositionLerp - (FrameTime() * 2))
    end

    pos = pos + ang:Right() * 7 + ang:Up() * -20 + ang:Forward() * 15
    local oang = Angle()
    oang:Set(ang)
    ang:RotateAroundAxis(oang:Up(), 90)
    ang:RotateAroundAxis(oang:Forward(), 10)
    ang:RotateAroundAxis(oang:Right(), -30 + (-100 * GolfClubPositionLerp))

    self.ViewModelFOV = 62

    if GOLFCAMVECTOR then
        local p = self:GetBall()
        if not IsValid(p) then return end

        pos,ang = LocalToWorld(Vector(-0.5 + GOLFSWINGX,13.5+ GOLFSWINGY,32.5), Angle(160,-90,0), p:GetPos(), GOLFCAMVECTOR:Angle())

        self.ViewModelFOV = LocalPlayer():GetFOV()
    end

    return pos, ang
end



local function makeCircle(x, y, radius, seg)
    local cir = {}

    table.insert(cir, {x = x, y = y, u = 0.5, v = 0.5})
    for i = 0, seg do
        local a = math.rad((i / seg) * -360)
        table.insert(
            cir,
            {
                x = x + math.sin(a) * radius,
                y = y + math.cos(a) * radius,
                u = math.sin(a) / 2 + 0.5,
                v = math.cos(a) / 2 + 0.5
            }
        )
    end

    local a = math.rad(0) -- This is need for non absolute segment counts
    table.insert(
        cir,
        {
            x = x + math.sin(a) * radius,
            y = y + math.cos(a) * radius,
            u = math.sin(a) / 2 + 0.5,
            v = math.cos(a) / 2 + 0.5
        }
    )

    surface.DrawPoly(cir)
end


function SWEP:DrawHUD()

    GOLFHUDSCALE = 10

    if GOLFCAMVECTOR and false then
        local xc = ScrW()/2
        local yc = ScrH()*3/4
        surface.SetDrawColor(255,255,255)
        surface.DrawCircle(xc,yc,GOLFBALLRADIUS*GOLFHUDSCALE,255,255,255)
        surface.DrawLine(
            xc - GOLFSWINGX*GOLFHUDSCALE, yc + GOLFSWINGY*GOLFHUDSCALE + GOLFCLUBRADIUS*GOLFHUDSCALE, 
            xc - GOLFSWINGX*GOLFHUDSCALE, yc + GOLFSWINGY*GOLFHUDSCALE - GOLFCLUBRADIUS*GOLFHUDSCALE
        )

        
        local strike_offset = math.Clamp(-GOLFSWINGY, -GOLFCLUBRADIUS, GOLFCLUBRADIUS)

        if GOLFSWINGFRAMES[1] then
            surface.DrawLine(
                xc - GOLFSWINGX*GOLFHUDSCALE, yc + GOLFSWINGY*GOLFHUDSCALE + strike_offset*GOLFHUDSCALE, 
                xc - GOLFSWINGFRAMES[1][1]*GOLFHUDSCALE, yc + GOLFSWINGFRAMES[1][2]*GOLFHUDSCALE + strike_offset*GOLFHUDSCALE
            )
        end

        -- surface.DrawLine(
        --     xc - GOLFBALLRADIUS*GOLFHUDSCALE,yc,
        --     xc - GOLFSWINGX*GOLFHUDSCALE, yc + GOLFSWINGY*GOLFHUDSCALE + offset*GOLFHUDSCALE
        -- )

    end


    local stage = self:GetStage()
    local strk = self:GetStroke()

    if (IsValid(self:GetBall())) then
        cam.Start3D()
        local ball = self:GetBall()
        local trace = LocalPlayer():GetEyeTrace()
        local p1 = util.IntersectRayWithPlane(EyePos(), EyeAngles():Forward(), ball:GetPos(), Vector(0, 0, 1))

        local p2 = ball:GetPos()
        if (p1 == nil) then
            p1 = p2
        end

        if (p1:Distance(p2) > 200) then
            p1 = (p1 - p2)
            p1 = p2 + (p1:GetNormalized() * 200)
        end
        local dist = p1:Distance(p2)

        local cpos = p1
        local bpos = ball:GetPos() + Vector(-5, 5, 0)
        local pos = trace.HitPos
        --pos.z = ball:GetPos().z
        local angle = Angle(0, 0, 0)
        local a2 = Angle(0, 0, 0)
        a2:RotateAroundAxis(Vector(0, 0, 1), math.deg(math.atan2(p1.x - p2.x, p2.y - p1.y)))

        local tv = Vector(-5, 5, 0)
        tv:Rotate(a2)
        if (stage == 2) then
            if self:WeirdGolf() then
                if not GOLFCAMVECTOR then
                    local off = 5

                    cam.Start3D2D(ball:GetPos()-a2:Forward()*off, a2, 1) 
                    local c = HSVToColor(120, 1, 1)
                    surface.SetDrawColor(c.r, c.g, c.b, 100)
                    draw.NoTexture()
                    
                    local cir = {}
                    table.insert(cir, {x = off, y = 25, u = 0.5, v = 0.5})
                    table.insert(cir, {x = off - 1.5, y = 5, u = 0.5, v = 0.5})
                    table.insert(cir, {x = off + 1.5, y = 5, u = 0.5, v = 0.5})
                    if bpos.z > EyePos().z then cir[1],cir[2] = cir[2],cir[1] end
                    surface.DrawPoly(cir)
                    cam.End3D2D()

                end
            else

                a2 = Angle(0,0,0)
                a2:RotateAroundAxis( Vector(0,0,1), math.deg(math.atan2(  p2.x-p1.x, p1.y-p2.y )) )
                tv = Vector(-5,5,0)
                tv:Rotate(a2)


                cam.Start3D2D( cpos + tv, a2, 1 )
                local c = HSVToColor(120 - ((dist/200)*120),1,1)
                surface.SetDrawColor( c.r, c.g, c.b, 100 )
                draw.NoTexture()
        
                local off=5
                local cir = {}
                table.insert( cir, { x = off, y = off-1, u = 0.5, v = 0.5 } )
                table.insert( cir, { x = off+2, y = 5+off-3, u = 0.5, v = 0.5 } )
                table.insert( cir, { x = off-2, y = 5+off-3, u = 0.5, v = 0.5 } )
                if bpos.z > EyePos().z then cir[1],cir[2] = cir[2],cir[1] end
                surface.DrawPoly( cir )
                if dist>4.5 then
                    
                    cir = {}
                    table.insert( cir, { x = off-1, y = 5+off-3, u = 0, v = 1 } )
                    table.insert( cir, { x = off+1, y = dist+off-2.5, u = 1, v = 0 } )
                    table.insert( cir, { x = off-1, y = dist+off-2.5, u = 1, v = 1 } )
                    if bpos.z > EyePos().z then cir[1],cir[2] = cir[2],cir[1] end
                    surface.DrawPoly( cir )
                    cir = {}
                    table.insert( cir, { x = off+1, y = 5+off-3, u = 0, v = 1 } )
                    table.insert( cir, { x = off+1, y = dist+off-2.5, u = 1, v = 0 } )
                    table.insert( cir, { x = off-1, y = 5+off-3, u = 1, v = 1 } )
                    if bpos.z > EyePos().z then cir[1],cir[2] = cir[2],cir[1] end
                    surface.DrawPoly( cir )
                        
                end
        
                cam.End3D2D()
            end
        end

        local ball = self:GetBall()
        local trc = {}
        trc.start = EyePos()
        trc.endpos = ball:GetPos()
        trc.filter = LocalPlayer()
        local seetrace = util.TraceLine(trc)
        if (seetrace.Entity ~= ball) then
            cam.Start3D2D(bpos, angle, 1)
            local c = ball:GetColor()
            surface.SetDrawColor(128, 128, 128, 255)
            draw.NoTexture()
            makeCircle(5, 5, 2.5, 32)
            surface.SetDrawColor(c.r, c.g, c.b, 255)
            draw.NoTexture()
            makeCircle(5, 5, 2, 32)
            cam.End3D2D()
        end

        cam.End3D()
    end

    

    if (stage == 0) then
        cam.Start3D()

        local trace = LocalPlayer():GetEyeTrace()
        local cpos = trace.HitPos + Vector(-6, 6, 0)

        local pos = trace.HitPos
        --pos.z = ball:GetPos().z
        local angle = Angle(0, 0, 0)

        cam.Start3D2D(cpos, angle, 1)

        surface.SetDrawColor(0, 0, 0, 200)
        draw.NoTexture()
        makeCircle(6, 6, 3, 32)
        local c = self.Owner:GetPlayerColor() * 255
        local h, s = ColorToHSV(Color(c.x, c.y, c.z))
        c = HSVToColor(h, s, 1)
        surface.SetDrawColor(c.r, c.g, c.b, 200)
        draw.NoTexture()
        makeCircle(6, 6, 2.75, 32)

        cam.End3D2D()

        cam.End3D()
    end

    local stg = "Place the ball"
    local clr = Color(255, 255, 255)
    local fnd = false
    local rdy = nil

    if (stage == 1) then
        stg = "Ball is moving..."
    end

    if (stage == 2 and IsValid(self:GetBall())) then
        local trace = LocalPlayer():GetEyeTrace()
        local ball = self:GetBall()

        local p1 = util.IntersectRayWithPlane(EyePos(), EyeAngles():Forward(), ball:GetPos(), Vector(0, 0, 1))
        local medist = LocalPlayer():EyePos():Distance(ball:GetPos())

        --local p1 = trace.HitPos
        local p2 = ball:GetPos()
        if (p1 == nil) then
            p1 = p2
        end

        if (p1:Distance(p2) > 200) then
            p1 = (p1 - p2)
            p1 = p2 + (p1:GetNormalized() * 200)
        end

        local dist = math.Clamp(p1:Distance(p2), 0, 200)

        stg = "Power: " .. math.ceil(dist / 2) .. "%"
        clr = HSVToColor(120 - ((dist / 200) * 120), 1, 1)

        if self:WeirdGolf() then
            stg = "Click to start swinging"
            clr = HSVToColor(120, 1, 1)

            if GOLFCAMVECTOR then
                stg = "Use your mouse to hit the ball"
            end
        end

        if (medist > 150) then
            stg = "Move closer to the ball"
            clr = Color(255, 0, 0, 255)
        end
    end

    local clr2 = Color(255, 255, 255, 255)
    local strom = strk .. " Stroke"
    if (strk > 1) then
        strom = strom .. "s"
    end
    if (strk == 0) then
        strom = ""
    end
    if (strk == 8) then
        clr2 = Color(255, 255, 0, 255)
    end
    if (strk == 9) then
        clr2 = Color(255, 100, 0, 255)
    end

    if (strk == 10) then
        clr2 = Color(255, 0, 0, 255)
        strom = "Final Stroke!"
    end

    local bw, bh = 384, 64
    local marg = 8
    local bh2 = 48
    local mix, miy = ScrW() - bw / 2 - marg, ScrH() - bh / 2 - marg
    draw.RoundedBox(8, ScrW() - bw - marg, ScrH() - bh - marg, bw, bh, Color(25, 25, 25, 200))
    if (stage == 0 or strom == "") then
        draw.SimpleText(stg, "Trebuchet24", mix, miy, clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    else
        draw.SimpleText(strom, "Trebuchet24", mix, miy - 16, clr2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(stg, "Trebuchet24", mix, miy + 16, clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    clr = Color(255,255,255,255)
    draw.RoundedBox(8, ScrW() - bw - marg -bw -marg, ScrH() - bh2 - marg, bw, bh2, Color(25, 25, 25, 200))
    draw.SimpleText("Controls: "..(self:GetControls() and "SIMULATION (higher reward)" or "Easy (lower reward)"), "Trebuchet24", mix -bw -marg, ScrH() - marg - bh2/2 - 8, clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText("Press R to change (right click to reset ball without changing)", "Trebuchet18", mix -bw -marg, ScrH() - marg - bh2/2 + 12, clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function SWEP:CustomAmmoDisplay()
end

if (CLIENT) then --
--[[ hook.Add( "PreDrawHalos", "GolfHalo", function()

	for k,v in pairs(ents.FindByClass("golfball"))do
	if(v:GetNWEntity("BallOwner") == LocalPlayer())then
	
	if(v:GetNWBool("shootable"))then
	halo.Add( {v}, Color( 100, 255, 100 ), 2, 2, 2 )
	else
	halo.Add( {v}, Color( 255, 100, 100 ), 2, 2, 2 )
	end
	
	end
	end
	
end ) ]]
end
