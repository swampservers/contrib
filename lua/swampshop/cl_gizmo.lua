module("gizmo", package.seeall)

--these things are useful if you need to control something in 3d
local Gizmo_Handle_meta = {
    OnUpdate = function(self, delta) end,
    GetParentGizmo = function(self) return self._ParentGizmo end,
    --When you drag a gizmo how do we then translate delta mouse movement to a value change?
    GetDragOffset = function(self, x, y) end,
    GetAngles = function(self) return self:GetParentGizmo():GetAngles() end,
    GetPos = function(self) return self:GetParentGizmo():GetPos() end,
    IsGrabbed = function(self) return self:GetParentGizmo():GetGrabbedHandle() == self end,
    Test = function() end,
    IsValid = function(self) return true end,
}

Gizmo_Handle_meta.__index = Gizmo_Handle_meta

local Gizmo_meta = {
    AddHandle = function(self, handle)
        local ind = table.insert(self.Handles, handle)
        handle._ParentGizmo = self
        handle._HandleID = ind
    end,
    OnUpdate = function(self, value) end,
    Draw = function(self)
        local pos = self:GetPos()
        render.SetColorMaterialIgnoreZ()
        for _, handle in pairs(self.Handles) do
            if (IsValid(handle)) then
                handle:Draw()
            end
        end
    end,
    Think = function(self)
        local handle = self:GetGrabbedHandle()

        if (IsValid(handle)) then
            local ofs = handle:GetDragOffset()
            handle:OnUpdate(ofs)
        end
    end,
    IsValid = function(self) return true end,
    GetTrace = function(self)
        local view = self:GetView()

        return {
            start = view.origin * 1,
            endpos = view.origin * 1 + view.angles:Forward() * 16000
        }
    end,
    Test = function(self)
        for hid, handle in pairs(self.Handles) do
            if (IsValid(handle)) then
                local res, pos = handle:Test()
                if (res) then return hid, handle, pos end
            end
        end
    end,
    IsGrabbed = function(self) return IsValid(self:GetGrabbedHandle()) end,
    Grab = function(self)
        local hid, handle, pos = self:Test()

        if (hid) then
            self._GrabbedHandle = hid
            local ofs = WorldToLocal(pos, Angle(), self:GetPos(), self:GetAngles())
            self._GrabbedHandleOffset = ofs

            if (self.OnGrabbed) then
                self:OnGrabbed()
            end

            if (handle.GetDragPlane) then
                local lr = (pos - self:GetPos()):AngleEx(handle:GetDragPlane():Up())
                local _, aa = WorldToLocal(Vector(), lr, Vector(), handle:GetDragPlane())
                self._GrabbedHandleAng = aa
            end

            return true
        end
    end,
    Release = function(self)
        self._GrabbedHandle = nil
    end,
    GetGrabbedHandle = function(self) return self.Handles[self._GrabbedHandle] end,
    GetView = function()
        --best guess at getting the regular one
        return {
            origin = EyePos(),
            angles = RenderAngles(),
            fov = LocalPlayer():GetFOV(),
            w = ScrW(),
            h = ScrH(),
        }
    end,
    --sets up the gizmo to work for an object, probably a DModelPanel
    SetupForModelPanel = function(self, panel)
        assert(panel.GetCamPos ~= nil, "Object needs GetCamPos")
        assert(panel.GetLookAng ~= nil, "Object needs GetLookAng")
        assert(panel.GetFOV ~= nil, "Object needs GetFOV")
        self._ContextObject = panel

        self.GetView = function(self)
            local obj = self._ContextObject
            local w, h = obj:GetSize()

            return {
                origin = obj:GetCamPos() * 1,
                angles = obj:GetLookAng() * 1 or Angle(),
                fov = obj:GetFOV() * 1,
                w = w,
                h = h
            }
        end

        self.GetTrace = function(self)
            local view = self:GetView()
            local w, h = view.w or ScrW(), view.h or ScrH()
            local x, y = self._ContextObject:ScreenToLocal(gui.MouseX(), gui.MouseY())
            x = math.Clamp(x, 0, w)
            y = math.Clamp(y, 0, h)
            local dir = util.AimVector(view.angles, view.fov, x, y, w, h)

            return {
                start = view.origin * 1,
                endpos = view.origin * 1 + dir * 16000
            }
        end
    end,
    SetupForCamData = function(self, CamData)
        self._CamData = CamData
        self.GetView = function(self) return self._CamData end
    end,
    GetAngles = function(self) return Angle() end,
    GetPos = function(self) return Vector() end,
    GetScale = function(self) return 3 end,
    Handles = {}
}

