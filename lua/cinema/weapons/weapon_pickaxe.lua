-- This file is subject to copyright - contact swampservers@gmail.com for more information.
SWEP.PrintName = "Pickaxe"
SWEP.DrawAmmo = false
SWEP.ViewModelFOV = 85
SWEP.Slot = 0
SWEP.SlotPos = 2
SWEP.Purpose = "Mine craft"
SWEP.Instructions = "Primary: Mine\nSecondary: Craft"
SWEP.ViewModel = Model("models/staticprop/props_mining/pickaxe01.mdl")
SWEP.WorldModel = Model("models/staticprop/props_mining/pickaxe01.mdl")
SWEP.Primary.Automatic = true
SWEP.SWINGINTERVAL = 0.3
SWEP.TARGETDISTANCE = 120
local DIAMONDMAT = Material("models/props_mining/pickaxe01_diamond")

function SWEP:Initialize()
    self:SetHoldType("melee2")
end

if CLIENT then
    MININGCRACKMATERIALS = {}

    for k = 1, 10 do
        table.insert(MININGCRACKMATERIALS, CreateMaterial("mining_crack_" .. tostring(k), "UnlitGeneric", {
            ["$basetexture"] = "swamponions/meinkraft/cracks",
            ["$alphatest"] = 1,
            -- ["$allowalphatocoverage"] = 1,
            ["$alphatestreference"] = 0.38 - 0.035 * k,
        }))
    end
end

hook.Add("PostDrawTranslucentRenderables", "DrawPickaxeBlockMarker", function(depth, sky)
    if sky or depth then return end

    if IsValid(Me) then
        local wep = Me:GetActiveWeapon()

        if IsValid(wep) and wep:GetClass():StartWith("weapon_pickaxe") then
            local x, y, z = wep:GetTargetingBlock()

            if x then
                render.DepthRange(0, 0.9998)
                render.DrawWireframeBox(cvx_to_game_coord_vec(Vector(x, y, z)), Angle(0, 0, 0), Vector(0, 0, 0), Vector(1, 1, 1) * CVX_SCALE, Color(0, 0, 0), true)
                render.DepthRange(0, 1)
            end

            local hb = wep.HitBlock --wep:GetNWVector("HitBlock",nil)

            if hb and cvx_in_world(hb.x, hb.y, hb.z) and cvx_get_vox_solid(hb.x, hb.y, hb.z) then
                local hl = wep.HitBlockHealth or 1 --wep:GetNWFloat("HitBlockHealth",1)
                hl = math.min(math.ceil((1 - hl) * 10), 10)

                if hl > 0 then
                    render.SetMaterial(MININGCRACKMATERIALS[hl])
                    render.DepthRange(0, 0.9998)
                    render.DrawBox(cvx_to_game_coord_vec(Vector(hb.x, hb.y, hb.z)), Angle(0, 0, 0), Vector(0, 0, 0), Vector(1, 1, 1) * CVX_SCALE, Color(0, 0, 0), true)
                    render.DepthRange(0, 1)
                end
            end
        end
    end
end)

function SWEP:GetTargetingBlock()
    local tr = util.TraceLine({
        start = self.Owner:EyePos(),
        endpos = self.Owner:EyePos() + self.Owner:EyeAngles():Forward() * self.TARGETDISTANCE,
        filter = function(ent)
            if ent:GetClass() == "cvx_leaf" then return true end
        end,
        --ignoreworld=false,
        mask = MASK_ALL,
        collisiongroup = COLLISION_GROUP_PLAYER,
    })

    if tr.Hit then return cvx_get_trace_hit_vox(tr) end -- else -- 	return cvx_get_nearest_solid_vox(self.Owner:EyePos() + self.Owner:EyeAngles():Forward() * 80, true)
end

function cvx_player_can_edit_vox(builder, x, y, z)
    return not cvx_is_protected_spot(x, y, z, builder)
end

function cvx_is_protected_spot(x, y, z, builder)
    if builder then
        builder = builder:SteamID()
    end

    local pt = cvx_to_game_coord_vec(Vector(x + 0.5, y + 0.5, z + 0.5))

    for k, v in pairs(Ents.prop_trash_zone) do
        if builder ~= v:GetOwnerID() and v:Protects(pt) then return true end
    end

    return false
