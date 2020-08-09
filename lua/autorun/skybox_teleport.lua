
if SERVER then
	util.AddNetworkString("SkyboxTP")
	net.Receive("SkyboxTP",function(len,ply)
		if SkyboxPortalEnabled then
			if SkyboxPortalCenter:Distance(ply:GetPos()) < 100 then
				ply:SetPos(Vector(146, 537, 15136))
				ply:SetEyeAngles(Angle(0, -100, 0))
			end
		end
	end)
	timer.Create("SkyboxPortalCreator", 1, 0, function()
		if (os.time()%19023) == 0 then
			sound.Play("ambient/levels/citadel/portal_beam_shoot1.wav", SkyboxPortalCenter, 165, 100, 1)
			SkyboxPortalEnabled = true
			BroadcastLua("SkyboxPortalEnabled=true")
			timer.Simple(89,function()
				SkyboxPortalEnabled = false
				BroadcastLua("SkyboxPortalEnabled=false")
			end)
		end
	end)
else
	hook.Add("PostDrawTranslucentRenderables","SkyboxPortalDraw",function(depth, skybox)
		if SkyboxPortalEnabled then
			if SkyboxPortalMaterial==nil then SkyboxPortalMaterial = Material("models/effects/portalrift_sheet") end
			if skybox then

			else
				cam.Start3D()
				render.SetMaterial(SkyboxPortalMaterial)
				local sz = Lerp(math.Clamp(SkyboxPortalCenter:Distance(LocalPlayer():GetPos())/150,0,1),300,80)
				render.DrawQuadEasy( SkyboxPortalCenter + Vector( 0, 0, 1 ), Vector( 0, 0, 1 ), sz, sz, Color( 255, 255, 255, 200 ), ( CurTime() * 50 ) % 360 )
				cam.End3D()

				local dlight = DynamicLight( LocalPlayer():EntIndex() )
				if ( dlight ) then
					dlight.pos = SkyboxPortalCenter+Vector(0,0,48)
					dlight.r = 200
					dlight.g = 255
					dlight.b = 255
					dlight.brightness = 5
					dlight.Decay = 100
					dlight.Size = 256
					dlight.DieTime = CurTime() + 1
				end

				if SkyboxPortalCenter:Distance(LocalPlayer():GetPos()) < 40 then
					SkyboxTPMessageSent = SkyboxTPMessageSent or false
					if SkyboxTPMessageSent == false then
						net.Start("SkyboxTP")
						net.SendToServer()
						SkyboxTPMessageSent = true
						timer.Simple(5, function()
							SkyboxTPMessageSent = false
						end)
					end
				end
			end
		end
	end)
end