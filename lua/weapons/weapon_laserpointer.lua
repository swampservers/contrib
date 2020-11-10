AddCSLuaFile()

SWEP.PrintName = "Laser Pointer"
SWEP.Author = "PYROTEKNIK & Brian"
SWEP.Category = "PYROTEKNIK"
SWEP.Instructions = "Left Click to Blind People, Right Click to toggle lethal, R to change color"
SWEP.Purpose = "Point it in someone's eye :)"

SWEP.Slot = 0
SWEP.SlotPos = 4

SWEP.Spawnable = true

SWEP.ViewModel = Model("models/brian/laserpointer.mdl")
SWEP.WorldModel = Model("models/brian/laserpointer.mdl")

SWEP.UseHands = false

SWEP.Primary.ClipSize = 1000
SWEP.Primary.DefaultClip = 1000
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.BobScale = 0
SWEP.SwayScale = 0
SWEP.DrawAmmo = false
SWEP.ClickSound = Sound("Weapon_Pistol.Empty")
SWEP.UnClickSound = Sound("Weapon_AR2.Empty")
SWEP.DrawCrosshair = false
SWEP.BounceWeaponIcon = false
-- PlayerCanHaveLaserBeams is a hook used for this. the argument is just ply
-- return false on this one and players won't be able to make their laser beam fully visible and lethal using right mouse
--[[
PS_WeaponProduct({
	name = 'Laser Pointer',
	description = "Makes a funny dot. Keep away from eyes. Right click for lethal beam. Re-buy for battery refill.",
	price = 350,
	model = 'models/brian/laserpointer.mdl',
	class = 'weapon_laserpointer'
})

]]
hook.Add(
    "PlayerCanHaveLaserBeams",
    "DisableBeamModeInTheaters",
    function(ply, wep)
        --if(ply.InTheater and ply.InTheater())then return false	end
        if (Safe ~= nil and isfunction(Safe) and Safe(ply)) then
            return false
        end
    end
)

if (CLIENT) then
    local wepicon = Material("laserpointer/laserpointer_icon.png", "smooth")

    SWEP.WepSelectIcon = wepicon:GetTexture("$basetexture")
    killicon.Add("weapon_laserpointer", "sprites/glow04_noz_gmod", Color(255, 64, 64, 255))
    function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
        surface.SetDrawColor(ColorAlpha(NamedColor("FgColor"), alpha))
        surface.SetMaterial(wepicon)

        local fsin = 0
        local cx, cy = x + wide / 2, y + tall / 2.25
        local size = 168
        local ix, iy = cx - size / 2, cy - size / 2
        surface.DrawTexturedRect(ix, iy, size, size)
        self:PrintWeaponInfo(x + wide + 20, y + tall * 0.95, alpha)
    end
end

local maxsat = 0.95
SWEP.ColorFunctions = {}
SWEP.ColorFunctions[0] = function(ply)
    local wpncolor = ply:GetWeaponColor()
    local ch, cs, cv = ColorToHSV(Color(wpncolor.r * 255, wpncolor.g * 255, wpncolor.b * 255))
    cv = 1
    cs = math.Clamp(cs * maxsat, 0, maxsat)
    local lasercolor = HSVToColor(ch, cs, cv)
    return lasercolor
end

SWEP.ColorFunctions[1] = function(ply)
    local plycolor = ply:GetPlayerColor()
    local ch, cs, cv = ColorToHSV(Color(plycolor.r * 255, plycolor.g * 255, plycolor.b * 255))
    cv = 1
    cs = math.Clamp(cs * maxsat, 0, maxsat)
    local lasercolor = HSVToColor(ch, cs, cv)
    return lasercolor
end

local function wtfhsv(h, s, v) --apparently HSVToColor does not create colors with a metatable so here's a shitty override function
    local c = HSVToColor(h, s, v)
    return Color(c.r, c.g, c.b)
end

SWEP.ColorFunctions[2] = wtfhsv(0, maxsat, 1)
SWEP.ColorFunctions[3] = wtfhsv(120, maxsat, 1)
SWEP.ColorFunctions[4] = wtfhsv(240, maxsat, 1)