end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + self.SWINGINTERVAL)
    self.Owner:SetAnimation(PLAYER_ATTACK1)

    if SERVER then
        if not self.Owner:InTheater() then
            sound.Play("weapons/iceaxe/iceaxe_swing1.wav", self.Owner:GetPos(), 60, 100, 0.4)
        end
    end

    if CLIENT and IsFirstTimePredicted() then
        self.swingtime = SysTime()
    end

    -- timer.Simple(self.SWINGINTERVAL/4,function() 
    -- if SERVER then
    if not IsValid(self) or not IsFirstTimePredicted() then return end
    local bullet = {}
    bullet.Num = 1
    bullet.Attacker = self.Owner
    bullet.Src = self.Owner:EyePos() --self.Owner:GetShootPos()
    bullet.Dir = self.Owner:EyeAngles():Forward() --self.Owner:GetAimVector()
    bullet.Distance = self.TARGETDISTANCE
    bullet.Tracer = 0
    bullet.Force = 1
    bullet.Damage = self:IsDiamond() and 2 or 1

    bullet.Callback = function(att, tr, dmginfo)
        local ent = tr.Entity

        if IsValid(ent) then
            if ent:GetClass() == "cvx_leaf" then
                sound.Play("swamponions/pickaxe.wav", ent:GetPos(), 80, 100, 1)
                local x, y, z = cvx_get_trace_hit_vox(tr)

                if x then
                    local ch = 1
                    local hb = self.HitBlock --self:GetNWVector("HitBlock",nil)

                    if hb and hb.x == x and hb.y == y and hb.z == z then
                        -- ch = self:GetNWFloat("HitBlockHealth",1)
                        ch = self.HitBlockHealth or 1
                    end

                    -- todo apply protection field here
                    local dmg = 0.28

                    if cvx_is_protected_spot(x, y, z, self.Owner) then
                        dmg = 0.04
                    end

                    if self:IsDiamond() then
                        dmg = dmg * 2
                    end

                    ch = ch - dmg

                    if self.Owner:GetMoveType() == MOVETYPE_NOCLIP then
                        ch = 0
                    end

                    if ch <= 0 then
                        self.HitBlock = nil --self:SetNWVector("HitBlock", Vector(-1,-1,-1))

                        if SERVER then
                            local idx = cvx_world_index(x, y, z)
                            Minecraft_Mine(idx, self.Owner)

                            if not self.Owner:HasWeapon("cvx_blocks") then
                                self.Owner:Give("cvx_blocks")
                                self.Owner:SetAmmo(0, "blocks")
                            end

                            if self.Owner:GetAmmoCount("blocks") < 100 then
                                self.Owner:GiveAmmo(2, "blocks", true)
                            end
                        end

                        cvx_set_vox(x, y, z, CVX_VALUE_AIR)
                    else
                        self.HitBlock = Vector(x, y, z) --self:SetNWVector("HitBlock", Vector(x,y,z))
                        -- self:SetNWFloat("HitBlockHealth",ch)
                        self.HitBlockHealth = ch --NOT SHARED BECAUSE OF SHITTY PREDICTION
                    end
                end
            end
        end
    end

    self.Owner:FireBullets(bullet)
    -- end
    -- end)
end

function SWEP:SecondaryAttack()
    self:SetNextSecondaryFire(CurTime() + 10)

    if CLIENT then
        RunConsoleCommand("say", "minecraft XD")
    end
end

function SWEP:IsDiamond()
    return false
end

print(1)


function SWEP:DrawWorldModel()
    local ply = self:GetOwner()

    if IsValid(ply) then
        local bn = ply:IsPony() and "LrigScull" or "ValveBiped.Bip01_R_Hand"
        local bon = ply:LookupBone(bn) or 0
        local opos = self:GetPos()
        local oang = self:GetAngles()
        local bp, ba = ply:GetBonePosition(bon)

        if bp then
            opos = bp
        end

        if ba then
            oang = ba
        end

        opos = opos + oang:Right() * 1
        opos = opos + oang:Forward() * 3
        opos = opos + oang:Up() * 8

        if ply:IsPony() then
            opos = opos + oang:Forward() * 4
            opos = opos + oang:Up() * 8
            opos = opos + oang:Right() * -3.5
        end

        oang:RotateAroundAxis(oang:Right(), 180)
        self:SetupBones()
        self:SetModelScale(0.8, 0)
        local mrt = self:GetBoneMatrix(0)

        if mrt then
            mrt:SetTranslation(opos)
            mrt:SetAngles(oang)
            self:SetBoneMatrix(0, mrt)
        end
    end

    if self:IsDiamond() then
        render.MaterialOverride(DIAMONDMAT)
    end

    self:DrawModel()
    render.MaterialOverride()
end

function SWEP:PreDrawViewModel()
    if self:IsDiamond() then
        render.MaterialOverride(DIAMONDMAT)
    end
end

function SWEP:PostDrawViewModel()
    render.MaterialOverride()
end

function SWEP:GetViewModelPosition(pos, ang)
    pos = pos + ang:Right() * 22
    pos = pos + ang:Up() * -30
    pos = pos + ang:Forward() * 25
    local dt = SysTime() - (self.swingtime or 0)
    dt = dt / self.SWINGINTERVAL

    if dt > 1 then
        dt = 0
    end

    dt = math.pow(dt, 0.3)
    dt = 1 - math.cos(dt * 2 * math.pi)
    ang:RotateAroundAxis(ang:Up(), 180)
    ang:RotateAroundAxis(ang:Right(), 30 * dt)

    return pos, ang
end

function SWEP:DrawHUD()
    surface.DrawCircle(ScrW() / 2, ScrH() / 2, 2, Color(0, 0, 0, 100))
    surface.DrawCircle(ScrW() / 2, ScrH() / 2, 1, Color(255, 255, 255, 100))
    local ptlrp = CurTime() - pickaxepointtime

    if ptlrp < 0.9 then
        draw.DrawText("+" .. tostring(pickaxepointamount), "TargetID", ScrW() * 0.5 + pickaxepointdirx * ptlrp * 100, ScrH() * 0.5 - (50 + ptlrp * 100), Color(255, 200, 50, 255 * (0.9 - ptlrp)), TEXT_ALIGN_CENTER)
    end
end

if CLIENT then
    pickaxepointtime = 0
    pickaxepointamount = 0
    pickaxepointdirx = 0

    net.Receive("PickaxePoints", function()
        pickaxepointtime = CurTime()
        pickaxepointamount = net.ReadInt(16)
        pickaxepointdirx = math.Rand(-0.4, 0.4)
    end)
end