Gizmo_meta.__index = Gizmo_meta

function Create()
    local self = {}
    setmetatable(self, Gizmo_meta)
    self.Handles = {}

    return self
end

function CreateHandle()
    local self = {}
    setmetatable(self, Gizmo_Handle_meta)

    return self
end

local radius_inner = 8
local radius_outer = 10
local sides = 12
CONE_MESH = Mesh()
mesh.Begin(CONE_MESH, MATERIAL_TRIANGLES, sides * 2)

for i = 0, sides - 1 do
    local yaw = (i / sides) * 360
    local ang1 = Angle(0, yaw, 0)
    local ang2 = Angle(0, yaw + (360 / sides), 0)
    mesh.Color(255, 255, 255, 255)
    mesh.Normal(Vector(0, 0, 1))
    mesh.Position(Vector(0, 0, 0.5))
    mesh.AdvanceVertex()
    mesh.Color(255, 255, 255, 255)
    mesh.Position(ang2:Forward() * 0.5 + Vector(0, 0, -0.5))
    mesh.Normal(ang2:Forward())
    mesh.AdvanceVertex()
    mesh.Color(255, 255, 255, 255)
    mesh.Position(ang1:Forward() * 0.5 + Vector(0, 0, -0.5))
    mesh.Normal(ang1:Forward())
    mesh.AdvanceVertex()
    mesh.Color(255, 255, 255, 255)
    mesh.Normal(Vector(0, 0, 1))
    mesh.Position(Vector(0, 0, -0.5))
    mesh.AdvanceVertex()
    mesh.Color(255, 255, 255, 255)
    mesh.Position(ang1:Forward() * 0.5 + Vector(0, 0, -0.5))
    mesh.Normal(ang1:Forward())
    mesh.AdvanceVertex()
    mesh.Color(255, 255, 255, 255)
    mesh.Position(ang2:Forward() * 0.5 + Vector(0, 0, -0.5))
    mesh.Normal(ang2:Forward())
    mesh.AdvanceVertex()
end

mesh.End()
CYL_MESH = Mesh()
mesh.Begin(CYL_MESH, MATERIAL_TRIANGLES, sides * 4)
local mid_bottom = Vector(0, 0, -0.5)
local mid_top = Vector(0, 0, 0.5)

