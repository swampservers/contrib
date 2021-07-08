-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
include('shared.lua')
DEFINE_BASECLASS("base_anim")
TRASH_LIGHTS = TRASH_LIGHTS or {}

function ENT:Initialize()
    -- default light thing
    local mn = table.remove(string.Explode("/", self:GetModel())):lower()

    if mn:find("light") or mn:find("lamp") or mn:find("lantern") then
        PropTrashLightData[self:GetModel()] = {
            untaped = false,
            size = 300,
            brightness = 2,
            style = 0,
            pos = Vector(0, 0, 0)
        }
    end

    TRASH_LIGHTS[self] = PropTrashLightData[self:GetModel()]
end

function ENT:Draw()
    local acd = self:GetPos():DistToSqr(EyePos())
    local acr = AutoCullBase() * (self:GetModelRadius() or 1)
    if acd > acr * 3.5 then return end
    local painted = self:GetMaterial() == "phoenix_storms/gear"

    if painted then
        local cr, cg, cb = render.GetColorModulation()
        render.SetColorModulation((cr * 1.6) + 0.3, (cg * 1.6) + 0.3, (cb * 1.6) + 0.3)
    else
        if self.GetUnboundedColor then
            local c = self:GetUnboundedColor()
            render.SetColorModulation(c.x, c.y, c.z)
        end

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

TRASH_LIGHTS = TRASH_LIGHTS or {}

hook.Add("Think", "TrashLights", function()
    if not IsValid(LocalPlayer()) then return end
    local ep = LocalPlayer():EyePos()

    for e, l in pairs(TRASH_LIGHTS) do
        if not IsValid(e) then
            TRASH_LIGHTS[e] = nil
            continue
        end

        -- for edits
        l = PropTrashLightData[e:GetModel()]
        if e:IsDormant() then continue end

        if (l.untaped or e:GetTaped()) and ep:DistToSqr(e:GetPos()) < (e:GetPos().z > -48 and 1000 * 1000 or 3000 * 3000) then
            local dlight = DynamicLight(e:EntIndex())
            local c = e:GetUnboundedColor() * 255

            if dlight then
                dlight.pos = e:LocalToWorld(l.pos)
                dlight.r = c.x
                dlight.g = c.y
                dlight.b = c.z
                dlight.brightness = l.brightness
                dlight.Size = l.size
                dlight.style = (l.style == -1) and e:EntIndex() % 12 or l.style

                if l.dir then
                    local d = Vector(0, 0, 0)
                    d:Set(l.dir)
                    d:Rotate(e:GetAngles())
                    dlight.dir = d
                    dlight.innerangle = light.innerangle
                    dlight.outerangle = light.outerangle
                end

                dlight.Decay = 500
                dlight.DieTime = CurTime() + 1
            end
        end
    end
end)

hook.Add("PreDrawHalos", "TrashHalos", function()
    if not IsValid(LocalPlayer()) then return end
    local id = LocalPlayer():SteamID()
    local sz = ScrH() / 200

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

        halo.Add({PropTrashLookedAt}, c, sz, sz, 1, true, false)

        if PropTrashLookedAt:GetClass() == "prop_trash_zone" then
            local e = {}

            for k, v in ipairs(ents.FindByClass('prop_trash')) do
                if v ~= PropTrashLookedAt and v:GetPos():WithinAABox(PropTrashLookedAt:GetBounds()) then
                    table.insert(e, v)
                end
            end

            halo.Add(e, Color(255, 0, 255), sz, sz, 1, true, false)
            -- TODO: check:
            -- if v:GetOwnerID() == LocalPlayer():SteamID() then
            --     render.SetColorModulation(0, 1, 1)
            -- else
            --     render.SetColorModulation(1, 0.5, 0)
            -- end
        end
    end

    if IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon():GetClass() == "weapon_trash_manager" then
        if IsValid(TRASHMANAGERWINDOW) then
            if TRASHMANAGERDELETEBUTTON:IsHovered() or TRASHMANAGERDELETEBUTTON:GetText() == "" then
                local d = LocalPlayer():GetActiveWeapon():GetDeleteEntities()
                TRASHMANAGERDELETEBUTTON:SetText("Cleanup " .. #d .. " props")

                if TRASHMANAGERDELETEBUTTON:IsHovered() then
                    halo.Add(d, Color(255, 0, 0), sz, sz, 1, true, false)
                end
            end

            if TRASHMANAGERSAVEBUTTON:IsHovered() or TRASHMANAGERSAVEBUTTON:GetText() == "" then
                local t = LocalPlayer():GetActiveWeapon():GetSaveEntities()
                TRASHMANAGERSAVEBUTTON:SetText("Save " .. #t .. " props")

                if TRASHMANAGERSAVEBUTTON:IsHovered() then
                    halo.Add(t, Color(255, 255, 0), sz, sz, 1, true, false)
                end
            end

            if IsValid(TRASHMANAGERFILEBUTTONS) then
                halo.Add(TRASHMANAGERFILEBUTTONS.mymodels, Color(0, 255, 0), sz, sz, 1, true, false)
            end
        end
        -- 
        -- halo.Add(LocalPlayer():GetActiveWeapon():GetSaveEntities(), Color( 0,255, 0), sz, sz, 1, true, false)
    end
end)

hook.Add("HUDPaint", "TrashHUD", function()
    if not IsValid(LocalPlayer()) then return end

    if IsValid(PropTrashLookedAt) then
        local c = PropTrashLookedAt:LocalToWorld(PropTrashLookedAt:OBBCenter()):ToScreen()

        if c.visible then
            draw.SimpleText(PropTrashLookedAt:GetOwnerID() == LocalPlayer():SteamID() and "Yours" or "Not yours", "DermaDefault", c.x, c.y, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    local lastt = LocalPlayer():GetNWFloat("LastTrash", 0)

    if lastt + TRASH_SPAWN_COOLDOWN > CurTime() then
        local barsize = (1 - (CurTime() - lastt) / TRASH_SPAWN_COOLDOWN) * ScrW() / 2
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawRect(ScrW() / 2 - barsize, ScrH() - 10, barsize * 2, 10)
    end
end)
