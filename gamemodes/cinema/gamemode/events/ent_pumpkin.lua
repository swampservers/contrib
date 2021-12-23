-- This file is subject to copyright - contact swampservers@gmail.com for more information.
ENT.Type = "anim"
DEFINE_BASECLASS("base_gmodentity")
ENT.Model = Model("models/props_halloween/jackolantern_01.mdl")
local ti = os.date("%B", os.time())
if ti ~= "October" then return end --Check if the month is October so this entity doesn't have to be enabled/disabled manually

--table of tables {Vector, Angle}
local postable = {
    {Vector(-487.9, 33.7, 8), Angle(0, -44, 0)}, --entrance 1
    {Vector(485.3, 39.4, 8), Angle(0, -128, 0)}, --entrance 2
    {Vector(708.4, -1867.3, -23), Angle(-4, 169, 0)}, --by gym door facing pit
    {Vector(-2009, -1731.3, 0), Angle(0, 52, 0)}, --by sushitheater entrance
    {Vector(-1917.5, -153.6, 0), Angle(0, -21, 0)}, --trump tower entrance
    {Vector(-1311, 4049, -23), Angle(0, -116, 1.2)}, --cemetery
    {Vector(1815, 3639, -24), Angle(0, -120, 0)}, --power plant bench by entrance
    {Vector(1688.8, 1560, -32), Angle(0, 44.4, -0.5)}, --AFK corral far side
    {Vector(2624, 515, -17), Angle(0, 66, 0)}, --AFK corral in dumpster
    {Vector(696, 1790, -32), Angle(0, -45, 0)}, --outside of pvt theater 1, in power area
    {Vector(2224, -1307, -32), Angle(0, 130, 0)}, --outside sportszone
    {Vector(1001, -770, -36), Angle(-3.5, -26, -1.9)}, --tree 1
    {Vector(1013, -515, -33), Angle(-1, 8.5, 1.8)}, --tree 2
    {Vector(-394, -6389.5, -18), Angle(-16, -32.5, 2.2)}, --skybox 1, in the west
    {Vector(484, -6632, -10), Angle(15, -123, 5)}, --skybox 2, behind some buildings
    {Vector(-346, -6911, 47), Angle(0, 43, 0)} --skybox 3, on top of a building
    
}

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
    if math.random(0, 20) < 1 then
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
    hook.Add("InitPostEntity", "spawnpumpkins", function()
        for i = 1, #postable do
            local pumpkin = ents.Create("ent_pumpkin")
            pumpkin:SetPos(postable[i][1])
            pumpkin:SetAngles(postable[i][2])
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
