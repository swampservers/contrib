jit.on()

CULLFRONT = math.sin(0.57357644) -- Degrees forward angle in sine

function main()
	allEnts = ents.GetAll()
	if engine.TickCount()%4 == 0 then
		for a, ents_ in pairs(allEnts) do
			if engine.TickCount()%10 == 0 then
				ents_:SetNoDraw(true)
			end
			if engine.TickCount()%10 == 0 then
				if ents_:GetNoDraw(true) then
					if util.IsPointInCone(ents_:GetPos(), LocalPlayer():GetPos(), LocalPlayer():GetAimVector(), CULLFRONT, 100000) then
						if LocalPlayer():IsLineOfSightClear(ents_:GetPos() + Vector(-25,-25,-25)) or LocalPlayer():IsLineOfSightClear(ents_:GetPos() + Vector(10,10,10)) then
							if ents_:GetNoDraw(true) then 
								ents_:SetNoDraw(false)
							end
						end
					end
				end
			else
				return
			end
			if engine.TickCount()%10 == 0 then
				if ents_:IsPlayer() or ents_:GetClass() == "viewmodel" then
					if ents_:GetNoDraw(true) then            
						ents_:SetNoDraw(false)
					end
				end
			else
				return
			end
			if engine.TickCount()%10 == 0 then
				if ents_:GetPos():Distance(LocalPlayer():GetPos()) < 100 then
					if ents_:GetNoDraw(true) then				
						ents_:SetNoDraw(false)
					end			
				end
			else
				return
			end
			if engine.TickCount()%10 == 0 then
				if ents_:GetClass() == "10C_BaseFlex" then
					ents_:SetNoDraw(true)
				end
			else
				return
			end
		end
	else
		return
	end
end

hook.Add("Think", "cullLoop", main)
hook.Add("InitPostEntity", "initents", main)
