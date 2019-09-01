
concommand.Add( "cinema_night_toggle", function()

  local sky_night_bk = Material( "swamponions/sky/sky_night_bk" )
  local sky_night_ft = Material( "swamponions/sky/sky_night_ft" )
  local sky_night_lf = Material( "swamponions/sky/sky_night_lf" )
  local sky_night_rt = Material( "swamponions/sky/sky_night_rt" )
  local sky_night_up = Material( "swamponions/sky/sky_night_up" )

  hook.Add( "PostDraw2DSkyBox", "DrawNightSky", function()
  	if not render.DrawingScreen() then
  		return
  	end

  	render.OverrideDepthEnable(true, false)
  	cam.Start3D(Vector(0, 0, 0))

  	render.SetMaterial(sky_night_rt)
  	render.SetMaterial(sky_night_bk)
  	render.SetMaterial(sky_night_lf)
  	render.SetMaterial(sky_night_ft)
  	render.SetMaterial(sky_night_up)

  	cam.End3D()
  	render.OverrideDepthEnable(false, false)
  end )

end )