SWEP.ColorFunctions[5] = wtfhsv(60, maxsat, 1)
SWEP.ColorFunctions[6] = wtfhsv(180, maxsat, 1)
SWEP.ColorFunctions[7] = wtfhsv(300, maxsat, 1)

SWEP.ColorFunctions[8] = function(ply)
    local plycolor = ply:GetPlayerColor()
    ply.lzroffset = ply.lzroffset or math.Rand(0, 360)
    local lasercolor = HSVToColor(180 + math.NormalizeAngle(ply.lzroffset + CurTime() * 720), maxsat, 1)
    return lasercolor
end

function SWEP:ButtonSound(state)
    local clicksound = self.ClickSound
    if (not state) then
        clicksound = self.UnClickSound
    end
    self:EmitSound(clicksound, 10, 150, 0.001)
end

function SWEP:Initialize()
    ---self:SetHoldType( "pistol" )
    self:SetHoldType("knife")
end

function SWEP:SetupDataTables()
    self:NetworkVar("Bool", 0, "OnState")
    self:NetworkVar("Bool", 1, "BeamMode")
    self:NetworkVar("Int", 0, "ColorMode")
end

hook.Add(
    "NetworkEntityCreated",
    "LaserPointerFind",
    function(ent)
        if ent:GetClass() == "weapon_laserpointer" then
            lpointer_laser_source[ent] = true
        end
    end
)

hook.Add(
    "EntityRemoved",
    "LaserPointerRemove",
    function(ent)
        if ent:GetClass() == "weapon_laserpointer" then
            lpointer_laser_source[ent] = nil
        end
    end
)

function SWEP:SecondaryAttack()
    local can = hook.Call("PlayerCanHaveLaserBeams", nil, self:GetOwner(), self)
    if (can ~= false) then
        self:SetBeamMode(not self:GetBeamMode())
        self:ButtonSound(true)
        self.LastRightClick = true
    end
    self:SetNextSecondaryFire(CurTime() + 0.2)
end

function SWEP:Deploy()
    if (CLIENT) then
        self.HornBG = nil
    end
    self:UpdateVMFOV()
    if (SERVER and self:GetOwner().laserpointerlastcolor) then
        self:SetColorMode(self:GetOwner().laserpointerlastcolor)
    end
    return true
end

function SWEP:Holster()
    return true
end

function SWEP:Reload()
    return true
end

hook.Add(
    "KeyPress",
    "LaserColorPicker",
    function(ply, key)
        if
            (key == IN_RELOAD and IsValid(ply:GetActiveWeapon()) and
                ply:GetActiveWeapon():GetClass() == "weapon_laserpointer")
         then
            ply:GetActiveWeapon():ChangeColor()
            ply:GetActiveWeapon():ButtonSound(true)
        end
    end
)

hook.Add(
    "KeyRelease",
    "LaserColorPicker",
    function(ply, key)
        if
            ((key == IN_RELOAD or key == IN_ATTACK2) and IsValid(ply:GetActiveWeapon()) and
                ply:GetActiveWeapon():GetClass() == "weapon_laserpointer")
         then
            if (ply:GetActiveWeapon().LastRightClick) then
                ply:GetActiveWeapon().LastRightClick = nil
                ply:GetActiveWeapon():ButtonSound(false)
            end
        end
    end
)

function SWEP:ChangeColor()
    local nextmode = self:GetColorMode() + 1
    if (self.ColorFunctions[nextmode] == nil) then
        nextmode = 0
    end
    self:SetColorMode(nextmode)
    self:GetOwner().laserpointerlastcolor = self:GetColorMode()
end

