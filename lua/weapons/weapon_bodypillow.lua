-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
AddCSLuaFile()

if CLIENT then
    CreateClientConVar("bodypillow_imgur", "", true, true)
end

SWEP.PrintName = "Body Pillow"
SWEP.Purpose = "Gives the feeling of companionship"
SWEP.Instructions = "Left click: boof\nRight click: drop\nReload: customize"
SWEP.Slot = 1
SWEP.SlotPos = 99
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.ViewModelFOV = 85
SWEP.ViewModel = Model("models/swamponions/bodypillow.mdl")
SWEP.WorldModel = Model("models/swamponions/bodypillow.mdl")
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.Damage = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Damage = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

function SWEP:GetHardened()
    return self:GetNWBool("Hard", false)
    -- return self.Owner:SteamID() == "STEAM_0:0:38422842"
end

function SWEP:TimeScale()
    -- return self:GetNWBool("Hard", false)
    return self:GetHardened() and 2 or 1
end

function bodypillow_unjiggle(self)
    if not self.Unjiggled then
        self:AddCallback("BuildBonePositions", function(e, nb)
            PILLOW_UNJIGGLE(e, nb)
        end)

        self.Unjiggled = true
    end
end

function PILLOW_UNJIGGLE(self, nb)
    pcall(function()
        --or (self.wep and not self.wep:GetHardened()) 
        if self:GetModel()~="models/swamponions/bodypillow.mdl" then return end --it got set on the viewmodel entity
        for i = 0, nb - 1 do
            local i2 = i < 3 and i or 2 - i
            local a = i == 0 and Angle(0, 0, 90) or (i < 3 and Angle() or Angle(0, 0, 180))
            local ro, ra = self:GetRenderOrigin(), self:GetRenderAngles()

            if self:GetClass()=="prop_trash_pillow" then ro,ra = self:GetPos(),self:GetAngles() end

            if not ro then
                if not IsValid(self.wep) or not IsValid(self.wep.Owner) then return end
                ro, ra = self.wep:GetViewModelPosition(self.wep.Owner:EyePos(), self.wep.Owner:EyeAngles())
            end

            self:SetBonePosition(i, LocalToWorld(Vector(0, 0, i2 * 10), a, ro, ra))
        end
    end)
end

function SWEP:DrawWorldModel()
    local ply = self:GetOwner()

    if (IsValid(ply)) then
        local bn = ply:IsPony() and "Lrig_LEG_FR_Humerus" or "ValveBiped.Bip01_R_Hand"
        local bon = ply:LookupBone(bn) or 0
        local opos = self:GetPos()
        local oang = self:GetAngles()
        local bp, ba = ply:GetBonePosition(bon)

        if (bp) then
            opos = bp
        end

        if (ba) then
            oang = ba
        end

        if ply:IsPony() then
            local pf = self:Boof()
            opos = opos + oang:Right() * (3 - (pf * 7))
            opos = opos + oang:Forward() * -8
            opos = opos + oang:Up() * (8 - (pf * 4))
            oang:RotateAroundAxis(oang:Forward(), -90 + (pf * 120))
            oang:RotateAroundAxis(oang:Right(), 100)
            oang:RotateAroundAxis(oang:Forward(), 5 + (pf * -30))
            oang:RotateAroundAxis(oang:Up(), (self:GetNWBool('flip') and 0 or 180))
        else
            opos = opos + oang:Right() * -2
            opos = opos + oang:Forward() * 4
            opos = opos + oang:Up() * 2
            oang:RotateAroundAxis(oang:Forward(), 30)
            oang:RotateAroundAxis(oang:Right(), 170)
            oang:RotateAroundAxis(oang:Up(), 60 + (self:GetNWBool('flip') and 180 or 0))
        end

        self:SetRenderOrigin(opos)
        self:SetRenderAngles(oang)
    end

    self:SetupBones()

    local url, own = self:GetImgur()

    if not url and self:GetHardened() then
        url = "cogLTj5.png" -- the default texture, hacky solution
    end
    
    if url then
        render.MaterialOverride(ImgurMaterial({
            id = url,
            owner = own,
            pos = self:GetPos(),
            stretch = true,
            params=self:GetHardened() and HardenedPillowArgs(util.CRC(  (own~="" and own or (IsValid(self.Owner) and self.Owner:SteamID() or ""))..url  )) or nil
        }))
    end

    if self:GetHardened() then
        bodypillow_unjiggle(self)
    end

    self:DrawModel()

    if url then
        render.MaterialOverride()
    end
end

function HardenedPillowArgs(hsh)
    return string.format([[{["$detail"]="decals/decalstain%03da",["$detailscale"]="1",["$detailblendfactor"]="2"}]],(hsh%15)+1)
end

