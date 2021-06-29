-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
AddCSLuaFile()
include("shared.lua")
language.Add("magicbutton", "Comedy")

hook.Add("GetTeamColor", "magicbutton_deathnotice", function(ent)
    if (ent:GetClass() == "magicbutton") then return Color(248, 204, 58) end
end)

local glintmat 

if (CLIENT) then
    glintmat = CreateMaterial("magicbutton_glint", "UnlitGeneric", {
        ["$basetexture"] = "sprites/physgun_glow",
        ["$model"] = 1,
        ["$additive"] = 1,
        ["$translucent"] = 1,
        ["$color2"] = Vector(4, 4, 4),
        ["$vertexalpha"] = 1,
        ["$vertexcolor"] = 1
    })
end

if (CLIENT) then
    function MAGICBUTTON_RENDER(self, flags)
        local pos = self:GetPos() + self:GetUp() * 3
        local c = self:GetColor()
        local spritepos = self:GetPos() + self:GetUp() * 1
        local spritenormal = EyePos() - spritepos
        local size = math.Clamp(spritenormal:Length() / 8, 16, 48)
        local drawsprite = true
        local pulse = math.sin(math.rad((CurTime() + self.timeoffs) * 720)) > 0 and 1 or 0.3

        if (self.Pressed) then
            drawsprite = false
            pulse = 0.2
        end

        local cvector = (Vector(c.r, c.g, c.b) / 255) * pulse
        local lc = render.ComputeLighting(pos, self:GetUp())
        spritepos = spritepos + spritenormal:GetNormalized() * 2
        render.SetColorModulation(cvector.x, cvector.y, cvector.z)
        local light1 = {}
        light1.type = MATERIAL_LIGHT_POINT
        light1.color = cvector * 15
        light1.pos = pos
        light1.fiftyPercentDistance = 2.35
        light1.zeroPercentDistance = 4
        render.SuppressEngineLighting(true)
        local normals = {
            Vector(1,0,0),
            Vector(-1,0,0),
            Vector(0,-1,0),
            Vector(0,1,0),
            Vector(0,0,1),
            Vector(0,0,-1),
        }

        for i = 0, 5 do
            local nrm = normals[i + 1]
            local light = render.ComputeLighting( self:GetPos() + nrm * -1, nrm)
            --debugoverlay.Line( self:GetPos() + nrm * 1, self:GetPos() + nrm * 4, 0.1, HSVToColor(i*45,1,1), true )
            
            render.SetModelLighting(i, light.x, light.y, light.z)

        end

        if (not self.Pressed) then
            render.SetLocalModelLights({light1})
        end



        render.SetAmbientLight(0.05, 0.05, 0.05)
        self:DrawModel()
        render.SuppressEngineLighting(false)

        if (drawsprite) then
            render.SetMaterial(glintmat)
            render.DrawQuadEasy(spritepos, spritenormal, size, size, (cvector):ToColor(), 0)
        end
    end

    net.Receive("magicbutton_transmitclone", function(len)
        local id = net.ReadInt(17)
        local decay = net.ReadInt(7)
        local pos = net.ReadVector()
        local ang = net.ReadAngle()
        local color = net.ReadColor()
        local state = net.ReadBool()

        if (decay == 0) then
            decay = nil
        end

        local existing = BUTTONS_CLIENT[id]

        if (decay == nil) then
            BUTTONS_CLIENT[id] = nil

            return
        end

        local lod = 0

        if (pos:Distance(EyePos()) > 500) then
            lod = 1
        end

        if (pos:Distance(EyePos()) > 1500) then
            lod = 2
        end

        BUTTONS_CLIENT[id] = {
            pos = pos,
            ang = ang,
            color = color,
            state = state,
            lod = lod,
            timeoffs = (existing and existing.timeoffs) or math.Rand(0, 1),
            decay = CurTime() + decay
        }
    end)

    BUTTONS_CLIENT = BUTTONS_CLIENT or {}

    hook.Add("PostDrawOpaqueRenderables", "DrawMagicButtons", function(depth, sky)
        local drawn = 0
        MAGICBUTTON_RENDERER = MAGICBUTTON_RENDERER or ClientsideModel("models/pyroteknik/secretbutton.mdl")
        MAGICBUTTON_RENDERER:SetPos(Vector())

        for k, v in pairs(BUTTONS_CLIENT) do
            if (CurTime() > (v.decay or 0)) then
                BUTTONS_CLIENT[k] = nil
                continue
            end

            if (v.color.a == 0) then continue end
            MAGICBUTTON_RENDERER.Pressed = v.state
            MAGICBUTTON_RENDERER.timeoffs = v.timeoffs
            MAGICBUTTON_RENDERER:SetPos(v.pos)
            MAGICBUTTON_RENDERER:SetAngles(v.ang)
            MAGICBUTTON_RENDERER:SetColor(v.color)
            MAGICBUTTON_RENDERER:SetLOD(v.lod or 2)
            MAGICBUTTON_RENDERER:ManipulateBonePosition(1, v.state and Vector(0, 0, -0.5) or Vector())
            MAGICBUTTON_RENDERER:SetupBones()
            MAGICBUTTON_RENDERER:DrawModel()
            drawn = drawn + 1
            MAGICBUTTON_RENDER(MAGICBUTTON_RENDERER)
        end

        MAGICBUTTON_RENDERER:SetPos(Vector())
    end)
end