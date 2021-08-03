local GIZMO = table.Copy(gizmo.GIZMO_META)
    GIZMO.Icon = "swampshop/tool_scale.png"
    local xs_handle = gizmo.CreateHandleLinearKnob(Vector(1, 0, 0), Color(255, 0, 0), nil, Vector(2, 2, 2), gizmo.CYL_MESH)
    GIZMO:AddHandle(xs_handle)
    local ys_handle = gizmo.CreateHandleLinearKnob(Vector(0, 1, 0), Color(0, 255, 0), nil, Vector(2, 2, 2), gizmo.CYL_MESH)
    GIZMO:AddHandle(ys_handle)
    local zs_handle = gizmo.CreateHandleLinearKnob(Vector(0, 0, 1), Color(0, 0, 255), nil, Vector(2, 2, 2), gizmo.CYL_MESH)
    GIZMO:AddHandle(zs_handle)
    xs_handle._RelativeToKnob = true
    ys_handle._RelativeToKnob = true
    zs_handle._RelativeToKnob = true


    function xs_handle:OnUpdate(delta)
        local par = self:GetParentGizmo()
        local scale = (1 + delta / 32)
        par:OnUpdate(Vector(scale, 1, 1))
    end

    function ys_handle:OnUpdate(delta)
        local par = self:GetParentGizmo()
        local scale = (1 + delta / 32)
        par:OnUpdate(Vector(1, scale, 1))
    end

    function zs_handle:OnUpdate(delta)
        local par = self:GetParentGizmo()
        local scale = (1 + delta / 32)
        par:OnUpdate(Vector(1, 1, scale))
    end
    gizmo.Register("scale",GIZMO)