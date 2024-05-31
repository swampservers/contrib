AddCSLuaFile()
ENT.Base = "base_anim"
ENT.PrintName = "Wormhole"
ENT.Category = "PYROTEKNIK"
ENT.Spawnable = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.RTSize = 256
ENT.DefaultRange = 512
ENT.ProjectedDepth = 32
local FILTERMODE_ALL = 0
local FILTERMODE_PONIES = 1

local function plane()
    local verts = {Vector(1, -1, 1), Vector(-1, -1, 1), Vector(-1, 1, 1), Vector(1, 1, 1)}

    local quads = {verts[1], verts[2], verts[3], verts[1], verts[3], verts[4]}
    --front

    return quads, verts
end

local function box()
    local verts = {Vector(-1, -1, -1), Vector(-1, -1, 1), Vector(1, -1, 1), Vector(1, -1, -1), Vector(-1, 1, -1), Vector(-1, 1, 1), Vector(1, 1, 1), Vector(1, 1, -1)}

    return verts
end

local function makemesh(pos, size)
    local verts = {}
    local tricount = 0
    local x, y, z = size.x, size.y, size.z

    local normals = {
        {Vector(0, -1, 0), Vector(0, 0, 1)},
        {Vector(0, 1, 0), Vector(0, 0, 1)},
        {Vector(-1, 0, 0), Vector(0, 0, 1)},
        {Vector(1, 0, 0), Vector(0, 0, 1)},
        {Vector(0, 0, 1), Vector(0, 1, 0)},
        {Vector(0, 0, -1), Vector(0, 1, 0)},
    }

    for _, sl in pairs(normals) do
        local normal = sl[1]
        local up = sl[2]
        local quad, physverts = plane()
        tricount = tricount + 12

        for k, v in pairs(quad) do
            local s = ((k - 1) % 6) + 1

            local uvs = {
                {0, 1},
                {0, 0},
                {1, 0},
                {0, 1},
                {1, 0},
                {1, 1}
            }

            local uv = uvs[s] or {0.5, 0.5}

            local dlp = LocalToWorld(v, Angle(), Vector(), up:AngleEx(normal))

            table.insert(verts, {
                pos = pos + dlp * size * 0.5,
                u0 = uv[1],
                v0 = 1 - uv[2],
                normal = normal
            })
        end
    end

    local conv = {}

    for k, v in pairs(box()) do
        table.insert(conv, v * size * 0.5)
    end

    local msh

    if CLIENT then
        msh = Mesh(mat)
        -- Creating the mesh
        mesh.Begin(msh, MATERIAL_TRIANGLES, tricount)

        for i, vertex in pairs(verts) do
            mesh.Position(vertex.pos or Vector())
            -- Texture coordinates go to channel 0
            mesh.TexCoord(0, vertex.u0 or 0, vertex.v0 or 0)
            -- Lightmap texture coordinates go to channel 1
            mesh.TexCoord(1, vertex.u1 or vertex.u0 or 0, vertex.v1 or vertex.v0 or 0)
            mesh.Normal(vertex.normal)
            mesh.AdvanceVertex()
        end

        mesh.End()
    end

    return msh, conv
end

function ENT:GetLinkChoices()
    local tab = {}

    for k, v in ipairs(ents.FindByClass("wormhole")) do
        if v:GetTargetName() == "" then continue end
        tab[v:GetTargetName()] = v:GetTargetName()
    end

    return tab
end

ENT.Editable = true

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "Link")

    self:NetworkVar("Bool", 0, "Active", {
        KeyName = "active"
    })

    self:NetworkVar("Float", 0, "W", {
        KeyName = "width"
    })

    self:NetworkVar("Float", 1, "H", {
        KeyName = "height"
    })

    self:NetworkVar("Int", 0, "FilterMode", {
        KeyName = "filtermode"
    })

    self:NetworkVar("Int", 1, "Range")
    self:NetworkVar("Int", 2, "ClipRange")

    if SERVER then
        self:NetworkVarNotify("Link", self.NetworkVarChanged)
        self:NetworkVarNotify("Range", self.NetworkVarChanged)
        self:NetworkVarNotify("ClipRange", self.NetworkVarChanged)
        self:NetworkVarNotify("W", self.NetworkVarChanged)
        self:NetworkVarNotify("H", self.NetworkVarChanged)
    end
