-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
SWEP.PrintName = "Garfield"
SWEP.Purpose = "Eat"
SWEP.Instructions = "Primary: Eat\n\nYou can eat players smaller and slightly larger than you. The bigger you get, the more health you have. To eat larger players, soften them up with weapons first, but be aware that they heal quickly based on size.\n\nR: Leap (costs weight!!)"
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.DrawWeaponInfoBox = true
SWEP.ViewModelFOV = 85
SWEP.ViewModelFlip = false
SWEP.Slot = 0
SWEP.SlotPos = 3
SWEP.Spawnable = false
SWEP.AdminSpawnable = false
SWEP.ViewModel = "models/weapons/c_arms.mdl"
--random model to give it appearance if it is dropped somehow
SWEP.WorldModel = "models/player/pyroteknik/garfield.mdl"
SWEP.Weight = 5
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
local Player = FindMetaTable("Player")
-- hook.Add("PlayerModelChanged", "GarfHead", function(ply, mdl)
--     if mdl:find("garfield.mdl") then
--         local bn = ply:LookupBone("ValveBiped.Bip01_Head1")
--         if bn then
--             ply:ManipulateBoneScale(bn, Vector(1, 1, 1) * 0.9)
--         end
--     end
-- end)
FATTESTCATS = FATTESTCATS or {}

-- table.remove(FATTESTCATS,1)
-- table.remove(FATTESTCATS,1)
-- table.remove(FATTESTCATS,1)
function Player:Obesity()
    return self:GetNWFloat("garfield", 1)
end

function Player:IsJuggernaut()
    return self:GetNWFloat("garfield", 1) > 40
end

function Player:SetObesity(obs)
    if obs == 1 and self:Obesity() == 1 then return end
    self:SetNWFloat("garfield", obs)
    local sc = 1 --self:HasWeapon("weapon_garfield") and 0.55 or 1
    -- if not self:IsBot() then
    self:SetModelScale(self:ObesityScale() * sc)

    -- else
    --     self:SetModelScale(0.75)
    -- end
    if SERVER then
        UpdateViewHeight(self)
    end

    self:SetRunSpeed(1 / self:ObesitySpeedScale(), "garf")
    self:SetWalkSpeed(1 / self:ObesitySpeedScale(), "garf")
    self:SetSlowWalkSpeed(1 / self:ObesitySpeedScale(), "garf")
    local mh = 100 * self:Obesity()
    self:SetMaxHealth(mh)
    self:SetHealth(math.min(self:Health(), mh))
    -- if SERVER then
    --     -- if #FATTESTCATS==0 or FATTESTCATS[1][3]<obs then
    --     --     FATTESTCATS = {{self:Name(), self:SteamID(), obs}}
    --     --     SetG("FATTESTCATS", FATTESTCATS)
    --     -- end
    --     local add = true
    --     local old = util.TableToJSON(FATTESTCATS)
    --     for k, v in pairs(FATTESTCATS) do
    --         if v[2] == self:SteamID() then
    --             v[1] = self:Name()
    --             v[3] = math.max(v[3], obs)
    --             add = false
    --         end
    --     end
    --     if add then
    --         table.insert(FATTESTCATS, {self:Name(), self:SteamID(), obs})
    --     end
    --     table.SortByMember(FATTESTCATS, 3)
    --     while #FATTESTCATS > 5 do
    --         table.remove(FATTESTCATS)
    --     end
    --     if util.TableToJSON(FATTESTCATS) ~= old then
    --         SetG("FATTESTCATS", FATTESTCATS)
    --     end
    --     if not IsValid(CURFATTESTCAT) or CURFATTESTCAT:Obesity() < obs then
    --         CURFATTESTCAT = self
    --         SetG("CURFATTESTCAT", CURFATTESTCAT)
    --     end
    -- end
end

function Player:ObesityScale()
    return math.pow(self:Obesity(), 1 / 3)
end

