-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Helltaker"
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize()
    self:SetModel("models/unconid/arcade_machine_helltaker.mdl") -- models/props_lab/generatorconsole.mdl")
    self:SetMoveType(MOVETYPE_NONE)
    self:PhysicsInitStatic(SOLID_VPHYSICS)
    self:DrawShadow(false)
    local phys = self:GetPhysicsObject()

    if IsValid(phys) then
        phys:EnableMotion(false)
    end

    if SERVER then
        self:SetUseType(SIMPLE_USE)
    end
end

function ENT:Use(act)
    if act:IsPlayer() then
        net.Start("HELLTAKER")
        net.WriteEntity(self)
        net.Send(act)
        -- act:Lock()
    end
end

function ENT:ScreenCenter()
    return LocalToWorld(Vector(0, -7, 59), Angle(0, 0, 61), self:GetPos(), self:GetAngles())
end

if CLIENT then
    DRAWN_HT_ENTS = {}

    function ENT:Draw()
        table.insert(DRAWN_HT_ENTS, self)
        self:DrawModel()
    end

    hook.Add("CalcView", "HellTakerView", function(ply, pos, angles, fov)
        if IsValid(HELLTAKERFRAME) then
            if IsValid(LocalPlayer()) and LocalPlayer():InVehicle() then
                HELLTAKERFRAME:Close()

                return
            end

            if IsValid(HELLTAKERPLAYENT) then
                local p, a = HELLTAKERPLAYENT:ScreenCenter()
                a:RotateAroundAxis(a:Up(), 90)
                a:RotateAroundAxis(a:Right(), -90)
                local lerp = math.min(1, (SysTime() - HELLTAKERPLAYENTTIME) * 2)
                lerp = 0.5 - 0.5 * math.cos(lerp * math.pi)

                return {
                    origin = LerpVector(lerp, pos, p - a:Forward() * 50 - a:Up() * 1),
                    angles = LerpAngle(lerp, angles, a),
                    fov = Lerp(lerp, fov, 60),
                    drawviewer = false
                }
            end
        end
    end)

    hook.Add("PreDrawViewModel", "HelltakerRemoveVM", function()
        if IsValid(HELLTAKERFRAME) then return true end
    end)

    hook.Add("PostDrawTranslucentRenderables", "DrawHTScreen", function()
        if #DRAWN_HT_ENTS > 0 then
            if IsValid(HELLTAKERHTML) then
                HELLTAKERHTML:UpdateHTMLTexture()
                local m = HELLTAKERHTML:GetHTMLMaterial() or Material("tools/toolsblack")

                if m then
                    surface.SetMaterial(m)
                    surface.SetDrawColor(255, 255, 255)

                    for i, v in ipairs(DRAWN_HT_ENTS) do
                        local p, a = v:ScreenCenter()
                        local w, h = HELLTAKERHTML:GetSize()
                        local tw = 310
                        local th = h * tw / w

                        cam.Culled3D2D(p, a, 0.1, function()
                            cam.IgnoreZ(true)
                            surface.DrawTexturedRectUV(-(tw / 2), -(th / 2), tw, th, 0, 0, w / math.nextpow2(w), h / math.nextpow2(h))
                            cam.IgnoreZ(false)
                        end)
                    end
                end
            end

            DRAWN_HT_ENTS = {}
        end
    end)

    function PlayHelltaker()
        -- if LocalPlayer():Nick() ~= "Joker Gaming" then return end
        if IsValid(HELLTAKERFRAME) then
            HELLTAKERFRAME:Close()

            return
        end

        HELLTAKERFRAME = vgui.Create("DFrame")
        -- HELLTAKERFRAME:SetTitle("") --"Helltaker (WIP)")
        -- HELLTAKERFRAME:ShowCloseButton(false)
        HELLTAKERFRAME:SetSize(900, 890 + 24)
        HELLTAKERFRAME:Center()
        HELLTAKERFRAME:MakePopup()
        HELLTAKERFRAME:SetZPos(-1000)

        -- HELLTAKERFRAME:SetPos(0,1100)
        -- 'function Frame:Paint( w, h )' works too
        -- Frame.Paint = function(self, w, h)
        --     draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255, 150))
        -- end
        function HELLTAKERFRAME:Paint()
        end

        HELLTAKERHTML = vgui.Create("HTML", HELLTAKERFRAME)
        HELLTAKERHTML:SetPos(0, 24)
        HELLTAKERHTML:SetSize(900, 890)
        HELLTAKERHTML:OpenURL("swamp.sv/helltaker")
        HELLTAKERHTML:SetZPos(-10000)
        HELLTAKERHTML:RunJavascript("defaultcontrols=false;")
        HELLTAKERFRAME:SetMouseInputEnabled(false)
        HELLTAKERFRAME:SetKeyboardInputEnabled(true)
        HELLTAKERHTML:SetKeyboardInputEnabled(false)
        HELLTAKERFRAME:RequestFocus()

        function HELLTAKERFRAME:OnKeyCodePressed(code)
            local map = {
                [KEY_UP] = "ArrowUp",
                [KEY_DOWN] = "ArrowDown",
                [KEY_LEFT] = "ArrowLeft",
                [KEY_RIGHT] = "ArrowRight",
                [KEY_H] = "KeyH",
                [KEY_N] = "KeyN",
                [KEY_R] = "KeyR",
                [KEY_ENTER] = "Enter",
                [KEY_BACKSPACE] = "Backspace",
                [KEY_0] = "Digit0",
                [KEY_1] = "Digit1",
                [KEY_2] = "Digit2",
                [KEY_3] = "Digit3",
                [KEY_4] = "Digit4",
                [KEY_5] = "Digit5",
                [KEY_6] = "Digit6",
                [KEY_7] = "Digit7",
                [KEY_8] = "Digit8",
                [KEY_9] = "Digit9",
            }

            if map[code] then
                HELLTAKERHTML:RunJavascript('DOMOVE("' .. map[code] .. '");')
            else
                local b = input.LookupKeyBinding(code)

                if code == KEY_E or b == "use" or b == "+use" then
                    self:Close()
                end
            end
        end

        HELLTAKERFRAME:SetAlpha(0)

        -- HELLTAKERFRAME:SetVisible(false)
        function HELLTAKERFRAME:OnClose()
            net.Start("HELLTAKER")
            net.SendToServer()
        end
    end

    net.Receive("HELLTAKER", function(len)
        HELLTAKERPLAYENT = net.ReadEntity()
        HELLTAKERPLAYENTTIME = SysTime()
        PlayHelltaker()
    end)
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
        e:SetAngles(Angle(0, -90, 0))
        e:SetPos(Vector(-520, 1355, -8))
        e:Spawn()
        e:Activate()
        e = ents.Create("ent_helltaker")
        e:SetAngles(Angle(0, 180, 0))
        e:SetPos(Vector(-2060, -1025, -8))
        e:Spawn()
        e:Activate()
    end

    timer.Simple(0, SETUPHELLTAKER)
    util.AddNetworkString("HELLTAKER")
    net.Receive("HELLTAKER", function(len, ply) end) -- ply:UnLock()
end
