-- This file is subject to copyright - contact swampservers@gmail.com for more information.
SWEP.PrintName = "Manager"
SWEP.DrawAmmo = false
SWEP.ViewModelFOV = 85
SWEP.Slot = 5
SWEP.SlotPos = 0
SWEP.Purpose = "Build things"
SWEP.Instructions = "Primary: Open"
SWEP.AdminSpawnable = false
SWEP.ViewModel = Model("models/props_lab/clipboard.mdl")
SWEP.WorldModel = Model("models/props_lab/clipboard.mdl")
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.Damage = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Damage = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
TRASH_MANAGER_BASE_LOAD_PRICE = 5000

function SWEP:Initialize()
    self:SetHoldType("slam")
end

function SWEP:DrawWorldModel()
    local owner = self:GetOwner()

    if IsValid(owner) then
        local bn = owner:IsPony() and "LrigScull" or "ValveBiped.Bip01_R_Hand"
        local bon = owner:LookupBone(bn) or 0
        local opos = self:GetPos()
        local oang = self:GetAngles()
        local bp, ba = owner:GetBonePosition(bon)

        if bp then
            opos = bp
        end

        if ba then
            oang = ba
        end

        if owner:IsPony() then
            opos = opos + oang:Forward() * 10
            opos = opos + oang:Right() * -2
            oang:RotateAroundAxis(oang:Forward(), 180)
        else
            opos = opos + oang:Right() * 4
            opos = opos + oang:Forward() * 5
            opos = opos + oang:Up() * -4
            oang:RotateAroundAxis(oang:Up(), 90)
            oang:RotateAroundAxis(oang:Forward(), -30)
            oang:RotateAroundAxis(oang:Right(), 20)
        end

        self:SetupBones()
        local mrt = self:GetBoneMatrix(0)

        if mrt then
            mrt:SetTranslation(opos)
            mrt:SetAngles(oang)
            self:SetBoneMatrix(0, mrt)
        end
    end

    self:DrawModel()
end

function SWEP:GetViewModelPosition(pos, ang)
    pos = pos + ang:Right() * 6
    pos = pos + ang:Up() * -8
    pos = pos + ang:Forward() * 14
    ang:RotateAroundAxis(ang:Up(), 150)
    ang:RotateAroundAxis(ang:Right(), -60)

    return pos, ang
end

--NOMINIFY
-- TODO(winter): Is this still needed?
local function DecorrectSaveData(props)
    local shift = nil

    for pti = 2, 4 do
        if Me:GetLocationName() == "Private Theater " .. pti then
            shift = 384 * (pti - 1)
        end
    end

    if shift then
        local l = LocationByName["Private Theater 1"]

        for _, v in ipairs(props) do
            if v.pos:WithinAABox(l.Min, l.Max) then
                v.pos.x = v.pos.x + shift
            end
        end
    end
end

