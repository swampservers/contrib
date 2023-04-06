-- This file is subject to copyright - contact swampservers@gmail.com for more information.
net.Receive("BoneModReset", function()
    local v = net.ReadEntity()

    timer.Simple(1, function()
        if not IsValid(v) then return end

        --(v:GetBoneCount()-1) do
        for n = 0, 128 do
            --if v:GetManipulateBoneAngles(n)~=Angle(0,0,0) then
            v:ManipulateBoneAngles(n, Angle(0, 0, 0))
            --if v:GetManipulateBonePosition(n)~=Vector(0,0,0) then 
            --v:ManipulateBonePosition(n,Vector(0,0,0))
            --if v:GetManipulateBoneScale(n)~=Vector(1,1,1) then 
            --v:ManipulateBoneScale(n,Vector(1,1,1))
            --NOT DOING THIS CUZ POINTSHOP
        end

        v:SetModel(v:GetModel())
    end)
end)

net.Receive("BoneSequence", function()
    local ply = net.ReadEntity()
    local command = net.ReadString()

    if command == "dab" then
        timer.Simple(1, function()
            timer.Simple(0.1, function()
                setDabEmotePower(ply, 0.25)
            end)

            timer.Simple(0.2, function()
                setDabEmotePower(ply, 0.5)
            end)

            timer.Simple(0.3, function()
                setDabEmotePower(ply, 0.75)
            end)

            timer.Simple(0.4, function()
                setDabEmotePower(ply, 1)
            end)
        end)

        timer.Simple(2.6, function()
            timer.Simple(0.1, function()
                setDabEmotePower(ply, 0.75)
            end)

            timer.Simple(0.2, function()
                setDabEmotePower(ply, 0.5)
            end)

            timer.Simple(0.3, function()
                setDabEmotePower(ply, 0.25)
            end)

            timer.Simple(0.4, function()
                setDabEmotePower(ply, 0)
            end)
        end)
    end

    if command == "tip" then
        timer.Simple(0.2, function()
            timer.Simple(0.1, function()
                setTipEmotePower(ply, 0.25)
            end)

            timer.Simple(0.2, function()
                setTipEmotePower(ply, 0.5)
            end)

            timer.Simple(0.3, function()
                setTipEmotePower(ply, 0.75)
            end)

            timer.Simple(0.4, function()
                setTipEmotePower(ply, 1)
            end)
        end)

        timer.Simple(1.5, function()
            timer.Simple(0.1, function()
                setTipEmotePower(ply, 0.75)
            end)

            timer.Simple(0.2, function()
                setTipEmotePower(ply, 0.5)
            end)

            timer.Simple(0.3, function()
                setTipEmotePower(ply, 0.25)
            end)

            timer.Simple(0.4, function()
                setTipEmotePower(ply, 0)
            end)
        end)
    end
end)

function setTipEmotePower(ply, mult)
    if not IsValid(ply) then return end
    if not ply:LookupBone("ValveBiped.Bip01_L_Upperarm") then return end
    ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_L_Upperarm"), Angle(60 * mult, -10 * mult, 40 * mult), "tip")
end

function setDabEmotePower(ply, mult)
    if not IsValid(ply) then return end
    if not ply:LookupBone("ValveBiped.Bip01_L_Upperarm") then return end
    ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Upperarm"), Angle(110 * mult, 0 * mult, 0 * mult), "dab")
    if not ply:LookupBone("ValveBiped.Bip01_Head1") then return end
    ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_Head1"), Angle(0 * mult, 0 * mult, 90 * mult), "dab")
end
