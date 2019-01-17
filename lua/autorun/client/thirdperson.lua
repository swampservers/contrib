
local wasf4down = false
hook.Add("Think", "ThirdPersonToggler", function()
	local isf4down = input.IsKeyDown(KEY_F4)
	if isf4down and not wasf4down then THIRDPERSON = !THIRDPERSON end
	wasf4down = isf4down
end)

hook.Add( "CalcView", "MyCalcViethridpersonw", function( ply, pos, angles, fov )
	if ply:IsPlayingTaunt() then return end
	if THIRDPERSON then
		local trace = {start=pos,endpos=pos-( angles:Forward()*100 ),mask=MASK_SOLID_BRUSHONLY}
		trace = util.TraceLine(trace )

		local view = {}

		if trace.Hit then 
			view.origin = pos-( angles:Forward()*((100*trace.Fraction)-5) )
		else
			view.origin = pos-( angles:Forward()*100 )
		end
		
		view.angles = angles
		view.fov = fov

		return view
	end
end)

hook.Add( "ShouldDrawLocalPlayer", "MyShouldDrawLocalPlthridpersonayer", function( ply )
	if THIRDPERSON then return true end
end )