end

function ENT:KeyValue(key, value)
    local num = tonumber(value)
    local str = tostring(value)

    if key == "width" then
        self:SetW(num)
    end

    if key == "height" then
        self:SetH(num)
    end

    if key == "range" then
        self:SetRange(num)
    end

    if key == "link" then
        timer.Simple(0, function()
            local link = table.Random(ents.FindByName(str))

            if IsValid(link) then
                self:SetLink(link)

                if link.SetLink then
                    link:SetLink(self)
                end
            end
        end)
    end

    if key == "active" then
        self:SetActive(tobool(value))
    end

    if key == "filtermode" then
        self:SetFilterMode(value)
    end
end

function ENT:AcceptInput(name, activator, caller, data)
    if name == "TurnOn" then
        self:SetKeyValue("active", true)
    end

    if name == "TurnOff" then
        self:SetKeyValue("active", false)
    end
end

function ENT:NetworkVarChanged(name, old, new)
    if name == "W" or name == "H" then
        self:SetupPhysics()
    end
end

function ENT:SetupPhysics()
    local w, h, d = self:GetW(), self:GetH(), self.ProjectedDepth

    if w == 0 or h == 0 then
        self:PhysicsDestroy()
        self:SetSolid(SOLID_NONE)

        if SERVER then
            self:SetTrigger(false)
        end

        return
    end

    local md = 1
    local msh, physm = makemesh(Vector(-md / 2, 0, 0), Vector(md, w, h))
    --self:PhysicsInitBox(Vector(-d,-w/2,-h/2),Vector(d,w/2,h/2))
    --self:UseTriggerBounds(true,w/2)
    self:SetCollisionBounds(Vector(-d, -w / 2, -h / 2), Vector(d, w / 2, h / 2))
    self:SetSolid(SOLID_OBB)
    self:SetSolidFlags(bit.bor(FSOLID_TRIGGER, FSOLID_NOT_SOLID, self:GetSolidFlags()))
    --self:SetCollisionBounds(Vector(-1,-1,-h/4),Vector(1,1,1))
    --self:SetModelScale(1)
    --self:SetCollisionGroup(COLLISION_GROUP_WORLD)
    self:SetMoveType(MOVETYPE_NONE)
    self:DrawShadow(false)

    if SERVER then
        self:SetTrigger(true)
    end

    if IsValid(self:GetPhysicsObject()) then
        self:GetPhysicsObject():EnableMotion(false)
    end

    if CLIENT then
        self:SetRenderBounds(Vector(-d, -w / 2, -h / 2), Vector(d, w / 2, h / 2))
        self.Mesh = msh
    end

    hook.Add("SetupPlayerVisibility", self, function(hole, ply, viewent)
        local pos, ang = ply:EyePos(), ply:EyeAngles()
        if not ply:TestPVS(hole) then return end

        if IsValid(viewent) then
            pos = viewent:GetPos()
            ang = viewent:GetAngles()
        end

        local link = hole:GetLink()

        if IsValid(hole) and IsValid(link) then
            local facing = hole:ShouldDrawPortal(pos, ang)
            local box = Vector(0, hole:GetW(), hole:GetH())
            local dst = pos:Distance(self:GetPos()) -- TODO(winter): Don't use Distance! It's expensive!
            --debugoverlay.BoxAngles(hole:GetPos(), -box / 2, box / 2, hole:GetAngles(), 0, facing and Color(0, 0, 255, 0) or Color(255,0,0,0))
            local lbox = Vector(0, link:GetW(), link:GetH())

            --debugoverlay.BoxAngles(link:GetPos(), -lbox / 2, lbox / 2, link:GetAngles(), 0, facing and Color(0, 0, 255, 16) or Color(255,0,0,16))
            if facing and dst <= self:GetRange() then
                local ppos, pang = self:GetProjectedPos(pos, ang)
                local lps = link:WorldToLocal(ppos, pang)
                local w, h = self:GetW() - 1, self:GetH() - 1
                lps.x = 1
                lps.y = math.Clamp(lps.y, -w / 2, w / 2)
                lps.z = math.Clamp(lps.z, -h / 2, h / 2)
                local proj_pos = link:LocalToWorld(lps, Angle())
                AddOriginToPVS(proj_pos)
                --debugoverlay.Cross(proj_pos,64,0.1,Color(0,255,0,255),true)
            end
        end
    end)
