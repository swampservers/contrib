-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
function DecodeMazePart2D(st, d1, d2)
    st = util.Base64Decode(st)
    print(st:len(), math.ceil(d1 * d2 / 8))
    assert(st:len() == math.ceil(d1 * d2 / 8))
    local dec = {}
    local byte = 0
    local bitid = 0

    for od = 1, d1 do
        local row = {}
        table.insert(dec, row)

        for id = 1, d2 do
            local bi = bitid % 8
            local ci = ((bitid - bi) / 8) + 1
            local char = string.byte(st[ci])
            char = bit.band(1, bit.rshift(char, bi))
            table.insert(row, char == 1)
            bitid = bitid + 1
        end
    end

    return dec
end

AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "MazeXS")
    self:NetworkVar("Int", 1, "MazeYS")
    self:NetworkVar("String", 0, "HWalls")
    self:NetworkVar("String", 1, "VWalls")
    self:NetworkVar("Vector", 0, "MazeOrigin")
end

function getboxmesh(x1, y1, x2, y2, zs, ofs)
    local m = {
        {
            pos = Vector(x2, y2, zs) - ofs,
            normal = Vector(1, 0, 0)
        },
        {
            pos = Vector(x2, y1, 0) - ofs,
            normal = Vector(1, 0, 0)
        },
        {
            pos = Vector(x2, y1, zs) - ofs,
            normal = Vector(1, 0, 0)
        },
        {
            pos = Vector(x2, y1, 0) - ofs,
            normal = Vector(1, 0, 0)
        },
        {
            pos = Vector(x2, y2, zs) - ofs,
            normal = Vector(1, 0, 0)
        },
        {
            pos = Vector(x2, y2, 0) - ofs,
            normal = Vector(1, 0, 0)
        },
        {
            pos = Vector(x1, y2, zs) - ofs,
            normal = Vector(0, 1, 0)
        },
        {
            pos = Vector(x2, y2, 0) - ofs,
            normal = Vector(0, 1, 0)
        },
        {
            pos = Vector(x2, y2, zs) - ofs,
            normal = Vector(0, 1, 0)
        },
        {
            pos = Vector(x2, y2, 0) - ofs,
            normal = Vector(0, 1, 0)
        },
        {
            pos = Vector(x1, y2, zs) - ofs,
            normal = Vector(0, 1, 0)
        },
        {
            pos = Vector(x1, y2, 0) - ofs,
            normal = Vector(0, 1, 0)
        },
        {
            pos = Vector(x1, y1, zs) - ofs,
            normal = Vector(-1, 0, 0)
        },
        {
            pos = Vector(x1, y2, 0) - ofs,
            normal = Vector(-1, 0, 0)
        },
        {
            pos = Vector(x1, y2, zs) - ofs,
            normal = Vector(-1, 0, 0)
        },
        {
            pos = Vector(x1, y2, 0) - ofs,
            normal = Vector(-1, 0, 0)
        },
        {
            pos = Vector(x1, y1, zs) - ofs,
            normal = Vector(-1, 0, 0)
        },
        {
            pos = Vector(x1, y1, 0) - ofs,
            normal = Vector(-1, 0, 0)
        },
        {
            pos = Vector(x2, y1, zs) - ofs,
            normal = Vector(0, -1, 0)
        },
        {
            pos = Vector(x1, y1, 0) - ofs,
            normal = Vector(0, -1, 0)
        },
        {
            pos = Vector(x1, y1, zs) - ofs,
            normal = Vector(0, -1, 0)
        },
        {
            pos = Vector(x1, y1, 0) - ofs,
            normal = Vector(0, -1, 0)
        },
        {
            pos = Vector(x2, y1, zs) - ofs,
            normal = Vector(0, -1, 0)
        },
        {
            pos = Vector(x2, y1, 0) - ofs,
            normal = Vector(0, -1, 0)
        }
    }

    for _, vert in pairs(m) do
        vert.u = (vert.pos.x + vert.pos.y) / zs
        vert.v = vert.pos.z / zs
    end

    local p = {Vector(x1, y1, 0) - ofs, Vector(x2, y1, 0) - ofs, Vector(x1, y2, 0) - ofs, Vector(x2, y2, 0) - ofs, Vector(x1, y1, zs) - ofs, Vector(x2, y1, zs) - ofs, Vector(x1, y2, zs) - ofs, Vector(x2, y2, zs) - ofs,}

    return m, p
