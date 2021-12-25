-- This file is subject to copyright - contact swampservers@gmail.com for more information.
if not SwampMaterialIndex then
    SwampMaterialIndex = 0

    if file.IsDir("swamp_vmtcache", "DATA") then
        local files, directories = file.Find("swamp_vmtcache/*", "DATA")

        for i, f in ipairs(files) do
            file.Delete("swamp_vmtcache/" .. f)
        end
    else
        file.CreateDir("swamp_vmtcache")
    end
end

SS_ClonedMaterials = SS_ClonedMaterials or {}

--NOMINIFY
-- you are probably cloning the material to edit it. the key is like the hash of your edits for caching.
-- function SS_GetMaterialClone(mat, key) ?
function SS_GetColoredMaterialClone(mat, color)
    if color.x == 1 and color.y == 1 and color.z == 1 then return mat end
    local key = ("%s|%s"):format(color, mat)

    if not SS_ClonedMaterials[key] then
        -- Jump into a fake folder then back out to give this material a unique name
        local clone1 = Material("c" .. tostring(color):gsub("%.", "p"):gsub(" ", "_") .. "/../" .. mat)
        local clone1_name = clone1:GetName()

        if clone1_name == "___error" then
            SwampMaterialIndex = SwampMaterialIndex + 1
            local default = "vertexlitgeneric\n{\n}"
            local data = file.Read("materials/" .. mat .. ".vmt", "GAME")

            if not data then
                print("MISSING", mat)
                data = default
            end

            data = data:Trim()
            local lines = ("\n"):Explode(data)

            for i, line in ipairs(lines) do
                line = line:lower()

                if line:find("color2") then
                    -- print("MATERIAL "..mat.." HAS COLOR2 ALREADY FIX THIS")
                    ErrorNoHalt("TELL SWAMP TO FIX " .. mat)
                end
            end

            if not data:EndsWith("}") then
                print("INVALID", mat)
                data = default
            end

            data = data:sub(1, -2) .. '\n"$color2" "[' .. tostring(color) .. ']"\n}'
            file.Write(("swamp_vmtcache/%s.vmt"):format(SwampMaterialIndex), data)
            SS_ClonedMaterials[key] = "../data/swamp_vmtcache/" .. SwampMaterialIndex
        else
            clone1:SetVector("$color2", color * (clone1:GetVector("$color2") or Vector(1, 1, 1)))
            SS_ClonedMaterials[key] = clone1_name
        end
    end

    return SS_ClonedMaterials[key]
end

-- SS_MaterialCache = {}
-- function SS_GetMaterial(nam)
--     SS_MaterialCache[nam] = SS_MaterialCache[nam] or Material(nam)
--     return SS_MaterialCache[nam]
-- end
-- function SS_GetColoredMaterialClone(mat, color)
--     if color.x == 1 and color.y == 1 and color.z == 1 then return mat end
--     local colorkey = "c" .. tostring(color):gsub("%.", "p"):gsub(" ", "_")
--     local clonekey = colorkey .. "/../" .. mat
--     if not SS_ClonedMaterials[clonekey] then
--         MATERIALCLONEINDEX = (MATERIALCLONEINDEX or 0) + 1
--         -- print("MAKE", clonekey)
--         -- mat = mat:gsub("'","")
--         local mat2 = Material(clonekey)
--         local matname = mat2:GetName()
--         if matname == "___error" then
--             -- print("INVALID MATERIAL", mat)
--             local data = file.Read("materials/" .. mat .. ".vmt", "GAME") or "vertexlitgeneric\n{\n}"
--             local fixdata = data:Trim():lower()
--             if not (fixdata:StartWith("vertexlitgeneric") or fixdata:StartWith("'vertexlitgeneric") or fixdata:StartWith("\"vertexlitgeneric")) then
--                 print("WARNING, WRONG SHADER ON BAD MATERIAL")
--                 print(mat, data)
--             elseif fixdata:find("proxies") then
--                 print("WARNING, PROXIES ON BAD MATERIAL")
--                 print(mat, data)
--             end
--             mat2 = CreateMaterial("clonedmaterial" .. MATERIALCLONEINDEX, "vertexlitgeneric", util.KeyValuesToTable(data))
--             --     mat2 = PPM_CLONE_MATERIAL(Material(mat), mat .. colorkey )
--             --     print("FIXED", mat2:GetName())
--             -- mat2 = Material(mat.."/"..MATERIALCLONEINDEX.."/../../"..table.remove( ("/"):Explode(mat) ) )
--             -- print(mat2:GetName(), mat.."/"..MATERIALCLONEINDEX.."/../../"..table.remove( ("/"):Explode(mat) ) )
--             matname = "!" .. mat2:GetName()
--         end
--         mat2:SetVector("$color2", color * (mat2:GetVector("$color2") or Vector(1, 1, 1)))
--         SS_ClonedMaterials[clonekey] = matname
--     end
--     return SS_ClonedMaterials[clonekey]
-- end
function Entity:SetColoredBaseMaterial(color)
    self:SetMaterial()
    self:SetSubMaterial()
    -- -- refactor - set default materials for models and support material override in shop
    -- if self:GetModel() == "models/props_crates/static_crate_40.mdl" then
    --     self:SetSkin(1)
    -- end
    -- might there be an issue if the mat doesn't default to white?
    if color.x == 1 and color.y == 1 and color.z == 1 then return end

    -- MATERIALCLONEINDEX = (MATERIALCLONEINDEX or 0) + 1
    for i, mat in ipairs(self:GetMaterials()) do
        self:SetSubMaterial(i - 1, SS_GetColoredMaterialClone(mat, color))
    end
end
-- self:SetMaterial(SS_GetColoredMaterialClone(mat, color))
-- function Entity:SetColoredMaterial(mat, color)
--     self:SetMaterial()
--     self:SetSubMaterial()    
-- end
