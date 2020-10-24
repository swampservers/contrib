-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

AddCSLuaFile()

--[[
ValveBiped.Bip01_Pelvis
ValveBiped.Bip01_Spine
ValveBiped.Bip01_Spine1
ValveBiped.Bip01_Spine2
ValveBiped.Bip01_Spine4
ValveBiped.Bip01_Neck1
ValveBiped.Bip01_Head1
ValveBiped.forward
ValveBiped.Bip01_R_Clavicle
ValveBiped.Bip01_R_UpperArm
ValveBiped.Bip01_R_Forearm
ValveBiped.Bip01_R_Hand
ValveBiped.Anim_Attachment_RH
ValveBiped.Bip01_L_Clavicle
ValveBiped.Bip01_L_UpperArm
ValveBiped.Bip01_L_Forearm
ValveBiped.Bip01_L_Hand
ValveBiped.Anim_Attachment_LH
ValveBiped.Bip01_R_Thigh
ValveBiped.Bip01_R_Calf
ValveBiped.Bip01_R_Foot
ValveBiped.Bip01_R_Toe0
ValveBiped.Bip01_L_Thigh
ValveBiped.Bip01_L_Calf
ValveBiped.Bip01_L_Foot
ValveBiped.Bip01_L_Toe0
ValveBiped.Bip01_L_Finger4
ValveBiped.Bip01_L_Finger41
ValveBiped.Bip01_L_Finger42
ValveBiped.Bip01_L_Finger3
ValveBiped.Bip01_L_Finger31
ValveBiped.Bip01_L_Finger32
ValveBiped.Bip01_L_Finger2
ValveBiped.Bip01_L_Finger21
ValveBiped.Bip01_L_Finger22
ValveBiped.Bip01_L_Finger1
ValveBiped.Bip01_L_Finger11
ValveBiped.Bip01_L_Finger12
ValveBiped.Bip01_L_Finger0
ValveBiped.Bip01_L_Finger01
ValveBiped.Bip01_L_Finger02
ValveBiped.Bip01_R_Finger4
ValveBiped.Bip01_R_Finger41
ValveBiped.Bip01_R_Finger42
ValveBiped.Bip01_R_Finger3
ValveBiped.Bip01_R_Finger31
ValveBiped.Bip01_R_Finger32
ValveBiped.Bip01_R_Finger2
ValveBiped.Bip01_R_Finger21
ValveBiped.Bip01_R_Finger22
ValveBiped.Bip01_R_Finger1
ValveBiped.Bip01_R_Finger11
ValveBiped.Bip01_R_Finger12
ValveBiped.Bip01_R_Finger0
ValveBiped.Bip01_R_Finger01
ValveBiped.Bip01_R_Finger02
ValveBiped.Bip01_L_Elbow
ValveBiped.Bip01_L_Ulna
ValveBiped.Bip01_R_Ulna
ValveBiped.Bip01_L_Pectoral
ValveBiped.Bip01_R_Shoulder
ValveBiped.Bip01_L_Shoulder
ValveBiped.Bip01_R_Trapezius
ValveBiped.Bip01_R_Wrist
ValveBiped.Bip01_R_Bicep
ValveBiped.Bip01_L_Bicep
ValveBiped.Bip01_L_Trapezius
ValveBiped.Bip01_L_Wrist
ValveBiped.Bip01_R_Elbow

LrigPelvis
LrigSpine1
LrigSpine2
LrigRibcage
LrigNeck1
LrigNeck2
LrigNeck3
LrigScull
Lrig_LEG_BL_Femur
Lrig_LEG_BL_Tibia
Lrig_LEG_BL_LargeCannon
Lrig_LEG_BL_PhalanxPrima
Lrig_LEG_BL_RearHoof
Lrig_LEG_BR_Femur
Lrig_LEG_BR_Tibia
Lrig_LEG_BR_LargeCannon
Lrig_LEG_BR_PhalanxPrima
Lrig_LEG_BR_RearHoof
Lrig_LEG_FL_Scapula
Lrig_LEG_FL_Humerus
Lrig_LEG_FL_Radius
Lrig_LEG_FL_Metacarpus
Lrig_LEG_FL_PhalangesManus
Lrig_LEG_FL_FrontHoof
Lrig_LEG_FR_Scapula
Lrig_LEG_FR_Humerus
Lrig_LEG_FR_Radius
Lrig_LEG_FR_Metacarpus
Lrig_LEG_FR_PhalangesManus
Lrig_LEG_FR_FrontHoof
Mane01
Mane02
Mane03
Mane04
Mane05
Mane06
Mane07
Mane03_tip
Tail01
Tail02
Tail03
]]

PS_Attachments = {
	eyes = "I'm special",
	head = {"ValveBiped.Bip01_Head1", "LrigScull"},
	neck = {"ValveBiped.Bip01_Neck1", "LrigNeck2"},
	upper_body = {"ValveBiped.Bip01_Spine4", "LrigSpine2"},
	lower_body = {"ValveBiped.Bip01_Spine", "LrigSpine1"},
	left_hand = {"ValveBiped.Bip01_L_Hand", "Lrig_LEG_FL_FrontHoof"},
	right_hand = {"ValveBiped.Bip01_R_Hand", "Lrig_LEG_FR_FrontHoof"},
	left_shoulder = {"ValveBiped.Bip01_L_Clavicle", "Lrig_LEG_FL_Humerus"},
	right_shoulder = {"ValveBiped.Bip01_R_Clavicle", "Lrig_LEG_FR_Humerus"},
	left_foot = {"ValveBiped.Bip01_L_Foot", "Lrig_LEG_BL_RearHoof"},
	right_foot = {"ValveBiped.Bip01_R_Foot", "Lrig_LEG_BR_RearHoof"},
}


function PS_CalculateSellPrice(ply, item)
	if item.class=="ponymodel" then return item.price*0.5 end
	return math.Round(item.price * 0.8)
end

function PS_BaseIncome(ply)
	return math.floor(20+math.Clamp((ply:PS_GetPoints())/5000,0,80))
end

function PS_BaseIncomeMultiplier(ply)
	local cash = ply:PS_GetDonation()
	local incomelevel = math.min(math.floor(math.min(cash,2000)/1000) + math.floor(cash/10000) + 1, 42)
	
	local mult = ((ply.HasHalfPoints and 1 or 3) + incomelevel) * 0.25
	
	if ply:IsAFK() then
		mult = mult/2
	else
		mult = mult*2
	end

	return mult
end

NoPointAltIds = {
["STEAM_0:1:149372369"]=true,
["STEAM_0:0:183199559"]=true,
["STEAM_0:0:179623822"]=true }

function PS_Income(ply)
	if NoPointAltIds[ply:SteamID()] then return 0 end
	local income = math.floor(PS_BaseIncome(ply) * PS_BaseIncomeMultiplier(ply))
	--if GAMEMODE.FolderName=="spades" then income=income*2 end
	if os.time() < 1601402349 then income=income*2 end
	return income
end
