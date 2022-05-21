-- This file is subject to copyright - contact swampservers@gmail.com for more information.
include("shared.lua")

surface.CreateFont("CSKillIcons", {
    font = "csd",
    size = ScreenScale(30),
    weight = 500,
    additive = true
})

--NOMINIFY
killicon.AddFont("weapon_slitter", "CSKillIcons", "j", Color(255, 80, 0, 255))
local BloodMaterials = {}

for k = 1, 6 do
    local m = Material("decals/blood" .. tostring(k) .. "_subrect")
    table.insert(BloodMaterials, m)
end

net.Receive("SlitThroatneck", function(len)
    local ent = net.ReadEntity()
    local ply = net.ReadEntity()
    local pos = net.ReadVector()
    local norm = net.ReadVector()

    for i = 1, 10 do
        timer.Simple((i - 1) * 0.015, function()
            local add = VectorRand()
            add.z = (add.z - 0.5) * 0.75
            add = 120 * add

            local tr = util.TraceLine({
                start = pos,
                endpos = pos + add,
                mask = MASK_NPCWORLDSTATIC
            })

            if tr.Hit then
                util.DecalEx(BloodMaterials[math.random(#BloodMaterials)], tr.Entity, tr.HitPos, tr.HitNormal, Color(255, 255, 255, 255), 1, 1)
            end
        end)
    end

    local function blood(p, n, s)
        local effectdata = EffectData()
        effectdata:SetOrigin(p)
        effectdata:SetNormal(n)
        effectdata:SetMagnitude(1)
        effectdata:SetScale(s)
        effectdata:SetColor(BLOOD_COLOR_RED)
        effectdata:SetFlags(3)
        util.Effect("bloodspray", effectdata, true, true)
    end

    if ply ~= Me then
        sound.Play("Weapon_Knife.Hit", pos, 80, 100, 1)
        local effectdata = EffectData()
        blood(pos, norm, 15)
    end

    for i = 1, 15 do
        local nextscale = 14 - (i - 1) * 0.6

        timer.Simple(0.15 * i, function()
            if IsValid(ent) and IsValid(ent:GetRagdollEntity()) then
                blood(ent:GetRagdollEntity():GetPos(), Vector(0, 0, 1), nextscale)
            end
        end)
    end
end)


function SWEP:DrawHUD()
    surface.DrawCircle(ScrW() / 2, ScrH() / 2, 2, Color(0, 0, 0, 100))
    surface.DrawCircle(ScrW() / 2, ScrH() / 2, 1, Color(255, 255, 255, 150))
    surface.SetDrawColor(Color(255, 255, 255, 150))
    local hitplayer = self:TargetedPlayer()

    if hitplayer and (hitplayer ~= justslitplayer or CurTime() - lastkillslit >= 0.35) then
        surface.DrawCircle(ScrW() / 2, ScrH() / 2, 16, Color(0, 0, 0, 100))
        surface.DrawCircle(ScrW() / 2, ScrH() / 2, 15, Color(255, 255, 255, 150))
    end

    local killeffect = math.min(CurTime() - lastkillslit, .15) / .15

    if killeffect < 0.98 then
        local size = Lerp(killeffect, 16, 48)
        surface.DrawCircle(ScrW() / 2, ScrH() / 2, size, Color(255, 255, 255, Lerp((killeffect - 0.5) * 2, 100, 0)))
        surface.DrawCircle(ScrW() / 2, ScrH() / 2, size - 1, Color(255, 255, 255, Lerp((killeffect - 0.5) * 2, 150, 0)))
    end

    surface.SetDrawColor(Color(255, 255, 255, 255))
end