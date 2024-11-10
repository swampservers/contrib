-- This file is subject to copyright - contact swampservers@gmail.com for more information.
ENT.Type = "anim"
ENT.Model = Model("models/swamponions/kekfrog_small.mdl")
DEFINE_BASECLASS("base_anim")

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

    self:SetModel(self.Model)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
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

-- We want kekfrog to be above ground for income, but not into space or protected areas
-- TODO(winter): Maybe bringing it to the moon would be a more impressive feat and therefore worth more?
function ENT:Income()
    local p = self:GetPos()
    if p.z < -128 or p.z > 1184 or p.x < -4096 or p.x > 5120 or self:IsProtected() then return 0 end
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
    -- inc = inc * 0.777

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

function ENT:CurseDestroyBonus()
    return 0 --self:Income() > 0 and 10000 or 0
end
