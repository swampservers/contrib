-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
include('shared.lua')
DEFINE_BASECLASS("base_anim")

-- DEFINE_BASECLASS("base_gmodentity")
PropTrashLightData = {
    ["models/props_interiors/furniture_lamp01a.mdl"] = {
        untaped = false,
        size = 500,
        brightness = 2,
        style = 0,
        pos = Vector(0, 0, 27)
    },
    ["models/maxofs2d/light_tubular.mdl"] = {
        untaped = false,
        size = 300,
        brightness = 2,
        style = -1,
        pos = Vector(0, 0, 0)
    }
}

function ENT:Think()
    local light = PropTrashLightData[self:GetModel()]

    if light and (self:GetTaped() or light.untaped) and EyePos():Distance(self:GetPos()) < (self:GetPos().z > -48 and 1000 or 3000) then
        local dlight = DynamicLight(self:EntIndex())

        if dlight then
            dlight.pos = self:LocalToWorld(light.pos)
            dlight.r = self:GetColor().r
            dlight.g = self:GetColor().g
            dlight.b = self:GetColor().b
            dlight.brightness = light.brightness
            dlight.Size = light.size
            dlight.style = (light.style == -1) and self:EntIndex() % 12 or light.style

            if light.dir then
                local d = Vector(0, 0, 0)
                d:Set(light.dir)
                d:Rotate(self:GetAngles())
                dlight.dir = d
                dlight.innerangle = light.innerangle
                dlight.outerangle = light.outerangle
            end

            dlight.Decay = 500
            dlight.DieTime = CurTime() + 1
        end

        self:SetNextClientThink(CurTime() + 0.1)
    else
        if light then
            self:SetNextClientThink(CurTime() + 0.1)
        else
            self:SetNextClientThink(CurTime() + 9999)
        end
    end

    return true
end

function ENT:Draw()
    local acd = self:GetPos():DistToSqr(EyePos())
    local acr = AutoCullBase() * (self:GetModelRadius() or 1)
    if acd > acr * 3.5 then return end
    -- if PropTrashLookedAt == self then
    --     local cr, cg, cb = render.GetColorModulation()
    --     local id = LocalPlayer():SteamID()
    --     render.SetColorModulation(1, 0.5, 0)
    --     if self:GetTaped() then
    --         if self:CanEdit(id) then
    --             render.SetColorModulation(0, 1, 1)
    --         end
    --     else
    --         if self:CanTape(id) then
    --             render.SetColorModulation(1, 1, 1)
    --         end
    --     end
    --     self:DrawOutline()
    --     render.SetColorModulation(cr, cg, cb)
    -- end
    local painted = self:GetMaterial() == "phoenix_storms/gear"

    if painted then
        local cr, cg, cb = render.GetColorModulation()
        render.SetColorModulation((cr * 1.6) + 0.3, (cg * 1.6) + 0.3, (cb * 1.6) + 0.3)
    else
        local c = self:GetNWVector("BasedColor", Vector(1, 1, 1))
        render.SetColorModulation(c.x, c.y, c.z)
        local imgur, own = self:GetImgur()

        if imgur then
            render.MaterialOverride(ImgurMaterial({
                id = imgur,
                owner = own,
                worksafe = true,
                pos = self:GetPos(),
                stretch = true,
                shader = "VertexLitGeneric"
            }))
        end
    end

    self:DrawModel()
    render.SetColorModulation(1, 1, 1)
    render.MaterialOverride()
    local h = self:Health()

    if h < 100 and MININGCRACKMATERIALS then
        if acd > acr * 1 then return end
        h = math.min(math.ceil((1 - (h / 100)) * 10), 10)
        if h <= 0 then return end
        render.MaterialOverride(MININGCRACKMATERIALS[h])
        render.DepthRange(0, 0.9998)
        self:DrawModel()
        render.DepthRange(0, 1)
        render.MaterialOverride()
    end
end

hook.Add("PreDrawHalos", "TrashHalos", function()
    if IsValid(PropTrashLookedAt) then
        local c = Color(255, 128, 0)

        if PropTrashLookedAt:GetTaped() then
            if PropTrashLookedAt:CanEdit(id) then
                c = Color(0, 255, 255)
            end
        else
            if PropTrashLookedAt:CanTape(id) then
                c = Color(255, 255, 255)
            end
        end

        local sz = ScrH() / 200

        halo.Add({PropTrashLookedAt}, c, sz, sz, 1, true, false)
    end
end)

hook.Add("HUDPaint", "TrashHUD", function()
    if IsValid(PropTrashLookedAt) then
        local c = PropTrashLookedAt:LocalToWorld(PropTrashLookedAt:OBBCenter()):ToScreen()

        if c.visible then
            draw.SimpleText(PropTrashLookedAt:GetOwnerID() == LocalPlayer():SteamID() and "Yours" or "Not yours", "DermaDefault", c.x, c.y, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
end)