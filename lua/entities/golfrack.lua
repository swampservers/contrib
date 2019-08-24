if SERVER then AddCSLuaFile() end
ENT.Type = "anim"
DEFINE_BASECLASS("base_gmodentity")
ENT.Model = Model("models/swamponions/golfstand.mdl")

function ENT:Initialize()
    self:SetModel(self.Model)
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

function ENT:Use(act, caller) --Just in case a player does not touch the golf rack
    self:StartTouch(act)
end

function ENT:StartTouch(ent)
    if ent:IsPlayer() and !ent:HasWeapon("weapon_golfclub") then
        if ent:GetLocationName()=="Golf" or ent:GetLocationName()=="Upper Caverns" or ent:GetLocationName()=="Lower Caverns" then --prevent grabbing the golf club through walls
            ent:Give("weapon_golfclub")
            ent:SelectWeapon("weapon_golfclub")
        end
    end
end

if SERVER then
    hook.Add("InitPostEntity", "spawngolfrack", function()
        local gf1 = ents.Create("golfrack")
        local gf2 = ents.Create("golfrack")
        local gf3 = ents.Create("golfrack")
        local gf4 = ents.Create("golfrack")
        local gf5 = ents.Create("golfrack")
        local gf6 = ents.Create("golfrack")
        local gf7 = ents.Create("golfrack")

        --Golf
        gf1:SetPos(Vector(961, -18.6, -3))
        gf1:SetAngles(Angle(0, 91, 0))
        gf1:Spawn()
        gf1:SetNoDraw(true) --NoDraw this entity, since the map model is already there

        gf2:SetPos(Vector(978, -1287, -3))
        gf2:SetAngles(Angle(0, -86.5, 0))
        gf2:Spawn()
        gf2:SetNoDraw(true)

        gf3:SetPos(Vector(2745, -1033, -3))
        gf3:SetAngles(Angle(0, 290 ,0))
        gf3:Spawn()

        --Upper Caverns
        gf4:SetPos(Vector(1994, 2028, -1073))
        gf4:SetAngles(Angle(-0.8, 90.3, 0))
        gf4:Spawn()

        gf5:SetPos(Vector(4735.3, 2080, -3191.9))
        gf5:SetAngles(Angle(0.6, 86.5, 1))
        gf5:Spawn()

        --Lower Caverns
        gf6:SetPos(Vector(5657, 689.7, -3162.9))
        gf6:SetAngles(Angle(1.7, -8.9, -3.6))
        gf6:Spawn()

        gf7:SetPos(Vector(3479.3, -625.4, -1332.5))
        gf7:SetAngles(Angle(-0.8, -7.9, 0))
        gf7:Spawn()
    end)
end