function SWEP:PrimaryAttack()
    if (self:Clip1() <= 0) then
        return true
    end
    if (self:GetOnState() ~= true) then
        local can = hook.Call("PlayerCanHaveLaserBeams", nil, self:GetOwner(), self)
        if (can == false) then
            self:SetBeamMode(false)
        end
        self:SetOnState(true)
        self:ButtonSound(true)
    end
    local ply = self:GetOwner()
    local trace = ply:GetEyeTrace()
    local take = 1
    if (self:GetBeamMode()) then
        take = 4
    end
    self:SetClip1(math.max(self:Clip1() - take, 0))
    if (self:GetBeamMode()) then
        LaserPointer_SVBeam(ply, self, ply:EyePos(), ply:GetAimVector())
    end
    timer.Create(
        self:EntIndex() .. "LaserPointerOff",
        0.3 + FrameTime(),
        1,
        function()
            if (IsValid(self)) then
                self:SetOnState(false)
                self:ButtonSound(false)
            end
        end
    )
    self:SetNextPrimaryFire(CurTime() + 0.2)
end

hook.Add(
    "KeyRelease",
    "LaserPointerReleaseCheck",
    function(ply, key)
        if (key == IN_ATTACK) then
            local pointer = ply:GetActiveWeapon()
            if (IsValid(pointer) and pointer:GetClass() == "weapon_laserpointer" and pointer:GetOnState() == true) then
                pointer:SetOnState(false)
                pointer:SetNextPrimaryFire(CurTime() + 0.2)
                pointer:ButtonSound(false)
                timer.Destroy(pointer:EntIndex() .. "LaserPointerOff")
            end
        end
    end
)

hook.Add(
    "HUDPaintBackground",
    "laserpointer_blinding",
    function()
    end
)

function SWEP:OnDrop()
end

local pony_head_hitbones = {}
pony_head_hitbones["LrigScull"] = true
pony_head_hitbones["Mane01"] = true
pony_head_hitbones["Mane02"] = true
pony_head_hitbones["Mane03"] = true
pony_head_hitbones["Mane04"] = true
pony_head_hitbones["Mane05"] = true

local laser_material
local beam_material

if (CLIENT) then
    beam_material =
        CreateMaterial(
        "laserpointer_beam",
        "UnlitGeneric",
        {
            ["$basetexture"] = "sprites/light_glow02",
            ["$model"] = 1,
            ["$additive"] = 1,
            ["$translucent"] = 1,
            ["$color2"] = Vector(4, 4, 4),
            ["$vertexalpha"] = 1,
            ["$vertexcolor"] = 1
        }
    )
    laser_material =
        CreateMaterial(
        "laserpointer_shine",
        "UnlitGeneric",
        {
            ["$basetexture"] = "sprites/physgun_glow",
            ["$model"] = 1,
            ["$additive"] = 1,
            ["$translucent"] = 1,
            ["$color2"] = Vector(4, 4, 4),
            ["$vertexalpha"] = 1,
            ["$vertexcolor"] = 1
        }
    )
end

