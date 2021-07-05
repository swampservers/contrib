-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
AddCSLuaFile()
local Player = FindMetaTable('Player')

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
SS_Attachments = {
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

local NoPointAltIds = {
    ["STEAM_0:1:149372369"] = true,
    ["STEAM_0:0:183199559"] = true,
    ["STEAM_0:0:179623822"] = true
}

function Player:SS_Income()
    if NoPointAltIds[self:SteamID()] then return 0 end
    local income = math.floor(self:SS_BaseIncome() * self:SS_BaseIncomeMultiplier())

    return income
end

function Player:SS_BaseIncome()
    return math.floor(20 + math.Clamp((self:SS_GetPoints()) / 5000, 0, 80))
end

function Player:SS_BaseIncomeMultiplier()
    local cash = self:SS_GetDonation()
    local incomelevel = math.min(math.floor(math.min(cash, 2000) / 1000) + math.floor(cash / 10000) + 1, 42)
    local mult = (3 + incomelevel) * 0.25

    if self:IsAFK() then
        mult = mult / 2
    else
        mult = mult * 2
    end

    if ((SERVER and self.IN_STEAMGROUP or IN_STEAMGROUP) or 0) <= 0 then
        mult = mult / 2
    end

    return mult
end

SS_AUCTION_COST = 5000
SS_AUCTION_BID_MULTIPLIER = 1.05
SS_AUCTION_PAY_FRACTION = 0.95
SS_AUCTION_DURATION = 5 * 24 * 3600
SS_AUCTION_BID_DURATION = 600
SS_AUCTION_PERPAGE = 20

SS_ItemRatings = {
    {
        id = 1,
        max = 0.1,
        name = "doo doo",
        color = Color(100, 50, 0),
        propnotes = "Can't be frozen, all models destroyable by light damage"
    },
    {
        id = 2,
        max = 0.25,
        name = "Worn out",
        color = Color(80, 80, 80),
        propnotes = "All models destroyable by light damage"
    },
    {
        id = 3,
        max = 0.4,
        name = "Knockoff",
        color = Color(160, 160, 160),
        propnotes = "Unfrozen by light damage, some models destroyable"
    },
    {
        id = 4,
        max = 0.7,
        name = "Standard Issue",
        color = Color(210, 210, 210),
        propnotes = "1 heavy damage to unfreeze, some models destroyable"
    },
    {
        id = 5,
        max = 0.85,
        name = "Upgraded",
        color = Color(80, 220, 0),
        propnotes = "Colorable in inventory, 1 heavy damage to unfreeze, not destroyable"
    },
    {
        id = 6,
        max = 0.95,
        name = "Rare",
        color = Color(0, 128, 255),
        propnotes = "Colorable in inventory, 2 heavy damage to unfreeze, not destroyable"
    },
    {
        id = 7,
        max = 0.995,
        name = "Epic",
        color = Color(128, 0, 255),
        propnotes = "Texturable in inventory, 2 heavy damage to unfreeze, not destroyable"
    },
    {
        id = 8,
        max = 1.0,
        name = "LEGENDARY",
        color = Color(255, 128, 0),
        propnotes = "Can build indoors, texturable in inventory, 2 heavy damage to unfreeze, not destroyable"
    },
    {
        id = 9,
        max = 1337,
        name = "BASED",
        color = Color(255, 0, 0),
        propnotes = "Texturable in inventory, not unfreezable or destroyable"
    },
}

function SS_GetRatingID(r)
    if r == nil then
        return 0
    else
        return SS_GetRating(r).id
    end
end

function SS_GetRating(r)
    for i, v in ipairs(SS_ItemRatings) do
        if v.max >= r then return v end
    end

    return SS_ItemRatings[#SS_ItemRatings]
end
