-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
include('shared.lua')
DEFINE_BASECLASS("base_anim")
TRASH_LIGHTS = TRASH_LIGHTS or {}
DAMAGED_TRASH = DAMAGED_TRASH or {}

hook.Add("PostDrawTranslucentRenderables", "TrashDamage", function()
    for ent, _ in pairs(DAMAGED_TRASH) do
        if IsValid(ent) then
            if MININGCRACKMATERIALS then
                local acd = ent:GetPos():DistToSqr(EyePos())
                local acr = AutoCullBase() * (ent:GetModelRadius() or 1)

                if acd < acr * 1 then
                    local h = math.min(math.ceil((1 - ent:GetStrength()) * 10), 10)

                    if h > 0 then
                        render.MaterialOverride(MININGCRACKMATERIALS[h])
                        render.DepthRange(0, 0.9998)
                        ent:DrawModel()
                        render.DepthRange(0, 1)
                        render.MaterialOverride()
                    end
                end
            end
        else
            DAMAGED_TRASH[ent] = nil
        end
    end
end)

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

    self.MyLightData = PropTrashLightData[self:GetModel()]
    TRASH_LIGHTS[self] = self.MyLightData
    self:ApplyMaterialData(self:GetMaterialData())
    -- local col = self:GetUnboundedColor()
    -- local imgur, own = self:GetImgur()
    -- print(self, col, imgur, self:GetModel())
    -- if imgur then
    --     self:SetWebMaterial({
    --         id = imgur,
    --         owner = own,
    --         params = [[{["$alphatest"]=1,["$color2"]="[]] .. tostring(col) .. [[]"}]]
    --     })
    -- else
    --     if col.x ~= 1 or col.y ~= 1 or col.z ~= 1 then
    --         print("COL",self)
    --         self:SetColoredBaseMaterial(col)
    --     end
    -- end
end

hook.Add("NotifyShouldTransmit", "ReaddTrashLight", function(ent, trans)
    local ld = ent.MyLightData

    if ld then
        TRASH_LIGHTS[ent] = trans and ld or nil
    end
end)

TRASH_PAINT_MATERIALS = TRASH_PAINT_MATERIALS or {}

local function GetPaintMaterial(paintid, col)
    TRASH_PAINT_MATERIALS[paintid] = TRASH_PAINT_MATERIALS[paintid] or {}
    local t = TRASH_PAINT_MATERIALS[paintid]
    local colstr = tostring(col)

    if not t[colstr] then
        t[colstr] = CreateMaterial("trashpaint" .. paintid .. " " .. colstr:gsub("%.", "p"), "VertexLitGeneric", {
            ["$basetexture"] = "phoenix_storms/gear",
            ["$color2"] = "[" .. tostring(col * 1.7 + 0.3) .. "]"
        })
        --was *1.6 + 0.3
    end

    return t[colstr]
end

-- function ENT:GetUnboundedColor()
--     return self:GetNWVector("col",Vector(1,1,1))
-- end
-- put it into one string to make sure only one update callback runs
function ENT:ApplyMaterialData(data)
    data = util.JSONToTable(data) or {}

    if data.p then
        self:SetMaterial("!" .. GetPaintMaterial(data.p, data.pc):GetName())
        self.lightcolor = data.pc

        return
    end

    local col = data.c or Vector(1, 1, 1)
    self.lightcolor = col

    if data.i then
        self:SetWebMaterial({
            id = data.i,
            owner = data.o,
            params = [[{["$alphatest"]=1,["$color2"]="[]] .. tostring(col) .. [[]"}]]
        })
    elseif col.x ~= 1 or col.y ~= 1 or col.z ~= 1 then
        self:SetColoredBaseMaterial(col)
    else
        self:SetMaterial()
    end
end

function ENT:Draw()
    --     local acd = self:GetPos():DistToSqr(EyePos())
    --     local acr = AutoCullBase() * (self:GetModelRadius() or 1)
    --     if acd > acr * 3.5 then return end
    --     local painted = self:GetMaterial() == "phoenix_storms/gear"
    --     if painted then
    --         local cr, cg, cb = render.GetColorModulation()
    --         render.SetColorModulation((cr * 1.6) + 0.3, (cg * 1.6) + 0.3, (cb * 1.6) + 0.3)
    --     else
    --         if self.GetUnboundedColor then
    --             local c = self:GetUnboundedColor()
    --             render.SetColorModulation(c.x, c.y, c.z)
    --         end
    --         local imgur, own = self:GetImgur()
    --         if imgur then
    --             render.MaterialOverride(ImgurMaterial({
    --                 id = imgur,
    --                 owner = own,
    --                 worksafe = true,
    --                 pos = self:GetPos(),
    --                 stretch = true,
    --                 shader = "VertexLitGeneric"
    --             }))
    --         end
    --     end
    self:DrawModel()
    --     render.SetColorModulation(1, 1, 1)
    --     render.MaterialOverride()
    --     -- local h = self.GetStrength and self:GetStrength()*100 or 100 --self:Health()
    --     -- if h < 100 and MININGCRACKMATERIALS then
    --     --     if acd > acr * 1 then return end
    --     --     h = math.min(math.ceil((1 - (h / 100)) * 10), 10)
    --     --     if h <= 0 then return end
    --     --     render.MaterialOverride(MININGCRACKMATERIALS[h])
    --     --     render.DepthRange(0, 0.9998)
    --     --     self:DrawModel()
    --     --     render.DepthRange(0, 1)
    --     --     render.MaterialOverride()
    --     -- end
end

TRASH_LIGHTS = TRASH_LIGHTS or {}

-- TODO can we do one every tick cyclically instead of all at once
timer.Create("TrashLights", 0.2, 0, function()
    if not IsValid(LocalPlayer()) then return end
    local ep = LocalPlayer():EyePos()

    for e, l in pairs(TRASH_LIGHTS) do
        if not IsValid(e) or e:IsDormant() then
            TRASH_LIGHTS[e] = nil
            continue
        end

        -- for edits
        -- l = PropTrashLightData[e:GetModel()]
        -- if not l then
        --     TRASH_LIGHTS[e] = nil
        --     continue
        -- end
        -- if e:IsDormant() then continue end
        if (l.untaped or e:GetTaped()) and ep:DistToSqr(e:GetPos()) < (e:GetPos().z > -48 and 1000 * 1000 or 3000 * 3000) then
            local dlight = DynamicLight(e:EntIndex())
            local c = (e.lightcolor or Vector(1, 1, 1)) * 255

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

                -- 1000 seconds to fade out
                dlight.Decay = 1
                dlight.DieTime = CurTime() + 0.5
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

            for k, v in ipairs(FindAllTrash()) do
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

--NOMINIFY
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
