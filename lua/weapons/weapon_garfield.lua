-- Copyright (C) 2021 Swamp Servers. https://github.com/swampservers/fatkid
-- Use is subject to a restrictive license, please see: https://github.com/swampservers/fatkid/blob/master/LICENSE
SWEP.PrintName = "Garfield"
SWEP.Purpose = "Eat"
SWEP.Instructions = "Primary: Eat\n\nYou can eat players smaller and slightly larger than you. The bigger you get, the more health you have. To win when eating larger players, soften them up with weapons first."
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


timer.Simple(1, function()
    hook.Add("CanOutfit", "ps_outfitter", function(ply, mdl, wsid) return false end)
end)


FATTESTCATS = FATTESTCATS or {}

function Player:Obesity()
    return self:GetNWFloat("garfield", 1)
end

function Player:SetObesity(obs)
    self:SetNWFloat("garfield", obs)
    self:SetModelScale(self:ObesityScale()*0.6)
    if SERVER then UpdateViewHeight(self) end
    self:SetRunSpeed(300/self:ObesitySpeedScale())
    self:SetWalkSpeed(300/self:ObesitySpeedScale())
    self:SetSlowWalkSpeed(300/self:ObesitySpeedScale())
    local mh = 100 * self:Obesity()
    self:SetMaxHealth(mh)
    self:SetHealth(math.min(self:Health(), mh))

    if SERVER then
        -- if #FATTESTCATS==0 or FATTESTCATS[1][3]<obs then

        --     FATTESTCATS = {{self:Name(), self:SteamID(), obs}}
        --     SetG("FATTESTCATS", FATTESTCATS)
        -- end
        local add = true
        local old = util.TableToJSON(FATTESTCATS)
        for k,v in pairs(FATTESTCATS) do
            if v[2] == self:SteamID() then v[1]=self:Name() v[3] = math.max(v[3], obs) add=false end
        end
        if add then table.insert(FATTESTCATS, {self:Name(), self:SteamID(), obs}) end
        table.SortByMember(FATTESTCATS, 3)
        while #FATTESTCATS > 5 do table.remove(FATTESTCATS) end
        --if util.TableToJSON(FATTESTCATS) ~= old then 
            SetG("FATTESTCATS", FATTESTCATS) --end

        if not IsValid(CURFATTESTCAT) or CURFATTESTCAT:Obesity() < obs then
            CURFATTESTCAT=self
            SetG("CURFATTESTCAT", CURFATTESTCAT)
        end
    end
end

function Player:ObesityScale()
    return math.pow(self:Obesity(), 1/3)
end

function Player:ObesitySpeedScale()
    return math.pow(self:Obesity(), 1/5)
end

hook.Add("PlayerSpawn","ResetGarfield",function(ply)
    timer.Simple(0, function()
        timer.Simple(0, function()
        ply:SetObesity(1)
        ply:Give("weapon_garfield")
    end) end)
end)

hook.Add("PlayerDeath","FinishEating",function(vic,inf,att)
    local eater = vic:GetNWEntity("EATER")
    if IsValid(eater) then
        local vo,ao = vic:Obesity(), eater:Obesity()
        local ratio = math.sqrt(vo/ao) * 0.8 --math.min(0.7, (vo/ao))
        if ratio < 0.2 then eater:Notify("Look for larger prey to grow faster!") end
        eater:SetObesity(ao + vo * ratio)
        eater:SetHealth(eater:GetMaxHealth())
        vic:SetNWEntity("EATER", nil)
    end
end)

if SERVER then
timer.Create("GarfieldDecay",30,0,function()
    for k,v in pairs(player.GetAll()) do
        v:SetObesity(math.max(1, v:Obesity()*0.98))
    end
end)
timer.Create("GarfieldHeal",5,0,function()
    for k,v in pairs(player.GetAll()) do
        v:SetHealth(math.min(math.floor(v:Health() + v:GetMaxHealth()*0.05), v:GetMaxHealth()))
    end
end)
end


-- local vec = ply:LocalToWorld(ply:OBBCenter()) - self.Owner:EyePos()
-- local aim = self.Owner:EyeAngles():Forward()
-- local power = (50 - vec:Length()) * math.max(0, vec:GetNormalized():Dot(aim))
-- power > 10