function Player:ObesitySpeedScale()
    --4)
    return math.pow(self:Obesity(), 1 / 8)
end

hook.Add("PlayerSpawn", "ResetGarfield", function(ply)
    timer.Simple(0, function()
        timer.Simple(0, function()
            ply:SetObesity(1)
        end)
    end)
end)

-- ply:Give("weapon_garfield")
hook.Add("PlayerDeath", "FinishEating", function(vic, inf, att)
    local eater = vic:GetNW2Entity("EATER")

    if IsValid(eater) then
        local vo, ao = vic:Obesity(), eater:Obesity()
        local ratio = 1 --math.min(math.pow(vo / ao, 0.3),1) * 0.9 --math.min(0.7, (vo/ao))

        if ratio < 0.3 then
            if ratio <= 0.1 then
                eater:Notify(">>>>>> Look for larger prey to keep growing! <<<<<<")
            else
                eater:Notify("Look for larger prey to grow faster!")
            end
        end

        if ratio > 0.1 then
            eater:SetObesity(ao + vo * ratio)
        end

        eater:SetHealth(math.min(eater:GetMaxHealth(), eater:Health() + 300)) --   eater:Health() + (eater:GetMaxHealth() - eater:Health()) * (ratio)) --/0.9))
        vic:SetNW2Entity("EATER", nil)
    end
end)

-- if SERVER then
--     timer.Create("GarfieldDecay", 30, 0, function()
--         for k, v in pairs(player.GetAll()) do
--             -- v:SetObesity(math.max(1, v:Obesity() * 0.99))
--         end
--     end)
--     --10
--     timer.Create("GarfieldHeal", 10, 0, function()
--         for k, v in pairs(player.GetAll()) do
--             v:SetHealth(math.min(math.floor(v:Health() + v:GetMaxHealth() * 0.05), v:GetMaxHealth()))
--         end
--     end)
-- end
function SWEP:Deploy()
    self.Owner:SetModel("models/player/pyroteknik/garfield.mdl")
end

function SWEP:Initialize()
    self:SetHoldType("normal")
end

local function issafe(v)
    return v:IsProtected() or (v:InTheater() and v:InVehicle())
end

