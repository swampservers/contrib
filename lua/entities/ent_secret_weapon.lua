AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
 
ENT.PrintName = "AntiKleiner"

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize()
    self:SetModel("models/weapons/w_irifle.mdl")
    self:SetMoveType(MOVETYPE_NONE)
    self:PhysicsInitStatic(SOLID_VPHYSICS)

    self:DrawShadow(false)

    self:SetAngles(Angle(0, -90, 10))
    self:SetPos(Vector(-2853.360, -316, -284.534) + Vector(-1, 10, -3)) --original position + offset

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:EnableMotion(false)
    end

    if SERVER then self:SetUseType(SIMPLE_USE) end
end

function ENT:Use(act)
    if act:IsPlayer() then 
        if act:HasWeapon("weapon_smg1") then
            act:Give("weapon_ar2")
            act:StripWeapon("weapon_smg1")
        elseif act:HasWeapon("weapon_ar2") then
            act:SetAmmo(60, "AR2")
            act:SendLua([[surface.PlaySound('items/ammo_pickup.wav')]])
        else
            act:ChatPrint("[orange]This weapon will not work on its own - it needs to be attached to another weapon.")
        end
    end
end