-- local eyer = self.Owner:EyeAngles():Right()
-- Vector(eyer.y, -eyer.x, 0):GetNormalized()
-- self.Owner:GetPos():Distance(ply:GetPos())

function SWEP:Initialize()
    self:SetHoldType("normal")
end

function SWEP:PrimaryAttack()

    if self:GetNWBool("EATING") then return end

    self:SetNextPrimaryFire(CurTime() + 0.5) --0.38)

    self:SetHoldType("duel")
    
    self.Owner:SetAnimation(PLAYER_ATTACK1)

    if SERVER then
        local ply,blocked=self:GetTargetPlayer()

        if ply then
            self:SetNWBool("EATING", true)
            
            local swsp,wsp,rsp = ply:GetSlowWalkSpeed(),ply:GetWalkSpeed(),ply:GetRunSpeed()
            if swsp>1 then ply.properSWSP = swsp end
            if wsp>1 then ply.properWSP = wsp end
            if rsp>1 then ply.properRSP = rsp end
            ply:SetSlowWalkSpeed(1)
            ply:SetWalkSpeed(1)
            ply:SetRunSpeed(1)


            local eater = self.Owner
            ply:SetNWEntity("EATER", eater)
            
            -- ply:EmitSound("ambient/creatures/town_child_scream1.wav")

            local function Finish()
                self:SetNWBool("EATING", false)
                self:SetHoldType("normal")
                ply:SetNWEntity("EATER", nil)
            end

            local function Update()
                if not IsValid(ply) or not ply:Alive() then Finish() return end

                if not IsValid(self) or not IsValid(eater) or not eater:Alive() then
                    ply:SetSlowWalkSpeed(ply.properSWSP or 1)
                    ply:SetWalkSpeed(ply.properWSP or 1)
                    ply:SetRunSpeed(ply.properRSP or 1)
                    Finish()
                    return
                end

                local loss = math.floor(7 + ply:GetMaxHealth()/100)

                local expectedHealth = ply:Health()-loss

                local dmginfo = DamageInfo()
                dmginfo:SetAttacker(self.Owner)
                dmginfo:SetInflictor(self)
                dmginfo:SetDamageForce(Vector(0, 0, 0))
                dmginfo:SetDamage(loss)
 
                if expectedHealth <= 0 then
                    FORCEMODELL=true
                    ply:SetModel("models/player/skeleton.mdl")
                    FORCEMODELL=false
                end

                ply:TakeDamageInfo(dmginfo)
                if ply:Health()~=expectedHealth then ply:SetHealth(expectedHealth) end


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

                timer.Simple(0.02, Update)
            end

            timer.Simple(0, function()
                eater:EmitSound("physics/flesh/flesh_bloody_break.wav")
                Update()
            end)

        else
            timer.Simple(0.3, function()
                if IsValid(self) then
                    self:SetHoldType("normal")
                end
            end)
        end
    end
end

function SWEP:GetTargetPlayer()
    local av = self.Owner:GetAimVector()
    av.z = 0
    av:Normalize()

    local center = self.Owner:GetPos() + (av * 48 * self.Owner:ObesityScale())
    local closestDist = 1000
    local ply = nil
    local blocked = {}

    local c1 = self.Owner:LocalToWorld(self.Owner:OBBCenter())

    for k, v in next, ents.FindInSphere(center, 50 * self.Owner:ObesityScale()) do
        if v:IsPlayer() and v ~= self.Owner and v:Alive() then

            local c2 = v:LocalToWorld(v:OBBCenter())

            local tr = util.TraceLine({
                start = c1,
                endpos = c2,
                mask = MASK_SOLID_BRUSHONLY
            })
            if tr and tr.Hit then
                continue
            end

            if IsValid(v:GetNWEntity("EATER")) then continue end
            
            if Safe(v) or v:Obesity() > self.Owner:Obesity()*1.3 then --or v:IsAFK() then -- or v:IsBot() then
                table.insert(blocked, v)
                continue
            end
            
            
            local dist = v:GetPos():Distance(self.Owner:GetPos())
            if dist < closestDist then
                ply = v
                closestDist = dist
            end
        end
    end

    return ply,blocked
end

