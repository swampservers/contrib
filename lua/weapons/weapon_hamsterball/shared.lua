-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
SWEP.PrintName = "Hamster Ball (WIP)"
SWEP.Slot = 4
SWEP.ViewModel = Model("")
SWEP.WorldModel = Model("")

--NOMINIFY
function SWEP:PrimaryAttack()
    if CLIENT then return end

    -- self:ExtEmitSound("npc/headcrab/attack1.wav", {
    --     speech = 0.7,
    --     shared = true
    -- })
    self:ExtEmitSound(table.Random(headcrabsounds), {
        speech = 0.7,
    })
    -- shared = true
end

function SWEP:SecondaryAttack()
    if CLIENT then return end

    -- self:ExtEmitSound("npc/barnacle/barnacle_gulp1.wav", {
    --     speech = 0.7,
    --     shared = true
    -- })
    self:ExtEmitSound(table.Random(headcrabsounds3), {
        speech = 0.7,
    })
    -- shared = true
end
