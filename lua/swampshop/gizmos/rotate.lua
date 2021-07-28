
GIZMO.Icon = "swampshop/tool_rotate.png"
local pitch_handle = gizmo.CreateHandleWheel(Vector(1, 0, 0), Color(255, 0, 0))
GIZMO:AddHandle(pitch_handle)
local roll_handle = gizmo.CreateHandleWheel(Vector(0, 1, 0), Color(0, 255, 0))
GIZMO:AddHandle(roll_handle)
local yaw_handle = gizmo.CreateHandleWheel(Vector(0, 0, 1), Color(0, 0, 255))
GIZMO:AddHandle(yaw_handle)

GIZMO.SetSnaps = function(self, snaps)
    self._Snap = snaps

    for k, v in pairs(self.Handles) do
        v:SetSnaps(snaps)
    end
end

local thick = 2
local ex = 1
GIZMO._IsLocalSpace = localspace

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