if SERVER then
    util.AddNetworkString("GarfieldEat")

    net.Receive("GarfieldEat", function(len, owner)
        local self = owner:GetActiveWeapon()
        if not (IsValid(self) and self:GetClass() == "weapon_garfield") then return end
        local ply = len > 0 and net.ReadEntity() or nil

        if IsValid(ply) and self:ValidTarget(ply) then
            self:SetNW2Entity("EATINGp", ply)
            local swsp, wsp, rsp = ply:GetSlowWalkSpeed(), ply:GetWalkSpeed(), ply:GetRunSpeed()

            if swsp > 1 then
                ply.properSWSP = swsp
            end

            if wsp > 1 then
                ply.properWSP = wsp
            end

            if rsp > 1 then
                ply.properRSP = rsp
            end

            ply:SetSlowWalkSpeed(1)
            ply:SetWalkSpeed(1)
            ply:SetRunSpeed(1)
            local eater = self.Owner
            ply:SetNW2Entity("EATER", eater)

            -- ply:EmitSound("ambient/creatures/town_child_scream1.wav")
            local function Finish()
                if IsValid(ply) then
                    ply:SetNW2Entity("EATER", nil)
                end

                if IsValid(self) then
                    self:SetNW2Entity("EATINGp", nil)
                    self:SetHoldType("normal")
                end
            end

            local function Update()
                if not IsValid(ply) or not ply:Alive() then
                    Finish()

                    return
                end

                if not IsValid(self) or not IsValid(eater) or not eater:Alive() or issafe(eater) or not self:ValidTarget(ply) then
                    Finish()
                    ply:SetSlowWalkSpeed(ply.properSWSP or 1)
                    ply:SetWalkSpeed(ply.properWSP or 1)
                    ply:SetRunSpeed(ply.properRSP or 1)

                    return
                end

                local loss = math.floor(9 + ply:GetMaxHealth() / 80)
                local expectedHealth = ply:Health() - loss
                local dmginfo = DamageInfo()
                dmginfo:SetAttacker(self.Owner)
                dmginfo:SetInflictor(self)
                dmginfo:SetDamageForce(Vector(0, 0, 0))
                dmginfo:SetDamage(loss)

                if expectedHealth <= 0 then
                    FORCEMODELL = true
                    ply:SetModel("models/player/skeleton.mdl")
                    FORCEMODELL = false
                end

                -- if expectedHealth > 0 then
                -- ply:SetHealth(expectedHealth)
                -- else
                local v = ply:GetVelocity()
                ply:TakeDamageInfo(dmginfo)
                ply:SetVelocity(-ply:GetVelocity())
                net.Start("GarfieldEat", true)
                net.Send(ply)

                -- print(v== ply:GetVelocity(), v, ply:GetVelocity())
                -- end
                if ply:Health() ~= expectedHealth and ply:Health() > 0 then
                    ply:SetHealth(expectedHealth)
                end

                if expectedHealth <= 0 and ply:Alive() then
                    ply:Kill()
                end

                for i = 0, 4 do
                    --blood decal
                    local st = ply:GetPos() + Vector(0, 0, 40)
                    local add = Vector(math.random(-100, 100), math.random(-100, 100), math.random(-500, 0))

                    local tr = util.TraceLine({
                        start = st,
                        endpos = st + add,
                        mask = MASK_SOLID_BRUSHONLY
                    })

                    if tr.Hit then
                        local Pos1 = tr.HitPos + tr.HitNormal
                        local Pos2 = tr.HitPos - tr.HitNormal
                        local Bone = tr.Entity:GetPhysicsObjectNum(tr.PhysicsBone or 0)

                        if not Bone then
                            Bone = tr.Entity
                        end

                        util.Decal("Blood", Pos1, Pos2)
                    end
                end

                --2 blood effects
                local effectdata = EffectData()
                effectdata:SetOrigin(ply:GetPos() + Vector(0, 0, 40))
                effectdata:SetNormal(VectorRand())
                effectdata:SetMagnitude(1)
                effectdata:SetScale(5)
                effectdata:SetColor(BLOOD_COLOR_RED)
                effectdata:SetFlags(3)
                util.Effect("BloodImpact", effectdata, true, true)
                util.Effect("bloodspray", effectdata, true, true)
                eater:SetAnimation(PLAYER_ATTACK1)
                timer.Simple(0.1, Update)
            end

            timer.Simple(0, function()
                local rf = RecipientFilter()
                rf:AddPAS(eater:EyePos())
                rf:RemovePlayer(eater)
                net.Start("GarfieldEat")
                net.WriteVector(eater:EyePos())
                net.Send(rf)
                ply:SendLua([[surface.PlaySound("ambient/creatures/town_child_scream1.wav")]])
                Update()
            end)
        else
            timer.Simple(0.3, function()
                if IsValid(self) then
                    self:SetHoldType("normal")
                end
            end)
        end
    end)
end

if CLIENT then
    net.Receive("GarfieldEat", function(len)
        if len == 0 then
            EATINGMETIME = SysTime()

            return
        end

        sound.Play("physics/flesh/flesh_bloody_break.wav", net.ReadVector(), 75, 100, 1)
    end)
end

hook.Add("HUDPaint", "eatingme", function()
    local alp = 1 - (SysTime() - (EATINGMETIME or 0)) * 3
    if alp <= 0 then return end
    surface.SetDrawColor(255, 0, 0, 72 * alp)
    surface.DrawRect(0, 0, ScrW(), ScrH())
end)

