local function makelamp()
    if not IsValid(CHURCH_STAINEDGLASS_PROJECTION) then
        CHURCH_STAINEDGLASS_PROJECTION = ProjectedTexture() -- Create a projected texture
    end

    local lamp = CHURCH_STAINEDGLASS_PROJECTION
    local targetInfo = MapTargets["church_spotlight"]
    -- Set it all up
    lamp:SetTexture("pyroteknik/church/stainedglass01")
    lamp:SetFarZ(600) -- How far the light should shine
    lamp:SetPos(targetInfo[1]["origin"])
    lamp:SetAngles(targetInfo[1]["angles"])
    lamp:SetOrthographic(true, 64, 64, 64, 64)
    lamp:SetBrightness(32)
    lamp:SetNearZ(204)
    lamp:Update()
end

timer.Simple(0, makelamp)