lpointer_laser_source = lpointer_laser_source or {}
function LaserPointer_DrawBeam(ply, wep, origin, dir, color, phase, startoverride)
    if (not CLIENT or not IsValid(ply) or not IsValid(wep) or origin == nil or dir == nil or color == nil) then
        return
    end
    phase = phase or 0
    if (phase >= 15) then
        return
    end
    local trace = {}
    trace.start = origin
    trace.endpos = origin + (dir * 20000)
	trace.mask = MASK_VISIBLE
    if (phase == 0) then
        trace.filter = ply
    end
    local bigstart = false
    local basesize = 8
    local beammode = wep:GetBeamMode()
    if (beammode) then
        basesize = 12
    end
    local tr = util.TraceLine(trace)
    local beamstart = origin
    local beamend = tr.HitPos
    if (tr.Entity == LocalPlayer():GetObserverTarget() or tr.Entity == LocalPlayer()) then
        local dot = dir:Dot(LocalPlayer():GetAimVector() * -1)
        if (tr.Entity:IsPlayer() and math.deg(math.acos(dot)) < 45) then
            local hitply = tr.Entity
            if
                (hitply:GetHitBoxHitGroup(tr.HitBox, hitply:GetHitboxSet()) == HITGROUP_HEAD or
                    pony_head_hitbones[hitply:GetBoneName(hitply:GetHitBoxBone(tr.HitBox, hitply:GetHitboxSet()))])
             then
                if (not tr.Entity:ShouldDrawLocalPlayer()) then
                    beamend = EyePos() + (origin - EyePos()):GetNormalized() * 16
                    tr.HitNormal = EyeAngles():Forward()
                    basesize = basesize * 16
                end
            end
        end
    end
    local cwh = Color(128, 128, 128)
    if (startoverride and type(startoverride) == "Vector") then
        beamstart = startoverride
    end
    if (phase == 0 or beammode) then
        local viewnormal = (EyePos() - beamstart):GetNormal()
        local startsize = basesize / 2
        --if(phase == 0)then startsize = startsize / 3 end
        render.DrawQuadEasy(
            beamstart + viewnormal * (basesize / 2),
            viewnormal,
            startsize / 2,
            startsize / 2,
            color,
            math.Rand(0, 360)
        )
        render.DrawQuadEasy(
            beamstart,
            viewnormal * (basesize / 2),
            startsize / 4,
            startsize / 4,
            cwh,
            math.Rand(0, 360)
        )
    end
    render.SetMaterial(beam_material)
    local dist = math.Rand(0.45, 0.55)
    if (beammode) then
        render.DrawBeam(beamstart,
			beamend,
			basesize / 4,
			dist,
			dist,
			color
		)
        render.DrawBeam(
			beamstart,
			beamend,
			basesize / 8,
			dist,
			dist,
			cwh
		)
    else
        if (phase == 0) then -- only the first beam is rendered in low beam mode, only a certain distance
            local dir2 = (beamend - beamstart):GetNormal()
            local bdist = math.min(16, beamstart:Distance(beamend))
            local bcut = 1 - (bdist / 16)
            local viewnormal = (EyePos() - beamstart):GetNormal()
            render.DrawBeam(
                beamstart + viewnormal * (basesize / 2),
                beamstart + dir2 * bdist,
                basesize / 8,
                dist,
                1 - math.Clamp(bcut, 0, 1) * 0.5,
                color
            )
            render.DrawBeam(
                beamstart + viewnormal * (basesize / 2),
                beamstart + dir2 * bdist,
                basesize / 16,
                dist,
                1 - math.Clamp(bcut, 0, 1) * 0.5,
                cwh
            )
        end
    end
    render.SetMaterial(laser_material)
    if ((tr.HitWorld or tr.Hit) and not tr.HitSky) then
        local reflect = tr.Entity:GetClass() == "func_reflective_glass"
        if (reflect) then
            local newstart = tr.HitPos
            local dir3 = tr.Normal - 2 * tr.Normal:Dot(tr.HitNormal) * tr.HitNormal
            LaserPointer_DrawBeam(ply, wep, newstart, dir3, color, phase + 1, nil)
        else
            --put the above 4 lines in else for if(reflect) if you want it to only place a dot on the end
            local viewnormal = (EyePos() - beamend):GetNormal()
			render.DrawQuadEasy(beamend + (viewnormal * 4),
				tr.HitNormal,
				basesize, 
				basesize, color,
				math.Rand(0, 360)
			)
            render.DrawQuadEasy(
                beamend + (viewnormal * 4),
                tr.HitNormal,
                basesize / 2,
                basesize / 2,
                cwh,
                math.Rand(0, 360)
            )
            render.DrawQuadEasy(
				beamend + (viewnormal * 4),
				viewnormal, 
				basesize,
				basesize,
				color,
				math.Rand(0, 360)
			)
            render.DrawQuadEasy(
                beamend + (viewnormal * 4),
                viewnormal,
                basesize / 2,
                basesize / 2,
                cwh,
                math.Rand(0, 360)
            )
        end
    end
end