function SWEP:PreDrawViewModel(vm, ply, wep)
    local url, own = self:GetImgur()

    if not url and self:GetHardened() then
        url = "cogLTj5.png" -- the default texture, hacky solution
    end

    if url then
        render.MaterialOverride(ImgurMaterial({
            id = url,
            owner = own,
            pos = self:GetPos(),
            stretch = true,
            params=self:GetHardened() and HardenedPillowArgs(util.CRC(  (own~="" and own or (IsValid(self.Owner) and self.Owner:SteamID() or ""))..url  )) or nil
        }))
    end

    if self:GetHardened() then
        vm.wep = self
        bodypillow_unjiggle(vm)
    end
end

function SWEP:PostDrawViewModel()
    render.MaterialOverride()
end

function SWEP:GetViewModelPosition(pos, ang)
    --local of,_ = LocalToWorld(self.Owner:GetCurrentViewOffset(),Angle(0,0,0),Vector(0,0,0),ang)
    --pos = pos - (of*0.5)
    pos = pos - (self.Owner:GetCurrentViewOffset() * 0.5)
    local pf = self:Boof()
    local v = ang:Forward()

    if math.abs(v.z) == 1 then
        v = -ang:Up()
    end

    v.z = 0
    ang = v:Angle()
    local angr = ang:Right()
    local angu = ang:Up()
    pos = pos + ang:Right() * (15 - (pf * 15))
    pos = pos + ang:Up() * (10 + (pf * 6))
    pos = pos + ang:Forward() * (24 + (pf * 4))
    ang:RotateAroundAxis(ang:Up(), self:GetNWBool('flip') and 90 or -90)
    ang:RotateAroundAxis(ang:Forward(), 0)
    ang:RotateAroundAxis(ang:Up(), ((1 - pf) * -50) + (pf * 60))
    ang:RotateAroundAxis(angr, pf * -70)
    ang:RotateAroundAxis(angu, pf * 40)
    --ang:RotateAroundAxis(ang:Forward(), pf*-40)
    --ang:RotateAroundAxis(ang:Right(), pf*80)

    return pos, ang
end

function SWEP:Initialize()
    self:SetHoldType("slam")
end

if SERVER then
    util.AddNetworkString("pillowboof")
    util.AddNetworkString("SetMyBodyPillow")

    net.Receive("SetMyBodyPillow", function(len, ply)
        local url = net.ReadString()

        if (ply.SetPillowTimeout or 0) > CurTime() - 2 then
            ply:Notify("Wait...")

            return
        end

        ply.SetPillowTimeout = CurTime()
        local wep = ply:GetWeapon("weapon_bodypillow")

        if IsValid(wep) then
            url = SanitizeImgurId(url)
            wep:SetImgur(url, ply:SteamID())

            if url then
                for k, v in pairs(ents.FindByClass("prop_trash_pillow")) do
                    local turl, own = v:GetImgur()

                    if own == ply:SteamID() and turl ~= url then
                        v:SetImgur()
                        ply:Notify("Can't have different custom pillows")
                    end
                end
            end
        end
    end)
else
    local emitter = ParticleEmitter(Vector(0, 0, 0))

    net.Receive("pillowboof", function()
        local pos = net.ReadVector()
        if pos:Distance(LocalPlayer():EyePos()) > 1200 then return end
        if not emitter then return end

        for i = 1, math.random(2, 12) do
            local particle = emitter:Add("particle/pillow-feather", pos + (VectorRand() * 10))

            if particle then
                particle:SetColor(255, 255, 255, 255)
                particle:SetVelocity(VectorRand():GetNormalized() * 15)
                particle:SetGravity(Vector(0, 0, -20))
                particle:SetLifeTime(0)
                particle:SetDieTime(math.Rand(5, 10))
                particle:SetStartSize(math.Rand(2, 6))
                particle:SetEndSize(0)
                particle:SetStartAlpha(math.random(200, 250))
                particle:SetEndAlpha(0)
                particle:SetCollide(true)
                particle:SetBounce(0.25)
                particle:SetRoll(math.pi * math.Rand(0, 1))
                particle:SetRollDelta(math.pi * math.Rand(-2, 2))
            end
        end
    end)
end

