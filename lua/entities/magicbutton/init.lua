-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
include("shared.lua")
include("sv_logic.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("sv_effects.lua")
include("sv_placement.lua")

function ENT:Initialize()
    self:SetModel("models/pyroteknik/secretbutton.mdl")

    if (not self.HasSpot) then
        self:Hide()
    end
    local bmins, bmaxs = Vector(3, 5, 0) * -1, Vector(3, 5, 2) * 1
    self:SetCollisionBounds(bmins, bmaxs)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_OBB)
    self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
    self:SetUseType(SIMPLE_USE)
    self:SetColor(HSVToColor(math.Rand(0, 360), 1, 1))
    self:SetTrigger(true)
    

    timer.Simple(60 * 60, function()
        if (IsValid(self)) then
            self:Remove()
        end
    end)
end

function ENT:Hide()
    local trace = self:FindHidingSpot()

    if (trace) then
        self:MoveToTraceResult(trace)
        --.Weird is a flag assigned when the button is placed on something either not wide enough for the button model, or too uneven.
        if (self.PlacementTrace and self.PlacementTrace.Weird) then

            if (self.PlacementTrace.HitTexture == "**studio**") then
                self:SetPos(self:GetPos() + self:GetUp() * 2)
            end
        end
    else
        print("hide fail")
    end
end

function ENT:OnRemove()
    self.Removing = true
    if(self.playingsound)then
        self:StopSound(self.playingsound)
    end
    self:Transmit()
end

function ENT:SpawnFunction(ply, tr, ClassName)
    local ent = ents.Create(ClassName)
    local trace = ent:FindHidingSpot(tr.HitPos + tr.HitNormal * 32)
    --[[testing placement
    local newt = {}
    newt.start = ply:GetShootPos()
    newt.endpos = newt.start + ply:GetAimVector()*32768
    newt.filter = ply
    newt.mins = Vector(1,1,1)*-8
    newt.maxs = Vector(1,1,1)*8
    
    local nt = util.TraceHull(newt)
    nt.traceinfo = newt

    trace = nt
    ]]
    if (trace) then
        ent:MoveToTraceResult(trace)
    end

    ent.HasSpot = true
    ent:Spawn()

    return ent
end

util.AddNetworkString("magicbutton_transmitclone")

function ENT:Transmit()
    local recip = MAGICBUTTON_SENDFILTER(self)
    local c = self:GetColor()
    net.Start("magicbutton_transmitclone")
    net.WriteInt(self:EntIndex(), 17)
    net.WriteInt(self.Removing and 0 or 4, 7)

    if (not self.Removing) then
        net.WriteVector(self:GetPos())
        net.WriteAngle(self:GetAngles())
        net.WriteColor(Color(c.r, c.g, c.b, c.a))
        net.WriteBool(self.Pressed or false)
    end

    net.Send(recip)
end

function ENT:Think()
    self:Transmit()
    self:NextThink(CurTime() + 1)

    if (self.HintSound and not self.Pressed) then
        Sound(self.HintSound)

        if (math.random(1, 2) == 1 or true) then
            self:EmitSound(self.HintSound, 70, 100, 1, CHAN_VOICE, nil)
        end
    end

    return true
end

--NOTE: On these functions, please return a string if there was a success, and nil if there was not.
function ENT:Effect(ply)
    local effect
    local item
    local outcometable = {}
    local coolonly = self.CoolEffectOnly
    local uncool = MAGICBUTTON_MODIFY(ply)

    for k, v in pairs(MagicButtonOutcomes) do
        if (not uncool and coolonly and not v.cool) then continue end
        if (uncool and not v.uncool) then continue end

        for i = 1, v.weight * (v.weightbonus or 1) or 1 do
            table.insert(outcometable, math.random(1, #outcometable + 1), k)
        end
    end

    for _, index in pairs(outcometable) do
        effect = MagicButtonOutcomes[index]

        if (effect.func ~= nil) then
            item = effect.func(ply, self)
        end

        if (item ~= nil) then break end
    end

    return item
end

function ENT:UpdateTransmitState()
    if (self.HintSound) then return TRANSMIT_ALWAYS end

    return TRANSMIT_NEVER
end

function ENT:Use(activator)
    if (not self.Pressed) then
        self.Pressed = true
        self:SetSolid(SOLID_NONE)
        self:Transmit()
        SafeRemoveEntityDelayed( self, self.OverrideDieTime or 8)

        MAGICBUTTON_STAT_TRACKING(activator)

        local message = self:Effect(activator)
        assert(message ~= nil,"Secret button failed to give any outcome")
        if (message ~= "") then 
            message = "[yellow]The Hilarious One [white]" .. message
            BotSayGlobal(":banana:" .. message)
        end
        activator:EmitSound("buttons/button9.wav") 
    end
end

function ENT:OnTakeDamage(dmg)
    if(dmg:GetDamageType() == DMG_BLAST)then return end
    if(dmg:GetAttacker():IsPlayer())then
        local ply = dmg:GetAttacker()

        
        if(!self.SpecialUsed)then
        timer.Simple(0,function()
            if(IsValid(self))then
                self:Use(ply)
            end
        end)
        end
        self.SpecialUsed = true

    end

end

function ENT:Touch(ent)
    if(ent:IsPlayer())then
        if(!self.SpecialUsed)then
            timer.Simple(0,function()
                if(IsValid(self))then
                    self:Use(ent)
                end
            end)
            end
        self.SpecialUsed = true
    end
end