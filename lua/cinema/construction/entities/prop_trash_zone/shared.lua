-- This file is subject to copyright - contact swampservers@gmail.com for more information.
AddCSLuaFile()
DEFINE_BASECLASS("prop_trash")
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.CanChangeTrashOwner = false

TrashZoneModels = {
    ["models/props_c17/tv_monitor01.mdl"] = {
        center = Vector(50, 0, 0),
        cubesize = 125,
        theater = {
            pos = Vector(7, -9, 5),
            ang = Angle(0, 90, 0),
            w = 16 * 0.95,
            h = 9 * 0.95
        }
    },
    ["models/props_phx/rt_screen.mdl"] = {
        center = Vector(100, 0, 0),
        cubesize = 250,
        theater = {
            pos = Vector(6.5, -28, 35),
            ang = Angle(0, 90, 0),
            w = 56,
            h = 31.5
        }
    },
    ["models/hunter/plates/plate1x2.mdl"] = {
        center = Vector(0, 0, 150),
        cubesize = 350,
        theater = {
            pos = Vector(-21.1, -28 * 1.36, 5.5),
            ang = Angle(0, 90, -90),
            w = 56 * 1.36,
            h = 31.5 * 1.36
        }
    },
    ["models/dav0r/camera.mdl"] = {
        center = Vector(150, 0, 0),
        cubesize = 400,
        theater = {
            pos = Vector(300, 160, 90),
            ang = Angle(0, -90, 0),
            w = 320,
            h = 180,
            projection = {
                pos = Vector(0, 0, 0),
                ang = Angle(0, 0, 0),
            }
        }
    },
    ["models/maxofs2d/hover_classic.mdl"] = {
        cubesize = 300
    },
    ["models/dav0r/hoverball.mdl"] = {
        cubesize = 400
    }
}

-- AddTrashClass("prop_trash_zone", TrashMobileTheaterData)
function ENT:SetupDataTables()
    BaseClass.SetupDataTables(self, true)
    self:NetworkVar("String", 2, "TheaterName")
    self:NetworkVar("Int", 2, "MobileLocationIndex")
end

-- function ENT:Draw()
--     local realmodel = self:GetModel()
--     if realmodel == "models/hunter/plates/plate1x2.mdl" then
--         self:SetModel("models/props_phx/rt_screen.mdl")
--         local oldpos = self:GetPos()
--         local oldang = self:GetAngles()
--         local wpos, wang = LocalToWorld(Vector(26, 0, -3), Angle(-90, 0, 0), oldpos, oldang)
--         self:SetPos(wpos)
--         self:SetAngles(wang)
--         self:SetModelScale(1.36)
--         self:SetupBones()
--         BaseClass.Draw(self, true)
--         self:SetModelScale(1)
--         self:SetPos(oldpos)
--         self:SetAngles(oldang)
--         self:SetModel(realmodel)
--     else
--         BaseClass.Draw(self, true)
--     end
--     TrashDrawProtectionOutlines(self)
-- end
-- function ENT:GetAreaMin()
--     local tmtd = TrashMobileTheaterData[self:GetModel()]
--     local cs = tmtd.cubesize
--     return self:LocalToWorld(tmtd.center) - Vector(cs / 2, cs / 2, cs / 2)
-- end
-- function ENT:GetAreaMax()
--     local cs = TrashMobileTheaterData[self:GetModel()].cubesize
--     return self:GetAreaMin() + Vector(cs, cs, cs)
-- end
-- function ENT:ProtectionRadius()
--     local field_size = TrashFieldModelToRadius[self:GetModel()]
--     local locid = self:GetLocation()
--     local ln = Location.GetLocationNameByIndex(locid)
--     if ln == "The Pit" then
--         field_size = field_size / 2
--     end
--     if ln == "In Minecraft" then
--         field_size = field_size * 1.5
--     end
--     return field_size
-- end
function ENT:GetBounds()
    local dat = TrashZoneModels[self:GetModel()]
    local center = dat.center and self:LocalToWorld(dat.center) or self:GetPos()
    local v = Vector(dat.cubesize, dat.cubesize, dat.cubesize) * 0.5

    return center - v, center + v
