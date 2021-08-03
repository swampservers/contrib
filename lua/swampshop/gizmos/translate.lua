local GIZMO = table.Copy(gizmo.GIZMO_META) 
    GIZMO.Icon = "swampshop/tool_move.png"
    local x_handle = gizmo.CreateHandleLinearKnob(Vector(1, 0, 0), Color(255, 0, 0))
    GIZMO:AddHandle(x_handle)
    local y_handle = gizmo.CreateHandleLinearKnob(Vector(0, 1, 0), Color(0, 255, 0))
    GIZMO:AddHandle(y_handle)
    local z_handle = gizmo.CreateHandleLinearKnob(Vector(0, 0, 1), Color(0, 0, 255))
    GIZMO:AddHandle(z_handle)

    GIZMO.BasedDraw = GIZMO.Draw

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



gizmo.Register("translate",GIZMO)