function LaserPointer_SVBeam(ply, wep, origin, dir, phase) -- for damagenot
    if (not SERVER or not IsValid(ply) or not IsValid(wep) or origin == nil or dir == nil) then
        return
    end
    phase = phase or 0
    if (phase >= 15) then
        return
    end
    local trace = {}
    trace.start = origin
    trace.endpos = origin + (dir * 60000)
	trace.mask = MASK_VISIBLE
    if (phase == 0) then
        trace.filter = ply
    end
    local tr = util.TraceLine(trace)
    if (tr.HitSky and (math.random(1, 10000) == 1)) then
        wep:MakePlane(tr.HitPos + (origin - tr.HitPos):GetNormal() * 1000, ply:GetPos())
    end
    if (tr.HitWorld or tr.Hit) then
        local reflect = tr.Entity:GetClass() == "func_reflective_glass"
        if (reflect) then
            local newstart = tr.HitPos
            local dir3 = tr.Normal - 2 * tr.Normal:Dot(tr.HitNormal) * tr.HitNormal
            LaserPointer_SVBeam(ply, wep, newstart, dir3, phase + 1)
        else
            if (IsValid(tr.Entity) and tr.Entity.Health ~= nil) then
                if (Safe == nil or (isfunction(Safe) and not Safe(tr.Entity))) then
                    local d = DamageInfo()
                    d:SetDamage(1)
                    d:SetAttacker(ply)
                    d:SetInflictor(wep)
                    d:SetDamageType(DMG_ENERGYBEAM)
                    tr.Entity:TakeDamageInfo(d)
                end
            end
        end
    end
end

local laserhook = function(depth, skybox)
    if (depth) then
        return
    end
    if (skybox) then
        return
    end
    render.SetMaterial(laser_material)
    if (laser_material) then
        for wep, _ in next, lpointer_laser_source do
            local ply = wep:GetOwner()
            if (not IsValid(ply)) then
                continue
            end
            if (not IsValid(wep)) then
                continue
            end
            if (wep ~= ply:GetActiveWeapon()) then
                continue
            end
            if (not wep:GetOnState()) then
                continue
            end
            local color = wep:GetLaserColor()
            local cwh = Color(128, 128, 128)
            local beamstart = ply:EyePos()
            local beamdir = ply:GetAimVector()
            local vm = ply:GetViewModel()
            if (not ply:ShouldDrawLocalPlayer() and ply == LocalPlayer()) then
                local vmpos, vmang = ply:GetActiveWeapon():GetViewModelPosition(EyePos(), EyeAngles())
                beamstart = vmpos + vmang:Up() * 6.6
                beamdir = vmang:Up()
            else
                local wep = ply:GetActiveWeapon()
                local vmpos, vmang = ply:EyePos(), ply:EyeAngles()
                local matrix = wep:DrawWorldModel(true)
                if (matrix) then
                    beamstart = matrix:GetTranslation() + matrix:GetAngles():Up() * 6.6
                    beamdir = matrix:GetAngles():Up()
                end
            end
            render.SetMaterial(laser_material)
            LaserPointer_DrawBeam(ply, wep, ply:EyePos(), ply:GetAimVector(), color, nil, beamstart, wep:GetBeamMode())
        end
    end
end
hook.Add("PostDrawTranslucentRenderables", "laserhook", laserhook)

