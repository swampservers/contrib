SWEP.PrintName = "BRRRAAAPPP"

SWEP.Slot = 0

SWEP.WorldModel = ""
SWEP.ViewModel = ""
SWEP.Primary.Ammo = "none"
SWEP.Secondary.Ammo = "none"
SWEP.Weight = 0
SWEP.AutoSwitchTo = false
SWEP.DrawCrosshair = false
if SERVER then 
	timer.Create("Braaaaap",1.7,0,function()
		FunnyFart = player.GetHumans()
		
		for k,v in pairs(FunnyFart) do
			if v:HasWeapon("weapon_brap") then
				if math.random() < 0.05 then
						v:GetWeapon("weapon_brap"):PrimaryAttack()
				end
			else
				if(v.BeansEaten != nil and v.BeansEaten > 0 and math.random(0,25) < v.BeansEaten)then
					v:Give("weapon_brap")
					v.BeansEaten = nil
				end
			end
		end
		FunnyFart = nil
	end)
end


function SWEP:PrimaryAttack()
		local pit = math.random(90,105)
		local stime = SoundDuration("fart/shitpants.wav")
		self:SetNextPrimaryFire(CurTime() +10000)
		self:SetNextSecondaryFire(CurTime() +10000)
		self:EmitSound("fart/shitpants.wav")
		local point = self:GetOwner():GetPos()
		
		if(IsValid(self) and SERVER)then self:MakeStink(self:GetOwner(),point) end

end


function SWEP:SecondaryAttack()

self:PrimaryAttack()

end

function SWEP:MakeStink(src,pos)
	local ply = self:GetOwner()
	for _,v in pairs(player.GetAll())do

		if isfunction(Safe) and Safe(v) then continue end
		if v == src then continue end
		if v:GetNWBool("spacehat") then continue end
		if v:GetPos():Distance(pos) < 140 then
				local d = DamageInfo()
				d:SetDamage( 3 ) 
				d:SetAttacker( ply or ent )
				d:SetDamageType( DMG_POISON ) 
				v:TakeDamageInfo( d )
		end	
	end
	self:Remove()
end

function SWEP:Deploy()
self:PrimaryAttack()
return true
end
function SWEP:OnDrop()
self:Remove()

end

function SWEP:Reload()

end
