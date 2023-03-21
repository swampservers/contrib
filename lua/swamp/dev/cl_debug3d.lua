-- This file is subject to copyright - contact swampservers@gmail.com for more information.
module("Debug3D", package.seeall)
-- the material to use when drawing edges in space
DebugMat = Material("effects/tool_tracer")

local function DrawBeam(startpos, endpos, color)
    local texcoord = math.Rand(0, 1)
    render.DrawBeam(startpos, endpos, 8, 0, texcoord, color or Color(255, 255, 255, 255))
end

-- draws an outlined box in 3d space with the specified color
function DrawBox(vecStart, vecEnd, color)
    local min = vecStart
    local max = vecEnd

    if min:Length() > max:Length() then
        local temp = min
        min = max
        max = temp
    end

    -- borrowed from gmt's invload_box
    render.SetMaterial(DebugMat)
    --Bottom face
    DrawBeam(min, Vector(max.x, min.y, min.z), color)
    DrawBeam(min, Vector(min.x, max.y, min.z), color)
    DrawBeam(Vector(max.x, max.y, min.z), Vector(min.x, max.y, min.z), color)
    DrawBeam(Vector(max.x, max.y, min.z), Vector(max.x, min.y, min.z), color)
    --Top face
    DrawBeam(Vector(min.x, min.y, max.z), Vector(max.x, min.y, max.z), color)
    DrawBeam(Vector(min.x, min.y, max.z), Vector(min.x, max.y, max.z), color)
    DrawBeam(max, Vector(min.x, max.y, max.z), color)
    DrawBeam(max, Vector(max.x, min.y, max.z), color)
    --All 4 sides
    DrawBeam(Vector(min.x, min.y, max.z), min, color)
    DrawBeam(Vector(min.x, max.y, max.z), Vector(min.x, max.y, min.z), color)
    DrawBeam(max, Vector(max.x, max.y, min.z), color)
    DrawBeam(Vector(max.x, min.y, max.z), Vector(max.x, min.y, min.z), color)
end

function DrawPlane(plane, color)
    --[[
    if not plane.points[4] then
        -- TODO: This only works if the plane is a box!! Fuck!! Figure out how to chop planes with other planes ala the GIF in https://developer.valvesoftware.com/wiki/Valve_Map_Format#Planes
        local testPoints = {
            plane.min,
            Vector(plane.min.x, plane.min.y, plane.max.z),
            Vector(plane.min.x, plane.max.y, plane.min.z),
            Vector(plane.min.x, plane.max.y, plane.max.z),
            Vector(plane.max.x, plane.min.y, plane.min.z),
            Vector(plane.max.x, plane.min.y, plane.max.z),
            Vector(plane.max.x, plane.max.y, plane.min.z),
            plane.max
        }

        for _, testPoint in ipairs(testPoints) do
            if (testPoint - plane.points[1]):Dot(plane.normal) < 1 then
                local pointExists = false
                for _, point in ipairs(plane.points) do
                    if testPoint:IsEqualTol(point, 1) then
                        pointExists = true
                        break
                    end
                end

                if not pointExists then
                    plane.points[4] = testPoint
                    break
                end
            end
        end
    end
    ]]
    render.SetMaterial(DebugMat)
    DrawBeam(plane.points[1], plane.points[2], color)
    DrawBeam(plane.points[2], plane.points[3], color)
    --DrawBeam(plane.points[3], plane.points[1], color)
    --[[
    if plane.points[4] then
        DrawBeam(plane.points[3], plane.points[4], color)
        DrawBeam(plane.points[4], plane.points[1], color)
    end
    ]]
end

-- draws 3d2d'd text in 3d space
-- the text will be centered at the position
function DrawText(vecPos, strText, strFont, color, scale)
    if not strFont then
        strFont = "Default"
    end

    if not color then
        color = Color(255, 255, 255, 255)
    end

    if not scale then
        scale = 1
    end

    local ang = Me:EyeAngles()
    ang:RotateAroundAxis(ang:Forward(), 90)
    ang:RotateAroundAxis(ang:Right(), 90)
    surface.SetFont(strFont)
    local width, height = surface.GetTextSize(strText)
    height = height * scale
    cam.Start3D2D(vecPos + Vector(0, 0, height / 2), Angle(0, ang.y, 90), scale)
    draw.DrawText(strText, strFont, 0, 0, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end