function SWEP:PrimaryAttack()
    if CLIENT and not IsFirstTimePredicted() then return end
    self:SetNextPrimaryFire(CurTime() + (0.6 / self:TimeScale()))

    --if CLIENT then self.localpf = RealTime() end
    if SERVER then
        if not self.Owner:IsPony() then
            setPlayerGesture(self.Owner, GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE, true)
        end

        timer.Simple(0.1 / self:TimeScale(), function()
            if IsValid(self) and IsValid(self.Owner) then
                local boof = self.Owner:EyePos() + (self.Owner:EyeAngles():Forward() * 50)
                local aim = self.Owner:EyeAngles():Forward()

                if math.abs(aim.z) == 1 then
                    aim = -self.Owner:EyeAngles():Up()
                end

                aim.z = 0
                aim:Normalize()
                aim.z = 0.7
                aim = aim * 30

                for k, v in pairs(player.GetAll()) do
                    local bcenter = v:LocalToWorld(v:OBBCenter())

                    if v ~= self.Owner and v:Alive() and bcenter:Distance(boof) < (self:GetHardened() and 100 or 70) then
                        bcenter = bcenter + (VectorRand() * 16)
                        bcenter.z = bcenter.z + 8
                        local sound2play = self:GetHardened() and "physics/plastic/plastic_barrel_impact_hard" .. tostring(math.random(1, 3)) .. ".wav" or "bodypillow/hit" .. tostring(math.random(1, 2)) .. ".wav"
                        sound.Play(sound2play, bcenter, 80, math.random(100, 115) + (self:GetHardened() and -20 or 0), 1)
                        net.Start("pillowboof")
                        net.WriteVector(bcenter)
                        net.SendPVS(bcenter)

                        if (not Safe(v)) and (not v:InVehicle()) and not (IsValid(v:GetActiveWeapon()) and v:GetActiveWeapon():GetClass()=="weapon_golfclub") then
                            if v:IsOnGround() then
                                v:SetPos(v:GetPos() + Vector(0, 0, 2))
                            end
                            local aimvel = aim

                            if self:GetHardened() then
                                aimvel = aim * 4
                                local dmg = DamageInfo()
                                dmg:SetAttacker(self.Owner)
                                dmg:SetInflictor(self)
                                dmg:SetDamage(2)
                                dmg:SetDamagePosition(v:LocalToWorld(v:OBBCenter()))
                                dmg:SetDamageType(DMG_CLUB)
                                dmg:SetDamageForce(aimvel * 30)
                                v:TakeDamageInfo(dmg)
                            end

                            v:SetVelocity(aimvel)
                        end
                    end
                end
            end
        end)
    end

    self:SetNWFloat("pf", CurTime())
    self:EmitSound("bodypillow/swing" .. tostring(math.random(1, 2)) .. ".wav", 60, math.random(100, 115), 0.1)
end

function SWEP:Boof()
    local pf = self:GetNWFloat("pf")
    local ct = CurTime()

    if self.localpf then
        pf = self.localpf
        ct = RealTime()
    end

    pf = pf * self:TimeScale()
    ct = ct * self:TimeScale()

    return math.max(0, math.min((ct - pf) * 5, ((pf + 1) - ct) / 0.8))
end

function SWEP:SecondaryAttack()
    if SERVER then
        if self.REMOVING then return end

        if not CannotMakeTrash(self.Owner) then
            local e = ents.Create("prop_trash_pillow")
            e:SetNWBool("Hard", self:GetHardened())
            local pos, ang = LocalToWorld(self.droppos or Vector(40, 0, 0), self.dropang or Angle(10, 240, -10), self.Owner:EyePos(), self.Owner:EyeAngles())
            local fwdv = self.Owner:EyeAngles():Forward() * 10
            local p2 = pos + fwdv

            local tr = util.TraceLine({
                start = self.Owner:EyePos(),
                endpos = p2,
                mask = MASK_SOLID_BRUSHONLY
            })

            if tr.Hit then
                p2 = tr.HitPos
            end

            pos = p2 - fwdv
            e:SetPos(pos)
            e:SetAngles(ang)
            e:SetOwnerID(self.Owner:SteamID())
            e:Spawn()
            e:Activate()
            e:GetPhysicsObject():SetVelocity(self.Owner:GetVelocity())
            local img, own = self:GetImgur()
            e:SetImgur(img, own)
            self.REMOVING = true
            self:Remove()
        else
            self.Owner:Notify("Can't drop right now, too much on map")
        end
    end
end

function SWEP:OnDrop()
    self:SecondaryAttack()

    if not self.REMOVING then
        self:Remove()
    end
end

function SWEP:OwnerChanged()
    if SERVER and IsValid(self.Owner) then
        self:SetImgur(SanitizeImgurId(self.Owner:GetInfo("bodypillow_imgur")) or "", self.Owner:SteamID())
    end
end

function SWEP:Reload()
    if CLIENT then
        if ValidPanel(self.OPENREQUEST) then return end
        local curl, cown = self:GetImgur()

        self.OPENREQUEST = Derma_StringRequest("Custom Waifu", "Post an imgur direct URL, such as:\nhttps://i.imgur.com/4aIcUgd.jpg\nLeft half is front of pillow, right half is back.", curl, function(url)
            url = SanitizeImgurId(url) or ""
            RunConsoleCommand("bodypillow_imgur", url)
            net.Start("SetMyBodyPillow")
            net.WriteString(url)
            net.SendToServer()
        end)
    end
end