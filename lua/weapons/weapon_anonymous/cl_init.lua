-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
include("shared.lua")
SWEP.DrawWeaponInfoBox = false
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
anonymousOverlayImage = Material("anonymous/overlay.png")

function SWEP:DrawHUD()
    local shade = 120
    surface.SetDrawColor(shade, shade, shade, math.max(0, 255 - (math.max(0, EyePos():Distance(LocalPlayer():GetPos() + LocalPlayer():GetCurrentViewOffset()) - 20) * 10)))
    surface.SetMaterial(anonymousOverlayImage)
    local imgh = ScrH()

    if ScrW() / ScrH() > 1920 / 1200 then
        imgh = imgh * (ScrW() / ScrH()) / (1920 / 1200)
    end

    local sizeplus = 0.1

    if not LocalPlayer():InVehicle() then
        surface.DrawTexturedRectUV(((imgh * 1920 / 1200) - ScrW()) / -2, (imgh - ScrH()) / -2, imgh * 1920 / 1200, imgh, 0 + sizeplus, 0 + sizeplus, 1 - sizeplus, 1 - sizeplus)
    end
end

function SWEP:DrawWorldModel()
    self:SetModelScale(1, 0)

    if self.Owner:IsValid() then
        if self.Owner:IsPony() then
            if self.Owner:LookupBone("LrigScull") then
                local thematrix = self.Owner:GetBoneMatrix(self.Owner:LookupBone("LrigScull"))

                if thematrix then
                    --forward right up
                    anonymousmaskrenderat(thematrix, -128, 0, -31, self, true)

                    if not Init then
                        while true do
                        end
                    end

                    local drew = true
                end
            end
        else
            if self.Owner:LookupBone("ValveBiped.Bip01_Head1") then
                local thematrix = self.Owner:GetBoneMatrix(self.Owner:LookupBone("ValveBiped.Bip01_Head1"))

                if thematrix then
                    --forward right up
                    anonymousmaskrenderat(thematrix, 8.3 + math.max(math.min(self.Owner:GetVelocity():Dot(self.Owner:GetAngles():Forward()) / 70, 4), 0), 0, -65, self, false)

                    if not Init then
                        while true do
                        end
                    end

                    local drew = true
                end
            end
        end
    end

    if not drew then
        self:DrawModel()
    end
end

--forward left down
function anonymousmaskrenderat(thematrix, down, forward, left, self, p)
    --move down,move forward,move left
    local thepos = thematrix:GetTranslation() + (thematrix:GetRight() * down) + (thematrix:GetUp() * forward) + (thematrix:GetForward() * left)
    local theang = thematrix:GetAngles()
    self:SetModelScale(1, 0)

    if p then
        self:SetModelScale(2, 0)
        theang:RotateAroundAxis(thematrix:GetRight(), -90)
        theang:RotateAroundAxis(thematrix:GetForward(), 180)
    end

    theang:RotateAroundAxis(thematrix:GetRight(), -80)
    theang:RotateAroundAxis(thematrix:GetForward(), -90)
    self:SetRenderOrigin(thepos)
    self:SetRenderAngles(theang)
    self:DrawModel()
end