end

function ENT:Initialize()
    self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
    self:SetModelScale(1)
    -- self:SetNoDraw(1)
    local hwalls = DecodeMazePart2D(self:GetHWalls(), self:GetMazeXS(), self:GetMazeYS())
    local vwalls = DecodeMazePart2D(self:GetVWalls(), self:GetMazeXS(), self:GetMazeYS())
    --copied below
    local sc = 128
    local sch = 128
    local th = 3.6
    local fth = 4
    local tris = {}
    local phys = {}
    local hwallst = {}

    for hx, ht in ipairs(hwalls) do
        for hy, v in ipairs(ht) do
            if hx == 1 then
                table.insert(hwallst, {})
            end

            table.insert(hwallst[hy], v)
        end
    end

    local addwall = false

    local side = {false, false}

    for i = 1, #(hwallst[1]) - 2 do
        table.insert(side, 2, addwall)
    end

    table.insert(hwallst, 1, side)

    side = {false, false}

    for i = 1, #(hwallst[1]) - 2 do
        table.insert(side, 2, addwall)
    end

    table.insert(hwallst, side)

    side = {false, false}

    for i = 1, #(vwalls[1]) - 2 do
        table.insert(side, 2, addwall)
    end

    table.insert(vwalls, 1, side)

    side = {false, false}

    for i = 1, #(vwalls[1]) - 2 do
        table.insert(side, 2, addwall)
    end

    table.insert(vwalls, side)

    for hy, ht in ipairs(hwallst) do
        --so last position wall is made
        table.insert(ht, false)
        local hx1 = nil

        for hx, v in ipairs(ht) do
            if v then
                if hx1 == nil then
                    hx1 = hx - 1
                end
            else
                if hx1 ~= nil then
                    local mp, pp = getboxmesh(hx1 * sc - th, (hy - 2) * sc - fth, (hx - 1) * sc + th, (hy - 2) * sc + fth, sch, self:GetPos() - self:GetMazeOrigin())
                    table.Add(tris, mp)
                    table.insert(phys, pp)
                    hx1 = nil
                end
            end
        end

        assert(hx1 == nil)
    end

    for hx, ht in ipairs(vwalls) do
        table.insert(ht, false)
        local hy1 = nil

        for hy, v in ipairs(ht) do
            if v then
                if hy1 == nil then
                    hy1 = hy - 1
                end
            else
                if hy1 ~= nil then
                    local mp, pp = getboxmesh((hx - 2) * sc - fth, hy1 * sc - th, (hx - 2) * sc + fth, (hy - 1) * sc + th, sch, self:GetPos() - self:GetMazeOrigin())
                    table.Add(tris, mp)
                    table.insert(phys, pp)
                    hy1 = nil
                end
            end
        end

        assert(hy1 == nil)
    end

    if CLIENT then
        self:FixRenderBounds()
    end

    self:PhysicsInitMultiConvex(phys)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)
    self:EnableCustomCollisions(true)
    self:GetPhysicsObject():EnableMotion(false)

    if CLIENT then
        self.Mesh = Mesh(MAZEWALLMATERIAL)
        self.Mesh:BuildFromTriangles(tris)
    end
end

function ENT:FixRenderBounds()
    --copied above
    local sc = 128
    local sch = 128
    self:SetRenderBoundsWS(self:GetMazeOrigin(), self:GetMazeOrigin() + Vector(self:GetMazeXS() * sc, self:GetMazeYS() * sc, sch))
end

-- crappy fix for reinitialization issues, better to do something like cvx
if CLIENT then
    function ENT:Think()
        self:FixRenderBounds()
    end
end

MAZEWALLMATERIAL = Material("models/swamponions/maze")

function ENT:GetRenderMesh()
    return {
        Mesh = self.Mesh,
        Material = MAZEWALLMATERIAL
    }
end