end

function ENT:Initialize()
    self:SetRange(self.DefaultRange)
    self:SetActive(true)
    self:SetupPhysics()
end

function ENT:ShouldDrawPortal(pos, ang)
    if not self:GetActive() then return false end
    local w, h = self:GetW(), self:GetH()
    if w == 0 or h == 0 then return false end
    pos = pos or EyePos()
    ang = ang or EyeAngles()
    local dst = pos:Distance(self:GetPos())
    local far = self:GetRange()
    local dfrac = dst / far
    if dfrac >= 1 then return false end
    local dot = (self:GetPos() - pos):GetNormalized():Dot(self:GetForward())
    if self:IsPosInside(pos) then return true end
    --if dot > 0 then return end

    return true
end

function ENT:FixRenderBounds()
end

-- crappy fix for reinitialization issues, better to do something like cvx
if CLIENT then
    function ENT:Think()
        self:FixRenderBounds()
    end
end

if SERVER then
    function ENT:Think()
        self:NextThink(CurTime() + 1)

        return true
    end
end

WORMHOLE_ANON_VAL = WORMHOLE_ANON_VAL or 0

function ENT:GetRenderTarget()
    if self.WormholeRenderID == nil then
        self.WormholeRenderID = WORMHOLE_ANON_VAL
        WORMHOLE_ANON_VAL = WORMHOLE_ANON_VAL + 1
    end

    local wormhole_id = "wormhw" -- .. self.WormholeRenderID
    local wormhole_id2 = wormhole_id .. "_ring" -- .. self.WormholeRenderID
    self.WormholeRT = self.WormholeRT or GetRenderTarget(wormhole_id, self.RTSize, self.RTSize)

    self.WormholeMat = CreateMaterial(wormhole_id, "UnlitGeneric", {
        ["$basetexture"] = self.WormholeRT:GetName(),
        --["$normalmap"] = "models/shadertest/shieldnoise0_normal", --["$dudvmap"] = "pyroteknik/wormhole/flow_dudv", --["$refracttint"] = Vector(1, 1, 1),
        ["$model"] = 1,
        ["$refractamount"] = 0.07,
        ["$nowritez"] = 0,
        ["$forcealphawrite"] = 1,
        ["$nocull"] = 1,
        ["$bluramount"] = 2,
    })

    self.WormholeRefractor = CreateMaterial(wormhole_id .. "refract", "refract", {
        ["$basetexture"] = self.WormholeRT:GetName(),
        ["$normalmap"] = "models/shadertest/shieldnoise0_normal",
        ["$dudvmap"] = "pyroteknik/wormhole/flow_dudv",
        ["$refracttint"] = Vector(1, 1, 1),
        ["$model"] = 1,
        ["$refractamount"] = 0.5,
        ["$nowritez"] = 0,
        ["$forcealphawrite"] = 1,
        ["$nocull"] = 1,
        ["$bluramount"] = 2,
    })

    local mat = self.WormholeMat
    local ref = self.WormholeRefractor
    local dst = EyePos():Distance(self:GetPos())
    local far = self:GetRange()
    local dfrac = dst / far
    ref:SetFloat("$refractamount", 0.5)
    ref:SetVector("$refracttint", Vector(2, 1, 4) * 1)
    local bump = ref:GetTexture("$normalmap")
    local fram = (bump and bump:GetNumAnimationFrames()) or 0
    ref:SetInt("$bumpframe", fram - (math.fmod(CurTime(), 1) * fram))

    -- mat 2
    self.WormholeMat2 = CreateMaterial(wormhole_id2, "UnlitGeneric", {
        --["$basetexture"] = self.WormholeRT2:GetName(),
        ["$additive"] = 1,
    })

    return self.WormholeRT, self.WormholeMat
