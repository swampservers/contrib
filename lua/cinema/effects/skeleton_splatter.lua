EFFECT.ShrinkTime = 6
EFFECT.RenderMode = RENDERMODE_TRANSCOLOR

list.Set("EffectType", "skeleton_splatter", {
    print = "Skeleton Gibs",
    material = "gui/effects/skeleton_splatter.png",
    func = function(ent, pos, angle, scale)
        local effectdata = EffectData()
        effectdata:SetOrigin(ent:GetPos())
        effectdata:SetAngles(ent:GetAngles())
        effectdata:SetStart(ent:GetForward() * scale * 200)
        effectdata:SetEntity(NULL)
        util.Effect("skeleton_splatter", effectdata, true, true)
    end
})

function EFFECT:Init(data)
    local pos = data:GetOrigin()
    local ang = data:GetAngles()
    local ent = data:GetEntity()
    local force = data:GetStart()
    force = force:GetNormalized() * math.Clamp(force:Length(), 0, 800)
    self:SetPos(pos)
    self:SetAngles(ang)
    local mdl = "models/pyroteknik/swamp/npc_skeleton_gibs.mdl"
    self.RenderMesh = ClientsideModel(mdl)
    local rem = self.RenderMesh

    if IsValid(ent) then
        ent:SetNoDraw(true)
        rem:SetSkin(ent:GetSkin())
        rem:SetColor(ent:GetColor())
        rem:SetRenderMode(RENDERMODE_TRANSALPHA)
    end

    self.SimulationFinished = false
    self.RenderMesh:SetParent(self)
    self.RenderMesh:SetPos(pos)
    self.RenderMesh:SetAngles(ang)
    self.RenderMesh:SetNoDraw(true)
    self.BoneSize = self.BoneSize or {}
    self.BonePosInit = self.BonePosInit or {}
    self.BonePos = self.BonePos or {}
    self.BoneVel = self.BoneVel or {}
    self.BoneTorque = self.BoneTorque or {}
    local set = 0
    local hbn = rem:GetHitBoxCount(set)

    for h = 0, hbn - 1 do
        local bone = rem:GetHitBoxBone(h, set)
        local mins, maxs = rem:GetHitBoxBounds(h, set)
        local size = mins - maxs
        size.x = math.abs(size.x)
        size.y = math.abs(size.y)
        size.z = math.abs(size.z)
        self.BoneSize[bone] = math.min(size.x, size.y, size.z)
    end

    local randomness = 15 + force:Length() / 6

    for i = 0, rem:GetBoneCount() - 1 do
        local pos, ang = rem:GetBonePosition(i)
        local nm = Matrix()

        if IsValid(ent) then
            nm:SetTranslation(pos)
            nm:SetAngles(ang)
        else
            nm:SetTranslation(self:GetPos())
            nm:SetAngles(AngleRand())
        end

        self.BonePos[i] = nm
        self.BonePosInit[i] = Matrix(nm)
        self.BoneTorque[i] = (VectorRand():GetNormalized() * math.Rand(0, 1)) * math.Rand(100, 600)
        self.BoneVel[i] = (force * math.Rand(0.6, 1)) + ((VectorRand():GetNormalized() * math.Rand(0.5, 1)) * randomness)
        self.BoneVel[i].z = 20 + math.abs(self.BoneVel[i].z)
    end

    self.RenderMesh:AddCallback("BuildBonePositions", function(rem, numbones)
        local tm = CurTime() - self.StartTime
        local vl = tm / self.ShrinkTime

        for i = 0, rem:GetBoneCount() - 1 do
            if not rem:GetBoneMatrix(i) then continue end
            local mat = Matrix(self.BonePos[i])
            if not mat then continue end
            rem:SetBoneMatrix(i, mat)
        end
    end)

    self.StartTime = CurTime()
end

