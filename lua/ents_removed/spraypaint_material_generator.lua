local function CreateDecalMats()
    local Colors = {
        Color(255,0,0),
        Color(255,64,0),
        Color(255,255,0),
        Color(0,255,0),
        Color(0,0,255),
        Color(126,10,243),
        Color(255,23,139),
        Color(255,255,255),
        Color(0,0,0),
    }
    local Sizes = {24,12,6} 
    
    local index = 0
    for k, size in pairs(Sizes)do
        for g, color in pairs(Colors)do
            index = index + 1
            local dname = "spraypaint_decal"..index
            local matname = dname
            local dirname = "spray/"..dname
            local color = color:ToVector()
            local cstring = "["..color.x.." "..color.y.." "..color.z.."]"
                
                local mat1 = [["LightmappedGeneric" 
                {
                    "$basetexture" "spray/dot"
                    "$translucent" "1"
                    "$decal" "1"
                    "$decalscale" "]]..(1 / 64)*size..[["
                    "$modelmaterial" "]]..dirname .. [[_model"
                    "$color2" "]]..cstring..[["
                }]]

                local mat2 = [["VertexLitGeneric"
                {
                    "$basetexture" "spray/dot"
                    "$translucent" 1
                    "$decal" "1"
                    "$decalscale" "]]..(1 / 64)*size..[["
                    "$color2" "]]..cstring..[["
                }]]

                file.CreateDir("chungus")
                file.Write("chungus/"..matname..".vmt",mat1)
                file.Write("chungus/"..matname.."_model.vmt",mat2)  

               

        end
    end

   


end


local function CreateStencilMats()
    local script = ""
    for i=1,40 do

            local dname = "stencil_decal"..i
            local matname = dname
            local dirname = "spray/"..dname
            local color = Vector(1,1,1)
            local cstring = "["..color.x.." "..color.y.." "..color.z.."]"
            local unit = 1/8
            local size = 16
            local Shader1 = "DecalModulate"
            local Shader2 = "DecalModulate"

                local mat1 = [["]]..Shader1..[["
                {
                    "$basetexture" "spray/stencils"
                    "$translucent" "1"
                    "$decal" "1"
                    "$decalsecondpass" "1"
                    "$frame" "]].. i-1 ..[["
                    "$decalscale" "]]..(1 / 64)*size..[["
                    "$modelmaterial" "]]..dirname .. [[_model"
                }]]

                local mat2 = [["]]..Shader2..[["
                {
                    "$basetexture" "spray/stencils"
                    "$translucent" "1"
                    "$decal" "1"
                    "$decalsecondpass" "1"
                    "$frame" "]].. i-1 ..[["
                    "$decalscale" "]]..(1 / 64)*size..[["
                }]]
                file.CreateDir("chungus")
                file.Write("chungus/"..matname..".vmt",mat1)
                file.Write("chungus/"..matname.."_model.vmt",mat2)  

                script = script.. [["]]..dname..[["
                {
                    "]]..dirname..[[" "1" 
                }
                ]]

            end
            

            file.Write("chungus/stencils.txt",script)  
end
--CreateDecalMats()

--CreateStencilMats()   