function SWEP:MakePlane(pos, targetpos)
    if (CLIENT) then
        return
    end
    if (GLOB_NEXTPLANE ~= nil and GLOB_NEXTPLANE > CurTime()) then
        return
    end
    local exp = ents.Create("env_explosion")
    exp:SetPos(pos)
    exp:Spawn()
    exp:SetKeyValue("iMagnitude", "0")
    exp:Fire("Explode", 0, 0)
    local ang = (targetpos - pos):Angle()
    ang:RotateAroundAxis(ang:Up(), 90)
    ang:RotateAroundAxis(ang:Right(), -40)
    local plane = ents.Create("prop_physics")
    plane:SetModel("models/xqm/jetbody3.mdl")
    plane:SetPos(pos)
    plane:SetAngles(ang)
    plane:Spawn()
    plane:Activate()
    plane:SetModelScale(0.1, 0)
    plane:SetModelScale(1, 0.2)
    plane:GetPhysicsObject():Wake()
    plane:GetPhysicsObject():SetDamping(0, 0)
    plane:GetPhysicsObject():EnableGravity(false)
    plane:GetPhysicsObject():SetVelocity(plane:GetRight() * 7000)
    plane:GetPhysicsObject():ApplyTorqueCenter(plane:GetRight() * 500000)
    local function PhysCallback(ent, data) -- Function that will be called whenever collision happends
        local exp = ents.Create("env_explosion")
        exp:SetPos(data.HitPos)
        exp:Spawn()
        exp:SetKeyValue("iMagnitude", "15000")
        exp:Fire("Explode", 0, 0)
        plane:EmitSound("BaseExplosionEffect.Sound")
        if (IsValid(plane)) then
            plane:Remove()
        end
    end
    plane:AddCallback("PhysicsCollide", PhysCallback) -- Add Callback

    timer.Create(
        plane:EntIndex() .. "lzplane_destroy",
        10,
        1,
        function()
            if (IsValid(plane)) then
                plane:Remove()
            end
        end
    )
    GLOB_NEXTPLANE = CurTime() + 20
end

function SWEP:GetLaserColor()
    local ply = self:GetOwner()
    if (IsValid(ply)) then
        local wpncolor = ply:GetWeaponColor()
        local lasercolor = Color(255, 0, 0)
        local cfunc = self.ColorFunctions[self:GetColorMode() or 0]
        if (cfunc) then
            if (IsColor(cfunc)) then
                lasercolor = cfunc
            end
            if (type(cfunc) == "function") then
                lasercolor = cfunc(ply)
            end
        end
        return lasercolor
    end
    return Color(255, 0, 0)
end

function SWEP:EquipAmmo(ply)
    local wpn = ply:GetWeapon("weapon_laserpointer")
    if (IsValid(wpn)) then
        wpn:SetClip1(math.min(wpn:Clip1() + self:GetMaxClip1(), self:GetMaxClip1() * 9.99))
    end
end

if (CLIENT) then
    function draw.Circle(x, y, radius, seg)
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

        local a = math.rad(0)
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
end

function SWEP:PostDrawViewModel(vm, weapon, ply)
    local pos, ang = vm:GetPos(), vm:GetAngles()
    render.SetMaterial(laser_material)
    local color = self:GetLaserColor()
    local cwh = Color(128, 128, 128)
    pos = pos + ang:Up() * -0.02
    ang:RotateAroundAxis(ang:Up(), 90)
    ang:RotateAroundAxis(ang:Forward(), 180)
    cam.Start3D2D(pos, ang, 0.008)
    surface.SetDrawColor(color_black)
    local w, h = 54, 40
    surface.DrawRect(-w / 2, -h / 2, w, h)
    if (self:Clip1() > self:GetMaxClip1() * 0.1 or math.sin(math.rad(CurTime() * 720)) > 0) then
        draw.SimpleText(
            math.Round((self:Clip1() / self:GetMaxClip1()) * 100, 0) .. "%",
            "Trebuchet24",
            0,
            9,
            self:GetLaserColor(),
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER
        )
    else
        local indcolor = table.Copy(self:GetLaserColor())
        draw.SimpleText(
            math.Round((self:Clip1() / self:GetMaxClip1()) * 100, 0) .. "%",
            "Trebuchet24",
            0,
            9,
            indcolor,
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER
        )
    end
    surface.SetDrawColor(self:GetLaserColor())
    local prog = self:GetColorMode() / #self.ColorFunctions
    surface.DrawRect(-w / 2 + 1, -h / 2 + 2 + ((h - 9) * prog), 4, 5)
    local indcolor = table.Copy(self:GetLaserColor())
    if (not self:GetBeamMode()) then
        indcolor.a = 64
    end
    surface.SetDrawColor(indcolor)
    draw.NoTexture()
    draw.Circle(0, -10, 6, 8)
    cam.End3D2D()
end