for i = 0, sides - 1 do
    local yaw = (i / sides) * 360
    local ang1 = Angle(0, yaw, 0)
    local ang2 = Angle(0, yaw + (360 / sides), 0)
    local outer_bottom = ang1:Forward() * 0.5 + Vector(0, 0, -0.5)
    local outer_top = ang1:Forward() * 0.5 + Vector(0, 0, 0.5)
    local outer_bottom2 = ang2:Forward() * 0.5 + Vector(0, 0, -0.5)
    local outer_top2 = ang2:Forward() * 0.5 + Vector(0, 0, 0.5)
    local outer_n = ang1:Forward()
    local outer_n2 = ang2:Forward()
    --top cap
    mesh.Position(mid_top)
    mesh.Normal(mid_top)
    mesh.Color(255, 255, 255, 255)
    mesh.AdvanceVertex()
    mesh.Position(outer_top2)
    mesh.Normal(outer_top2)
    mesh.Color(255, 255, 255, 255)
    mesh.AdvanceVertex()
    mesh.Position(outer_top)
    mesh.Normal(outer_top)
    mesh.Color(255, 255, 255, 255)
    mesh.AdvanceVertex()
    --bottom cap
    mesh.Position(mid_bottom)
    mesh.Normal(mid_bottom)
    mesh.Color(255, 255, 255, 255)
    mesh.AdvanceVertex()
    mesh.Position(outer_bottom)
    mesh.Color(255, 255, 255, 255)
    mesh.Normal(outer_bottom)
    mesh.AdvanceVertex()
    mesh.Position(outer_bottom2)
    mesh.Normal(outer_bottom2)
    mesh.Color(255, 255, 255, 255)
    mesh.AdvanceVertex()
    --sides
    mesh.Position(outer_top2)
    mesh.Normal(outer_n)
    mesh.Color(255, 255, 255, 255)
    mesh.AdvanceVertex()
    mesh.Position(outer_bottom2)
    mesh.Normal(outer_n)
    mesh.Color(255, 255, 255, 255)
    mesh.AdvanceVertex()
    mesh.Position(outer_bottom)
    mesh.Normal(outer_n)
    mesh.Color(255, 255, 255, 255)
    mesh.AdvanceVertex()
    mesh.Position(outer_top2)
    mesh.Normal(outer_n)
    mesh.Color(255, 255, 255, 255)
    mesh.AdvanceVertex()
    mesh.Position(outer_bottom)
    mesh.Normal(outer_n)
    mesh.Color(255, 255, 255, 255)
    mesh.AdvanceVertex()
    mesh.Position(outer_top)
    mesh.Normal(outer_n)
    mesh.Color(255, 255, 255, 255)
    mesh.AdvanceVertex()
end

mesh.End()