function SWEP:PrimaryAttack()
    if CLIENT and not IsValid(TRASHMANAGERWINDOW) then
        TRASHMANAGERWINDOW = ui.DFrame(function(p)
            p:SetTitle("Trash manager")
            p:SetSize(300, 360)
            p:Center()
            p:MakePopup()
            p:CloseOnEscape()

            ui.DLabel(function(p)
                p:Dock(TOP)
                p:SetText("You can delete any props in an area you own.")
            end)

            TRASHMANAGERDELETEBUTTON = ui.DButton(function(p)
                p:Dock(TOP)
                p:SetText("")

                function p:DoClick()
                    -- GetDeleteEntities gets called serverside for this
                    net.Start("TrashBuilds")
                    net.WriteUInt(TRASHBUILD_CLEANUP, TRASHBUILD_BITS)
                    net.SendToServer()
                end
            end)

            ui.DHorizontalDivider(function(p)
                p:Dock(TOP)
            end)

            ui.DLabel(function(p)
                p:Dock(TOP)
                p:SetText([[You can save any props spawned from your inventory.
This will save any of your taped props on the map,
but you need a nearby theater/field to respawn them.]])
                p:SizeToContentsY()
            end)

            TRASHMANAGERSAVEBUTTON = ui.DButton(function(p)
                p:Dock(TOP)
                p:SetText("")

                function p:DoClick()
                    Derma_StringRequest("Build Name", "Name of this prop configuration?", "stuff", function(buildname)
                        buildname = buildname and string.Trim(buildname):gsub("[^%w-_]+", "") or ""

                        if buildname ~= "" then
                            -- GetSaveEntities gets called serverside for this
                            net.Start("TrashBuilds")
                            net.WriteUInt(TRASHBUILD_UPDATE, TRASHBUILD_BITS)
                            net.WriteString(buildname)
                            net.SendToServer()
                        else
                            Me:Notify("Please specify a valid build name (letters, numbers, _, and -)")
                        end
                    end)
                end
            end, function(text) end)

            ui.DHorizontalDivider(function(p)
                p:Dock(TOP)
            end)

            TRASHMANAGERFILES = ui.DListView(function(p)
                p:Dock(FILL)
                p:SetMultiSelect(false)
                p:AddColumn("Saved builds")

                function p:Reset()
                    self:Clear()

                    if IsValid(TRASHMANAGERFILEBUTTONS) then
                        TRASHMANAGERFILEBUTTONS:Remove()
                    end

                    for buildname in pairs(TrashBuilds) do
                        self:AddLine(buildname)
                    end
                end

                function p:OnRowSelected(i, r)
                    if IsValid(TRASHMANAGERFILEBUTTONS) then
                        TRASHMANAGERFILEBUTTONS:Remove()
                    end

                    local buildname = r:GetColumnText(1)
                    net.Start("TrashBuilds")
                    net.WriteUInt(TRASHBUILD_DOWNLOAD, TRASHBUILD_BITS)
                    net.WriteString(buildname)
                    net.SendToServer()
                end

                function p:LoadPreview(buildname)
                    local props = table.RealDeepCopy(TrashBuilds[buildname]) -- Needed so we don't wipe out networked data from the checks below
                    props = props.props or props
                    local items = {}

                    for _, v in pairs(Me.items or {}) do
                        items[v.id] = v
                    end

                    DecorrectSaveData(props)
                    local i = 1
                    local mepos = Me:GetPos()
                    local meid = Me:SteamID()

                    -- Load range and location ownership limits (for the preview, done serverside as well)
                    while i <= #props do
                        local v = props[i]

                        if not items[v.id] or v.pos:DistToSqr(mepos) > TRASH_MANAGER_LOAD_RANGE ^ 2 then
                            table.remove(props, i)
                        else
                            local locownerid = TrashLocationOwner(FindLocation(v.pos), v.pos)
                            local locowner = player.GetBySteamID(locownerid)

                            if locownerid ~= meid and (not IsValid(locowner) or not (locowner.TrashFriends or {})[meid]) then
                                table.remove(props, i)
                            else
                                i = i + 1
                            end
                        end
                    end

                    -- Prop limit (for the preview, done serverside as well)
                    while #props > TRASH_MANAGER_PROP_LIMIT do
                        table.remove(props)
                    end

                    TRASHMANAGERFILEBUTTONS = ui.Panel({
                        parent = TRASHMANAGERWINDOW
                    }, function(p)
                        p:Dock(BOTTOM)

                        ui.DButton(function(p)
                            p:SetText("Delete")
                            p:Dock(LEFT)

                            function p:DoClick()
                                net.Start("TrashBuilds")
                                net.WriteUInt(TRASHBUILD_REMOVE, TRASHBUILD_BITS)
                                net.WriteString(buildname)
                                net.SendToServer()
                            end
                        end)

                        ui.DButton(function(p)
                            p:SetText("Adv. Edit")
                            p:Dock(LEFT)

                            function p:DoClick()
                                TRASHMANAGERWINDOW:Close()

                                ui.TrashBuildEditor(function(p)
                                    p:SetBuild(buildname, items)
                                end)
                            end
                        end)

                        ui.DButton(function(p)
                            local price = TRASH_MANAGER_BASE_LOAD_PRICE

                            for _, v in ipairs(props) do
                                price = price + items[v.id]:SpawnPrice()
                            end

                            p:SetText("Load " .. #props .. " props (cost " .. price .. ")")
                            p:Dock(FILL)

                            function p:DoClick()
                                net.Start("TrashBuilds")
                                net.WriteUInt(TRASHBUILD_LOAD, TRASHBUILD_BITS)
                                net.WriteTable(props)
                                net.SendToServer()
                            end
                        end)

                        p:SizeToChildren(false, true)
                        p.mymodels = {}

                        -- Preview build
                        for _, v in ipairs(props) do
                            local e = ClientsideModel(items[v.id]:Model())
                            e:SetMaterial("models/effects/vol_light001")
                            e:SetPos(v.pos)
                            e:SetAngles(v.ang)
                            table.insert(p.mymodels, e)
                        end

                        function p:OnRemove()
                            for _, v in ipairs(p.mymodels) do
                                v:Remove()
                            end
                        end
                    end)
                end

                p:Reset()
            end)

            ui.DButton(function(p)
                p:Dock(BOTTOM)
                p:SetText("Manage Friends")

                function p:DoClick()
                    TRASHMANAGERWINDOW:Close()

                    ui.DFrame(function(p)
                        p:SetTitle("Trash friends")
                        p:SetSize(300, 300)
                        p:Center()
                        p:MakePopup()
                        p:CloseOnEscape()
                        Me.TrashFriends = Me.TrashFriends or {}

                        ui.DLabel(function(p)
                            p:Dock(TOP)
                            p:SetText("Your friends can build in your areas.")
                        end)

                        ui.DListView(function(p)
                            p:Dock(FILL)
                            p:SetMultiSelect(false)
                            p:AddColumn("Player")
                            p:AddColumn("Friend?"):SetFixedWidth(50)

                            -- TODO(winter): This should probably be sorted alphabetically or something
                            for _, ply in player.HumanIterator() do
                                if ply ~= Me then
                                    p:AddLine(ply:Name(), Me.TrashFriends[ply:SteamID()] and "X" or "").player = ply
                                end
                            end

                            function p:OnRowSelected(index, pnl)
                                if IsValid(pnl.player) then
                                    Me.TrashFriends[pnl.player:SteamID()] = not Me.TrashFriends[pnl.player:SteamID()] and true or nil
                                    Me:Notify(pnl.player:Name() .. " is " .. (Me.TrashFriends[pnl.player:SteamID()] and "now" or "no longer") .. " a trash friend")
                                    pnl:SetColumnText(2, Me.TrashFriends[pnl.player:SteamID()] and "X" or "")
                                end

                                net.Start("SetTrashFriends")
                                net.WriteTable(Me.TrashFriends)
                                net.SendToServer()
                            end
                        end)
                    end)
                end
            end)

            ui.DHorizontalDivider(function(p)
                p:Dock(BOTTOM)
            end)
        end)
    end

    self:SetNextPrimaryFire(CurTime() + 0.3)
end

function SWEP:SecondaryAttack()
    self:SetNextSecondaryFire(CurTime() + 0.3)
end

local LastReloadTime = 0

function SWEP:Reload()
    return false
end

function SWEP:DrawHUD()
end

function SWEP:GetDeleteEntities()
    local owner = self:GetOwner()
    local id = owner:SteamID()
    local pos = owner:GetPos()
    local cleanups = {}

    for _, v in ents.Iterator() do
        if v:GetTrashClass() and v:GetTrashClass() ~= "prop_trash_zone" and v:GetLocationOwner() == id and v:GetPos():DistToSqr(pos) <= TRASH_MANAGER_LOAD_RANGE ^ 2 then
            table.insert(cleanups, v)
        end
    end

    return cleanups
end

function SWEP:GetSaveEntities()
    local owner = self:GetOwner()
    local saves = {}
    local itemids = {}

    for _, v in pairs(owner.items or {}) do
        itemids[v.id] = v
    end

    for _, v in ents.Iterator() do
        if v:GetTrashClass() then
            local id = v:GetItemID()

            if id ~= 0 and itemids[id] and v:GetTaped() and (SERVER and owner:TestPVS(v) or CLIENT and not v:IsDormant()) then
                table.insert(saves, v)
            end
        end
    end

    return saves
end
