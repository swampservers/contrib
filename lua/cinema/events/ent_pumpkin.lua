-- This file is subject to copyright - contact swampservers@gmail.com for more information.
ENT.Type = "anim"
DEFINE_BASECLASS("base_anim")
ENT.Model = Model("models/props_halloween/jackolantern_01.mdl")
local ti = os.date("%B", os.time())
if ti ~= "October" then return end --Check if the month is October so this entity doesn't have to be enabled/disabled manually

function ENT:Initialize()
    self:SetModel(table.Random({"models/props_halloween/jackolantern_01.mdl", "models/props_halloween/jackolantern_02.mdl"}))

    self:SetMoveType(MOVETYPE_NONE)
    self:PhysicsInitStatic(SOLID_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:DrawShadow(false)

    if SERVER then
        self:SetUseType(SIMPLE_USE)
    end

    local phys = self:GetPhysicsObject()

    if IsValid(phys) then
        phys:EnableMotion(false)
    end
end

function ENT:Draw()
    self:DrawModel()
end

function ENT:Use(act, cal)
    --random chance to play a noise
    if math.random(0, 20) == 0 then
        act:ExtEmitSound("squee.wav", {
            pitch = math.random(80, 120)
        })

        act:ChatPrint("[orange]Happy Halloween!")
    end
end

--make pumpkins explode
function ENT:OnTakeDamage(dmg)
    if self:GetNoDraw() == true then return end
    self:SetHealth(self:Health() - dmg:GetDamage())

    if self:Health() <= 0 and dmg:GetAttacker():IsPlayer() then
        self:SetNoDraw(true)
        self:SetSolid(SOLID_NONE) --hide pumpkin
        util.BlastDamage(self, self, self:GetPos(), 150, 200)
        local edat = EffectData()
        edat:SetOrigin(self:GetPos())
        util.Effect("Explosion", edat)

        timer.Simple(60, function()
            if not IsValid(self) then return end
            self:SetNoDraw(false)
            self:SetSolid(SOLID_VPHYSICS)
            self:SetHealth(self:GetMaxHealth())
        end)
    end
end

if SERVER then
    timer.Simple(1, function()
        for _, ent in ipairs(Ents.ent_pumpkin) do
            ent:Remove()
        end

        for _, targetInfo in ipairs(MapTargets["ent_pumpkin"]) do
            local pumpkin = ents.Create("ent_pumpkin")
            pumpkin:SetPos(targetInfo["origin"])
            pumpkin:SetAngles(targetInfo["angles"])
            pumpkin:SetModelScale(math.Rand(0.7, 1.3))
            pumpkin:SetMaxHealth(50)
            pumpkin:SetHealth(50)
            pumpkin:Spawn()
            --[[local plight = ents.Create("light_dynamic") --performance heavy
            plight:SetPos(vectable[i])
            plight:SetKeyValue("distance", 256)
            plight:SetKeyValue("brightness", 2)
            plight:SetKeyValue("style", table.Random({1, 6}))
            plight:SetKeyValue("_light", "255 136 0 255")
            plight:Fire("TurnOn")
            plight:Spawn()]]
        end
    end)
end
