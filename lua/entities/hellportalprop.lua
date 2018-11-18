AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"

local left1 = Vector(0,-125,-68)
local left2 = Vector(13,-39,45)

local right1 = Vector(0,38,-68)
local right2 = Vector(13,140,45)

local top1 = Vector(0,-125,220)
local top2 = Vector(13,140,45)

local back1 = Vector(-13,-39,-68)
local back2 = Vector(-2.5,38,45)

local hellportal = Material("hell/hellportal")

function ENT:Initialize()

	self:SetModel("models/props/de_inferno/stoneinfwndwa.mdl")
	self:SetModelScale(2)

	self:PhysicsInitMultiConvex({
		{
			Vector(left1.x,left1.y,left1.z),
			Vector(left1.x,left1.y,left2.z),
			Vector(left1.x,left2.y,left1.z),
			Vector(left1.x,left2.y,left2.z),
			Vector(left2.x,left1.y,left1.z),
			Vector(left2.x,left1.y,left2.z),
			Vector(left2.x,left2.y,left1.z),
			Vector(left2.x,left2.y,left2.z),
		},
		{
			Vector(right1.x,right1.y,right1.z),
			Vector(right1.x,right1.y,right2.z),
			Vector(right1.x,right2.y,right1.z),
			Vector(right1.x,right2.y,right2.z),
			Vector(right2.x,right1.y,right1.z),
			Vector(right2.x,right1.y,right2.z),
			Vector(right2.x,right2.y,right1.z),
			Vector(right2.x,right2.y,right2.z),
		},
		{
			Vector(top1.x,top1.y,top1.z),
			Vector(top1.x,top1.y,top2.z),
			Vector(top1.x,top2.y,top1.z),
			Vector(top1.x,top2.y,top2.z),
			Vector(top2.x,top1.y,top1.z),
			Vector(top2.x,top1.y,top2.z),
			Vector(top2.x,top2.y,top1.z),
			Vector(top2.x,top2.y,top2.z),
		},
		{
			Vector(back1.x,back1.y,back1.z),
			Vector(back1.x,back1.y,back2.z),
			Vector(back1.x,back2.y,back1.z),
			Vector(back1.x,back2.y,back2.z),
			Vector(back2.x,back1.y,back1.z),
			Vector(back2.x,back1.y,back2.z),
			Vector(back2.x,back2.y,back1.z),
			Vector(back2.x,back2.y,back2.z),
		}
	})

	self:SetSolid(SOLID_VPHYSICS)
	self:EnableCustomCollisions(true)
	
end

if CLIENT then

	function ENT:Draw()
	
		local pos,ang = self:GetPos(),self:GetAngles()
		
		self:DrawModel()
		render.SetMaterial(hellportal)
		render.DrawQuad(Vector(pos.x-42,pos.y-8,pos.z-69),Vector(pos.x-42,pos.y-8,pos.z+45),Vector(pos.x+42,pos.y-8,pos.z+45),Vector(pos.x+42,pos.y-8,pos.z-69))
		
	end
	
end