end

function ENT:GetRenderMesh()
    local tex, mat = self:GetRenderTarget()
    if RENDERING_WORMHOLE then return end
    if not self.Mesh then return end

    return {
        Mesh = self.Mesh,
        Material = mat
    }
end

function ENT:Draw(flags)
    if not self:GetActive() then return end
    if RENDERING_WORMHOLE then return end
    if not self.Mesh then return end

    if self:ShouldDrawPortal() then
        WORMHOLE_QUEUE = {}
        WORMHOLE_QUEUE[self] = true

        if self.WormholeMat then
            self.WormholeMat:SetTexture("$basetexture", self.WormholeRT)
        end
    elseif self.WormholeMat then
    end

    -- TODO(winter): Should do some sort of fading between the two
    -- TODO(winter): Figure out a better thing to fade to. Maybe scissor + preserve out the visible section of WormholeRT? Or just fill it with some color?
    --self.WormholeMat:SetTexture("$basetexture", "vgui/black")
    render.DepthRange(0.01, 1)

    if self:IsPosInside(EyePos()) then
        render.DepthRange(0, 0.5)
    end

    --render.SetMaterial(self.WormholeMat)
    --render.DrawQuadEasy(self:WorldSpaceCenter(), self:GetForward(), self:GetW(), self:GetH())
    self:DrawModel(flags)
    render.DepthRange(0, 1)
end

function ENT:IsPosInside(pos)
    local lpos = WorldToLocal(pos, Angle(), self:GetPos(), self:GetAngles())
    if math.abs(lpos.y) <= self:GetW() / 2 and math.abs(lpos.z) <= self:GetH() / 2 and lpos.x >= -self.ProjectedDepth and lpos.x < 5 then return true end

    return false
end

function ENT:GetProjectedPos(pos, ang, vel, ply)
    local link = self:GetLink()
    local pw = self:GetW() - 1
    local ph = self:GetH() - 1
    local item_width = 0
    local item_mins = Vector(0, 0, 0)
    local item_maxs = Vector(0, 0, 0)

    if IsValid(ply) then
        local cmins, cmaxs = ply:GetCollisionBounds()
        local w = math.max(math.abs(cmins.x), math.abs(cmaxs.x), math.abs(cmins.y), math.abs(cmaxs.y))
        item_mins = Vector(-w, -w, cmins.z)
        item_maxs = Vector(w, w, cmaxs.z)
    end

    if not IsValid(link) then return end
    local origin_pos, origin_ang = self:GetPos(), self:GetAngles()
    local link_pos, link_ang = link:GetPos(), link:GetAngles()
    link_ang:RotateAroundAxis(link_ang:Up(), 180)
    local proj_vel
    local local_pos, local_ang = WorldToLocal(pos, ang, origin_pos, origin_ang)

    if IsValid(ply) then
        local dw = LocalToWorld(local_pos, local_ang, link_pos, link_ang)
        debugoverlay.Box(dw, item_mins, item_maxs, 3, Color(0, 255, 0, 0))
        local_pos.y = math.Clamp(local_pos.y, -pw / 2 - item_mins.x, pw / 2 - item_maxs.x)
        local_pos.z = math.Clamp(local_pos.z, -ph / 2 + item_mins.z, ph / 2 - item_maxs.z)
        local dw = LocalToWorld(local_pos, local_ang, link_pos, link_ang)
        debugoverlay.Box(dw, item_mins, item_maxs, 3, Color(0, 0, 255, 0))
    end

    --local_pos = local_pos * 0.25
    if vel then
        local local_vel = WorldToLocal(vel, Angle(), Vector(), origin_ang)
        local_vel = local_vel + local_pos
        local_vel.y = math.Clamp(local_vel.y, -pw / 2 - item_mins.x, pw / 2 - item_maxs.x)
        local_vel.z = math.Clamp(local_vel.z, -ph / 2 + item_mins.z, ph / 2 - item_maxs.z)
        local_vel = local_vel - local_pos
        proj_vel = LocalToWorld(local_vel, ang, Vector(), link_ang)
    end

    local proj_pos, proj_ang = LocalToWorld(local_pos, local_ang, link_pos, link_ang)

    return proj_pos, proj_ang, proj_vel or Vector()
