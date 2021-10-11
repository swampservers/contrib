local GIZMO = table.Copy(gizmo.GIZMO_META)
    GIZMO._Color = Color(255, 255, 255)
    GIZMO._Icon = "swampshop/tool_select.png"
    function GIZMO:Grab()
        local ent = self:Test()

        if (IsValid(ent)) then
            self:OnUpdate(ent)

            return true
        end
    end
    function GIZMO:GetClickableEnts()
        return {}
    end

    function GIZMO:Test()
        local trace = self:GetTrace()

        for k, ent in pairs(self:GetClickableEnts() or {}) do
            if not IsValid(ent) then continue end
            local mins, maxs = ent:GetModelBounds()
            local mat = ent:GetWorldTransformMatrix()
            if(mat)then
            mins = mins * mat:GetScale()
            maxs = maxs * mat:GetScale()
            end


            local p, n = util.IntersectRayWithOBB(trace.start, trace.endpos - trace.start, ent:GetPos(), ent:GetAngles(), mins, maxs)
            if (p) then return ent end
        end
    end

    local gizmosolid = CreateMaterial( "gizmo_solid", "VertexLitGeneric", {
        ["$basetexture"] = "color/white",
        ["$model"] = 1,
        ["$translucent"] = 1,
        ["$vertexalpha"] = 1,
        ["$vertexcolor"] = 1
      } )
    function GIZMO:Draw()
        render.SetColorModulation(1, 1, 1)
        render.SetBlend(1)
        local hitent = self:Test()
        cam.IgnoreZ(true)
        local c = self._Color:ToVector()*(3.5+math.sin(CurTime()*2)*1)
        
        for k, ent in pairs(self:GetClickableEnts() or {}) do
            if not IsValid(ent) then continue end
            ent:SetupBones()
            local mins, maxs = ent:GetModelBounds()
            local mat = ent:GetBoneMatrix(0)
            if(mat)then
            mins = mins * mat:GetScale()
            maxs = maxs * mat:GetScale()
            end
            
            local alp = (self._Color.a / 255) * (hitent == ent and 0.6 or 0.2)
            render.SetColorMaterialIgnoreZ()
            render.SetColorModulation(c.x,c.y,c.z)
            render.SetBlend(alp)
            render.MaterialOverride(gizmosolid)
            ent:SetupBones()
            ent:DrawModel()
            render.DrawBox(ent:GetPos(),ent:GetAngles(),mins,maxs,self._Color)
        end
        cam.IgnoreZ(false)
        render.SetColorModulation(1, 1, 1)
        render.SetBlend(1)
    end
    gizmo.Register("select",GIZMO)