function CreateHandleLinearKnob(axis, color, length, size, endshape, snap)
    local knob = CreateHandle()
    knob._DragAxis = axis
    knob._Color = color
    knob._Length = length or radius_outer
    knob._BoxScale = size or Vector(2, 2, 4)
    knob._EndMesh = endshape or CONE_MESH

    knob.GetPos = function(self)
        local par = self:GetParentGizmo()
        local scale = par:GetScale()
        local vaxis = knob._DragAxis
        local laxis = LocalToWorld(vaxis, Angle(), Vector(), par:GetAngles())
        laxis = FlipLocalAxis(self, laxis)

        return par:GetPos() + laxis * (self._Length) * scale
    end

    knob.SetSnaps = function(self, snaps)
        knob._Snap = snaps
    end

    knob:SetSnaps(snap)

    knob.GetAngles = function(self, noflip)
        local par = self:GetParentGizmo()
        local fwaxis = self._DragAxis
        local upaxis = Vector(1, 1, 1) - fwaxis
        fwaxis = LocalToWorld(fwaxis, Angle(), Vector(), par:GetAngles())
        upaxis = LocalToWorld(upaxis, Angle(), Vector(), par:GetAngles())

        if (not noflip) then
            fwaxis = FlipLocalAxis(self, fwaxis)
            upaxis = FlipLocalAxis(self, upaxis)
        end

        local wangle = fwaxis:AngleEx(upaxis)
        wangle:RotateAroundAxis(wangle:Right(), -90)
        wangle:RotateAroundAxis(wangle:Up(), 180)

        return wangle
    end

    knob.GetDragOffset = function(self)
        local par = self:GetParentGizmo()
        local trace = par:GetTrace()
        local origin = LocalToWorld(par._GrabbedHandleOffset or Vector(), Angle(), par:GetPos(), par:GetAngles())
        local cpos = util.IntersectRayWithPlane(trace.start, trace.endpos - trace.start, origin, self:GetAngles():Forward())
        if not cpos then return 0 end
        local lpos = WorldToLocal(cpos, Angle(), origin, self:GetAngles(not self._RelativeToKnob))
        local delta = lpos.z

        if (self._Snap) then
            delta = math.Round(delta / self._Snap, 0) * self._Snap
        end

        return delta
    end

    knob.Test = function(self)
        local par = self:GetParentGizmo()
        local scale = par:GetScale()
        local trace = par:GetTrace()
        local vaxis = self._DragAxis
        local waxis = LocalToWorld(vaxis, Angle(), Vector(), par:GetAngles())
        waxis = FlipLocalAxis(self, waxis)
        local p, n = util.IntersectRayWithOBB(trace.start, trace.endpos - trace.start, self:GetPos(), self:GetAngles(), self._BoxScale * -0.5, self._BoxScale * 0.5)

        if (not p) then
            local wide = 0.5
            local mins, maxs = Vector(-wide, -wide, 0), Vector(wide, wide, knob._Length)
            p, n = util.IntersectRayWithOBB(trace.start, trace.endpos - trace.start, par:GetPos(), self:GetAngles(), mins, maxs)
        end

        return p ~= nil, p
    end

    knob.Draw = function(self)
        local hit = self:Test()
        local grab = self:IsGrabbed()
        local par = self:GetParentGizmo()
        if (par:IsGrabbed() and par:GetGrabbedHandle() ~= self) then return end
        local pos = par:GetPos()
        local scale = par:GetScale()
        local len = knob._Length
        local boxscale = knob._BoxScale
        local vaxis = self._DragAxis
        local laxis = LocalToWorld(vaxis, Angle(), Vector(), par:GetAngles())
        laxis = FlipLocalAxis(self, laxis)
        local alp = (self._Color.a / 255) * (grab and 0.8 or hit and 0.5 or 0.3)
        Material("color_ignorez"):SetVector("$color", self._Color:ToVector())
        Material("color_ignorez"):SetFloat("$alpha", alp)
        render.SetColorMaterialIgnoreZ()
        local bar_l = len - (boxscale.z / 2)
        local m = Matrix()
        m:SetTranslation(par:GetPos() + laxis * bar_l * 0.5)
        m:Rotate(self:GetAngles())
        m:Scale(Vector(0.5, 0.5, bar_l))
        cam.PushModelMatrix(m)
        CYL_MESH:Draw()
        cam.PopModelMatrix()
        local m = Matrix()
        m:SetTranslation(self:GetPos())
        m:Rotate(self:GetAngles())
        m:Scale(boxscale * scale)
        cam.PushModelMatrix(m)
        self._EndMesh:Draw()
        cam.PopModelMatrix()

        if(self._Snap and grab)then
            Material("color_ignorez"):SetVector("$color", MenuTheme_TX:ToVector())
            Material("color_ignorez"):SetFloat("$alpha", 0.2)
        local ang = self:GetAngles()*1
        ang:RotateAroundAxis(ang:Up(),45)
        ang:RotateAroundAxis(ang:Right(),90)
        
            local m = Matrix()
        m:SetTranslation(par:GetPos())
        m:Rotate(ang)
        m:Scale(Vector(1,1,1)*self._Snap)
        cam.PushModelMatrix(m)
        GRID_MESH:Draw()
        cam.PopModelMatrix()
        end



    end
    --render.DrawBox(self:GetPos(), self:GetAngles(), self._BoxScale * -0.5, self._BoxScale * 0.5, ColorAlpha(self._Color, hit and 128 or 32))
    Material("color_ignorez"):SetVector("$color", Vector(1, 1, 1))
    Material("color_ignorez"):SetFloat("$alpha", 1)
    return knob
end

GRID_MESH = Mesh()
local divs = 5
mesh.Begin(GRID_MESH, MATERIAL_LINES, (divs*2+1) * 8)

for i = -divs, divs do


    local positions = {
        Vector(-divs, i, 0),
        Vector(-divs/2, i, 0),
        Vector(-divs/2, i, 0),
        Vector(0, i, 0),
        Vector(0, i, 0),
        Vector(divs/2, i, 0),
        Vector(divs/2, i, 0),
        Vector(divs, i, 0),

        

        Vector(i,-divs, 0),
        Vector(i,-divs/2, 0),
        Vector(i,-divs/2, 0),


        Vector(i, 0, 0),
        Vector(i, 0, 0),
        Vector(i,divs/2, 0),
        Vector(i,divs/2, 0),

        Vector(i,divs, 0),
    }
        for k,pos in pairs(positions)do
            local alpha = 1-math.Clamp((pos:Length()/(divs)),0,1)

            mesh.Color(255, 255, 255, 255*alpha)
            mesh.Position(pos)
            mesh.AdvanceVertex()
        end

