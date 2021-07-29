-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
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

function SWEP:Initialize()
    self:SetHoldType("slam")
end

function SWEP:DrawWorldModel()
    local ply = self:GetOwner()

    if (IsValid(ply)) then
        local bn = ply:IsPony() and "LrigScull" or "ValveBiped.Bip01_R_Hand"
        local bon = ply:LookupBone(bn) or 0
        local opos = self:GetPos()
        local oang = self:GetAngles()
        local bp, ba = ply:GetBonePosition(bon)

        if (bp) then
            opos = bp
        end

        if (ba) then
            oang = ba
        end

        if ply:IsPony() then
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

        if (mrt) then
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
local function CorrectSaveData(data)
    for k, v in pairs(data) do
        for pti = 4, 2, -1 do
            local l = LocationByName["Private Theater " .. pti]
            print(type(v.pos))

            if v.pos:WithinAABox(l.Min, l.Max) then
                v.pos.x = v.pos.x - 384
            end
        end
    end
end

local function DecorrectSaveData(data)
    local shift = nil

    for pti = 2, 4 do
        if LocalPlayer():GetLocationName() == "Private Theater " .. pti then
            shift = 384 * (pti - 1)
        end
    end

    if shift then
        local l = LocationByName["Private Theater 1"]

        for k, v in pairs(data) do
            if v.pos:WithinAABox(l.Min, l.Max) then
                v.pos.x = v.pos.x + shift
            end
        end
    end
end