function EFFECT:Think()
    self.StartTime = self.StartTime or CurTime()
    local tm = CurTime() - self.StartTime
    local vl = 1 - (tm / self.ShrinkTime)
    local rem = self.RenderMesh
    local mins, maxs = rem:GetPos(), rem:GetPos()
    rem:SetColor(ColorAlpha(rem:GetColor(), vl * 255))
    SKELETON_LAST_RATTLE = SKELETON_LAST_RATTLE or 0
    local upd = false

    if not self.SimulationFinished then
        for i = 0, rem:GetBoneCount() - 1 do
            local boxsize = 4

            if self.BoneSize[i] then
                boxsize = self.BoneSize[i]
            end

            local nm = self.BonePos[i] or Matrix()
            local pos, ang, vel = nm:GetTranslation(), nm:GetAngles(), self.BoneVel[i]

            if self.BoneVel[i] then
                nm:SetTranslation(nm:GetTranslation() + self.BoneVel[i] * FrameTime())
            end

            if self.BoneTorque[i] then
                local sa = nm:GetAngles()
                sa:RotateAroundAxis(self.BoneTorque[i]:GetNormalized(), self.BoneTorque[i]:Length() * FrameTime())
                nm:SetAngles(sa)
            end

            local tr

            local trt = {
                start = pos,
                endpos = pos,
                mins = Vector(-0.5, -0.5, -0.5) * boxsize,
                maxs = Vector(0.5, 0.5, 0.5) * boxsize,
                collisiongroup = COLLISION_GROUP_DEBRIS,
            }

            if vel then
                trt.endpos = trt.endpos + vel * FrameTime()
                tr = util.TraceHull(trt)

                if tr.StartSolid then
                    trt.mins = Vector(0, 0, 0)
                    trt.maxs = Vector(0, 0, 0)
                    tr = util.TraceLine(trt)
                end

                if tr.Hit and not tr.StartSolid then
                    local n = tr.HitNormal
                    n = n + (VectorRand():GetNormalized() * math.Rand(0, 0.2))
                    n:Normalize()
                    local vn = vel:GetNormalized()
                    local ref = tr.Normal - 2 * tr.Normal:Dot(n) * n
                    nm:SetTranslation(tr.HitPos)
                    self.BoneVel[i] = ref * vel:Length() * 0.7

                    if self.BoneVel[i]:Length() < math.max(1, FrameTime() * 60) then
                        self.BoneVel[i] = nil
                        self.BoneTorque[i] = nil
                    else
                        local nn = (tr.HitNormal + (VectorRand() * math.Rand(0.1, 0.8))):GetNormalized()
                        self.BoneTorque[i] = self.BoneTorque[i] / 2
                        self.BoneTorque[i] = self.BoneTorque[i] + (nn:Cross(vel:GetNormalized()) * vel:Length() * math.pi * 2)

                        if CurTime() > SKELETON_LAST_RATTLE + 0.05 then
                            SKELETON_LAST_RATTLE = CurTime()
                            sound.Play("skeleton/bones_step0" .. math.random(1, 4) .. ".wav", pos, 60, math.random(90, 120))
                        end
                    end
                end

                if tr.StartSolid then
                    self.BoneVel[i] = nil
                    self.BoneTorque[i] = nil
                end

                if self.BoneVel[i] then
                    for g = 0, math.Round(FrameTime() * 10) do
                        self.BoneVel[i] = self.BoneVel[i] / 1.002
                    end

                    self.BoneVel[i] = self.BoneVel[i] + Vector(0, 0, -800) * FrameTime()
                end

                upd = true
                debugoverlay.SweptBox(trt.start, trt.endpos, trt.mins, trt.maxs, Angle(), 0, Color(255, 0, 0, 1))
            end

            pos = self.BonePos[i]:GetTranslation()
            mins.x, maxs.x = math.min(mins.x, pos.x + trt.mins.x), math.max(maxs.x, pos.x + trt.maxs.x)
            mins.y, maxs.y = math.min(mins.y, pos.y + trt.mins.y), math.max(maxs.y, pos.y + trt.maxs.y)
            mins.z, maxs.z = math.min(mins.z, pos.z + trt.mins.z), math.max(maxs.z, pos.z + trt.maxs.z)
        end

        if upd then
            self:SetRenderBoundsWS(mins, maxs)
            rem:SetPos(LerpVector(0.5, mins, maxs))
            debugoverlay.Box(Vector(), mins, maxs, 0, Color(255, 0, 0, 4))
        else
            self.SimulationFinished = true
        end
    end

    if tm > self.ShrinkTime then
        rem:Remove()

        return false
    end

    return true
end

function EFFECT:Render()
    local tm = CurTime() - self.StartTime
    local rem = self.RenderMesh
    rem:DrawModel()

    render.RenderFlashlights(function()
        rem:DrawModel()
    end)
end
