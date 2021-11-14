
local function dbg(...)
    -- print(...)

end
local function dbgn(...)
    -- print(...)

end



--requires mdlinspect.lua
function MDLIsPlayermodel(f)
    local mdl, err, err2 = mdlinspect.Open(f)
    if not mdl then return nil, err, err2 end
    if mdl.version < 44 or mdl.version > 49 then return false, "bad model version" end
    local ok, err = mdl:ParseHeader()
    if not ok then return false, err or "hdr" end
    if not mdl.bone_count or mdl.bone_count <= 2 then return false, "nobones" end
    local imdls = mdl:IncludedModels()
    local found_anm

    for k, v in next, imdls do
        v = v[2]
        if v and v:find("_arms_", 1, true) then return false, "arms" end
        if v and not v:find"%.mdl$" then return false, "badinclude", v end

        if v == "models/m_anm.mdl" or v == "models/f_anm.mdl" or v == "models/z_anm.mdl" then
            found_anm = true
        end
    end

    local attachments = mdl:Attachments()

    if (not attachments or not next(attachments)) and not found_anm then
        return false, "noattachments"
    else
        local found

        for k, v in next, attachments do
            local name = v[1]

            if name == "eyes" or name == "anim_attachment_head" or name == "mouth" or name == "anim_attachment_RH" or name == "anim_attachment_LH" then
                found = true
                break
            end
        end

        if not found and not found_anm then return false, "attachments" end
    end



    -- bounds check
    local meshes = util.GetModelMeshes(f) or {}

    local max,min
    local vcount = 0
    
    for k, v in pairs(meshes) do
        for _, l in pairs(meshes[k]["verticies"]) do
            vcount = vcount + 1
            local p = l.pos
            
            if not max then max=p min=p continue end

            max.x = math.max(max.x, p.x)
            max.y = math.max(max.y, p.y)
            max.z = math.max(max.z, p.z)
            min.x = math.min(min.x, p.x)
            min.y = math.min(min.y, p.y)
            min.z = math.min(min.z, p.z)
        end
    end
  
    if vcount < 30 then
        return false, "Model has too few vertices (" .. vcount .. "<30)"
    elseif min:Distance(max) > 200 then
        return false, "Model's boundary box is too large (" .. min:Distance(max) .. ">200)"
    end

    return true, found_anm
end




function IsUGCFilePath(path)
	return path:find("^.:") or path:find("^[%\\%/]") or false
end


