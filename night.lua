
util.AddNetworkString("PrintConsole")

concommand.Add( "cinema_night_toggle", function()

  string = "Night Toggled"
  net.WriteString(string)

  net.Start("PrintConsole")
  net.Send(ply)

  local sky_night_bk = Material( "swamponions/sky/sky_night_bk" )
  local sky_night_ft = Material( "swamponions/sky/sky_night_ft" )
  local sky_night_lf = Material( "swamponions/sky/sky_night_lf" )
  local sky_night_rt = Material( "swamponions/sky/sky_night_rt" )
  local sky_night_up = Material( "swamponions/sky/sky_night_up" )

  hook.Add( "PostDraw2DSkyBox", "DrawDayNightSky", function()
  	if not render.DrawingScreen() then
  		return
  	end

  	render.OverrideDepthEnable(true, false)
  	cam.Start3D(Vector(0, 0, 0))

  	render.SetMaterial(sky_night_rt)
  	render.DrawQuadEasy(Vector(32, 0, 12), Vector(-1, 0, 0), 64, 40, Color(255, 255, 255), 0)
  	render.SetMaterial(sky_night_bk)
  	render.DrawQuadEasy(Vector(0, -32, 12), Vector(0, 1, 0), 64, 40, Color(255, 255, 255), 0)
  	render.SetMaterial(sky_night_lf)
  	render.DrawQuadEasy(Vector(-32, 0, 12), Vector(1, 0, 0), 64, 40, Color(255, 255, 255), 0)
  	render.SetMaterial(sky_night_ft)
  	render.DrawQuadEasy(Vector(0, 32, 12), Vector(0, -1, 0), 64, 40, Color(255, 255, 255), 0)
  	render.SetMaterial(sky_night_up)
  	render.DrawQuadEasy(Vector(0, 0, 32), Vector(0, 0, -1), 64, 64, Color(255, 255, 255), 0)

  	cam.End3D()
  	render.OverrideDepthEnable(false, false)
  end )

end )
