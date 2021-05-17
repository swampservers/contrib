-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Helltaker"
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize()
    self:SetModel("models/props_lab/generatorconsole.mdl")
    self:SetMoveType(MOVETYPE_NONE)
    self:PhysicsInitStatic(SOLID_VPHYSICS)
    self:DrawShadow(false)
    -- self:SetAngles(Angle(0, 90, 0))
    -- self:SetPos(Vector(-533, 1505, 0))
    self:SetAngles(Angle(0, 110, 0))
    self:SetPos(Vector(-533, 1320, 0))
    local phys = self:GetPhysicsObject()

    if IsValid(phys) then phys:EnableMotion(false) end

    if SERVER then self:SetUseType(SIMPLE_USE) end
end

function ENT:Use(act)
    if act:IsPlayer() then
        act:SendLua("PlayHelltaker()")
        act:Lock()
    end
end

if CLIENT then
    function PlayHelltaker()
        -- if LocalPlayer():Nick() ~= "Joker Gaming" then return end

        if ValidPanel(HELLTAKERFRAME) then
            HELLTAKERFRAME:Remove()
            HELLTAKERFRAME = nil
            return
        end

        HELLTAKERFRAME = vgui.Create("DFrame")
        HELLTAKERFRAME:SetTitle("Helltaker (WIP)")
        HELLTAKERFRAME:SetSize(800, 824)
        HELLTAKERFRAME:Center()
        HELLTAKERFRAME:MakePopup()
        HELLTAKERFRAME:SetZPos(-1000)

        -- 'function Frame:Paint( w, h )' works too
        -- Frame.Paint = function(self, w, h)
        --     draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255, 150))
        -- end

        HELLTAKERHTML = vgui.Create("HTML", HELLTAKERFRAME)
        HELLTAKERHTML:SetPos(0, 24)
        HELLTAKERHTML:SetSize(800, 800)
        HELLTAKERHTML:OpenURL("swampservers.net/helltaker")
        HELLTAKERHTML:SetZPos(-10000)
        HELLTAKERHTML:RunJavascript("defaultcontrols=false;")

        HELLTAKERFRAME:SetMouseInputEnabled(true)
        HELLTAKERFRAME:SetKeyboardInputEnabled(true)
        HELLTAKERHTML:SetKeyboardInputEnabled(false)
        HELLTAKERFRAME:RequestFocus()

        function HELLTAKERFRAME:OnKeyCodePressed(code)
            local map = {
                [KEY_UP] = "ArrowUp",
                [KEY_DOWN] = "ArrowDown",
                [KEY_LEFT] = "ArrowLeft",
                [KEY_RIGHT] = "ArrowRight",
                [KEY_R] = "KeyR",
                [KEY_ENTER] = "Enter"
            }
            if map[code] then
                HELLTAKERHTML:RunJavascript('DOMOVE("' .. map[code] .. '");')
            end
        end

        function HELLTAKERFRAME:OnClose()
            net.Start("HT_Unlock")
            net.SendToServer()
        end
    end

end

if SERVER then
    hook.Add("InitPostEntity", "MAKEHT", function()
        SHOULDSETUPHELLTAKER = true
        SETUPHELLTAKER()
    end)

    function SETUPHELLTAKER()
        if not SHOULDSETUPHELLTAKER then return end
        for i, v in ipairs(ents.FindByClass("ent_helltaker")) do
            v:Remove()
        end
        local e = ents.Create("ent_helltaker")
        e:Spawn()
        e:Activate()
    end

    timer.Simple(0, SETUPHELLTAKER)

    util.AddNetworkString("HT_Unlock")
    net.Receive("HT_Unlock", function(len, ply) ply:UnLock() end)
end
