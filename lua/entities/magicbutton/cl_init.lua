-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
AddCSLuaFile()
include("shared.lua")
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
        local pulse = math.sin(math.rad((CurTime()+self.timeoffs) * 720)) > 0 and 1 or 0.3

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

        for i = 0, 5 do
            render.SetModelLighting(i, lc.x, lc.y, lc.z)
        end

        render.SetLocalModelLights({light1})

        render.SetAmbientLight(0.05, 0.05, 0.05)
        --render.SuppressEngineLighting( true )
        self:DrawModel()
        render.SuppressEngineLighting(false)

        if (drawsprite) then
            render.SetMaterial(glintmat)
            render.DrawQuadEasy(spritepos, spritenormal, size, size, (cvector):ToColor(), 0)
        end
    end

    net.Receive("magicbutton_transmitclone", function(len)
        local id = net.ReadInt(17)
        local pos = net.ReadVector()
        local ang = net.ReadAngle()
        local color = net.ReadColor()
        local state = net.ReadBool()
        local decay = net.ReadInt(7)

        if (decay == 0) then
            decay = nil
        end

        MAGICBUTTON_PLACECLIENT(id, pos, ang, color, state, decay)
    end)

    BUTTONS_CLIENT = BUTTONS_CLIENT or {}
    hook.Add("PostDrawOpaqueRenderables","DrawMagicButtons",function(depth,sky)
        local drawn = 0
        MAGICBUTTON_RENDERER = MAGICBUTTON_RENDERER or ClientsideModel("models/pyroteknik/secretbutton.mdl")
        MAGICBUTTON_RENDERER:SetPos(Vector())
        for k,v in pairs(BUTTONS_CLIENT)do
            if(v.color.a == 0)then continue end
            MAGICBUTTON_RENDERER.Pressed = v.state
            MAGICBUTTON_RENDERER.timeoffs = v.timeoffs
            
            MAGICBUTTON_RENDERER:SetLOD(0)
            MAGICBUTTON_RENDERER:SetPos(v.pos)
            MAGICBUTTON_RENDERER:SetAngles(v.ang)
            MAGICBUTTON_RENDERER:SetColor(v.color)
            MAGICBUTTON_RENDERER:ManipulateBonePosition(1,v.state and Vector(0,0,-0.5) or Vector())
            MAGICBUTTON_RENDERER:SetupBones()
            MAGICBUTTON_RENDERER:DrawModel()
            drawn = drawn + 1
            MAGICBUTTON_RENDER(MAGICBUTTON_RENDERER)
        end
        MAGICBUTTON_RENDERER:SetPos(Vector())
    end)

    function MAGICBUTTON_PLACECLIENT(id, pos, ang, color, state, decay)
        local existing = BUTTONS_CLIENT[id]
        BUTTONS_CLIENT[id] = {pos=pos,ang=ang,color=color,state=state,timeoffs=(existing and existing.timeoffs) or math.Rand(0,1)}
        timer.Create(id .. "buttonmodel_clear", decay or 2, 1, function()
            BUTTONS_CLIENT[id] = nil
        end)
    end
end