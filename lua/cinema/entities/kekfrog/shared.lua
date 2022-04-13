-- This file is subject to copyright - contact swampservers@gmail.com for more information.
ENT.Type = "anim"
DEFINE_BASECLASS("base_gmodentity")

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "CollectPoints")
    self:NetworkVar("Int", 1, "OfferedPoints")

    if SERVER then
        self:SetCollectPoints(0)
        self:SetOfferedPoints(0)
    end
end

function ENT:Initialize()
    if SERVER then
        local tr = util.TraceLine({
            start = self:GetPos(),
            endpos = self:GetPos() - self:GetAngles():Up() * 100,
            -- mask = MASK_NPCWORLDSTATIC
            filter = Ents.player
        })

        if tr.Hit then
            self:SetPos(tr.HitPos + self:GetAngles():Up() * 3)
        end

        timer.Simple(0.1, function()
            if IsValid(self) then
                self:InWallCheck()
            end
        end)

        self.lastcollect = CurTime()
    end

    self:SetModel("models/swamponions/kekfrog.mdl")
    self:SetModelScale(0.15)
    self:PhysicsInitBox(Vector(-1, -1, -1) * 10, Vector(1, 1, 1) * 10)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    -- self:PhysicsInitStatic(SOLID_VPHYSICS)
    self:DrawShadow(false)
    local phys = self:GetPhysicsObject()
    -- self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    if IsValid(phys) then end -- phys:EnableMotion(false)

    if SERVER then
        -- self:SetTrigger(true)
        self:SetUseType(SIMPLE_USE)
        self:AddEFlags(EFL_FORCE_CHECK_TRANSMIT)
    end
end

function ENT:Income()
    local p = self:GetPos()
    if p.z < -100 or p.z > 1000 or p.x < -3300 or p.x > 3300 or self:IsProtected() then return 0 end
    local inc = 1000 + self:GetOfferedPoints() / 50
    local i = 1

    while true do
        local k = 2000 * i

        if inc > k then
            inc = k + (inc - k) * 0.5
            i = i + 1
        else
            break
        end
    end
    inc = inc * 0.5

    return math.ceil(inc * self:IncomeSuppression())
end

function ENT:IncomeSuppression()
    local inc = 1

    for i, v in ipairs(Ents.kekfrog) do
        if v ~= self and v:GetOfferedPoints() >= self:GetOfferedPoints() then
            local d = self:GetPos():Distance(v:GetPos())
            inc = inc * math.min(d / 2000, 1)
        end
    end

    return inc
end
