-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
CVX_LIMITED_BLOCKS = true
CVX_DISABLE_LINE = true

DUMMYLOCALLIGHT = {
    color = Vector(0, 0, 0),
    pos = Vector(0, 0, 0),
    quadraticFalloff = 1,
    linearFalloff = 0,
    constantFalloff = 0,
}

function cvx_pre_draw_leaf(ent)
    --if true then return end
    render.SuppressEngineLighting(true)
    local a, b, c, d, e, f = 0.4, 0.25, 0.5, 0.2, 0.7, 0.15
    local red, green, blue = 0.6, 0.2, 0.02 --0.9,0.35,0.05
    local howfarup = (EyePos().z - CVX_ORIGIN.z) / (CVX_WORLD_ZS * CVX_SCALE) --ent:GetPos().z
    local p = 1 - math.min(howfarup * 4, 1)
    --p = math.pow(p, 2)
    local a, b, c, d, e, f = 0.3, 0.3, 0.4, 0.4, 0.1, 1
    --frontback
    render.SetModelLighting(0, red * p * a, green * p * a, blue * p * a)
    render.SetModelLighting(1, red * p * b, green * p * b, blue * p * b)
    --rightleft
    render.SetModelLighting(2, red * p * c, green * p * c, blue * p * c)
    render.SetModelLighting(3, red * p * d, green * p * d, blue * p * d)
    --topbotton
    render.SetModelLighting(4, red * p * e, green * p * e, blue * p * e)
    render.SetModelLighting(5, red * p * f, green * p * f, blue * p * f)
    -- for i=0,5 do 
    --     render.SetModelLighting(i,0,0,0)
    -- end
    local ep = ent:GetPos()
    --if ep:Distance(EyePos()) < 3000 then
    cvx_sort_dlights(ep)
    --end
    local lights = {}

    -- print(#CVX_SORTABLE_DLIGHTS)
    for i = 1, 4 do
        local l = CVX_SORTABLE_DLIGHTS[i]

        if l then
            lights[i] = l[3]
        else
            lights[i] = DUMMYLOCALLIGHT
        end
    end

    render.SetLocalModelLights({})
    render.SetLocalModelLights(lights)
    -- local gm = 1.0 --0.95
    -- --frontback
    -- render.SetModelLighting(0,0.5*gm,0.5*gm,0.5*gm)
    -- render.SetModelLighting(1,0.3*gm,0.3*gm,0.3*gm)
    -- --rightleft
    -- render.SetModelLighting(2,0.7*gm,0.7*gm,0.7*gm)
    -- render.SetModelLighting(3,0.2*gm,0.2*gm,0.2*gm)
    -- --topbotton
    -- render.SetModelLighting(4,1*gm,1*gm,1*gm)
    -- render.SetModelLighting(5,0.1*gm,0.1*gm,0.1*gm)
end

function cvx_sort_dlights(ep)
    local t = CVX_SORTABLE_DLIGHTS
    if #t <= 4 then return end

    for k, v in ipairs(t) do
        v[4] = v[2]:Distance(ep) * v[1]
    end

    -- table.sort(CVX_SORTABLE_DLIGHTS, function(a,b)
    --     return a[4]<b[4]
    -- end)
    -- move up the 4 smallest elements, which is much faster than fully sorting the array
    local function moveup(from, to)
        local v = t[from]

        for i = from, to + 1, -1 do
            t[i] = t[i - 1]
        end

        t[to] = v
    end

    for i = 2, 4 do
        for j = 1, i - 1 do
            if t[i][4] < t[j][4] then
                moveup(i, j)
                break
            end
        end
    end

    for i = 5, #t do
        if t[i][4] < t[4][4] then
            t[i], t[4] = t[4], t[i]

            for j = 1, 3 do
                if t[4][4] < t[j][4] then
                    moveup(4, j)
                    break
                end
            end
        end
    end
    -- for i=2,#t do
    --     assert(t[math.min(i-1,4)][4] < t[i][4])
    -- end
end

function cvx_post_draw_leaf(e)
    render.SuppressEngineLighting(false)
end

CVX_DLIGHT_PROXY_META = {
    __index = function(t, k) return t._data[k] end,
    __newindex = function(t, k, v)
        k = string.lower(k)

        if k ~= "sortrgb" then
            t._light[k] = v
        end

        t._data[k] = v
    end
}

if not BASE_DYNAMIC_LIGHT then
    BASE_DYNAMIC_LIGHT = DynamicLight
end

CVX_TRACKED_DLIGHTS = {}
CVX_SORTABLE_DLIGHTS = {}

DynamicLight = function(idx, elight)
    CVX_TRACKED_DLIGHTS[idx] = setmetatable({
        _data = {
            dietime = (CurTime() + 1)
        },
        _light = BASE_DYNAMIC_LIGHT(idx, elight)
    }, CVX_DLIGHT_PROXY_META)

    return CVX_TRACKED_DLIGHTS[idx]
end

CVXDynamicLight = function(idx, elight)
    CVX_TRACKED_DLIGHTS[idx] = {}

    return CVX_TRACKED_DLIGHTS[idx]
end

hook.Add("Think", "DlightCleanup", function()
    -- chat.AddText(table.Count(CVX_TRACKED_DLIGHTS))
    local nxt = {}
    CVX_SORTABLE_DLIGHTS = {}

    -- eyeglow override
    if IsValid(LocalPlayer()) then
        table.insert(CVX_SORTABLE_DLIGHTS, {
            2e-6, --lower number = light has more priority
            LocalPlayer():EyePos(), {
                color = Vector(1, 1, 1) * 0.2, --0.08,
                pos = LocalPlayer():EyePos(),
                quadraticFalloff = 0,
                linearFalloff = 1,
                constantFalloff = 0,
            }
        })
    end

    for k, v in pairs(CVX_TRACKED_DLIGHTS) do
        if v.dietime > CurTime() then
            nxt[k] = v

            --Don't double count the eyeglow one
            if not IsValid(LocalPlayer()) or k ~= LocalPlayer():EntIndex() then
                table.insert(CVX_SORTABLE_DLIGHTS, {
                    1 / ((v.sortrgb or math.max(v.r, v.g, v.b)) * v.brightness * v.size), v.pos, {
                        color = Vector(v.r, v.g, v.b) * 0.000015 * v.brightness * v.size,
                        pos = v.pos,
                        quadraticFalloff = 1,
                        linearFalloff = 0,
                        constantFalloff = 0,
                    }
                })
            end
        end
    end

    CVX_TRACKED_DLIGHTS = nxt
end)

local function ReadOre()
    local idx = net.ReadUInt(24)
    local v = net.ReadUInt(8)

    if v == 0 then
        local old = MINECRAFT_EXPOSED_ORES[idx]

        if old ~= nil then
            if MINECRAFTOREMESHES[old] then
                MINECRAFTOREMESHES[old]:Destroy()
                MINECRAFTOREMESHES[old] = nil
            end
        end

        MINECRAFT_EXPOSED_ORES[idx] = nil
    else
        if MINECRAFTOREMESHES[v] then
            MINECRAFTOREMESHES[v]:Destroy()
            MINECRAFTOREMESHES[v] = nil
        end

        MINECRAFT_EXPOSED_ORES[idx] = v
    end
end

net.Receive("cvxOres", function(len)
    local c = net.ReadUInt(24)
    MINECRAFT_EXPOSED_ORES = {}

    for i = 1, c do
        ReadOre()
    end
end)

net.Receive("cvxOre", function(len)
    ReadOre()
end)

REQUESTED_ORES = nil
local ma = Material("swamponions/meinkraft/iron_ore")
local mb = Material("swamponions/meinkraft/gold_ore")
local mc = Material("swamponions/meinkraft/diamond_ore")
local md = Material("lights/white")

MINECRAFTOREMATERIALS = {ma, mb, mc, md}

MINECRAFTOREMESHES = {} --MINECRAFTOREMESHES or {}

hook.Add("PostDrawOpaqueRenderables", "MinecraftOres", function(depth, sky)
    if sky or depth then return end
    if not (IsValid(LocalPlayer()) and LocalPlayer():GetLocationName() == "In Minecraft") then return end
    MINECRAFT_OREANGLE = Angle(0, 0, 0)
    MINECRAFT_OREMINS = -Vector(0.51, 0.51, 0.51) * CVX_SCALE
    MINECRAFT_OREMAXS = Vector(0.51, 0.51, 0.51) * CVX_SCALE

    for i, mat in ipairs(MINECRAFTOREMATERIALS) do
        if isnumber(mat) then
            print("NUMBER BUG")
            PrintTable(MINECRAFTOREMATERIALS)
            continue
        end

        if MINECRAFTOREMESHES[i] == nil then
            local m = Mesh(mat) -- Create the IMesh object
            local count = 0

            for k, v in pairs(MINECRAFT_EXPOSED_ORES or {}) do
                if v == i then
                    count = count + 1
                end
            end

            mesh.Begin(m, MATERIAL_QUADS, count * 6)

            for k, v in pairs(MINECRAFT_EXPOSED_ORES or {}) do
                if v == i then
                    local x, y, z = cvx_from_world_index(k)
                    local origin = cvx_to_game_coord_vec(Vector(x, y, z))

                    for face = 1, 6 do
                        local normal = CVX_QUAD_NORMALS[face]
                        local even = (face % 2 == 0)
                        mesh.Position(origin + CVX_QUAD_VERTEX0[face])
                        mesh.TexCoord(0, 0, 0)
                        mesh.Normal(normal)
                        mesh.AdvanceVertex()

                        if even then
                            mesh.Position(origin + CVX_QUAD_VERTEX1[face])
                            mesh.TexCoord(0, 1, 0)
                        else
                            mesh.Position(origin + CVX_QUAD_VERTEX2[face])
                            mesh.TexCoord(0, 0, 1)
                        end

                        mesh.Normal(normal)
                        mesh.AdvanceVertex()
                        mesh.Position(origin + CVX_QUAD_VERTEX3[face])
                        mesh.TexCoord(0, 1, 1)
                        mesh.Normal(normal)
                        mesh.AdvanceVertex()

                        if even then
                            mesh.Position(origin + CVX_QUAD_VERTEX2[face])
                            mesh.TexCoord(0, 0, 1)
                        else
                            mesh.Position(origin + CVX_QUAD_VERTEX1[face])
                            mesh.TexCoord(0, 1, 0)
                        end

                        mesh.Normal(normal)
                        mesh.AdvanceVertex()
                    end
                end
            end

            mesh.End()
            MINECRAFTOREMESHES[i] = m
        end

        if mat:GetInt("$flags") ~= 2097152 then
            mat:SetInt("$flags", 2097152)
        end

        render.SetMaterial(mat)
        MINECRAFTOREMESHES[i]:Draw()
    end
end)

hook.Add("Think", "MinecraftOreUpdates", function()
    if not (IsValid(LocalPlayer()) and LocalPlayer():GetLocationName() == "In Minecraft") then return end

    if not REQUESTED_ORES then
        net.Start("cvxOres")
        net.SendToServer()
        REQUESTED_ORES = true

        return
    end

    for k, v in pairs(MINECRAFT_EXPOSED_ORES or {}) do
        if v >= 3 then
            local idx = k
            local dlight = DynamicLight(idx)

            if dlight then
                local x, y, z = cvx_from_world_index(k)
                local center = cvx_to_game_coord_vec(Vector(x + 0.5, y + 0.5, z + 0.5))
                dlight.pos = center

                if v == 4 then
                    local s = idx * 0.771
                    local c = HSVToColor(idx, math.sqrt(s - math.floor(s)), 1)
                    local b = 1

                    if math.mod(idx, 2) == 0 then
                        b = 0.5 + math.sin(SysTime() * 2 + idx) * 0.5
                    end

                    dlight.r = c.r * b
                    dlight.g = c.g * b
                    dlight.b = c.b * b
                else
                    dlight.r = 0
                    dlight.g = 100
                    dlight.b = 130
                end

                dlight.sortrgb = 255
                dlight.brightness = 1
                dlight.size = 600
                dlight.decay = 1000
                dlight.dietime = CurTime() + 0.1
            end
        end
    end
end)

-- TODO: this doesn't quite work because of min z distance, they can be outside a vox and still see thru
local BLACKBOXMAT = Material("tools/toolsblack")

hook.Add("PreDrawOpaqueRenderables", "SpadesAntiXray", function()
    if CVX_WORLD_ID then
        local pos = (EyePos() - CVX_ORIGIN) / CVX_SCALE

        if cvx_get_vox_solid(math.floor(pos.x), math.floor(pos.y), math.floor(pos.z)) then
            if IsValid(LocalPlayer()) and LocalPlayer():GetMoveType() == MOVETYPE_NOCLIP then return end
            render.CullMode(1)
            render.SetMaterial(BLACKBOXMAT)
            render.DrawBox(EyePos() + EyeAngles():Forward() * 0, Angle(0, 0, 0), Vector(-1, -1, -1) * 50, Vector(1, 1, 1) * 50, Color(0, 0, 0, 255))
            render.CullMode(0)
        end
    end
end)


timer.Create("MinecraftPlayerLighting",0.1,0,function()
    if IsValid(LocalPlayer()) and LocalPlayer().GetLocationName and LocalPlayer():GetLocationName()=="In Minecraft" then
        hook.Add("PrePlayerDraw","MCPRPD", function(ply) cvx_pre_draw_leaf(ply) end) --hack but it works
        hook.Add("PostPlayerDraw","MCPOPD", function(ply) cvx_post_draw_leaf() end)
        hook.Add("HUDPaint","MinecraftCompass",function()
                local fw = LocalPlayer():EyeAngles():Forward()
                fw.z=0
                fw:Normalize()
                surface.SetDrawColor(255,255,255,255)
                local c = 45
                surface.DrawCircle(c,c,30,255,255,255)
                surface.DrawLine(c,c,c+30*-fw.x,c+30*-fw.y)
                draw.SimpleText("N","DermaDefault",c+38*-fw.x,c+38*-fw.y,Color( 255, 255, 255, 255 ),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        end)
    else
        hook.Remove("PrePlayerDraw","MCPRPD")
        hook.Remove("PostPlayerDraw","MCPOPD")
        hook.Remove("HUDPaint","MinecraftCompass")
    end
end)