function GMABlacklist(fpath,wsid)
	assert(fpath)

	local f = file.Open(fpath,'rb','MOD')
	dbg("GMABlacklist",fpath,f and "" or (IsUGCFilePath(fpath) and "UGC, SKIP" or "INVALIDFILE"))
	
	if not f then
		if IsUGCFilePath(fpath) then return true,'file' end -- Can no longer access gma data
		return nil,"file"
	end
	
	local gma,err = gmaparse.Parser(f)
	if not gma then return nil,err end

	local ok ,err = gma:ParseHeader()
	if not ok then return nil,err end
	

	local paths = {}
	local check_vtfs = {}
	for i=1,8192*2 do
		local entry,err = gma:EnumFiles()
		if not entry then
			if err then dbge("GMABlacklist","enumfiles",wsid,err) end
			break
		end
		local path = entry.Name
		assert(path)
		
		paths[#paths+1] = path:lower()
		if path:Trim():sub(-4):lower()=='.vtf' then
			--print(path,entry.Offset)
			assert(not check_vtfs[entry.Offset] )
			check_vtfs[entry.Offset] = path
		end
	end
	
	local endheader = f:Tell()
	
	if not next(check_vtfs) then dbgn(3,"CheckVTF","none found??") end
	
	for offset,path in next, check_vtfs do
		dbgn(2,"CheckVTF",path)
		
		if not gma:SeekToFileOffset(offset) then return nil,'seekfail' end
		
		local dat, err = file.ParseVTF(f)
		if not dat then 
			-- dbge("GMABlacklist","ParseVTF",path,wsid,"could not parse",err)
		elseif dat.width>4096 or dat.height>4096 then
			-- dbge("GMABlacklist","ParseVTF",wsid,"oversize")
			return nil,'oversize vtf'
		end
	end
	
	for i=1,#paths do
		local path = paths[i]
		
		--Check 1: modules
		if path:find("includes",4,true) and path:gsub("\\","/"):gsub("/./","/"):gsub("/./","/"):gsub("/+","/"):find("lua/includes/",1,true) then
			return nil,"includes"
		end
		
		--Check 2
		-- Model overrides / script overrides / config overrides / etc

		
	end
	
	return true
	
end











-- binfuncs
do -- uint conversion..
	local mod   = math.fmod
	local floor = math.floor

	local function rshift(x,n)
		return floor((x%4294967296)/2^n)
	end

	local function band(x,y)
		local z,i,j = 0,1
		for j = 0,31 do
			if (mod(x,2)==1 and mod(y,2)==1) then
				z = z + i
			end
			x = rshift(x,1)
			y = rshift(y,1)
			i = i*2
		end
		return z
	end
	------------------------------------------------------------------

    local byte,char=string.byte,string.char
    to_u_int = function(i,endian)
        if type(i)~="number" then debug.Trace() error"need unsigned integer" end
        if i<0 then error"bad integer x<0" end
        if i>0xffffffff then error"bad integer x>0xffffffff" end
        return endian and char(
				band(i,255) ,
				band(rshift(i,8),255 ),
				band(rshift(i,16),255 ),
				band(rshift(i,24),255 ))
		or 	char(
				band(rshift(i,24),255 ),
				band(rshift(i,16),255 ),
				band(rshift(i,8),255 ),
				band(i,255) )
    end
    from_u_int = function(s,endian,offset)
		offset=offset and tonumber(offset) or 0
        if type(s)~="string" then error"string required" end
        --if s:len()~=4 then error"this is not a uint" end

        local b1,b2,b3,b4=
			byte(s,offset+(endian and 1 or 4)),
            byte(s,offset+(endian and 2 or 3)),
            byte(s,offset+(endian and 3 or 2)),
            byte(s,offset+(endian and 4 or 1))
        local n = b1 + b2*256 + b3*65536 + b4*16777216

       if n<0 then error"conversion failure, garry/python sucks" end
       if n>0xffffffff then error"conversion failure, garry/python sucks" end
       return n
    end

end

local d=0xFFFFFF00
local a=0x00FFFFFF
assert(from_u_int(to_u_int(a))==a)
assert(from_u_int(to_u_int(d))==d)
assert(from_u_int(to_u_int(d,true),true)==d)
assert(from_u_int(to_u_int(d,true),false)==a)
-- /binfuncs

--fileextras
if SERVER then
	AddCSLuaFile()
end

local File = FindMetaTable"File"

local visit_folders
visit_folders = function(init_path,scope,cb)
	scope = scope or 'GAME'
	
	local stack = {
		init_path,
	}
	
	-- "models/player"
	
	-- "models/player/fld1"
	-- "models/player/fld2"
	
	-- "models/player/fld1/asd"
	-- "models/player/fld1/qwe"
	-- "models/player/fld2"
	
	while stack[1] do
		local entry = stack[1]
		table.remove(stack,1)
		
		local fi,fo = file.Find(entry..'/*.*',scope)
		local ret = cb(entry..'/',fi,fo)
		if ret == nil then
			for k,v in next,fo do
				table.insert(stack,1,entry..'/'..v)
			end
		elseif ret == false then return end
	end
	
end


file.RecurseFolders = visit_folders

local tmp = {}
function File.ReadString(f,n,ch)
	n = n or 256
	ch = ch or '\0'
	local startpos = f:Tell()
	local offset = 0
	local tmpn = 0
	local sz = f:Size()
	
	--TODO: Use n and sz instead
	for i=1,1048576 do
--	while true do
		if f:Tell()>=sz then return nil,"eof" end
		local str = f:Read(n)
		--if not str then return nil,"eof","wtf" end
		local pos = str:find(ch,1,true)
		if pos then
			--offset = offset + pos
			
			--reset position
			f:Seek(startpos+offset+pos)
			
			tmp[tmpn + 1] = str:sub(1,pos - 1)
			return table.concat(tmp,'',1,tmpn+1)
		else
			tmpn = tmpn + 1
			tmp[tmpn] = str
			offset = offset + n
		end
	end
	return nil,"not found"
end
--/fileextras




