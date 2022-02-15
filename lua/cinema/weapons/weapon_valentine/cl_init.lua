-- This file is subject to copyright - contact swampservers@gmail.com for more information.
include('shared.lua')

--NOMINIFY
function ValentineUI(dear, sincerely)
    if IsValid(ValentineFrame) then
        ValentineFrame:Remove()
    end

    vgui("DFrame", function(p)
        ValentineFrame = p
        p:SetSize(600, 600)
        p:Center()
        p:MakePopup()
        p:SetTitle("")
        p:ShowCloseButton(false)

        function p:Paint(w, h)
            surface.SetMaterial(Material["holiday/valentine_card_unlit"])
            surface.SetDrawColor(Color.white)
            surface.DrawTexturedRect(0, 0, w, h)
        end

        vgui("DLabel", function(p)
            p:SetText("Dear " .. dear .. ",")
            p:SetFont(Font["Segoe Script40"])
            p:SetTall(40)
            p:SetContentAlignment(5)
            p:Dock(TOP)
            p:SetTextColor(Color.white)
            p:DockMargin(0, 190, 0, 0)
        end)

        p.Note = vgui("SLabel", function(p)
            p:Dock(BOTTOM)
            p:SetContentAlignment(5)
            p:SetTall(40)
        end)

        vgui("Panel", function(p)
            p:Dock(BOTTOM)
            p:SetTall(24)
            p:DockPadding(200, 0, 200, 0)

            ValentineFrame.Button1 = vgui("DButton", function(p)
                p:Dock(LEFT)
                p:SetWide(80)
            end)

            ValentineFrame.Button2 = vgui("DButton", function(p)
                p:Dock(RIGHT)
                p:SetWide(80)
            end)
        end)

        vgui("DLabel", function(p)
            p:Dock(BOTTOM)
            p:SetText(sincerely)
            p:SetFont(Font["Segoe Script40"])
            p:SetContentAlignment(5)
            p:SetTextColor(Color.white)
            p:SetTall(40)
            p:DockMargin(0, 0, 0, 80)
        end)

        vgui("DLabel", function(p)
            p:Dock(BOTTOM)
            p:SetText("Sincerely,")
            p:SetFont(Font["Segoe Script48"])
            p:SetContentAlignment(5)
            p:SetTextColor(Color.white)
            p:SetTall(40)
        end)
    end)
end

function SWEP:DrawWorldModel()
    local ply = self:GetOwner()

    if IsValid(ply) then
        local bp, ba = ply:GetBonePosition(ply:LookupBone(ply:IsPony() and "LrigScull" or "ValveBiped.Bip01_R_Hand") or 0)
        local pos, ang

        if bp then
            pos, ang = bp, ba
        else
            pos, ang = self:GetPos(), self:GetAngles()
        end

        if ply:IsPony() then
            pos, ang = LocalToWorld(Vector(8.5, 4, 0), Angle(0, 90, 90), pos, ang)
        else
            pos, ang = LocalToWorld(Vector(4, -4, 0), Angle(-90, -20, 0), pos, ang)
        end

        self:SetupBones()
        local mrt = Matrix()
        mrt:SetTranslation(pos)
        mrt:SetAngles(ang)
        self:SetBoneMatrix(0, mrt)
    end

    render.ModelMaterialOverride(Material["holiday/valentine_card"])
    self:DrawModel()
    render.ModelMaterialOverride()
end

function SWEP:PreDrawViewModel()
    render.ModelMaterialOverride(Material["holiday/valentine_card"])
end

function SWEP:PostDrawViewModel()
    render.ModelMaterialOverride()
end

function SWEP:GetViewModelPosition(pos, ang)
    pos, ang = LocalToWorld(Vector(15, -8, -8), Angle(70, 90, 0), pos, ang)

    return pos, ang
end
