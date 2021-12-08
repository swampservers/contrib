-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

SS_MaterialCache = {}

function SS_GetMaterial(nam)
    SS_MaterialCache[nam] = SS_MaterialCache[nam] or Material(nam)

    return SS_MaterialCache[nam]
end

SS_ClonedMaterials = SS_ClonedMaterials or {}

--NOMINIFY
-- you are probably cloning the material to edit it. the key is like the hash of your edits for caching.
-- function SS_GetMaterialClone(mat, key) ?
function SS_GetColoredMaterialClone(mat, color)
    if color.x == 1 and color.y == 1 and color.z == 1 then return mat end
    local colorkey = "c" .. tostring(color):gsub("%.", "p"):gsub(" ", "_")
    local clonekey = colorkey .. "/../" .. mat

    if not SS_ClonedMaterials[clonekey] then
        MATERIALCLONEINDEX = (MATERIALCLONEINDEX or 0) + 1
        -- print("MAKE", clonekey)
        -- mat = mat:gsub("'","")
        local mat2 = Material(clonekey)
        local matname = mat2:GetName()

        if matname == "___error" then
            -- print("INVALID MATERIAL", mat)
            local data = file.Read("materials/" .. mat .. ".vmt", "GAME") or "vertexlitgeneric\n{\n}"
            local fixdata = data:Trim():lower()

            if not (fixdata:StartWith("vertexlitgeneric") or fixdata:StartWith("'vertexlitgeneric") or fixdata:StartWith("\"vertexlitgeneric")) then
                print("WARNING, WRONG SHADER ON BAD MATERIAL")
                print(mat, data)
            elseif fixdata:find("proxies") then
                print("WARNING, PROXIES ON BAD MATERIAL")
                print(mat, data)
            end

            mat2 = CreateMaterial("clonedmaterial" .. MATERIALCLONEINDEX, "vertexlitgeneric", util.KeyValuesToTable(data))
            --     mat2 = PPM_CLONE_MATERIAL(Material(mat), mat .. colorkey )
            --     print("FIXED", mat2:GetName())
            -- mat2 = Material(mat.."/"..MATERIALCLONEINDEX.."/../../"..table.remove( ("/"):Explode(mat) ) )
            -- print(mat2:GetName(), mat.."/"..MATERIALCLONEINDEX.."/../../"..table.remove( ("/"):Explode(mat) ) )
            matname = "!" .. mat2:GetName()
        end

        mat2:SetVector("$color2", color * (mat2:GetVector("$color2") or Vector(1, 1, 1)))
        SS_ClonedMaterials[clonekey] = matname
    end

    return SS_ClonedMaterials[clonekey]
end

function Entity:SetColoredBaseMaterial(color)
    self:SetMaterial()
    self:SetSubMaterial()
    -- -- refactor - set default materials for models and support material override in shop
    -- if self:GetModel() == "models/props_crates/static_crate_40.mdl" then
    --     self:SetSkin(1)
    -- end
    -- might there be an issue if the mat doesn't default to white?
    if color.x == 1 and color.y == 1 and color.z == 1 then return end
    MATERIALCLONEINDEX = (MATERIALCLONEINDEX or 0) + 1

    for i, mat in ipairs(self:GetMaterials()) do
        self:SetSubMaterial(i - 1, SS_GetColoredMaterialClone(mat, color))
    end
end
-- self:SetMaterial(SS_GetColoredMaterialClone(mat, color))
-- function Entity:SetColoredMaterial(mat, color)
--     self:SetMaterial()
--     self:SetSubMaterial()    
-- end
