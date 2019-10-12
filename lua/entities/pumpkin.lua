if SERVER then AddCSLuaFile() end
ENT.Type = "anim"
DEFINE_BASECLASS("base_gmodentity")
ENT.Model = Model("models/props_halloween/jackolantern_01.mdl")
local ti = os.date("%B", os.time())
if ti != "October" then return end --Check if the month is October so this entity doesn't have to be enabled/disabled manually

local vectable = {Vector(486.4, 23, 0),
Vector(-487.8, 17.3, 0),
Vector(-2040, -1254, 0),
Vector(2590.7, 692, -26.6),
Vector(1690.5, 1559.1, -33), 
Vector(606.7, -1932.4, 0),
Vector(326, -1064.7, -101.8),
Vector(-651, -1813.3, -5.7),
Vector(-2167.7, 612.5, 5.4),
Vector(-2742.5, 164.8, -7.9)}
local angtable = {Angle(0, -128, 0),
Angle(0, -45, 0),
Angle(0, 135, 0),
Angle(-1.8, 57.4, 2.5),
Angle(2.7, 42.1, -4.8),
Angle(0, 154.4, 0), 
Angle(-1, -148.4, 0.6),
Angle(5.8, -147.4, -1.8),
Angle(3.2, -72.6, 0.9),
Angle(7.5, 161.9, -0.1)}

function ENT:Initialize()
    self:SetModel(table.Random({"models/props_halloween/jackolantern_01.mdl", "models/props_halloween/jackolantern_02.mdl"}))
    self:SetMoveType(MOVETYPE_NONE)
	self:PhysicsInitStatic(SOLID_VPHYSICS)

    self:DrawShadow(false)
    if SERVER then
        self:SetTrigger(true) 
        self:SetUseType(SIMPLE_USE)
    end
	
    self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
        phys:EnableMotion(false)
	end
end

function ENT:Draw()
    self:DrawModel()
end

if SERVER then
    hook.Add("InitPostEntity", "spawnpumpkins", function()
        for i=1, 10, 1 do
            local pumpkin = ents.Create("pumpkin")
            pumpkin:SetPos(vectable[i])
            pumpkin:SetAngles(angtable[i])
            pumpkin:Spawn()

            /*local plight = ents.Create("light_dynamic") --performance heavy
            plight:SetPos(vectable[i])
            plight:SetKeyValue("distance", 256)
            plight:SetKeyValue("brightness", 2)
            plight:SetKeyValue("style", table.Random({1, 6}))
            plight:SetKeyValue("_light", "255 136 0 255")
            plight:Fire("TurnOn")
            plight:Spawn()*/
        end
    end)
end
