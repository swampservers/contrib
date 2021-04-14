-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
if (SERVER) then return end
include("shared.lua")
language.Add("kleiner", "Dr. Isaac Kleiner")

function ENT:Initialize()
    local effectdata = EffectData()
    effectdata:SetOrigin(self:GetPos())
    effectdata:SetEntity(self)
    util.Effect("propspawn", effectdata)
end

local spkr = Material("voice/icntlk_pl")

hook.Add("CreateClientsideRagdoll", "KleinerRagdollsFix", function(ent, rag)
    if (IsValid(ent) and ent:GetClass() == "kleiner") then
        if (ent.GetBased) then
            rag.wasbased = ent:GetBased()
        end

        function rag:GetPlayerColor()
            rag.LastPlayerColor = rag.LastPlayerColor or (IsValid(ent) and ent:GetPlayerColor()) or nil

            return (rag.LastPlayerColor) or (self.wasbased and KLEINER_NPC_ENT_COLOR_BASED) or KLEINER_NPC_ENT_COLOR_STANDARD
        end

        if (IsValid(rag)) then
            for i = 0, 7 do
                rag:SetSubMaterial(i, ent:GetSubMaterial(i, ""))
            end
        end

        timer.Simple(10, function()
            if (IsValid(rag)) then
                rag:Remove()
            end
        end)
    end
end)

function ENT:GetStareTarget()
    local target = self:GetTarget()
    if (IsValid(target)) then return target:EyePos() end

    return self:EyePos() + self:GetAngles():Forward() * 600
end

function ENT:Draw()
    if (self:GetTalking() > CurTime()) then
        local bone = self:GetBonePosition(self:LookupBone("ValveBiped.Bip01_Head1") or 0)
        render.SetMaterial(spkr)
        render.DrawSprite(bone + Vector(0, 0, 16), 16, 16, color_white)
    end

    local lod = self:GetPos():Distance(EyePos())

    if (lod < 400) then
        local eyepos = self:GetPos() + Vector(0, 0, 72)
        local eyeang = self:GetAngles()
        local targetpos = self:GetStareTarget() or Vector()
        local angle = (targetpos - eyepos):Angle()
        local pos, ang = WorldToLocal(targetpos, angle, eyepos, eyeang)
        self:SetPoseParameter("head_yaw", ang.yaw / 2)
        self:SetPoseParameter("head_pitch", ang.pitch / 4)

        if (lod < 200) then
            self:SetEyeTarget(targetpos)
        end
    end

    self:DrawModel()
end

function ENT:GetPlayerColor()
    if (self:GetBased()) then return KLEINER_NPC_ENT_COLOR_BASED end

    return KLEINER_NPC_ENT_COLOR_STANDARD
end

function ENT:OnRemove()
    if (self.LastSound) then
        self:StopSound(self.LastSound)
    end
end
--maybe for later? hud that counts your bounty level against kleiners
--[[

local function KleinerViolenceStarValue(star)
	return  math.max(math.floor( (2.8^star)),1)
end

local function KleinerViolenceStars(value)
	local stars = 0
	for i=1,10 do
	
		if(value >=  KleinerViolenceStarValue(i))then
			stars = stars + 1
		end
	end
	return stars
end


local starmat = Material( "icon16/star.png" , "noclamp")

local function KleinerBountyHUD()
	surface.SetDrawColor( color_white )
	surface.SetMaterial( starmat )
	local x,y = ScrW()/2,ScrH() - 128
	local starc =  KleinerViolenceStars(KLEINER_VIOLENCE_LEVEL or 1)
	local dispnum = 5
	local imagesize = 32
	for i=1,5 do
	local sx = x - imagesize - ((dispnum/2)*(imagesize)) + (i*imagesize)
	surface.SetDrawColor( starc >= i and color_white or color_black )
	surface.DrawTexturedRect( sx, y-(imagesize/2), imagesize, imagesize ) -- Exactly same as above line
	if(i == starc + 1 or true)then
	draw.SimpleText( KleinerViolenceStarValue(i), "DermaDefault", sx+(imagesize/2), y, color_white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
	end
	end
	draw.SimpleText( KLEINER_VIOLENCE_LEVEL, "DermaDefault", x, y+imagesize, color_white,TEXT_ALIGN_CENTER )
end 


hook.Remove( "HUDPaint", "DrawTexturedRectUV_example1")

net.Receive("kleinernpc_warning",function()
	local violence = net.ReadInt(16)
	KLEINER_VIOLENCE_LEVEL = violence
	local delay = math.Clamp(violence,5,40)
	hook.Add( "HUDPaint", "KleinerBountyHUD", KleinerBountyHUD)
	KLEINER_BOUNTYHUD_END = CurTime() + delay
	timer.Create("KleinerBountyHUD",delay,1,function()
		hook.Remove( "HUDPaint", "KleinerBountyHUD")
	end)
	
end)
]]