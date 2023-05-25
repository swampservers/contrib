-- This file is subject to copyright - contact swampservers@gmail.com for more information.
AddCSLuaFile()
DEFINE_BASECLASS("prop_trash")
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.CanChangeTrashOwner = false

-- AddTrashClass("prop_trash_pillow", "models/swamponions/bodypillow.mdl")
function ENT:OnTakeDamage(dmg)
    if dmg:GetDamageType() == DMG_ACID then
        self:SetNWBool("Hard", true)
    end
end

function ENT:GetHardened()
    return self:GetNWBool("Hard", false)
end

function ENT:SetupDataTables()
    BaseClass.SetupDataTables(self, true)
end

function ENT:Initialize()
    self:SetModel("models/swamponions/bodypillow.mdl")
    BaseClass.Initialize(self, true)
end

function ENT:Use(ply)
    if self.REMOVING then return end

    if self:IsUnTaped() then
        if ply:HasWeapon("weapon_bodypillow") then
            ply:PickupObject(self)
            ply:Notify("You already have one of these in your inventory!")
        else
            local wep = ply:Give("weapon_bodypillow")
            ply:SelectWeapon("weapon_bodypillow")
            wep:SetNWBool("Hard", self:GetHardened())
            local pos, ang = WorldToLocal(self:GetPos(), self:GetAngles(), ply:EyePos(), ply:EyeAngles())
            wep.droppos = pos
            wep.dropang = ang

            if ang:Right().x > 0 then
                wep:SetNWBool('flip', true)
            end

            local url, owner = self:GetWebMatInfo()
            wep:SetWebMatInfo(url, owner)
            self.REMOVING = true
            self:Remove()
        end
    end
end

function ENT:Tape()
end
-- function ENT:Draw()
--     local url, own = self:GetImgur()
--     if not url and self:GetHardened() then
--         url = "cogLTj5.png" -- the default texture, hacky solution
--     end
--     --HACK to not load on painted things
--     if url and self:GetMaterial() ~= "phoenix_storms/gear" then
--         render.MaterialOverride(WebMaterial({
--             id = url,
--             owner = own,
--             pos = self:GetPos(),
--             nsfw="?",
--             stretch = true,
--             params = self:GetHardened() and HardenedPillowArgs(util.CRC((self:GetOwnerID() or "") .. url)) or nil
--         }))
--     end
--     if self:GetHardened() then
--         -- local m = self:GetModel()
--         -- self:SetModel("models/error.mdl")
--         -- self:SetModel(m)
--         bodypillow_unjiggle(self)
--     end
--     BaseClass.Draw(self) --, true)
--     if url then
--         render.MaterialOverride()
--     end
-- end