function SWEP:PrimaryAttack()
    if CLIENT then
        if not IsValid(TRASHMANAGERWINDOW) then
            TRASHMANAGERWINDOW = vgui("DFrame", function(p)
                p:SetTitle("Trash manager")
                p:SetSize(300, 360)
                p:Center()
                p:MakePopup()
                p:CloseOnEscape()

                vgui("DLabel", function(p)
                    p:Dock(TOP)
                    p:SetText("You can delete any props in an area you own.")
                end)

                TRASHMANAGERDELETEBUTTON = vgui("DButton", function(p)
                    p:Dock(TOP)
                    p:SetText("")

                    function p:DoClick()
                        net.Start("TrashManagerAction")
                        net.WriteString("cleanup")
                        net.SendToServer()
                    end
                end)

                vgui("DHorizontalDivider", function(p)
                    p:Dock(TOP)
                end)

                vgui("DLabel", function(p)
                    p:Dock(TOP)
                    p:SetText([[You can save any props spawned from your inventory.
This will save any of your frozen props on the map,
but you need a nearby theater/field to respawn them.]])
                    p:SizeToContentsY()
                end)

                TRASHMANAGERSAVEBUTTON = vgui("DButton", function(p)
                    p:Dock(TOP)
                    p:SetText("")

                    function p:DoClick()
                        Derma_StringRequest("Filename", "Name of this prop configuration?", "stuff", function(text)
                            local w = LocalPlayer():GetActiveWeapon()

                            if IsValid(w) and w:GetClass() == "weapon_trash_manager" then
                                local c = {}

                                for i, v in ipairs(w:GetSaveEntities()) do
                                    table.insert(c, {
                                        id = v:GetItemID(),
                                        pos = v:GetPos(),
                                        ang = v:GetAngles()
                                    })
                                end

                                CorrectSaveData(c)

                                c = {
                                    map = game.GetMap(),
                                    props = c
                                }

                                if not file.IsDir("swampbuilds", "DATA") then
                                    file.CreateDir("swampbuilds")
                                end

                                file.Write("swampbuilds/" .. text .. ".txt", util.TableToJSON(c, true))
                                TRASHMANAGERFILES:Reset()
                            end
                        end)
                    end
                end, function(text) end)

                vgui("DHorizontalDivider", function(p)
                    p:Dock(TOP)
                end)

                TRASHMANAGERFILES = vgui("DListView", function(p)
                    p:Dock(FILL)
                    p:SetMultiSelect(false)
                    p:AddColumn("Saved builds")

                    function p:Reset()
                        self:Clear()

                        if IsValid(TRASHMANAGERFILEBUTTONS) then
                            TRASHMANAGERFILEBUTTONS:Remove()
                        end

                        local f, d = file.Find("swampbuilds/*.txt", "DATA")

                        for i, v in ipairs(f) do
                            self:AddLine(v)
                        end

                        function p:OnRowSelected(i, r)
                            if IsValid(TRASHMANAGERFILEBUTTONS) then
                                TRASHMANAGERFILEBUTTONS:Remove()
                            end

                            local fn = r:GetColumnText(1)
                            local d = util.JSONToTable(file.Read("swampbuilds/" .. fn))
                            d = d.props or d
                            local items = {}

                            for k, v in pairs(LocalPlayer().SS_Items or {}) do
                                items[v.id] = v
                            end

                            DecorrectSaveData(d)
                            local i = 1

                            while i <= #d do
                                local v = d[i]

                                if not items[v.id] or v.pos:Distance(LocalPlayer():GetPos()) > TRASH_MANAGER_LOAD_RANGE or TrashLocationOwner(FindLocation(v.pos), v.pos) ~= LocalPlayer():SteamID() then
                                    table.remove(d, i)
                                else
                                    i = i + 1
                                end
                            end

                            while #d > TRASH_MANAGER_PROP_LIMIT do
                                table.remove(d)
                            end

                            TRASHMANAGERFILEBUTTONS = vgui("Panel", TRASHMANAGERWINDOW, function(p)
                                p:Dock(BOTTOM)

                                vgui("DButton", function(p)
                                    p:SetText("Delete")
                                    p:Dock(LEFT)

                                    function p:DoClick()
                                        file.Delete("swampbuilds/" .. fn)
                                        TRASHMANAGERFILES:Reset()
                                    end
                                end)

                                vgui("DButton", function(p)
                                    local price = 0

                                    for k, v in pairs(d) do
                                        price = price + items[v.id]:SpawnPrice()
                                    end

                                    p:SetText("Load " .. table.Count(d) .. " props (cost " .. price .. ")")
                                    p:Dock(FILL)

                                    function p:DoClick()
                                        net.Start("TrashManagerAction")
                                        net.WriteString("load")
                                        net.WriteTable(d)
                                        net.SendToServer()
                                    end
                                end)

                                p:SizeToChildren(false, true)
                                p.mymodels = {}

                                for k, v in pairs(d) do
                                    local e = ClientsideModel(items[v.id]:GetModel())
                                    e:SetMaterial("models/effects/vol_light001")
                                    e:SetPos(v.pos)
                                    e:SetAngles(v.ang)
                                    table.insert(p.mymodels, e)
                                end

                                function p:OnRemove()
                                    for i, v in ipairs(p.mymodels) do
                                        v:Remove()
                                    end
                                end
                            end)
                        end
                    end

                    p:Reset()
                end)



                vgui("DButton", function(p)
                    p:Dock(BOTTOM)
                    p:SetText("Manage Friends")

                    function p:DoClick()

                        TRASHMANAGERWINDOW:Close()

                        vgui("DFrame", function(p)
                            p:SetTitle("Trash friends")
                            p:SetSize(300, 300)
                            p:Center()
                            p:MakePopup()
                            p:CloseOnEscape()

                            LocalPlayer().TrashFriends = LocalPlayer().TrashFriends or {}
            
                            vgui("DLabel", function(p)
                                p:Dock(TOP)
                                p:SetText("Your friends can build in your areas.")
                            end)

                            vgui( "DListView", function(p)
                                p:Dock( FILL )
                                p:SetMultiSelect( false )
                                p:AddColumn( "Player" )
                                p:AddColumn( "Friend?" ):SetFixedWidth(50)

                                for i,v in ipairs(player.GetAll()) do
                                    if v~=LocalPlayer() and not v:IsBot() then
                                        p:AddLine(v:Name(), LocalPlayer().TrashFriends[v] and "X" or "").player = v
                                    end
                                end

                                function p:OnRowSelected( index, pnl )

                                    if IsValid(pnl.player) then
                                        LocalPlayer().TrashFriends[pnl.player] = (not LocalPlayer().TrashFriends[pnl.player]) and true or nil
                                        pnl:SetColumnText(2, LocalPlayer().TrashFriends[pnl.player] and "X" or "")
                                    end

                                    net.Start("SetTrashFriends")
                                    net.WriteTable(LocalPlayer().TrashFriends)
                                    net.SendToServer()
                                end


                            end)

                        end)

                    end
                end)

                
                vgui("DHorizontalDivider", function(p)
                    p:Dock(BOTTOM)
                end)

            end)
        end
    end

    self:SetNextPrimaryFire(CurTime() + 0.3)
end

net.Receive("SetTrashFriends",function(len)
    local e = net.ReadEntity()
    if not IsValid(e) then return end
    if net.ReadBool() then
        e.TrashFriends = {[LocalPlayer()]=true}
    else
        e.TrashFriends = {}
    end
end)

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
    local id = self.Owner:SteamID()
    local cleanups = {}

    for i, v in ipairs(ents.GetAll()) do
        if v:GetTrashClass() and v:GetLocationOwner() == id and v:GetPos():Distance(self.Owner:GetPos()) <= TRASH_MANAGER_LOAD_RANGE then
            table.insert(cleanups, v)
        end
    end

    return cleanups
end

function SWEP:GetSaveEntities()
    local saves = {}
    local itemids = {}

    for k, v in pairs(self.Owner.SS_Items or {}) do
        itemids[v.id] = v
    end

    for i, v in ipairs(ents.GetAll()) do
        if v:GetTrashClass() then
            local id = v:GetItemID()

            if id ~= 0 and itemids[id] and v:GetTaped() and not v:IsDormant() then
                table.insert(saves, v)
            end
        end
    end

    return saves
end
