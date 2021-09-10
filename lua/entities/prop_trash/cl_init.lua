-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
include('shared.lua')
DEFINE_BASECLASS("base_anim")
TRASH_LIGHTS = TRASH_LIGHTS or {}
DAMAGED_TRASH = DAMAGED_TRASH or {}

hook.Add("PostDrawTranslucentRenderables", "TrashDamage", function()
    for ent, _ in pairs(DAMAGED_TRASH) do
        if IsValid(ent) and not ent:IsDormant() then
            if MININGCRACKMATERIALS then
                local acd = ent:GetPos():DistToSqr(EyePos())
                local acr = 200000 * (ent:GetModelRadius() or 1)

                if acd < acr then
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
    local special = self:GetSpecialModelData()

    self.MyLightData = special.class == "light" and special.data or nil
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

    -- ["$alphatest"]=1,
    if data.i then
        self:SetWebMaterial({
            id = data.i,
            owner = data.o,
            params = [[{["$color2"]="[]] .. tostring(col) .. [[]"}]]
        })
    else
        self:SetColoredBaseMaterial(col)
    end
end


-- local matcache = {}

-- function ENT:SetGoodSkin()
--     self:SetMaterial()
--     self:SetSkin(0) 

--     local mdl = self:GetModel()
--     if mdl=="models/props_crates/static_crate_40.mdl" then self:SetSkin(1) end
--     -- local bestidx = 0
--     -- local bestcount = 0

--     -- for i=1,self:SkinCount() do
--     --     self:SetSkin(i-1)

--     --     local okcount = 0
--     --     for j,v in ipairs(self:GetMaterials()) do
--     --         print(i,j,v)
--     --         if matcache[v]==nil then matcache[v]=Material(v) end
--     --         if not matcache[v]:IsError() then okcount=okcount+1 end
--     --     end
        
--     --     if okcount > bestcount then bestidx = i-1 end
--     -- end

--     -- self:SetSkin(bestidx)
-- end

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
local mind2 = 600 ^ 2
local maxd2 = 3000 ^ 2
local targetcount = 8

-- TODO can we do one every tick cyclically instead of all at once
timer.Create("TrashLights", 0.1, 0, function()
    if not IsValid(LocalPlayer()) then return end
    local ep = LocalPlayer():EyePos()
    local ev = LocalPlayer():EyeAngles():Forward()
    local f = CurrentFrustrum()
    local candidates = {}

    for e, l in pairs(TRASH_LIGHTS) do
        if not IsValid(e) or e:IsDormant() then
            TRASH_LIGHTS[e] = nil
            continue
        end

        local p = e:LocalToWorld(l.pos)
        local d = ep:DistToSqr(p)

        local b = e:GetNWFloat("bright",0)

        -- (l.untaped or e:GetTaped()) instead of b>0
        if b>0 and d < maxd2 and not FrustrumCull(f, p, 250) then
            table.insert(candidates, {
                e = e,
                l = l,
                p = p,
                d = d,
                b=b
            })
        else
            if e.lightmade then
                local dlight = DynamicLight(e:EntIndex())
                if dlight then
                    dlight.r = 0
                    dlight.g = 0
                    dlight.b = 0
                    dlight.brightness = 0
                    dlight.Size = 0
                    dlight.Decay = 1
                    dlight.DieTime = CurTime() + 0.01
                end
            end
        end

        e.lightmade = false
    end

    -- print("Candidates", #candidates)
    -- TOPK sort?
    table.SortByMember(candidates, "d", true)

    for i, v in ipairs(candidates) do
        if i > targetcount and v.d > mind2 then break end -- print("break", i-1)
        local e, l, p = v.e, v.l, v.p
        e.lightmade = true
        local dlight = DynamicLight(e:EntIndex())
        local c = (e.lightcolor or Vector(1, 1, 1)) * 255 * v.b

        if dlight then
            dlight.pos = p
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
            dlight.DieTime = CurTime() + 0.3
        end
    end
end)

-- TODO merge this shit with zone
hook.Add("PreDrawTranslucentRenderables", "TrashHoverDraw", function()
    if IsValid(PropTrashLookedAt) and PropTrashLookedAt:GetSpecialModelData().class == "gate" then

        -- render.CullMode(MATERIAL_CULLMODE_CW)
        render.SetColorMaterial()
        local col = Color(255, 160, 80, 60)
        local min, max = unpack(PropTrashLookedAt:GetSpecialModelData().data.inputarea )
        render.DrawBox(PropTrashLookedAt:GetPos(), PropTrashLookedAt:GetAngles(), min, max, col, false)
        -- render.CullMode(MATERIAL_CULLMODE_CCW)
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
            local owner = player.GetBySteamID(PropTrashLookedAt:GetOwnerID())
            draw.SimpleText(owner == LocalPlayer() and "Yours" or (IsValid(owner) and "Belongs to " .. owner:GetName() or "Belongs to someone offline."), "DermaDefault", c.x, c.y, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    local lastt = LocalPlayer():GetNWFloat("LastTrash", 0)

    if lastt + TRASH_SPAWN_COOLDOWN > CurTime() then
        local barsize = (1 - (CurTime() - lastt) / TRASH_SPAWN_COOLDOWN) * ScrW() / 2
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawRect(ScrW() / 2 - barsize, ScrH() - 10, barsize * 2, 10)
    end
end)