function SWEP:DrawWorldModel(query)
    local ply = self:GetOwner()
    self:SetModelScale(1, 0)
    self:SetSubMaterial()
    local mrt
    local horn = false
    if IsValid(ply) then
        local modelStr = ply:GetModel():sub(1, 17)
        local isPony =
            modelStr == "models/ppm/player" or modelStr == "models/mlp/player" or modelStr == "models/cppm/playe"
        if (isPony and self.HornBG == nil) then
            self.HornBG = ply:FindBodygroupByName("Horn")
            if (self.HornBG == -1) then
                self.HornBG = ply:FindBodygroupByName("horn")
            end
        end
        if (self.HornBG ~= nil and self.HornBG ~= -1 and ply:GetBodygroup(self.HornBG) == 0) then
            horn = true
        end
        local bn = isPony and "LrigScull" or "ValveBiped.Bip01_R_Hand"
        local bon = ply:LookupBone(bn) or 0
        local opos = self:GetPos()
        local oang = self:GetAngles()
        local bp, ba = ply:GetBonePosition(bon)
        if bp then
            opos = bp
        end
        if ba then
            oang = ba
        end
        if isPony then
            if (horn) then
                opos = opos + (oang:Forward() * 7) + (oang:Right() * 15.5) + (oang:Up() * 0)
                oang:RotateAroundAxis(oang:Right(), 80)
                oang:RotateAroundAxis(oang:Forward(), 12)
                oang:RotateAroundAxis(oang:Up(), 20)
            else
                opos = opos + (oang:Forward() * 6.4) + (oang:Right() * -1.8) + (oang:Up() * 0)
                oang:RotateAroundAxis(oang:Right(), 80)
                oang:RotateAroundAxis(oang:Forward(), 12)
                oang:RotateAroundAxis(oang:Up(), 20)
            end
        else
            if (bn ~= 0) then
                oang:RotateAroundAxis(oang:Forward(), 90)
                oang:RotateAroundAxis(oang:Right(), 90)
                opos = opos + (oang:Forward() * 1) + (oang:Up() * -3) + (oang:Right() * 1.5)
                oang:RotateAroundAxis(oang:Forward(), 69)
                oang:RotateAroundAxis(oang:Up(), 10)
            end
        end
        oang = (ply:GetEyeTrace().HitPos - opos):Angle()
        oang:RotateAroundAxis(oang:Right(), -90)
        opos = opos + oang:Up() * -2
        if (isPony) then
            if (horn) then
                opos = opos - oang:Up() * 5
            else
                opos = opos + oang:Up() * 3
            end
        end
        self:SetupBones()
        mrt = self:GetBoneMatrix(0)
        if mrt then
            mrt:SetTranslation(opos)
            mrt:SetAngles(oang)
            if (query ~= true) then
                self:SetBoneMatrix(0, mrt)
            end
        end
    end
    if (query ~= true and not horn) then
        render.MaterialOverride()
        draw.NoTexture()
        render.SetBlend(1)
        self:DrawModel()
    end
    if (query == true) then
        return mrt
    end
end

function SWEP:OnRemove()
    return true
end

function SWEP:Think()
end

function SWEP:UpdateVMFOV()
end

function SWEP:CalcView(ply, pos, ang, fov)
    self.ViewModelFOV = fov -- this one seems to disconnect while suit zooming, i'll do another pr once i figure out a workaround that isn't buggy
end

function SWEP:GetViewModelPosition(epos, eang)
    local leftright = 1
    local tr = {}
    tr.start = epos
    tr.endpos = epos + self:GetOwner():GetAimVector() * 60000
    tr.filter = LocalPlayer()
    local trace = util.TraceLine(tr)

    epos, eang = self:GetOwner():EyePos(), self:GetOwner():EyeAngles()
    local fov = self.ViewModelFOV
    epos = epos + eang:Forward() * (10 + (15 - math.Clamp(fov - 70, 0, 15)) * 0.25)
    epos = epos + eang:Right() * 4 * leftright
    epos = epos + eang:Up() * -4

    eang = (epos - trace.HitPos):Angle()
    eang:RotateAroundAxis(eang:Right(), 90)
    epos = epos + eang:Up() * -4
    return epos, eang
end
