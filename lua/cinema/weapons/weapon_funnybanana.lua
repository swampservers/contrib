-- This file is subject to copyright - contact swampservers@gmail.com for more information.
DEFINE_BASECLASS("weapon_swamp_base")
SWEP.PrintName = "Funny Picture of a Banana"
SWEP.Purpose = "A hilarious picture. Look at it!"
SWEP.Author = "John J. Callanan"
SWEP.Instructions = "Left Click: Laugh\nRight Click: Laugh Hard"
SWEP.ViewModel = "models/chev/bananaframe.mdl"
SWEP.WorldModel = "models/chev/bananaframe.mdl"

local cartoonsnd = {"funnysounds01.ogg", "funnysounds02.ogg"}

function SWEP:PrimaryAttack()
    local owner = self:GetOwner()

    if CLIENT then
        if owner:IsPony() then
            RunConsoleCommand("act", "dance")
        else
            RunConsoleCommand("act", "laugh")
        end

        --random chance to banana-ify the screen
        if math.random(0, 10) < 3 then
            RunConsoleCommand("pp_texturize", "pp/texturize/banana.png")

            timer.Simple(6, function()
                RunConsoleCommand("pp_texturize", "")
            end)
        end
    end

    if SERVER then
        owner:Say("hahaha! what a funny picture!")

        for _, owner in player.Iterator() do
            if owner ~= owner and owner:GetPos():Distance(owner:GetPos()) < 200 then
                timer.Simple(math.Rand(0, 1.5), function()
                    if IsValid(owner) then
                        owner:ExtEmitSound("weapon_funnybanana/hahaha.ogg", {
                            level = 70
                        }, {
                            pitch = math.random(90, 110)
                        })
                    end
                end)
            end
        end
    end

    owner:ExtEmitSound("weapon_funnybanana/hahaha_funnypicture.ogg", {
        shared = true,
        level = 70,
        channel = CHAN_WEAPON
    })

    timer.Simple(2, function()
        if IsValid(self) and IsValid(owner) then
            self:ExtEmitSound("weapon_funnybanana/audiencelaugh.ogg", {
                shared = true,
                level = 65,
                volume = 0.7,
                channel = CHAN_AUTO
            })

            self:ExtEmitSound("weapon_funnybanana/slipsoundc.ogg", {
                shared = true,
                level = 65,
                volume = 0.5,
                channel = CHAN_AUTO
            })

            self:ExtEmitSound("weapon_funnybanana/" .. cartoonsnd[math.random(#cartoonsnd)], {
                shared = true,
                level = 65,
                volume = 0.4,
                channel = CHAN_AUTO
            })

            self:ExtEmitSound("airhorn/honk1.ogg", {
                shared = true,
                level = 65,
                volume = 0.5,
                channel = CHAN_AUTO
            })
        end
    end)

    self:SetNextPrimaryFire(CurTime() + 10)
end

--Same as primary attack, but you laugh so hard you die (because the picture is very funny)
function SWEP:SecondaryAttack()
    self:PrimaryAttack()

    if SERVER then
        self:TimerSimple(5, function()
            local owner = IsValid(self) and self:GetOwner()

            if IsValid(owner) and owner:Alive() and owner:GetLocationName() ~= "Treatment Room" then
                owner:Kill()
                owner:ChatPrint("[red]you died after laughing too hard")
            end
        end)
    end

    self:SetNextSecondaryFire(CurTime() + 10)
end

if CLIENT then
    function SWEP:DrawWorldModel()
        local owner = self:GetOwner()

        if IsValid(owner) then
            local bn = owner:IsPony() and "LrigScull" or "ValveBiped.Bip01_R_Hand"
            local bon = owner:LookupBone(bn) or 0
            local opos = self:GetPos()
            local oang = self:GetAngles()
            local bp, ba = owner:GetBonePosition(bon)

            if bp then
                opos = bp
            end

            if ba then
                oang = ba
            end

            if owner:IsPony() then
                opos = opos + oang:Forward() * 11
                opos = opos + oang:Up() * -0
                opos = opos + oang:Right() * 0
                oang:RotateAroundAxis(oang:Forward(), 90)
            else
                opos = opos + oang:Right() * 2.5
                opos = opos + oang:Forward() * 4
                opos = opos + oang:Up() * 1
                oang:RotateAroundAxis(oang:Forward(), 180)
                oang:RotateAroundAxis(oang:Up(), 90)
            end

            self:SetupBones()
            self:SetModelScale(0.6, 0)
            local mrt = self:GetBoneMatrix(0)

            if mrt then
                mrt:SetTranslation(opos)
                mrt:SetAngles(oang)
                self:SetBoneMatrix(0, mrt)
            end
        end

        self:DrawModel()
    end

    function SWEP:GetViewModelPosition(p, a)
        local bpos = Vector(15, 30, -15)
        local bang = Vector(-20, 125, 20)
        local right = a:Right()
        local up = a:Up()
        local forward = a:Forward()
        a:RotateAroundAxis(right, bang.x)
        a:RotateAroundAxis(up, bang.y)
        a:RotateAroundAxis(forward, bang.z)
        p = p + bpos.x * right
        p = p + bpos.y * forward
        p = p + bpos.z * up

        return p, a
    end
end

function SWEP:Deploy()
    BaseClass.Deploy(self)
    self:SetHoldType("pistol")

    return true
end

function SWEP:Initialize()
    return true
end