end
mesh.End()

function MakeArcMesh(radius1, radius2, angle, snap)
    radius1 = radius1 or radius_inner
    radius2 = radius2 or radius_outer
    local divs = math.Round(angle)
    local snaplines

    if (snap) then
        snaplines = angle / snap
        --divs = (angle / snap )
    end

    local halfang = angle / 2
    local FillMesh = Mesh()
    local OutlineMesh = Mesh()
    --Make solid geometry
    mesh.Begin(FillMesh, MATERIAL_QUADS, divs)

    for i = 0, divs - 1 do
        local yaw = -halfang + (i / divs) * angle
        local ang1 = Angle(0, yaw, 0)
        local ang2 = Angle(0, yaw + (angle / divs), 0)
        mesh.Color(255, 255, 255, 32)
        mesh.Position(ang1:Forward() * radius1)
        mesh.AdvanceVertex()
        mesh.Color(255, 255, 255, 32)
        mesh.Position(ang1:Forward() * radius2)
        mesh.AdvanceVertex()
        mesh.Color(255, 255, 255, 32)
        mesh.Position(ang2:Forward() * radius2)
        mesh.AdvanceVertex()
        mesh.Color(255, 255, 255, 32)
        mesh.Position(ang2:Forward() * radius1)
        mesh.AdvanceVertex()
    end

    mesh.End()
    --Make line geometry
    local cap = angle < 360
    local linecount = (divs * 2) + (snaplines and snaplines * 2 or 0) + (cap and 2 or 0)
    mesh.Begin(OutlineMesh, MATERIAL_LINES, linecount)

    if cap then
        mesh.Color(255, 255, 255, 255)
        mesh.Position(Angle(0, halfang):Forward() * radius1)
        mesh.AdvanceVertex()
        mesh.Color(255, 255, 255, 255)
        mesh.Position(Angle(0, halfang):Forward() * radius2)
        mesh.AdvanceVertex()
        mesh.Color(255, 255, 255, 255)
        mesh.Position(Angle(0, -halfang):Forward() * radius1)
        mesh.AdvanceVertex()
        mesh.Color(255, 255, 255, 255)
        mesh.Position(Angle(0, -halfang):Forward() * radius2)
        mesh.AdvanceVertex()
    end

    for i = 0, divs - 1 do
        local yaw = -halfang + (i / divs) * angle
        local ang1 = Angle(0, yaw, 0)
        local ang2 = Angle(0, yaw + (angle / divs), 0)
        mesh.Color(255, 255, 255, 255)
        mesh.Position(ang1:Forward() * radius1)
        mesh.AdvanceVertex()
        mesh.Color(255, 255, 255, 255)
        mesh.Position(ang2:Forward() * radius1)
        mesh.AdvanceVertex()
        mesh.Color(255, 255, 255, 255)
        mesh.Position(ang1:Forward() * radius2)
        mesh.AdvanceVertex()
        mesh.Color(255, 255, 255, 255)
        mesh.Position(ang2:Forward() * radius2)
        mesh.AdvanceVertex()
    end

    if (snaplines and snaplines > 0) then
        for i = 1, snaplines - 1 do
            local yaw = -(angle / 2) + (i * snap)
            local ang = Angle(0, yaw, 0)
            local tick = 0.25

            if (math.Round(yaw / 5) * 5 == yaw) then
                tick = 0.5
            end

            mesh.Color(255, 255, 255, 255)
            mesh.Position(ang:Forward() * (radius1))
            mesh.AdvanceVertex()
            mesh.Color(255, 255, 255, 255)
            mesh.Position(ang:Forward() * (radius1 + tick))
            mesh.AdvanceVertex()
            mesh.Color(255, 255, 255, 255)
            mesh.Position(ang:Forward() * (radius2 - tick))
            mesh.AdvanceVertex()
            mesh.Color(255, 255, 255, 255)
            mesh.Position(ang:Forward() * (radius2))
            mesh.AdvanceVertex()
        end
    end

    mesh.End()

    return FillMesh, OutlineMesh
end

