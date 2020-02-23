AddCSLuaFile()

ENT.Type = "anim"
DEFINE_BASECLASS("base_gmodentity")

function ENT:Initialize()
	if CLIENT then
		self.Entity:SetNoDraw(true)
	else
		self.Trail = util.SpriteTrail(self, 0, Color(255, 255, 255, 90), false, 4, 4, 0.2, 1/8, "chev/rainbowdashtrail") --trail is parented to this entity
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
		if !IsValid(ply) or !IsValid(ply:GetActiveWeapon()) or ply:GetActiveWeapon():GetClass() != "weapon_flappy" then
			self:Remove()
		end --if owner isn't valid, or owner's active weapon isn't valid, or owner has a weapon but it's not the fedora
	return end
	if !FLAPPYFEDORATRAIL then return end

	if !IsValid(ply) then return end
	if (ply == LocalPlayer() and THIRDPERSON) or ply != LocalPlayer() then --only move the entity if in thirdperson, or the player isn't the localplayer
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
end

function ENT:Draw() end
