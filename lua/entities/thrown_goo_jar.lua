AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "Thrown Goo Jar"
ENT.Author = "PYROTEKNIK"
ENT.Category = "PYROTEKNIK"
ENT.Spawnable = false
ENT.AdminSpawnable = true

if (SERVER) then
    util.AddNetworkString("gooeffect")
end


local pmeta = FindMetaTable("Player")

function pmeta:GooStun(length)
    

    self._gooendtime = (length == -1 and 0) or math.max(self._gooendtime or 0, CurTime() + length)

    if (SERVER and length > 0) then --try to nicely coat the player in white stuff :)
        for i=-2,2 do 
            local tr = {}
            local dir = VectorRand() * Vector(1, 1, 0.1):GetNormalized()
            local origin = self:WorldSpaceCenter() + Vector(0,0,16)*i
            tr.start = origin + dir * 24
            tr.endpos = origin

            tr.filter = function(ent)
                if (ent == self) then return true end

                return false
            end

            local trc = util.TraceLine(tr)

            if (trc.Hit and trc.Entity == self) then
                util.Decal("PaintSplatBlue", trc.HitPos, trc.Normal)
            end
        end
    end

    if (SERVER) then
        net.Start("gooeffect")
        net.WriteEntity(self)
        net.WriteFloat(length)
        net.SendPVS(self:GetPos())
    end

    if (CLIENT) then
        CUMSTAINS = CUMSTAINS or {}

        table.insert(CUMSTAINS, {CurTime() + length, math.random(0, ScrW(), math.random(0, ScrH()))})
    end
end

function pmeta:GetGooStunned()
    --if(true)then  return true,500 end
    return CurTime() < (self._gooendtime or 0), math.max(0, (self._gooendtime or 0) - CurTime())
end

if (CLIENT) then
    net.Receive("gooeffect", function(len)
        local ply = net.ReadEntity()
        local duration = net.ReadFloat()
        if IsValid(ply) then ply:GooStun(duration) end
    end)
end


hook.Add("PlayerSpawn", "GooStunReset", function(ply)
    ply:GooStun(-1)
end)

hook.Add("EntityTakeDamage", "GooStunGive", function(target, dmginfo)

    if (target:IsPlayer() and dmginfo:GetInflictor():GetClass() == "thrown_goo_jar" and dmginfo:GetAttacker() == target) then
        return true
    end
    if (target:IsPlayer() and dmginfo:GetInflictor():GetClass() == "thrown_goo_jar") then
        local coomer = (IsValid(target:GetActiveWeapon()) and target:GetActiveWeapon():GetClass() == "weapon_coomjar")

        if (not coomer or true) then
            target:GooStun(math.Clamp(dmginfo:GetDamage() / 10, 0, 4))
        end
    end
end)

local tab = {
    ["$pp_colour_addr"] = 0,
    ["$pp_colour_addg"] = 0,
    ["$pp_colour_addb"] = 0,
    ["$pp_colour_brightness"] = 0,
    ["$pp_colour_contrast"] = 1,
    ["$pp_colour_colour"] = 1,
    ["$pp_colour_mulr"] = 0,
    ["$pp_colour_mulg"] = 00,
    ["$pp_colour_mulb"] = 0
}

hook.Add("RenderScreenspaceEffects", "GooOnScreen", function()
    local stunned, time = LocalPlayer():GetGooStunned()
    local opacity = math.min(time / 4, 1) / 50
    tab["$pp_colour_brightness"] = math.Clamp(time / 4, 0, 0.4)

    if tab["$pp_colour_brightness"]>0 then
        DrawColorModify(tab)
    end

    if (time > 0) then
        DrawMaterialOverlay("pyroteknik/cum_overlay", opacity)
    end
end)

hook.Add("SetupMove", "GooMovement", function(ply, mv, cmd)
    if (ply:GetGooStunned()) then
        local stunned, time = ply:GetGooStunned()
        local div = Lerp(math.min(time / 4, 1),1,400)

        mv:SetForwardSpeed(mv:GetForwardSpeed() / div)
        mv:SetSideSpeed(mv:GetSideSpeed() / div)
        ply:ViewPunch(AngleRand() * FrameTime() * 0.04)
    end
end)

hook.Add("CalcMainActivity", "GooEw", function(ply, vel)
    if (ply:GetGooStunned()) then
        if (not ply:OnGround()) then return ACT_HL2MP_IDLE_CAMERA, -1 end
        if (vel:Length() < 40) then return ACT_HL2MP_IDLE_CAMERA, -1 end

        return ACT_HL2MP_RUN_PANICKED, -1
    end
end)

function ENT:Initialize()
    if (SERVER) then
        self.Entity:SetModel("models/chev/cumjar.mdl")
        local bmins, bmaxs = Vector(-1, -1, -1), Vector(1, 1, 1)
        self:SetCollisionBounds(bmins, bmaxs)
        self.Entity:PhysicsInit(SOLID_BBOX)
        self.Entity:SetMoveType(MOVETYPE_FLYGRAVITY)
        self.Entity:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
        self:SetUseType(SIMPLE_USE)
        self:SetSubMaterial(1, "models/shiny")
        self:SetSubMaterial(2, "engine/occlusionproxy")
        local trail = util.SpriteTrail(self, 0, Color(255, 255, 255), false, 15, 1, 0.1, 1 / (15 + 1) * 0.5, "trails/laser")
    end
end

local TRIGGER_BLACKLIST = {}
TRIGGER_BLACKLIST["trigger_hurt"] = true

--TRIGGER_BLACKLIST[FSOLID_NOT_SOLID] = true
--TRIGGER_BLACKLIST[FSOLID_TRIGGER] = true
function ENT:Touch(entity)
    if (TRIGGER_BLACKLIST[entity:GetClass()]) then return end

    for flag, _ in pairs(TRIGGER_BLACKLIST) do
        if (type(flag) == "number" and self:GetSolidFlags() >= flag) then return end
    end

    local trace = self:GetTouchTrace()

    if (trace.HitSky) then
        self:Remove()

        return
    end

    local dir = trace.Normal
    local pos = trace.HitPos + trace.HitNormal * 48
    local decals = 0
    local dmg = DamageInfo()
    dmg:SetDamage(85)
    dmg:SetDamageType(DMG_ACID)
    dmg:SetDamageForce(self:GetVelocity() * 1000)
    dmg:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or game.GetWorld())
    dmg:SetInflictor(self)
    util.BlastDamageInfo(dmg, trace.HitPos, 128)

    while decals < 5 do
        local tr = {}
        tr.start = pos
        tr.endpos = pos + dir:GetNormalized() * 64
        local trc = util.TraceLine(tr)

        if (trc.Hit) then
            util.Decal("PaintSplatBlue", tr.start, tr.endpos, {self})

            local vPoint = self:GetPos()
            local effectdata = EffectData()
            effectdata:SetOrigin(trc.HitPos)
            effectdata:SetAngles(VectorRand():AngleEx(trace.HitNormal))
            effectdata:SetNormal(trc.HitNormal)
            effectdata:SetScale(10)
            util.Effect("watersplash", effectdata)
            decals = decals + 1
        end

        dir = VectorRand()
    end

    self:EmitSound("physics/glass/glass_cup_break" .. math.random(1, 2) .. ".wav")
    self:EmitSound("coomer/splort.ogg")
    self:Remove()
end

--lol i caught it
function ENT:Use(ply)
    ply:Give("weapon_goojar")
    self:Remove()
end