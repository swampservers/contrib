-- This file is subject to copyright - contact swampservers@gmail.com for more information.
include("shared.lua")
SWEP.Instructions = "WASD: Move\nSpace: Jump\nCtrl: Brake\nLMB: Hamster noises"
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.AlwaysThirdPerson = true

--NOMINIFY
function SWEP:Move(ply, mv)
    -- bug when fullupdate happens, it causes the callback to go away but not the value set
    if not ply.AddedHamsterBallBoneCallback then
        ply.AddedHamsterBallBoneCallback = true

        ply:AddCallback("BuildBonePositions", function(ent, nb)
            BuildHamsterBallBones(ent, nb)
        end)
    end

    return true
end

--         -- local matrix = e:GetBoneMatrix(0):GetTranslation()
--         -- local pos = matrix
--         -- ply:SetRenderOrigin(e:GetPos())
--         -- mv:SetVelocity( e:GetVelocity()) 
--         -- e:SetRenderOrigin() --mv:GetOrigin())
--         -- mv:SetOrigin( e:GetBoneMatrix(0):GetTranslation() )
--         -- mv:SetVelocity(Vector(0,0,0))
--         -- mv:SetOrigin(e:GetRenderOrigin())
--         -- mv:SetOrigin(e:GetNetworkOrigin())
--         -- ply:SetParent()
--         -- ply:SetLocalPos(Vector(0,0,0))
--         -- ply.CalcAbsolutePosition = function(ply, pos,ang)
--         --     local e = ply:GetNWEntity("MoveTie")
--         --     if not IsValid(e) then return end
--         --     -- ply:SetRenderOrigin(e:GetBoneMatrix(0):GetTranslation())
--         --     -- return e:GetBoneMatrix(0):GetTranslation(), ang
--         -- end
--         -- ply:SetPredictable(true)
--         ply.RenderOverride = function(ply, mode)
--             local e = ply:GetNWEntity("MoveTie")
--             -- -- if not IsValid(e) then return end
--             -- ply:SetRenderOrigin(Vector(0,0,0)) --e:GetBoneMatrix(0):GetTranslation())
--             -- -- return e:GetBoneMatrix(0):GetTranslation(), ang
--             -- ply:InvalidateBoneCache()
--             -- ply:SetupBones()
--             ply:DrawModel()
--         end
-- function GetHamsterBallBones(ent,nb)
--     HAMSTERBALLPOS = ent:GetBoneMatrix(0):GetTranslation()
-- end
function BuildHamsterBallBones(ent, nb)
    local e = ent:GetNWEntity("HamsterBall")
    if not IsValid(e) then return end -- if ent.HamsterBallScaled then --     ent.HamsterBallScaled = false --     ent:SetModelScale(1) -- end
    -- if not ent.HamsterBallScaled then
    --     ent.HamsterBallScaled = true
    --     ent:SetModelScale(0.5)
    -- end
    -- if not e.AddedHamsterBallBoneCallback then
    --     e.AddedHamsterBallBoneCallback = true
    --     e:AddCallback("BuildBonePositions", function(b, nb)
    --         GetHamsterBallBones(b, nb)
    --     end)
    -- end
    -- if not HAMSTERBALLPOS then return end
    -- local move = ent:GetBoneMatrix(0):GetTranslation()- e:GetBoneMatrix(0):GetTranslation()
    local move = ent:GetBoneMatrix(0):GetTranslation() - e:GetPos()

    -- local move = e:GetNetworkOrigin() - e:GetPos()
    -- local move = ent:GetPos() - e:GetPos()
    -- local move = e:GetNetworkOrigin() - ent:GetPos() 
    -- print("MOVE", move)
    for i = 0, nb - 1 do
        -- local p, a = ent:GetBonePosition(i)
        -- ent:SetBonePosition(i, p - move, a)
        local m = ent:GetBoneMatrix(i)

        -- m:Translate(move)
        if m then
            m:SetTranslation(m:GetTranslation() - move)
            ent:SetBoneMatrix(i, m)
        end
        -- ent:SetBonePosition(i, e:GetPos() + Vector(0, 0, 20), a)
    end
    -- ent:SetRenderOrigin(Vector(0,0,0))
    -- ent:SetBonePosition(0, Vector(0,0,0),Angle(0,0,0))
end
-- -- IDEA: MATERIAL CRATE WITH WEIRD GLASS ETC