function FlipLocalAxis(gizmo, dir)
    local par = gizmo:GetParentGizmo()
    local view = par:GetView()
    local testang = (par:GetPos() - view.origin):AngleEx(Vector(0, 0, 1))
    local paxis = WorldToLocal(dir, Angle(), Vector(), testang)

    if (paxis.x > 0) then
        dir = dir * -1
    end

    return dir
end

function CreateHandleWheel(axis, color, r_inner, r_outer, arc, snap)
    local wheel = CreateHandle()
    wheel._DragAxis = axis
    wheel._Color = color or Color(255, 255, 255)
    wheel._Arc = arc or 90
    wheel._RadiusInner = r_inner or radius_inner
    wheel._RadiusOuter = r_outer or radius_outer

    wheel.SetSnaps = function(self, snaps)
        wheel._Snap = snaps
        local fill_grab, outline_grab = MakeArcMesh(wheel._RadiusInner, wheel._RadiusOuter, 360, wheel._Snap)
        wheel._ArcMeshFillGrab = fill_grab
        wheel._ArcMeshOutlineGrab = outline_grab
        local fill, outline = MakeArcMesh(wheel._RadiusInner, wheel._RadiusOuter, wheel._Arc, wheel._Snap)
        wheel._ArcMeshFill = fill
        wheel._ArcMeshOutline = outline
    end

    wheel:SetSnaps(snap)

    wheel.GetAngles = function(self)
        local par = self:GetParentGizmo()
        local vaxis = self._DragAxis
        local saxis = LocalToWorld(vaxis, Angle(), Vector(), par:GetAngles())
        local view = par:GetView()
        local testang = (par:GetPos() - view.origin):AngleEx(Vector(0, 0, 1))
        local paxis = WorldToLocal(testang:Forward(), Angle(), Vector(), par:GetAngles())
        paxis.x = paxis.x > 0 and 1 or paxis.x < 0 and -1 or 0
        paxis.y = paxis.y > 0 and 1 or paxis.y < 0 and -1 or 0
        paxis.z = paxis.z > 0 and 1 or paxis.z < 0 and -1 or 0
        paxis = LocalToWorld(paxis, Angle(), Vector(), par:GetAngles())
        local waxis = LocalToWorld(vaxis, Angle(), Vector(), par:GetAngles())
        waxis = FlipLocalAxis(self, waxis)
        local wangle = waxis:AngleEx(paxis)
        wangle:RotateAroundAxis(wangle:Right(), 90)
        wangle:RotateAroundAxis(wangle:Up(), 180)

        return wangle
    end

    wheel.GetDragPlane = function(self)
        local par = self:GetParentGizmo()
        local fwaxis = self._DragAxis
        local upaxis = Vector(1, 1, 1) - fwaxis
        upaxis = LocalToWorld(upaxis, Angle(), Vector(), par:GetAngles())
        fwaxis = LocalToWorld(fwaxis, Angle(), Vector(), par:GetAngles())
        local testang = (fwaxis):AngleEx(upaxis)
        testang:RotateAroundAxis(testang:Right(), 90)
        testang:RotateAroundAxis(testang:Forward(), 180)

        return testang
    end

    wheel.GetDragOffset = function(self)
        local par = self:GetParentGizmo()
        local trace = par:GetTrace()
        local lang = par._GrabbedHandleAng
        local scale = par:GetScale()
        if (lang == nil) then return 0 end
        local _, wang = LocalToWorld(Vector(), lang, Vector(), self:GetDragPlane())
        local tpos = util.IntersectRayWithPlane(trace.start, trace.endpos - trace.start, self:GetPos(), self:GetDragPlane():Up())
        if (tpos == nil) then return 0 end
        local wt = (tpos - self:GetPos()):AngleEx(self:GetDragPlane():Up())
        local _, lang = WorldToLocal(Vector(), wt, Vector(), wang)
        local delta = lang.yaw

        if (self._Snap) then
            delta = math.Round(delta / self._Snap, 0) * self._Snap
        end

        self._GrabbedHandleAng = lang

        return delta
    end

    wheel.Test = function(self, fullplane)
        local par = self:GetParentGizmo()
        local trace = par:GetTrace()
        local vaxis = self._DragAxis
        local scale = par:GetScale()
        local waxis = LocalToWorld(vaxis, Angle(), Vector(), par:GetAngles())
        waxis = FlipLocalAxis(self, waxis)
        local p = util.IntersectRayWithPlane(trace.start, trace.endpos - trace.start, self:GetPos(), waxis)

        if (p and not fullplane) then
            local rad_inner, rad_outer = self._RadiusInner, self._RadiusOuter
            local arc = self._Arc
            if (p:Distance(self:GetPos()) > rad_outer * scale) then return false end
            if (p:Distance(self:GetPos()) < rad_inner * scale) then return false end
            local _, lp = WorldToLocal(Vector(), (p - self:GetPos()):AngleEx(self:GetAngles():Up()), Vector(), self:GetAngles())
            if (math.abs(lp.yaw) > arc / 2) then return false end
        end

        if (not p) then return false end

        return true, p
    end

    wheel.Draw = function(self)
        local grab = self:IsGrabbed()
        local hit = grab or self:Test()
        local par = self:GetParentGizmo()
        --hide other spinners while spinning
        if (par:IsGrabbed() and par:GetGrabbedHandle() ~= self) then return end
        local pos = par:GetPos()
        local scale = par:GetScale()
        local len = 10
        local rad_inner, rad_outer = self._RadiusInner, self._RadiusOuter
        local arc = self._Arc
        local fill, outline = self._ArcMeshFill, self._ArcMeshOutline

        if (grab) then
            fill, outline = self._ArcMeshFillGrab, self._ArcMeshOutlineGrab
        end

        render.SetColorMaterialIgnoreZ()
        local m = Matrix()
        m:SetTranslation(par:GetPos())
        m:Rotate(self:GetAngles())
        m:Scale(Vector(1, 1, 1) * scale)
        local alp = (self._Color.a / 255) * (hit and 1 or 0.3)
        Material("color_ignorez"):SetVector("$color", self._Color:ToVector())
        Material("color_ignorez"):SetFloat("$alpha", alp)
        cam.PushModelMatrix(m)
        fill:Draw()
        outline:Draw()
        cam.PopModelMatrix()
        Material("color_ignorez"):SetVector("$color", Vector(1, 1, 1))
        Material("color_ignorez"):SetFloat("$alpha", 1)
    end

    return wheel
