-- This file is subject to copyright - contact swampservers@gmail.com for more information.
print("real fake doors")

local function IsDoor(door)
    if door:GetClass() == "prop_door_rotating" then return true end

    return false
end

local function BreakDoor(door,dmg)
    if door.IsBroken then return end

    
    local prop = ents.Create("prop_physics")
    prop:SetPos(door:GetPos())
    prop:SetAngles(door:GetAngles())
    prop:SetModel(door:GetModel())
    prop:SetSkin(door:GetSkin())
    door:EmitSound("physics/wood/wood_furniture_break"..math.random(1,2)..".wav")
    for i=0,door:GetNumBodyGroups() -1 do
        local v = door:GetBodygroup(i)
        prop:SetBodygroup(i,v)
    end
    prop:Spawn()
    prop:Activate()
    local phys = prop:GetPhysicsObject()
    if IsValid(phys) then
        phys:ApplyForceOffset(dmg:GetDamageForce()*5,dmg:GetDamagePosition())
        phys:Wake()
    end
    door.IsBroken = true

    door:SetNoDraw(true)
    door:SetSolid(SOLID_NONE)

    door.BrokenProp = prop

    return true
end




hook.Add( "EntityTakeDamage", "DestructibleDoors", function( door, dmg )
    if IsDoor(door) then
        
        BreakDoor(door,dmg)

    end
end )