end

function ENT:Think()
    local t = self:GetTaped()
    self.LastMobileLocationIndex = self.LastMobileLocationIndex or 0

    if self.LastMobileLocationIndex ~= self:GetMobileLocationIndex() then
        if self:GetMobileLocationIndex() > 0 then
            self:CreateTheater()
        else
            self:DestroyTheater()
        end

        self.LastMobileLocationIndex = self:GetMobileLocationIndex()
    end

    self:NextThink(CurTime() + 0.1)

    return true
end

function ENT:CreateTheater()
    local i = self:GetMobileLocationIndex()
    local tzm = TrashZoneModels[self:GetModel()]
    local th = tzm.theater
    if not th then return end
    local li = MobileLocations[i]
    local l = Locations[li]
    l.Min, l.Max = self:GetBounds()
    l.Name = self:GetTheaterName()
    l.Theater.Width, l.Theater.Height = th.w, th.h
    l.Theater.Pos, l.Theater.Ang = LocalToWorld(th.pos, th.ang, self:GetPos(), self:GetAngles())
    -- if tmtd.projection then
    --     -- TODO implement this
    --     l.Theater.Projector = {
    --         pos = self:LocalToWorld(tmtd.projection.pos),
    --         ang = self:LocalToWorldAngles(tmtd.projection.ang),
    --     }
    -- end
    l.Theater.PermanentOwnerID = self:GetOwnerID()
    local t = theater.GetByLocation(li)

    if t then
        t._Name = l.Name

        if SERVER then
            t._OriginalName = t._Name
        end

        t._Pos = l.Theater.Pos
        t._Ang = l.Theater.Ang
        t._Width = l.Theater.Width * 10
        t._Height = l.Theater.Height * 10
        t._PermanentOwnerID = l.Theater.PermanentOwnerID
    end

    RefreshLocations()
end

function ENT:DestroyTheater()
    local i = self:GetMobileLocationIndex()

    if i == 0 then
        i = self.LastMobileLocationIndex or 0
    end

    if i > 0 then
        local li = MobileLocations[i]
        local l = Locations[li]
        l.Min = Vector(-1, -1, -10001)
        l.Max = Vector(1, 1, -10000)
        RefreshLocations()
    end
end

function ENT:OnRemove()
    self:DestroyTheater()
end

function ENT:CannotTape(userid)
    -- self:GetPos():Distance(Vector(0, -1152, 0)) > 900 and 
    local basederror = BaseClass.CannotTape and BaseClass.CannotTape(self, userid)
    if basederror then return basederror end
    local badcount = -1
    local mn, mx = self:GetBounds()

    for k, v in pairs(FindAllTrash()) do
        if v:GetTaped() then
            if v:GetPos():WithinAABox(mn, mx) then
                badcount = badcount + (v:GetOwnerID() == self:GetOwnerID() and -1 or 1)
            end

            if v:GetTrashClass() == "prop_trash_zone" and v:GetOwnerID() ~= self:GetOwnerID() then
                local on, ox = v:GetBounds()
                if not ((mn.x > ox.x or on.x > mx.x) or (mn.y > ox.y or on.y > mx.y) or (mn.z > ox.z or on.z > mx.z)) then return "Intersects other zone!" end
            end
        end
    end

    if badcount > 0 then return "Too many of others' props nearby!" end
end

-- function ENT:ProtectsIfTaped(other)
--     return other:GetPos():WithinAABox(self:GetAreaMin(), self:GetAreaMax())
-- end
function ENT:Protects(pos)
    return self:GetTaped() and pos:WithinAABox(self:GetBounds())
end
-- function ENT:Protects(other)
--     return self:GetTaped() and self:ProtectsIfTaped(other)
-- end
