
CVX_LIMITED_BLOCKS = true
CVX_DISABLE_LINE = true

DUMMYLOCALLIGHT = {
    color=Vector(0,0,0),
    pos=Vector(0,0,0),
    quadraticFalloff=1,
    linearFalloff=0,
    constantFalloff=0,
}

function cvx_pre_draw_leaf(ent) 
    --if true then return end
    render.SuppressEngineLighting(true)

    local a,b,c,d,e,f = 0.4,0.25,0.5,0.2,0.7,0.15

    local red,green,blue = 0.9,0.35,0.05

    local howfarup = (EyePos().z-CVX_ORIGIN.z)/(CVX_WORLD_ZS * CVX_SCALE) --ent:GetPos().z
    local p = 1-math.min(howfarup*5,1)

    --p = math.pow(p, 2)

    local a,b,c,d,e,f = 0.3,0.3,0.4,0.4,0.1,1

    --frontback
    render.SetModelLighting(0,red*p*a,green*p*a,blue*p*a)
    render.SetModelLighting(1,red*p*b,green*p*b,blue*p*b)
    --rightleft
    render.SetModelLighting(2,red*p*c,green*p*c,blue*p*c)
    render.SetModelLighting(3,red*p*d,green*p*d,blue*p*d)
    --topbotton
    render.SetModelLighting(4,red*p*e,green*p*e,blue*p*e)
    render.SetModelLighting(5,red*p*f,green*p*f,blue*p*f)

    -- for i=0,5 do 
    --     render.SetModelLighting(i,0,0,0)
    -- end

    
    -- I do not like this
    local lights={}

    local ep = ent:GetPos()

    --if ep:Distance(EyePos()) < 3000 then
        cvx_sort_dlights(ep)
    --end

    for i,v in ipairs(CVX_SORTABLE_DLIGHTS) do
        table.insert(lights, v[3])
        if #lights==4 then break end
    end

    while #lights < 4 do
        table.insert(lights, DUMMYLOCALLIGHT)
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
    table.sort(CVX_SORTABLE_DLIGHTS, function(a,b)
        return a[2]:Distance(ep)*a[1] < b[2]:Distance(ep)*b[1]
    end)
end

function cvx_post_draw_leaf(e) 
    render.SuppressEngineLighting(false)

end



CVX_DLIGHT_PROXY_META = {
    __index = function(t,k)
        return t._data[k]
    end,
    __newindex = function(t,k,v)
        k = string.lower(k)
        t._light[k]=v
        t._data[k]=v
    end
}

if not BASE_DYNAMIC_LIGHT then
    BASE_DYNAMIC_LIGHT = DynamicLight
end

CVX_TRACKED_DLIGHTS = {}
CVX_SORTABLE_DLIGHTS = {}

DynamicLight = function(idx, elight)
    CVX_TRACKED_DLIGHTS[idx] = setmetatable({_data={},_light=BASE_DYNAMIC_LIGHT(idx, elight)}, CVX_DLIGHT_PROXY_META)
    return CVX_TRACKED_DLIGHTS[idx]
end

hook.Add("Think","DlightCleanup",function()
    -- chat.AddText(table.Count(CVX_TRACKED_DLIGHTS))
    local nxt = {}
    CVX_SORTABLE_DLIGHTS = {
        


    }

    -- eyeglow override
    if IsValid(LocalPlayer()) then
        table.insert(CVX_SORTABLE_DLIGHTS,
        {2e-6, --lower number = light has more priority
        LocalPlayer():EyePos(),
        {
            color=Vector(1,1,1)*0.2, --0.08,
            pos=LocalPlayer():EyePos(),
            quadraticFalloff=0,
            linearFalloff=1,
            constantFalloff=0,
        }
        })
    end

    for k,v in pairs(CVX_TRACKED_DLIGHTS) do
        if v.dietime > CurTime() then
            nxt[k]=v

            --Don't double count the eyeglow one
            if not IsValid(LocalPlayer()) or k~=LocalPlayer():EntIndex() then
                table.insert(CVX_SORTABLE_DLIGHTS,
                    {1/(math.max(v.r,v.g,v.b)*v.brightness*v.size),
                    v.pos,
                    {
                        color=Vector(v.r,v.g,v.b)*0.000015*v.brightness*v.size,
                        pos=v.pos,
                        quadraticFalloff=1,
                        linearFalloff=0,
                        constantFalloff=0,
                    }
                })
            end
        end
    end
    CVX_TRACKED_DLIGHTS = nxt
end)




-- TODO: this doesn't quite work because of min z distance, they can be outside a vox and still see thru
local BLACKBOXMAT =  Material( "tools/toolsblack" )
hook.Add("PreDrawOpaqueRenderables","SpadesAntiXray",function()
	if CVX_WORLD_ID then
		if IsValid(LocalPlayer()) and LocalPlayer():GetMoveType()==MOVETYPE_NOCLIP then return end
		local pos = (EyePos()-CVX_ORIGIN)/CVX_SCALE
		if cvx_get_vox_solid(math.floor(pos.x), math.floor(pos.y), math.floor(pos.z)) then
			render.CullMode(1)
			render.SetMaterial(BLACKBOXMAT)
			render.DrawBox(EyePos()+EyeAngles():Forward()*0, Angle(0,0,0), Vector(-1,-1,-1)*50, Vector(1,1,1)*50, Color(0,0,0,255))
			render.CullMode(0)
		end
	end
end)