ENT.RenderGroup 	= RENDERGROUP_TRANSLUCENT

ENT.Mode = 0
ENT.TimeToNext = 0
ENT.Alpha = 1

THEATER_LOAD_IDLE		= 0
THEATER_LOAD_FADEDELAY	= 1
THEATER_LOAD_FADINGOUT 	= 2
THEATER_LOAD_PAUSE 		= 3
THEATER_LOAD_FADINGIN 	= 4

local clr = {}
clr[ "$pp_colour_addr" ] 		= 0
clr[ "$pp_colour_addg" ] 		= 0
clr[ "$pp_colour_addb" ] 		= 0
clr[ "$pp_colour_brightness" ]  = 0
clr[ "$pp_colour_contrast" ] 	= 1
clr[ "$pp_colour_colour" ] 		= 1
clr[ "$pp_colour_mulr" ] 		= 0
clr[ "$pp_colour_mulg" ] 		= 0
clr[ "$pp_colour_mulb" ] 		= 0

function ENT:Draw()
	self:DrawModel()
end

//This usermessage is only sent to the player actually teleporting, so we should be good
usermessage.Hook("theater_door_load", function( um ) 
	local self = um:ReadEntity()

	self.TimeToNext = CurTime() + self.DelayTime //Give a slight pause before fading out
	self.Mode = THEATER_LOAD_FADEDELAY;
	LocalPlayer().LoadingEntity = self;


end )

hook.Add( "RenderScreenspaceEffects", "theater_render_loading", function()
	if !IsValid( LocalPlayer().LoadingEntity ) || LocalPlayer().LoadingEntity.Mode == THEATER_LOAD_IDLE then return end

	local mode = LocalPlayer().LoadingEntity.Mode 
	local ent = LocalPlayer().LoadingEntity

	if mode == THEATER_LOAD_FADEDELAY then
		if CurTime() > ent.TimeToNext then
			ent.Mode = THEATER_LOAD_FADINGOUT
			ent.Alpha = 1 //make sure it's 1
		end
	elseif mode == THEATER_LOAD_FADINGOUT then
		ent.Alpha = ent.Alpha - ( FrameTime() * 1 ) / ent.FadeTime

		if ent.Alpha <= 0 then 
			ent.Alpha = 0
			ent.Mode = THEATER_LOAD_PAUSE
			ent.TimeToNext = CurTime() + ent.WaitTime
		end
	elseif mode == THEATER_LOAD_PAUSE then

		if CurTime() > ent.TimeToNext then
			ent.Mode = THEATER_LOAD_FADINGIN
			ent.Alpha = 0 //make sure it's 0
		end
	elseif mode == THEATER_LOAD_FADINGIN then
		ent.Alpha = ent.Alpha + ( FrameTime() * 1 ) / ent.FadeTime

		if ent.Alpha >= 1 then
			ent.Alpha = 1
			ent.Mode = THEATER_LOAD_IDLE
		end
	end

	clr["$pp_colour_brightness"] = ent.Alpha - 1
	clr["$$pp_colour_colour"] = ent.Alpha
	DrawColorModify( clr )
end )