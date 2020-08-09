
CVX_LIMITED_BLOCKS = true
CVX_DISABLE_LINE = true


function cvx_pre_draw_leaf(ent) 
    if true then return end
    render.SuppressEngineLighting(true)

    -- local a,b,c,d,e,f = 0.4,0.25,0.5,0.2,0.7,0.15

    -- local red,green,blue = 1,0.4,0

    -- local howfarup = (ent:GetPos().z-CVX_ORIGIN.z)/(CVX_WORLD_ZS * CVX_SCALE)
    -- local p = 1-math.min(howfarup*5,1)

    -- p = p*5

    -- local a,b,c,d,e,f = 0.3,0.3,0.4,0.4,0.1,1

    -- --frontback
    -- render.SetModelLighting(0,red*p*a,green*p*a,blue*p*a)
    -- render.SetModelLighting(1,red*p*b,green*p*b,blue*p*b)
    -- --rightleft
    -- render.SetModelLighting(2,red*p*c,green*p*c,blue*p*c)
    -- render.SetModelLighting(3,red*p*d,green*p*d,blue*p*d)
    -- --topbotton
    -- render.SetModelLighting(4,red*p*e,green*p*e,blue*p*e)
    -- render.SetModelLighting(5,red*p*f,green*p*f,blue*p*f)

    for i=0,5 do 
        render.SetModelLighting(i,0,0,0)
    end

    
    -- I do not like this
    local lights={
        {
            color=Vector(1,1,1)*0.08,
            pos=EyePos(),
            quadraticFalloff=0,
            linearFalloff=1,
            constantFalloff=0,
        },
        -- {
        --     color=Vector(1,0.4,0)*5,
        --     pos=Vector(ent:GetPos().x,ent:GetPos().y,CVX_ORIGIN.z-100),
        --     quadraticFalloff=1,
        --     linearFalloff=0,
        --     constantFalloff=0,
        -- }
    }

    -- todo use the nearest ones and all that
    for k,v in pairs(CVX_TRACKED_DLIGHTS) do
        table.insert(lights,
        {
            color=Vector(v.r,v.g,v.b)*0.000015*v.brightness*v.size,
            pos=v.pos,
            quadraticFalloff=1,
            linearFalloff=0,
            constantFalloff=0,
        })
        if #lights==4 then break end
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

DynamicLight = function(idx, elight)
    CVX_TRACKED_DLIGHTS[idx] = setmetatable({_data={},_light=BASE_DYNAMIC_LIGHT(idx, elight)}, CVX_DLIGHT_PROXY_META)
    return CVX_TRACKED_DLIGHTS[idx]
end

hook.Add("Think","DlightCleanup",function()
    -- chat.AddText(table.Count(CVX_TRACKED_DLIGHTS))
    local nxt = {}
    for k,v in pairs(CVX_TRACKED_DLIGHTS) do
        if v.dietime > CurTime() then nxt[k]=v end
    end
    CVX_TRACKED_DLIGHTS = nxt
end)