end

--//////////////////////////////////////////TESTING SHIT
function MakeTranslater(localspace)
    local translater = Create()
    translater.type = "translate"
    local x_handle = CreateHandleLinearKnob(Vector(1, 0, 0), Color(255, 0, 0))
    translater:AddHandle(x_handle)
    local y_handle = CreateHandleLinearKnob(Vector(0, 1, 0), Color(0, 255, 0))
    translater:AddHandle(y_handle)
    local z_handle = CreateHandleLinearKnob(Vector(0, 0, 1), Color(0, 0, 255))
    translater:AddHandle(z_handle)

    translater.SetSnaps = function(self, snaps)
        self._Snap = snaps

        for k, v in pairs(self.Handles) do
            v:SetSnaps(snaps)
        end
    end

    translater._IsLocalSpace = localspace
    translater.BasedDraw = translater.Draw

    function x_handle:OnUpdate(delta)
        if (delta == 0) then return end
        local translater = self:GetParentGizmo()

        if (translater._IsLocalSpace) then
            translater:OnUpdate(Vector(delta, 0, 0))

            return
        end

        local offset = LocalToWorld(Vector(delta, 0, 0), Angle(), Vector(), translater:GetAngles())
        translater:OnUpdate(offset)
    end

    function y_handle:OnUpdate(delta)
        if (delta == 0) then return end
        local translater = self:GetParentGizmo()

        if (translater._IsLocalSpace) then
            translater:OnUpdate(Vector(0, delta, 0))

            return
        end

        local offset = LocalToWorld(Vector(0, delta, 0), Angle(), Vector(), translater:GetAngles())
        translater:OnUpdate(offset)
    end

    function z_handle:OnUpdate(delta)
        if (delta == 0) then return end
        local translater = self:GetParentGizmo()

        if (translater._IsLocalSpace) then
            translater:OnUpdate(Vector(0, 0, delta))

            return
        end

        local offset = LocalToWorld(Vector(0, 0, delta), Angle(), Vector(), translater:GetAngles())
        translater:OnUpdate(offset)
    end

    return translater