function SWEP:SecondaryAttack()
    self:SetNextSecondaryFire(CurTime() + 2)

    
    if SERVER then
        local files = {
            "i_eat_jon_its_what_i_do.ogg","i_gotta_have_a_good_meal.ogg","i_hate_alarm_clocks.ogg","im_am_hungry_i_want_some_lasaga.ogg","its_time_to_kick_odie_off_the_table.ogg",
            "time_for_a_nap_im_a_cat_who_loves_to_snooze.ogg","youre_going_into_orbit_you_stupid_mutt.ogg"
        }
        local snd = files[math.random(#files)]
        self:ExtEmitSound("garfield/"..snd, {
            speech = 2.2,
            shared = false
        })
    end
end

function SWEP:Deploy()
    self.Owner:DrawViewModel(false)
end

function SWEP:DrawWorldModel()
    if not IsValid(self.Owner) then
        self:DrawModel()
    end
end

if CLIENT then
-- function draw.CenteredWordBox(bordersize,  x,  y, text, font, boxcolor, textcolor)
--     surface.SetFont(font)
--     w,h = surface.GetTextSize(text)
--     draw.WordBox(bordersize,  x - (bordersize + w/2),  y - (bordersize + h/2), text, font, boxcolor, textcolor)
-- end

function draw.WordBox( bordersize, x, y, text, font, color, fontcolor, xalign )

	surface.SetFont( font )
	local w, h = surface.GetTextSize( text )

    if ( xalign == TEXT_ALIGN_CENTER ) then
		x = x - (bordersize + w / 2)
	elseif ( xalign == TEXT_ALIGN_RIGHT ) then
		x = x - (bordersize * 2 + w)
	end

	draw.RoundedBox( bordersize, x, y, w+bordersize * 2, h+bordersize * 2, color )

	surface.SetTextColor( fontcolor.r, fontcolor.g, fontcolor.b, fontcolor.a )
	surface.SetTextPos( x + bordersize, y + bordersize )
	surface.DrawText( text )

	return w + bordersize * 2, h + bordersize * 2

end


end

local garfMat = Material( "vgui/garfield.png" ,"smooth")
local lasagnaMat = Material( "vgui/lasagna.png","smooth" )

function SWEP:DrawHUD()

	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.SetMaterial( garfMat ) 
    for x =-1,1,2 do
	surface.DrawTexturedRect( ScrW()/2 - 40 + 150*x, 0, 80,80 ) 
    end
    draw.WordBox(8,ScrW()*2/4,20,"Weight: "..tostring(math.floor(10*LocalPlayer():Obesity())).. " lbs", "DermaLarge", Color(0,0,0,100), Color(255,255,255,255), TEXT_ALIGN_CENTER)

    local txt = ""

    local cf = GetG("CURFATTESTCAT")
    if IsValid(cf) then
        txt = txt .."Current largest:\n"
        txt = txt .. cf:Name() .. " - ".. tostring(math.floor(10*cf:Obesity())) .. " lbs\n"
    end
    txt = txt.."\nHighest ever:\n"


    for i,cat in ipairs(GetG("FATTESTCATS") or {}) do
        txt = txt .. tostring(i)..". "..cat[1].." ("..cat[2]..") - "..tostring(math.floor(10*cat[3])).." lbs\n"
        -- draw.WordBox(8,ScrW()*2/4,30, txt, "Trebuchet18", Color(0,0,0,100), Color(255,255,255,255), TEXT_ALIGN_CENTER)
    end

    draw.DrawText(txt, "DermaDefault", 10, 10, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT )
    

    GARFIELDOUTLINEPLY, blocked = self:GetTargetPlayer()
    if GARFIELDOUTLINEPLY then
        local data2D = GARFIELDOUTLINEPLY:LocalToWorld(GARFIELDOUTLINEPLY:OBBCenter()):ToScreen()
        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( lasagnaMat ) 
        surface.DrawTexturedRect(data2D.x-64, data2D.y-64, 128,128 ) 
        -- draw.SimpleText( "V", "Trebuchet24", data2D.x, data2D.y, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end

    for i,v in ipairs(blocked) do
        local data2D = v:LocalToWorld(v:OBBCenter()):ToScreen()
        draw.SimpleText( "X", "DermaLarge", data2D.x, data2D.y, Color( 255,0,0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
end
