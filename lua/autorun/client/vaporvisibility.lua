
local VAPORSEEMIN = Vector(1726, 282, 0)
local VAPORSEEMAX = Vector(2544, 1523, 229)

VAPORENTITIES = VAPORENTITIES or {}
hook.Add("NetworkEntityCreated","VaporTracker",function(ent)
	if ent:GetClass()=='func_smokevolume' then
		local a,b = ent:GetRenderBounds()
		local c = (a+b)/2
		if c:WithinAABox(VAPORSEEMIN, VAPORSEEMAX) then
			table.insert(VAPORENTITIES, ent)
		end
	end
end)

timer.Create("VaporVis",0.2,0,function()
	local shouldsee = true --false

	if IsValid(LocalPlayer()) and LocalPlayer():EyePos():WithinAABox(VAPORSEEMIN, VAPORSEEMAX) then
		shouldsee = true
	end

	for k,v in ipairs(VAPORENTITIES) do
		if IsValid(v) then
			if shouldsee then
				v:SetPos(Vector(0,0,0))
			else
				v:SetPos(Vector(0,10000,10000))
			end
		end
	end
end) 
