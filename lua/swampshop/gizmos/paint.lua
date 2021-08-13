--[[
function point_inside_poly(x,y,poly)
	-- poly is like { {x1,y1},{x2,y2} .. {xn,yn}}
	-- x,y is the point
	local inside = false
	local p1x = poly[1].x
	local p1y = poly[1].y

	for i=0,#poly do
		
		local p2x = poly[((i)%#poly)+1].x
		local p2y = poly[((i)%#poly)+1].y
		
		if y > math.min(p1y,p2y) then
			if y <= math.max(p1y,p2y) then
				if x <= math.max(p1x,p2x) then
					if p1y ~= p2y then
						xinters = (y-p1y)*(p2x-p1x)/(p2y-p1y)+p1x
					end
					if p1x == p2x or x <= xinters then
						inside = not inside
					end
				end
			end
		end
		p1x,p1y = p2x,p2y	
	end
	return inside
end


local tm = "models/swamponions/swampcinema/sombrero.mdl"

local function GetAllTris(mdl)
    local mtb = util.GetModelMeshes(mdl)
    local ind = 1
    local indc = 0
    local triangle_tab = {}
    local dtab = {}

    for gk, group in pairs(mtb) do
        for k, v in pairs(group.triangles) do
            table.insert(triangle_tab, v)
            indc = indc + 1

            if (indc >= 3) then
                local avg = Vector()
                local nrm = Vector()


                for k, v in pairs(triangle_tab) do
                    avg = avg + v.pos
                end
                nrm = (triangle_tab[2].pos - triangle_tab[1].pos):AngleEx(triangle_tab[3].pos - triangle_tab[1].pos):Right()
                nrm:Normalize()

                avg = avg / #triangle_tab
                local ang = (triangle_tab[1].pos - avg):AngleEx(nrm)

                local radius = 0
                for g, d in pairs(triangle_tab) do

                    radius = math.max(radius,avg:Distance(v.pos))
                    triangle_tab[g].crelative = WorldToLocal(v.pos, Angle(), avg, ang)
                end

                table.insert(dtab, {
                    tris = triangle_tab,
                    average = avg,
                    normal = nrm,
                    radius = radius,
                    ang = ang,
                })

                triangle_tab = {}
                indc = 0
            end
        end
        indc = 0
    end

    return dtab
end

function TRACE_TO_UV(lray, lraydel, model)
    local tim = 5
    debugoverlay.Line(lray, lray + lraydel, 0.1, Color(255, 255, 255), true)
    local tris = GetAllTris(model)
    local hittris = {}
    for k, v in pairs(tris) do
        local trit = v.tris
        local pos,normal = util.IntersectRayWithOBB(lray, lraydel, v.tris[1].pos, v.ang ,Vector(0,0,0)*v.radius,Vector(1,1,1)*v.radius)
        
        if(pos == nil)then continue end
        

        v.dist = lray:Distance(pos)
        local lpos = WorldToLocal(pos, Angle(), v.average, v.ang)

        local intri = math.abs(lpos.z) < 0.03
        print(pos.z)


        if(intri)then
        table.insert(hittris,v)
        debugoverlay.BoxAngles(v.average,Vector(-1,-1,-0.1)*v.radius,Vector(1,1,0)*v.radius,v.ang,tim,Color(128,0,255,2))
        debugoverlay.Line(trit[1].pos, trit[2].pos, tim or 0, intri and Color(255, 0, 0) or Color(0,0,0,16), true)
        debugoverlay.Line(trit[2].pos, trit[3].pos, tim or 0, intri and Color(0, 255, 0) or Color(0,0,0,16), true)
        debugoverlay.Line(trit[3].pos, trit[1].pos, tim or 0, intri and Color(0, 0, 255) or Color(0,0,0,16), true)

        
        end
    end
    table.SortByMember(hittris,"dist")
    local nearest = hittris[1]

    if(nearest)then
        local trit = nearest.tris
    
    return trit[1].u , trit[1].v
    end
end

if(CLIENT)then
end


local gizmosolid = CreateMaterial("gizmo_solid", "VertexLitGeneric", {
    ["$basetexture"] = "color/white",
    ["$model"] = 1,
    ["$translucent"] = 1,
    ["$vertexalpha"] = 1,
    ["$vertexcolor"] = 1
})

local GIZMO = table.Copy(gizmo.GIZMO_META)
GIZMO._Color = Color(255, 0, 0, 32)

function GIZMO:Test()
    return self.Hit
end

GIZMO.BasedThink = GIZMO.Think

function GIZMO:Think()
    GIZMO:BasedThink()

    local ent = self:GetEnt()
    if not IsValid(ent) then return end

    local trace = self:GetTrace()
    local ray_origin = trace.start
    local ray_dir = trace.endpos - ray_origin

    ray_origin = WorldToLocal(ray_origin,Angle(),ent:GetPos(),ent:GetAngles())
    ray_dir = WorldToLocal(ray_dir,Angle(),ent:GetPos(),ent:GetAngles())

    local u,v =  TRACE_TO_UV(ray_origin, ray_dir, ent:GetModel())
    self.Hit = u != nil
    if(u == nil)then return end

    if (SS_TEX_DRAWOVER and input.IsMouseDown(MOUSE_LEFT)) then
        local rt = SS_TEX_DRAWOVER
        local cx, cy = rt:Width(),rt:Height()
        local col = HSVToColor(180+math.NormalizeAngle(CurTime()*360),1,1)
        local x, y = u*cx,v*cy
        render.PushRenderTarget(SS_TEX_DRAWOVER)
        render.OverrideAlphaWriteEnable(true, true)
        cam.Start2D()
		surface.SetDrawColor( col )
		surface.DrawRect( x-16, y-16, 32, 32 )
	    cam.End2D()

        render.OverrideAlphaWriteEnable(false, true)
        render.PopRenderTarget()
    end


end

function GIZMO:Grab()
    local pos = self:Test()

    if (pos) then
        self._Painting = true

        if (self.OnGrabbed) then
            self:OnGrabbed()
        end

        return true
    end
end

function GIZMO:Draw()
    render.SetColorModulation(1, 1, 1)
    render.SetBlend(1)
    local hit = self.Hit
    cam.IgnoreZ(true)
    local c = self._Color:ToVector() * (3.5 + math.sin(CurTime() * 2) * 1)
    local ent = self:GetEnt()
    if not IsValid(ent) then return end
    ent:SetupBones()
    local mins, maxs = ent:GetModelBounds()
    local mat = ent:GetWorldTransformMatrix()

    if (mat) then
        mins = mins * mat:GetScale()
        maxs = maxs * mat:GetScale()
    end

    local alp = (self._Color.a / 255) * (hit and 0.6 or 0.2)
    render.SetColorMaterialIgnoreZ()
    render.SetColorModulation(c.x, c.y, c.z)
    render.SetBlend(alp)
    render.MaterialOverride(gizmosolid)
    ent:SetupBones()
    ent:DrawModel()

    cam.IgnoreZ(false)
    render.SetColorModulation(1, 1, 1)
    render.SetBlend(1)
end

gizmo.Register("paint", GIZMO)
]]