function SWEP:PrimaryAttack()
    if IsValid(self:GetNW2Entity("EATINGp")) then return end
    self:SetNextPrimaryFire(CurTime() + 0.2) --0.38)
    self:SetHoldType("duel")
    self.Owner:SetAnimation(PLAYER_ATTACK1)

    if CLIENT and IsFirstTimePredicted() then
        local ply, alpha, blocked = self:GetTargetPlayer()
        -- print("!")
        net.Start("GarfieldEat")

        if ply and alpha >= 1 then
            surface.PlaySound("physics/flesh/flesh_bloody_break.wav")
            net.WriteEntity(ply)
            -- self:SetNW2Entity("EATINGp", ply) 
            -- print("E")
        end

        net.SendToServer()
    end
end

function CylinderDist(v1, v2)
    return math.max(math.sqrt((v1.x - v2.x) ^ 2 + (v1.y - v2.y) ^ 2), math.abs(v1.z - v2.z))
end

function SWEP:MaxRange()
    return 65 + 25 * self.Owner:ObesityScale()
end

local OBESITYSCALE = 1.4

function SWEP:IsTooBig(v)
    return v:Obesity() * (v:Health() / v:GetMaxHealth()) > self.Owner:Obesity() * 1.4
end

-- copied below
function SWEP:ValidTarget(v)
    if self.Owner:GetNW2Entity("EATER") == v and not self:IsTooBig(v) then return true end
    if issafe(v) or self:IsTooBig(v) then return false end
    if CylinderDist(v:GetPos(), self.Owner:GetPos()) > (self:MaxRange() * 1.5 + 60) then return false end

    return true
end

-- local vec = ply:LocalToWorld(ply:OBBCenter()) - self.Owner:EyePos()
-- local aim = self.Owner:EyeAngles():Forward()
-- local power = (50 - vec:Length()) * math.max(0, vec:GetNormalized():Dot(aim))
-- power > 10
-- local eyer = self.Owner:EyeAngles():Right()
-- Vector(eyer.y, -eyer.x, 0):GetNormalized()
-- self.Owner:GetPos():Distance(ply:GetPos())
function SWEP:GetTargetPlayer()
    if self.Owner:IsProtected() then return nil, 0, {} end
    local maxdist = self:MaxRange()
    local ep = self.Owner:EyePos()
    local av = self.Owner:EyeAngles():Forward()
    local ap = ep - av * (maxdist / 10)
    -- av = Vector(av.y, -av.x, 0)
    local op = self.Owner:GetPos()
    local best = nil
    local bestalpha = 0
    local blocked = {}

    for k, v in ipairs(player.GetAll()) do
        if v == self.Owner then continue end
        if not v:Alive() then continue end
        if CLIENT and v:IsDormant() then continue end
        local pp = v:GetPos()
        local pcp = v:LocalToWorld(v:OBBCenter())
        local cyldist = CylinderDist(op, pp)
        local cylalpha = math.Clamp(2 - (cyldist / maxdist), 0, 1)
        local offset = pcp - ap
        local offsetlength = offset:Length()
        local aimdot = math.max(0, (offset / offsetlength):Dot(av))
        local rol = offsetlength / maxdist
        local alpha = math.min(cylalpha, aimdot * (2 - rol * 0.5))

        --* 1.3 then
        if issafe(v) or self:IsTooBig(v) then
            if alpha > 0 then
                table.insert(blocked, v)
            end

            continue
        end

        if IsValid(v:GetNW2Entity("EATER")) and (SERVER or v:GetNW2Entity("EATER") ~= self.Owner) then continue end

        if (util.TraceLine({
            start = ep,
            endpos = pcp,
            mask = MASK_SOLID_BRUSHONLY
        }) or {}).Hit then
            continue
        end

        if alpha > bestalpha then
            best = v
            bestalpha = alpha
        end
    end

    if IsValid(self.Owner:GetNW2Entity("EATER")) and not self:IsTooBig(self.Owner:GetNW2Entity("EATER")) then
        best = self.Owner:GetNW2Entity("EATER")
        bestalpha = 1
    end
    -- end
    -- local av = self.Owner:GetAimVector()
    -- av.z = 0
    -- av:Normalize()
    -- local center = self.Owner:GetPos() + (av * (23 + 25 * math.pow(self.Owner:ObesityScale(), 0.5)))
    -- local closestDist = 1000
    -- local ply = nil
    -- local blocked = {}
    -- local c1 = self.Owner:LocalToWorld(self.Owner:OBBCenter())
    -- for k, v in ipairs(player.GetAll()) do
    --     if v==self.Owner then continue end
    --     if v:GetPos():Distance(center) > (25+25 * math.pow(self.Owner:ObesityScale(),0.5)) then continue end
    --     if not v:Alive() then continue end
    --     if CLIENT and v:IsDormant() then continue end
    --     local c2 = v:LocalToWorld(v:OBBCenter())
    --     local tr = util.TraceLine({
    --         start = c1,
    --         endpos = c2,
    --         mask = MASK_SOLID_BRUSHONLY
    --     })
    --     if tr and tr.Hit then continue end
    --     if IsValid(v:GetNW2Entity("EATER")) then 
    --         if CLIENT and v:GetNW2Entity("EATER")==self.Owner then else
    --         continue end
    --         end
    --     --or v:IsAFK() then -- or v:IsBot() then
    --     if Safe(v) or v:Obesity() * (v:Health()/v:GetMaxHealth()) > self.Owner:Obesity() * 1.5 then --* 1.3 then
    --         table.insert(blocked, v)
    --         continue
    --     end
    --     local dist = v:GetPos():Distance(self.Owner:GetPos())
    --     if dist < closestDist then
    --         ply = v
    --         closestDist = dist
    --     end
    -- end
    -- -- if CLIENT then print(ply) end
    -- local alpha = 1
    -- return ply, alpha, blocked

    return best, math.Clamp(bestalpha, 0, 1), blocked
