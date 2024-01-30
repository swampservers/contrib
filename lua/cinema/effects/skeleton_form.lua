EFFECT.ShrinkTime = 0.25
EFFECT.RenderMode = RENDERMODE_TRANSCOLOR

list.Set("EffectType", "skeleton_form", {
    print = "Bone Forming",
    material = "gui/effects/skeleton_splatter.png",
    func = function(ent, pos, angle, scale)
        local effectdata = EffectData()
        effectdata:SetOrigin(ent:GetPos())
        effectdata:SetAngles(ent:GetAngles())
        effectdata:SetStart(ent:GetForward() * scale * 200)
        effectdata:SetEntity(NULL)
        util.Effect("skeleton_form", effectdata, true, true)
    end
})

function EFFECT:Init(data)
    local epos = data:GetOrigin()
    local eang = data:GetAngles()
    local ent = data:GetEntity()
    self.ParentEntity = ent
    local force = data:GetStart()
    force = force:GetNormalized() * math.Clamp(force:Length(), 0, 800)
    sound.Play("skeleton/bones_step0" .. math.random(1, 4) .. ".wav", epos, 60, math.random(90, 120))
    self:SetPos(epos)
    self:SetAngles(eang)
    self:SetRenderBounds(Vector(-128, -128, 0), Vector(128, 128, 128))
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
    self.RenderMesh:SetPos(epos)
    self.RenderMesh:SetAngles(eang)
    self.RenderMesh:SetNoDraw(true)
    self.BoneSize = self.BoneSize or {}
    self.BonePosInit = self.BonePosInit or {}
    self.BonePos = self.BonePos or {}
    self.BoneVel = self.BoneVel or {}
    self.BoneTorque = self.BoneTorque or {}
    local set = 0
    local randomness = 15 + force:Length() / 6

    for i = 0, rem:GetBoneCount() - 1 do
        local pos, ang = rem:GetBonePosition(i)
        local nm = Matrix()
        local sm = Matrix()
        sm:SetTranslation(epos + VectorRand():GetNormalized() * Vector(64, 64, 0) + Vector(0, 0, -16))
        sm:SetAngles(AngleRand())

        if IsValid(ent) then
            nm:SetTranslation(pos)
            nm:SetAngles(ang)
        else
            nm:SetTranslation(self:GetPos())
            nm:SetAngles(AngleRand())
        end

        self.BonePos[i] = sm
        self.BonePosInit[i] = Matrix(nm)
        self.BoneTorque[i] = (VectorRand():GetNormalized() * math.Rand(0, 1)) * math.Rand(1500, 4400)
        self.BoneVel[i] = (nm:GetTranslation() - sm:GetTranslation()) / self.ShrinkTime
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

        if vel then
            if self.BoneVel[i] then
                for g = 0, math.Round(FrameTime() * 10) do
                    self.BoneVel[i] = self.BoneVel[i] / 1.002
                end
            end

            upd = true
        end

        pos = self.BonePos[i]:GetTranslation()
    end

    rem:SetPos(LerpVector(0.5, mins, maxs))

    if tm > self.ShrinkTime then
        rem:Remove()

        if IsValid(self.ParentEntity) then
            self.ParentEntity:SetNoDraw(false)
        end

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
