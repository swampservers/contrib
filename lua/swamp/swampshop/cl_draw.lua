-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local EntityGetModel = Entity.GetModel

function TryRequestShownItems(ply)
    if ply.RequestedShownItemsVersion ~= ply.NW.ShownItemsVersion then
        ply.RequestedShownItemsVersion = ply.NW.ShownItemsVersion
        RequestShownItems(ply)
    end
end

--NOMINIFY
hook.Add("PrePlayerDraw", "SS_PrePlayerDraw", function(ply)
    if not ply:Alive() then return end
    if EyePos():DistToSqr(ply:GetPos()) > 2000000 then return end
    TryRequestShownItems(ply)
    local m = ply:GetActualModel()

    -- check if player is setup, but skip this check if we already setup this playermodel
    if ply.SS_SetupPlayermodel ~= m then
        m = ply:GetBoneContents(0) ~= 0 and m
    end

    if ply.SS_SetupPlayermodel ~= m then
        SS_ApplyMods(ply, ply.SS_ShownItems)
        ply.SS_SetupPlayermodel = m
    end

    if EyePos():DistToSqr(ply:GetPos()) < 2000000 then
        ply:SS_AttachAccessories(ply.SS_ShownItems)
    end
end)

--only bone scale right now...
--if you do pos/angles, must do a combination override to make it work with emotes, vape arm etc
function SS_ApplyMods(ent, mods)
    local z1, z2, z3 = Vector(1, 1, 1), Vector(0, 0, 0), Angle(0, 0, 0)

    for i = 0, ent:GetBoneCount() - 1 do
        ent:ManipulateBoneScale(i, z1)
        ent:ManipulateBonePosition(i, z2)
        ent:ManipulateBoneAngles(i, z3)
        ent:ManipulateBoneJiggle(i, 0)
    end

    if HumanTeamName then return end
    local pone = IsPonyModel(ent:GetModel())
    local suffix = pone and "_p" or "_h"
    --if pelvis has no children, it's not ready!
    local pelvis = ent:LookupBone(pone and "LrigPelvis" or "ValveBiped.Bip01_Pelvis")
    if pelvis then end -- assert(#ent:GetChildBones(pelvis) > 0, ent:GetModel() ) 
    ent:SetSubMaterial()
    ent:SetPonyMaterials()

    for _, item in pairs(mods or {}) do
        if item.class == "skinner" then
            local col = item.cfg.color or Vector(1, 1, 1)

            -- todo: forceload in shop?
            ent:SetWebSubMaterial(item.cfg.submaterial or 0, {
                id = (item.cfg.imgur or {}).url or "EG84dgp.png",
                owner = ent,
                stretch = true,
                shader = "VertexLitGeneric",
                params = string.format('{["$color2"]="[%f %f %f]"}', col.x, col.y, col.z)
            })
        elseif item.ApplyBoneMod then
            item:ApplyBoneMod(ent)
        end
    end

    local maxscale = ent:GetModel() == "models/milaco/minecraft_pm/minecraft_pm.mdl" and 1 or 2.25 * 1.5

    for i = 0, ent:GetBoneCount() - 1 do
        ent:ManipulateBoneScale(i, ent:GetManipulateBoneScale(i):Clamp(0.125, maxscale))
        ent:ManipulateBonePosition(i, ent:GetManipulateBonePosition(i):Clamp(-8, 8))
    end
end

-- todo: change IN_SHOP to ent attribute?
function SS_SetItemMaterialToEntity(item, ent, owner)
    local col = item.GetColor and item:GetColor() or item.cfg.color or item.color or Vector(1, 1, 1)

    if item.cfg.imgur then
        ent:SetWebMaterial({
            id = item.cfg.imgur.url,
            owner = owner,
            forceload = owner == nil,
            params = [[{["$alphatest"]=1,["$color2"]="[]] .. tostring(col) .. [[]"}]]
        })
    elseif item.material then
        ent:SetMaterial(SS_GetColoredMaterialClone(item.material, col))
    else
        ent:SetColoredBaseMaterial(col)
    end
end

-- Revise if we add translucent accessories
hook.Add("PreDrawOpaqueRenderables", "SS_DrawLocalPlayerAccessories", function()
    if IsValid(Me) and Me:Alive() then
        if Me.RequestedShownItemsVersion ~= Me.NW.ShownItemsVersion then
            Me.RequestedShownItemsVersion = Me.NW.ShownItemsVersion
            RequestShownItems(Me)
        end

        Me:SS_AttachAccessories(Me.SS_ShownItems)
        local d = Me:ShouldDrawLocalPlayer()

        for i, v in ipairs(SS_CreatedAccessories[Me] or {}) do
            -- Setting this on and off during same frame doesn't work
            v:SetNoDraw(true)

            if d then
                v:DrawModel()
            end
        end
    end
end)

-- It seems like the ragdoll is created before the cleanup, so this is ok
hook.Add('CreateClientsideRagdoll', 'SS_CreateClientsideRagdoll', function(ply, rag)
    if IsValid(ply) and ply:IsPlayer() then
        local counter = 0

        for k, mdl in pairs(SS_CreatedAccessories[ply] or {}) do
            counter = counter + 1
            if counter > 10 then return end
            local gib = GibClientProp(mdl:GetModel(), mdl:GetPos(), mdl:GetAngles(), ply:GetVelocity(), 1, 6)

            if mdl.matrix then
                gib:EnableMatrix("RenderMultiply", mdl.matrix)
            end

            local item = mdl.item
            SS_SetItemMaterialToEntity(item, gib, ply)
        end

        -- used by pony model TODO remove
        rag.RagdollSourcePlayer = ply
        SS_ApplyMods(rag, ply.SS_ShownItems)
    end
end)

for k, v in pairs(SS_CreatedAccessories or {}) do
    if IsValid(k) then
        k:SS_AttachAccessories()
    end
end

for i, v in ipairs(player.GetAll()) do
    v.SS_SetupPlayermodel = nil
end

SS_CreatedAccessories = {}
SS_UpdatedAccessories = {}

hook.Add("NetworkEntityCreated", "RefreshAccessories", function(ent)
    ent.SS_AttachedModel = nil
end)

-- Note: we expect items table not to change internally when items are updated (make whole new table)
function Entity:SS_AttachAccessories(items)
    -- print(items, rangecheck)
    SS_UpdatedAccessories[self] = true
    local m = self:GetActualModel()
    -- they sometimes go NULL when in/out of vehicle
    local iv = self:IsPlayer() and self:InVehicle()
    local current = SS_CreatedAccessories[self]

    -- slow, havent found better way
    if CurTime() > (self.SS_DetachCheckTime or 0) then
        -- print("CHE")
        -- if current and IsValid(current[1]) and not IsValid(current[1]:GetParent()) then self.SS_AttachedModel=nil print("F") end
        self.SS_AttachedModel = nil
        self.SS_DetachCheckTime = CurTime() + math.Rand(0.5, 1)
    end

    if self.SS_AttachedModel == m and self.SS_AttachedInVehicle == iv and self.SS_AttachedItems == items then return end -- TODO: add :Reattach() method on mdls to do this, and handle eye attachment -- if CurTime() > (self.SS_DetachCheckTime or 0) then --     -- print("CHE") --     for i,v in ipairs(SS_CreatedAccessories[self] or {}) do --         v:FollowBone(self, v.follow or 0) --         v:SetLocalPos(v.translate) --         v:SetLocalAngles(v.rotate) --     end --     self.SS_DetachCheckTime = CurTime() + math.Rand(1,2) -- end
    -- TODO improve this, we probably should just reattach every so often
    -- if not self.DELAYSECONDATTACH then
    --     timer.Simple(0.5, function()
    --         if IsValid(self) and self.SS_ShownItems then
    --             self.SS_AttachedModel = nil
    --             self.DELAYSECONDATTACH = true
    --             self:SS_AttachAccessories(self.SS_ShownItems)
    --             self.DELAYSECONDATTACH = false
    --         end
    --     end)
    -- end
    -- if Me==self then print("H)") end
    -- if self.SS_AttachedModel == m and self.SS_AttachedItems == items then return end
    self.SS_AttachedModel = m
    self.SS_AttachedInVehicle = iv
    self.SS_AttachedItems = items
    local recycle = defaultdict(function() return {} end)

    if current then
        for i, v in ipairs(current) do
            table.insert(recycle[v:GetModel()], v)
        end
    end

    if items then
        SS_CreatedAccessories[self] = {}

        for k, item in pairs(items) do
            if item.AccessoryTransform then
                local function make()
                    local rmodels = recycle[item:GetModel()]
                    local mdl

                    if #rmodels > 0 then
                        mdl = table.remove(rmodels, 1)
                    else
                        mdl = ClientsideModel(item:GetModel(), RENDERGROUP_OPAQUE)
                    end

                    mdl.item = item
                    local pone = IsPonyModel(EntityGetModel(self))
                    local attach, translate, rotate, scale = item:AccessoryTransform(pone)

                    if attach == "eyes" then
                        local attach_id = self:LookupAttachment("eyes")
                        local head_bone_id = self:LookupBone(SS_Attachments["head"][pone and 2 or 1])
                        local attach_angpos = self:GetAttachment(attach_id)

                        if attach_id < 1 or not head_bone_id or not attach_angpos then
                            mdl:Remove()

                            return nil
                        end

                        local bpos, bang = self:GetBonePosition(head_bone_id)
                        translate, rotate = LocalToWorld(translate, rotate, attach_angpos.Pos, attach_angpos.Ang)
                        translate, rotate = WorldToLocal(translate, rotate, bpos, bang)
                        mdl:FollowBone(self, head_bone_id)
                        -- This has issues with detaching when sitting
                        -- mdl:SetParent(self, attach_id)
                    else
                        local bone_id = self:LookupBone(SS_Attachments[attach][pone and 2 or 1])

                        if not bone_id then
                            mdl:Remove()

                            return nil
                        end

                        mdl:FollowBone(self, bone_id)
                    end

                    -- just added
                    -- mdl:SetPredictable(true)
                    -- if scale ~= e.appliedscale then
                    mdl.matrix = isnumber(scale) and Matrix({
                        {scale, 0, 0, 0},
                        {0, scale, 0, 0},
                        {0, 0, scale, 0},
                        {0, 0, 0, 1}
                    }) or Matrix({
                        {scale.x, 0, 0, 0},
                        {0, scale.y, 0, 0},
                        {0, 0, scale.z, 0},
                        {0, 0, 0, 1}
                    })

                    -- TODO: do we need to adjust renderbounds?
                    mdl:EnableMatrix("RenderMultiply", mdl.matrix)
                    -- e.appliedscale = scale
                    -- end
                    --this likes to change itself
                    mdl:SetLocalPos(translate)
                    mdl:SetLocalAngles(rotate)
                    mdl.follow = bone_id
                    mdl.translate = translate
                    mdl.rotate = rotate
                    SS_SetItemMaterialToEntity(item, mdl, self:IsPlayer() and self or nil)
                    mdl:SetPredictable(true)

                    return mdl
                end

                table.insert(SS_CreatedAccessories[self], make())
            end
        end
    else
        SS_CreatedAccessories[self] = nil
    end

    for m, mt in pairs(recycle) do
        for i, v in ipairs(mt) do
            v:Remove()
        end
    end
end

hook.Add("Think", "SS_CleanupAccessories", function()
    for ent, mdls in pairs(SS_CreatedAccessories) do
        if not SS_UpdatedAccessories[ent] then
            for i, mdl in ipairs(mdls) do
                mdl:Remove()
            end

            SS_CreatedAccessories[ent] = nil

            if IsValid(ent) then
                ent.SS_AttachedItems = nil
            end
        end
    end

    SS_UpdatedAccessories = {}
end)
