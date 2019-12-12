--[[
SLITPOINTS=nil
SLITPOINTSMAT = Material( "effects/tool_tracer" )
hook.Add("PostDrawTranslucentRenderables", "DrawArenaBorder", function(dep,sky)
	if dep or sky then return end
	local alpha = 1.0- math.Clamp( (Vector(0,-1152,0):Distance(EyePos())-1500)/200, 0,1)
	if alpha==0 then return end
	if SLITPOINTS==nil then
		SLITPOINTS = {}
		for d=0,72 do
			local deg = math.rad(d*5)
			local pt = Vector(math.sin(deg)*650,(math.cos(deg)*650)-1152, 1)
			table.insert(SLITPOINTS, pt) ]]
			--[[local tr = util.TraceLine( {
				start = pt,
				endpos = pt + Vector(0,0,-128),
				collisiongroup = COLLISION_GROUP_WORLD
			} )
			table.insert(SLITPOINTS, tr.HitPos+Vector(0,0,1)) ]]
	--[[	end
	end

	render.SetMaterial(SLITPOINTSMAT)
	local texcoord = math.Rand( 0, 1 )
	local function DrawBeam( startpos, endpos )
		render.DrawBeam( startpos, endpos, 8, texcoord-1, texcoord, Color( 255, 255, 255, 255*alpha ) )
	end
	
	for q=1,72 do
		DrawBeam(SLITPOINTS[q],SLITPOINTS[q+1])	
	end

end) ]]--

hook.Add( "PostDrawTranslucentRenderables", "dirtmike",function(depth, sky)
	if sky then
		return
	end

	if EyePos():DistToSqr(Vector(-2488, 576,7)) > 1000000 then
		return
	end

	cam.Start3D2D(Vector(-2488, 576,7), Angle(0,0,82), 0.35 )
		surface.SetFont( "DebugFixed" )
		surface.SetTextColor( 0, 0, 0, 255 )
		surface.SetTextPos( 3, 3 )
		surface.DrawText( "Here Lies" )
		surface.SetTextPos( 0, 15 )
		surface.DrawText( "Dirty Mike" )
		surface.SetTextPos( 6, 32 )
		surface.DrawText( "He Never" )
		surface.SetTextPos( 10, 44 )
		surface.DrawText( "Scored" )
	cam.End3D2D()
end )

clockARMS = Material("tools/toolsblack")
clockCenter = Vector(0,1038.8-40,192-8)
clockScale = 0.1
hook.Add( "PostDrawTranslucentRenderables", "lobbyclock",function(depth, sky)
	if sky then
		return
	end

	if not render.DrawingScreen() then 
		return
	end

	if EyePos().y > 1010 then return end
	
	render.SetMaterial(clockARMS)

	local time = os.time() + 3600

	local seconds = Vector(0,-200,0)
	seconds:Rotate(Angle(0,(time%60)*6,0))
	DrawClockLine(0,0, seconds.x,seconds.y, 4)

	local minutes = Vector(0,-240,0)
	minutes:Rotate(Angle(0,((time/60)%60)*6,0))
	DrawClockLine(0,0, minutes.x,minutes.y, 8)

	local hours = Vector(0,-170,0)
	hours:Rotate(Angle(0,(((time/3600)%12)-8)*30,0))
	DrawClockLine(0,0, hours.x,hours.y, 12)

	render.DrawSphere(clockCenter+Vector(0,1.5,0), 2, 16, 16, Color(0,0,0))
end )

function DrawClockLine(startX,startY, endX, endY, thickness )

	local v1 = Vector(startX,startY,0)
	local v2 = Vector(endX,endY,0)
	local v3 = v2-v1
	v3:Normalize()
	v3:Mul(thickness/2)
	local v4 = Vector()
	v4:Set(v3)
	v4:Rotate(Angle(0,90,0))
	local p1 = XYToClock(v1-v3+v4)
	local p2 = XYToClock(v1-v3-v4)
	local p3 = XYToClock(v2+v3-v4)
	local p4 = XYToClock(v2+v3+v4)
	render.DrawQuad( p1,p2,p3,p4, Color(0,0,0) )
end

function XYToClock(v)
	return clockCenter + Vector(v.x*clockScale,0,-v.y*clockScale)
end