end

function ENT:ProjectDirection(dir)
    local link = self:GetLink()
    if not IsValid(link) then return end
    local origin_pos, origin_ang = self:GetPos(), self:GetAngles()
    local link_pos, link_ang = link:GetPos(), link:GetAngles()
    link_ang:RotateAroundAxis(link_ang:Up(), 180)
    local local_dir = WorldToLocal(dir, Angle(), Vector(), origin_ang)
    local proj_dir = LocalToWorld(local_dir, Angle(), Vector(), link_ang)

    return proj_dir
end

function ENT:DrawProjection()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    local hole = self
    local link = hole:GetLink()
    local asp = self:GetW() / self:GetH()
    if not IsValid(link) then return end
    local rt, mat, rt2, mat2 = hole:GetRenderTarget()
    local eye_pos, eye_ang = ply:EyePos(), ply:EyeAngles()
    local dst = eye_pos:Distance(self:GetPos())
    local far = self:GetRange()
    local dfrac = math.Clamp(dst / far, 0, 1)
    local fov = Lerp(dfrac, 90, 90)
    eye_ang = hole:GetAngles()
    eye_ang.yaw = eye_ang.yaw + 180
    local par_ang = (eye_pos - hole:GetPos()):Angle()
    _, par_ang = WorldToLocal(Vector(), par_ang, Vector(), hole:GetAngles())
    par_ang = -par_ang * Lerp(dfrac, 0.5, 1)
    _, eye_ang = LocalToWorld(Vector(), par_ang, Vector(), eye_ang)
    local proj_pos, proj_ang = hole:GetProjectedPos(hole:GetPos(), eye_ang)
    local lpos = WorldToLocal(proj_pos, proj_ang, hole:GetPos(), hole:GetAngles())
    local normal = link:GetForward()
    local position = normal:Dot(link:GetPos())
    local box = Vector(0, hole:GetW(), hole:GetH())
    local clip_range = self:GetClipRange()
    local znear = 1
    local zfar = znear + clip_range

    if clip_range <= 0 then
        zfar = nil
    end

    render.PushRenderTarget(rt)
    render.Clear(0, 0, 0, 0, true, true)
    render.PushCustomClipPlane(normal, position - 64)

    render.RenderView({
        origin = proj_pos,
        angles = proj_ang,
        x = 0,
        y = 0,
        w = ScrW(),
        h = ScrH(),
        znear = znear,
        zfar = zfar,
        aspect = asp,
        fov = fov,
        drawmonitors = false,
        drawhud = false,
        drawviewmodel = false,
        drawviewer = false,
    })

    render.PopCustomClipPlane()
    render.BlurRenderTarget(rt, 4, 4, 2)
    local mat = self.WormholeRefractor
    mat:SetTexture("$basetexture", rt)
    render.SetMaterial(mat)
    render.DrawScreenQuad()
    render.PopRenderTarget()
end

if CLIENT then
    local nextrender = 0

    hook.Add("PostRender", "Wormhole_Render", function()
        local realtime = RealTime()

        if realtime > nextrender then
            WORMHOLE_QUEUE = WORMHOLE_QUEUE or {}

            for hole, _ in pairs(WORMHOLE_QUEUE) do
                if IsValid(hole) then
                    RENDERING_WORMHOLE = hole
                    hole:DrawProjection()
                    RENDERING_WORMHOLE = nil
                end
            end

            WORMHOLE_QUEUE = {}
            RENDERING_WORMHOLE = nil
            nextrender = realtime + (1 / 60) -- Limit rendering to ~60 times per second
        end
    end)