end

function SWEP:SecondaryAttack()
    self:SetNextSecondaryFire(CurTime() + 0.5)

    if SERVER then
        local files = {"i_eat_jon_its_what_i_do.ogg", "i_gotta_have_a_good_meal.ogg", "i_hate_alarm_clocks.ogg", "im_am_hungry_i_want_some_lasaga.ogg", "its_time_to_kick_odie_off_the_table.ogg", "time_for_a_nap_im_a_cat_who_loves_to_snooze.ogg", "youre_going_into_orbit_you_stupid_mutt.ogg", "i_ate_those_food.ogg"}

        local snd = files[math.random(#files)]

        self:ExtEmitSound("garfield/" .. snd, {
            pitch = 110 / math.sqrt(self.Owner:ObesityScale()),
            level = 75 + math.sqrt(self.Owner:Obesity()),
            speech = 2.2,
            shared = false
        })
    end
end

function SWEP:Reload()
    if SERVER then end
end

hook.Add("KeyPress", "GarfieldJump", function(ply, key)
    if CLIENT then return end
    if key ~= IN_JUMP then return end
    local self = ply:GetWeapon("weapon_garfield")
    if not IsValid(self) then return end

    if not self.Owner:Crouching() then
        self.Owner:Notify("Crouch and jump to leap forward (costs weight)")

        return
    end

    if not self.Owner:IsOnGround() then return end
    if CurTime() - (self.lastreload or 0) < 5 then return end
    self.lastreload = CurTime()
    self.Owner:SetPos(self.Owner:GetPos() + Vector(0, 0, 1))
    local av = self.Owner:GetAimVector()
    av.z = math.max(av.z, 0.5)
    av:Normalize()
    self.Owner:SetVelocity(av * 450 - self.Owner:GetVelocity())
    self.Owner:SetObesity(math.max(1, self.Owner:Obesity() * 0.95))
end)

function SWEP:Deploy()
    self.Owner:DrawViewModel(false)
end

function SWEP:DrawWorldModel()
    if not IsValid(self.Owner) then
        self:DrawModel()
    end
end

local garfMat = Material("vgui/garfield.png", "smooth")
local lasagnaMat = Material("vgui/lasagna.png", "smooth")

function SWEP:DrawHUD()
    surface.SetDrawColor(255, 255, 255, 255)
    surface.SetMaterial(garfMat)

    for x = -1, 1, 2 do
        surface.DrawTexturedRect(ScrW() / 2 - 40 + 150 * x, 0, 80, 80)
    end

    draw.WordBox(8, ScrW() * 2 / 4, 20, "Weight: " .. tostring(math.floor(10 * LocalPlayer():Obesity())) .. " lbs", "DermaLarge", Color(0, 0, 0, 100), Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
    local txt = ""
    local cf = GetG("CURFATTESTCAT")

    if IsValid(cf) then
        txt = txt .. "Current largest:\n"
        txt = txt .. cf:Name() .. " - " .. tostring(math.floor(10 * cf:Obesity())) .. " lbs\n"
    end

    txt = txt .. "\nHighest ever:\n"

    for i, cat in ipairs(GetG("FATTESTCATS") or {}) do
        txt = txt .. tostring(i) .. ". " .. cat[1] .. " (" .. cat[2] .. ") - " .. tostring(math.floor(10 * cat[3])) .. " lbs\n"
        -- draw.WordBox(8,ScrW()*2/4,30, txt, "Trebuchet18", Color(0,0,0,100), Color(255,255,255,255), TEXT_ALIGN_CENTER)
    end

    draw.DrawText(txt, "DermaDefault", 10, 10, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
    surface.SetDrawColor(255, 255, 255, 255)
    surface.SetMaterial(lasagnaMat)
    GARFIELDOUTLINEPLY, alpha, blocked = self:GetTargetPlayer()
    local eatin = self:GetNW2Entity("EATINGp")

    if IsValid(eatin) then
        -- print(1)
        if not EATINSTARTH then
            EATINSTARTH = eatin:Health()
        end

        local r = math.max(0, eatin:Health() / EATINSTARTH)
        local data2D = eatin:LocalToWorld(eatin:OBBCenter()):ToScreen()
        surface.DrawTexturedRectUV(data2D.x - 64, data2D.y - 64 + (1 - r) * 128, 128, r * 128, 0, 1 - r, 1, 1)
    else
        EATINSTARTH = nil

        if GARFIELDOUTLINEPLY then
            -- print(2)
            local data2D = GARFIELDOUTLINEPLY:LocalToWorld(GARFIELDOUTLINEPLY:OBBCenter()):ToScreen()

            if alpha >= 1 then
                local glo = (math.sin(CurTime() * 10) + 1) * 4 - 1
                surface.SetDrawColor(0, 255, 0, 255)
                surface.DrawTexturedRect(data2D.x - 80 - (glo), data2D.y - 80 - (glo), 160 + glo * 2, 160 + glo * 2)
                surface.SetDrawColor(0, 0, 0, 255)
                surface.DrawTexturedRect(data2D.x - 72, data2D.y - 72, 144, 144)
            end

            surface.SetDrawColor(255, 255, 255, 255 * alpha)
            surface.DrawTexturedRect(data2D.x - 64, data2D.y - 64, 128, 128)
        else
        end
        -- print(3)
    end

    if not self.Owner:IsProtected() then
        for i, v in ipairs(blocked) do
            local data2D = v:LocalToWorld(v:OBBCenter()):ToScreen()
            -- draw.SimpleText("X", "DermaLarge", data2D.x, data2D.y, Color(255, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            surface.SetDrawColor(255, 0, 0, 255)
            surface.DrawTexturedRect(data2D.x - 64, data2D.y - 64, 128, 128)
        end
    end
end

hook.Add("CanOutfit", "garffafasd", function(ply, mdl, wsid)
    if ply:HasWeapon('weapon_garfield') then return false end
end)