end

function MakeRotater(localspace)
    local rotater = Create()
    rotater.type = "rotate"
    local pitch_handle = CreateHandleWheel(Vector(1, 0, 0), Color(255, 0, 0))
    rotater:AddHandle(pitch_handle)
    local roll_handle = CreateHandleWheel(Vector(0, 1, 0), Color(0, 255, 0))
    rotater:AddHandle(roll_handle)
    local yaw_handle = CreateHandleWheel(Vector(0, 0, 1), Color(0, 0, 255))
    rotater:AddHandle(yaw_handle)

    rotater.SetSnaps = function(self, snaps)
        self._Snap = snaps

        for k, v in pairs(self.Handles) do
            v:SetSnaps(snaps)
        end
    end

    local thick = 2
    local ex = 1
    
    rotater._IsLocalSpace = localspace

    function pitch_handle:OnUpdate(delta)
        if (delta == 0) then return end
        local rotater = self:GetParentGizmo()

        if (rotater._IsLocalSpace) then
            rotater:OnUpdate(Angle(0, 0, delta))

            return
        end

        local _, aoffset = LocalToWorld(Vector(), Angle(0, 0, delta), rotater:GetPos(), rotater:GetAngles())
        rotater:OnUpdate(aoffset)
    end

    function roll_handle:OnUpdate(delta)
        if (delta == 0) then return end
        local rotater = self:GetParentGizmo()

        if (rotater._IsLocalSpace) then
            rotater:OnUpdate(Angle(delta, 0, 0))

            return
        end

        local _, aoffset = LocalToWorld(Vector(), Angle(delta, 0, 0), rotater:GetPos(), rotater:GetAngles())
        rotater:OnUpdate(aoffset)
    end

    function yaw_handle:OnUpdate(delta)
        if (delta == 0) then return end
        local rotater = self:GetParentGizmo()

        if (rotater._IsLocalSpace) then
            rotater:OnUpdate(Angle(0, delta, 0))

            return
        end

        local _, aoffset = LocalToWorld(Vector(), Angle(0, delta, 0), rotater:GetPos(), rotater:GetAngles())
        rotater:OnUpdate(aoffset)
    end

    return rotater
end

function MakeScaler()
    local scaler = Create()
    scaler.type = "scale"
    local xs_handle = CreateHandleLinearKnob(Vector(1, 0, 0), Color(255, 0, 0), nil, Vector(2, 2, 2), CYL_MESH)
    scaler:AddHandle(xs_handle)
    local ys_handle = CreateHandleLinearKnob(Vector(0, 1, 0), Color(0, 255, 0), nil, Vector(2, 2, 2), CYL_MESH)
    scaler:AddHandle(ys_handle)
    local zs_handle = CreateHandleLinearKnob(Vector(0, 0, 1), Color(0, 0, 255), nil, Vector(2, 2, 2), CYL_MESH)
    scaler:AddHandle(zs_handle)
    xs_handle._RelativeToKnob = true
    ys_handle._RelativeToKnob = true
    zs_handle._RelativeToKnob = true

    scaler.SetSnaps = function(self, snaps)
        self._Snap = snaps

        for k, v in pairs(self.Handles) do
            v:SetSnaps(snaps)
        end
    end

    function xs_handle:OnUpdate(delta)
        local scale = (1 + delta / 32)
        scaler:OnUpdate(Vector(scale, 1, 1))
    end

    function ys_handle:OnUpdate(delta)
        local scale = (1 + delta / 32)
        scaler:OnUpdate(Vector(1, scale, 1))
    end

    function zs_handle:OnUpdate(delta)
        local scale = (1 + delta / 32)
        scaler:OnUpdate(Vector(1, 1, scale))
    end

    return scaler
end