end

function ENT:StartTouch(ent)
    local link = self:GetLink()
    if not IsValid(link) then return end
    local filterMode = self:GetFilterMode()

    if ent:IsPlayer() then
        if filterMode == FILTERMODE_PONIES and (not ent.IsPony or not ent:IsPony()) then
            ent:ChatPrint("[red]Only the condemned may enter this realm.")
            local dmginfo = DamageInfo()
            dmginfo:SetDamage(20)
            dmginfo:SetDamageType(DMG_DISSOLVE)
            dmginfo:SetDamageForce(self:GetForward() * 5000)
            dmginfo:SetAttacker(self)
            dmginfo:SetInflictor(self)
            ent:SetVelocity(self:GetForward() * 400)
            ent:TakeDamageInfo(dmginfo)

            return
        end

        local chole = ent:GetNWEntity("WormholeCurrent")
        --if IsValid(chole) and chole:GetLink() == self then return end
        ent:SetNWEntity("WormholeCurrent", self)
    end
end

function ENT:Touch(ent)
    local link = self:GetLink()
    if not IsValid(link) then return end

    if not ent:IsPlayer() then
        local phys = ent:GetPhysicsObject()
        local pos = ent:GetPos()
        local ang = ent:GetAngles()
        local vel = ent:GetVelocity()

        if IsValid(phys) then
            pos = phys:GetPos()
            ang = phys:GetAngles()
            vel = phys:GetVelocity()
        end

        local lpos = WorldToLocal(pos + vel * FrameTime(), ang, self:GetPos(), self:GetAngles())
        local lv = WorldToLocal(vel, ang, Vector(), self:GetAngles())

        if lpos.x < 0 and lv.x < 0 then
            local npos, nang, nvel = self:GetProjectedPos(pos, ang, vel)

            if IsValid(phys) then
                phys:SetVelocity(nvel)
                phys:SetPos(npos)
                phys:SetAngles(nang)
            else
                ent:SetVelocity(-ent:GetVelocity() + nvel)
                ent:SetPos(npos)
                ent:SetAngles(nang)
            end

            link:EmitSound("ambient/machines/machine1_hit2.wav", 120, 150, 0.1, CHAN_USER_BASE)
            self:EmitSound("ambient/machines/machine1_hit2.wav", 120, 150, 0.1, CHAN_USER_BASE)
        end
    end
end

function ENT:EndTouch(ent)
    if ent:GetNWEntity("WormholeCurrent") == self then
        ent:SetNWEntity("WormholeCurrent", nil)
    end
end

hook.Add("FinishMove", "WormholeTransitionFinish", function(ply, mv)
    if ply.NextWormhole then
        ply.NextWormhole = nil
    end
end)

hook.Remove("Move", "WormholeTransition")

