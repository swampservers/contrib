-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
AddCSLuaFile()
ENT.Type = "anim"
DEFINE_BASECLASS("base_gmodentity")

function ENT:Initialize()
    if CLIENT then
        self.Entity:SetNoDraw(true)
    else
        self.Trail = util.SpriteTrail(self, 0, Color(255, 255, 255, 90), false, 4, 4, 0.2, 1 / 8, "chev/rainbowdashtrail") --trail is parented to this entity
    end

    self:DrawShadow(false)
    self:AddEFlags(EFL_FORCE_CHECK_TRANSMIT)
    self.Owner = self:GetOwner()
end

function ENT:UpdateTransmitState()
    return TRANSMIT_ALWAYS
end


function ENT:Think()
    local ply = self:GetOwner()

    if SERVER then
        if not IsValid(ply) or not IsValid(ply:GetActiveWeapon()) or ply:GetActiveWeapon():GetClass() ~= "weapon_flappy" then
            self:Remove()
        end
        return
    end

    if IsValid(ply) and ( ply ~= LocalPlayer() or hook.Run("ShouldDrawLocalPlayer", ply) )then
        local bn = ply:IsPony() and "LrigSpine1" or "ValveBiped.Bip01_Head1"
        local bon = ply:LookupBone(bn) or 0
        local bonepos = ply:GetBonePosition(bon)
        local plyaim = ply:GetAimVector()

        if ply:IsPony() then
            self:SetPos(bonepos + Vector(plyaim.x * 1, plyaim.y * 1, plyaim.z - 4))
        else
            self:SetPos(bonepos + Vector(plyaim.x * 2, plyaim.y * 2, plyaim.z + 7))
        end
    end

    if IsValid(LocalPlayer()) and IsValid(ply) and ply:GetPos():DistToSqr(LocalPlayer():EyePos())>1000000 then
        self:SetNextClientThink( CurTime() + 0.1 )
        return true
    end
end

    -- hook.Add("DrawTranslucentAccessories", "MoveFedoraPoint", function(ply)
    --     local self = ply:GetNWEntity("fedora_point")
    --     if IsValid(self) then
    --         print("MOVE", self)
    --         if IsValid(ply) and ( ply ~= LocalPlayer() or hook.Run("ShouldDrawLocalPlayer", ply) )then
    --             local bn = ply:IsPony() and "LrigSpine1" or "ValveBiped.Bip01_Head1"
    --             local bon = ply:LookupBone(bn) or 0
    --             local bonepos = ply:GetBonePosition(bon)
    --             local plyaim = ply:GetAimVector()
    
    --             if ply:IsPony() then
    --                 self:SetPos(bonepos + Vector(plyaim.x * 1, plyaim.y * 1, plyaim.z - 4))
    --             else
    --                 self:SetPos(bonepos + Vector(plyaim.x * 2, plyaim.y * 2, plyaim.z + 7))
    --             end
    --         end
    --     end
    -- end)


function ENT:Draw()
end