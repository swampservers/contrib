-- Encyclopedia SWEP by swamponions - STEAM_0:0:38422842

AddCSLuaFile()

SWEP.PrintName			= "Nintendo Switch"	

SWEP.Author = "swamponions"

--They actually do. That's the joke.
SWEP.Purpose = "Try to contain your excitement!"

SWEP.Slot				= 1
SWEP.SlotPos			= 99

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModelFOV = 85
SWEP.ViewModelFlip = false

SWEP.ViewModel 				= Model("models/swamponions/switchbox.mdl")
SWEP.WorldModel 			= Model("models/swamponions/switchbox.mdl")

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.Primary.ClipSize			= -1
SWEP.Primary.Damage				= -1
SWEP.Primary.DefaultClip		= -1
SWEP.Primary.Automatic			= false
SWEP.Primary.Ammo				= "none"

SWEP.Secondary.ClipSize			= -1
SWEP.Secondary.DefaultClip		= -1
SWEP.Secondary.Damage			= -1
SWEP.Secondary.Automatic		= false
SWEP.Secondary.Ammo				= "none"

function SWEP:DrawWorldModel()
	local ply = self:GetOwner()

	if(IsValid(ply))then

		local bn = "ValveBiped.Bip01_R_Hand"
		local bon = ply:LookupBone(bn) or 0

		local opos = self:GetPos()
		local oang = self:GetAngles()
		local bp,ba = ply:GetBonePosition(bon)
		if(bp)then opos = bp end
		if(ba)then oang = ba end


			oang:RotateAroundAxis(oang:Forward(), 20)
			oang:RotateAroundAxis(oang:Up(), 90)
			oang:RotateAroundAxis(oang:Right(), 90)
			opos = opos + oang:Right()*2
			opos = opos + oang:Forward()*-3
			opos = opos + oang:Up()*10.5

		self:SetupBones()

		local mrt = self:GetBoneMatrix(0)
		if(mrt)then
			mrt:SetTranslation(opos)
			mrt:SetAngles(oang)
			self:SetBoneMatrix(0, mrt )
		end
	end
	self:DrawModel()

end

function SWEP:Deploy()
	if IsValid(self.Owner) then self.Owner:SetFlexScale(1.9) end
end


function SWEP:Holster()
	if IsValid(self.Owner) then self.Owner:SetFlexScale(1) end
	return true
end

function SWEP:GetViewModelPosition( pos, ang )
	pos = pos + ang:Right()*6
	pos = pos + ang:Up()*-12
	pos = pos + ang:Forward()*20
	ang:RotateAroundAxis(ang:Forward(), -3)
	ang:RotateAroundAxis(ang:Up(), -105)
	ang:RotateAroundAxis(ang:Right(), -90)
	pos = pos + ang:Forward()*0.2
	return pos, ang 
end


function SWEP:Initialize() 
	self:SetHoldType("slam") 	 
end 

function SWEP:PrimaryAttack()

end

function SWEP:SecondaryAttack()

end

function SWEP:Reload()

end

if CLIENT then

--this makes the mouth opening work without clobbering other addons
hook.Add("InitPostEntity", "SwitchMouthMoveSetup", function()
	timer.Simple(0.9, function()
		Switch_OriginalMouthMove = Switch_OriginalMouthMove or GAMEMODE.MouthMoveAnimation
	 
		function GAMEMODE:MouthMoveAnimation(ply)
			--run the base MouthMoveAnimation if player isn't vaping/Switchtalking
			local wep = ply:GetActiveWeapon()
			if not IsValid(wep) or wep:GetClass()~="weapon_switch" then
				if ply.SwitchSmiling then
					ply.SwitchSmiling=nil
					local FlexNum = ply:GetFlexNum() - 1
					if ( FlexNum <= 0 ) then return end
					for i = 0, FlexNum - 1 do
						local Name = ply:GetFlexName(i)
						if (Name=="smile") then
							ply:SetFlexWeight(i, 0)
						end
					end
				end
				return Switch_OriginalMouthMove(GAMEMODE, ply)
			end

			ply.SwitchSmiling=true
			local FlexNum = ply:GetFlexNum() - 1
			if ( FlexNum <= 0 ) then return end
			for i = 0, FlexNum - 1 do
				local Name = ply:GetFlexName(i)
				if (Name=="smile" || Name == "jaw_drop" || Name == "right_part" || Name == "left_part" || Name == "right_mouth_drop" || Name == "left_mouth_drop" ) then
					ply:SetFlexWeight(i, Name=="smile" and 0.7 or 1)
				end
			end
		end
	end)
end)

end