hook.Add("SetupMove", "WormholeTransition", function(ply, mv, cmd)
    local hole = ply:GetNWEntity("WormholeCurrent")

    if IsValid(hole) then
        local link = hole:GetLink()
        local pos, ang, vel = mv:GetOrigin(), mv:GetAngles(), mv:GetVelocity()
        local eye = ply:EyePos()
        pos = pos + vel * FrameTime()
        local mang = mv:GetMoveAngles()
        local fidvel = mv:GetFinalIdealVelocity()
        local fijvel = mv:GetFinalJumpVelocity()
        local lpos = WorldToLocal(pos, ang, hole:GetPos(), hole:GetAngles())
        local lpos2 = WorldToLocal(ply:EyePos(), ang, hole:GetPos(), hole:GetAngles())
        local lvel = WorldToLocal(vel, Angle(), Vector(), hole:GetAngles())
        local through = lpos.x < 0 and lvel.x < 0
        local edge = false

        if math.abs(lpos2.y) > hole:GetW() / 2 then
            through = false
        end

        if math.abs(lpos2.z) > hole:GetH() / 2 then
            through = false
        end

        if through then
            local newpos, newang, newvel = hole:GetProjectedPos(pos, ang, vel, ply)
            local neweye, newmang = hole:GetProjectedPos(eye, mang, vel)
            -- NOTE(winter): This prevents players from getting stuck in the portal, or in nearby geometry
            newpos:Add(Vector(0, 0, 4))
            newpos:Add(link:GetForward() * 32)
            local newfidvel = hole:ProjectDirection(fidvel)
            local newfijvel = hole:ProjectDirection(fijvel)
            --if cmd:TickCount() == 0 then end
            ply.PortalTilt = newang.roll ~= 0
            ply:SetNetworkOrigin(newpos)
            ply:SetPos(newpos)
            mv:SetOrigin(newpos)
            mv:SetAngles(newang)
            mv:SetMoveAngles(newmang)
            mv:SetVelocity(newvel)
            cmd:SetViewAngles(newang)
            ply:SetEyeAngles(newang)
            mv:SetFinalIdealVelocity(newfidvel)
            mv:SetFinalJumpVelocity(newfijvel)
            local fix = neweye + newvel * FrameTime() * 2

            if IsFirstTimePredicted() then
                ply:ViewPunch(Angle(math.Rand(-0.5, 0.5) * 4, math.Rand(-0.5, 0.5) * 4, math.Rand(-0.5, 0.5) * 4))
                ply:EmitSound("ambient/machines/machine1_hit2.wav", 50, 150, 0.1, CHAN_USER_BASE)
            end

            ply.NextWormhole = hole:GetLink()
            local dur = 0.01

            timer.Create("WormholeTransition", dur, 1, function()
                hook.Remove("CalcView", "WormholeTransition")
                hook.Remove("GetMotionBlurValues", "WormholeTransition")
                hook.Remove("CalcViewModelView", "WormholeTransition")
            end)

            timer.Create("WormholeTransition2", 0.2, 1, function()
                hook.Remove("RenderScreenspaceEffects", "WormholeTransition")
            end)

            hook.Add("RenderScreenspaceEffects", "WormholeTransition", function()
                local tm = timer.TimeLeft("WormholeTransition2") / 0.2
                tm = math.Clamp(tm, 0, 1)
                local fract = tm

                local tab = {
                    ["$pp_colour_addr"] = 0,
                    ["$pp_colour_addg"] = 0,
                    ["$pp_colour_addb"] = 0,
                    ["$pp_colour_brightness"] = fract,
                    ["$pp_colour_contrast"] = 1,
                    ["$pp_colour_colour"] = 1,
                    ["$pp_colour_mulr"] = 0,
                    ["$pp_colour_mulg"] = 0,
                    ["$pp_colour_mulb"] = 0
                }

                DrawColorModify(tab)
            end)

            hook.Add("CalcView", "WormholeTransition", function(ply, origin, ang, fov, znear, zfar)
                local view = {}
                local tm = timer.TimeLeft("WormholeTransition") / dur
                tm = math.Clamp(tm, 0, 1)
                local fract = 1 - tm
                view.origin = LerpVector(fract, fix, origin)

                return view
            end)

            hook.Add("CalcViewModelView", "WormholeTransition", function(wep, vm, oldpos, oldang, pos, ang)
                local view = {}
                local tm = timer.TimeLeft("WormholeTransition") / dur
                tm = math.Clamp(tm, 0, 1)
                local fract = 1 - tm
                pos = LerpVector(fract, fix, pos)

                return pos, ang
            end)

            hook.Add("GetMotionBlurValues", "WormholeTransition", function(horizontal, vertical, forward, rotational) return 0, 0, 0, 0 end)
        end
    end

    if ply.PortalTilt then
        local newang = cmd:GetViewAngles()
        newang.roll = math.ApproachAngle(newang.roll, 0, FrameTime() * 360)
        mv:SetAngles(newang)
        cmd:SetViewAngles(newang)

        if math.abs(newang.roll) < 0.1 then
            newang.roll = 0
            ply.PortalTilt = nil
        end
    end
end)
