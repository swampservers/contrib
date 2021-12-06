local Tag = 'mdlinspect'
module(Tag, package.seeall)

-- binfuncs
if SERVER then
    AddCSLuaFile()
end

-- uint conversion..
do
    local mod = math.fmod
    local floor = math.floor

    local function rshift(x, n)
        return floor((x % 4294967296) / 2 ^ n)
    end

    local function band(x, y)
        local z, i, j = 0, 1

        for j = 0, 31 do
            if (mod(x, 2) == 1 and mod(y, 2) == 1) then
                z = z + i
            end

            x = rshift(x, 1)
            y = rshift(y, 1)
            i = i * 2
        end

        return z
    end

    ------------------------------------------------------------------
    local byte, char = string.byte, string.char

    to_u_int = function(i, endian)
        if type(i) ~= "number" then
            debug.Trace()
            error"need unsigned integer"
        end

        if i < 0 then
            error"bad integer x<0"
        end

        if i > 0xffffffff then
            error"bad integer x>0xffffffff"
        end

        return endian and char(band(i, 255), band(rshift(i, 8), 255), band(rshift(i, 16), 255), band(rshift(i, 24), 255)) or char(band(rshift(i, 24), 255), band(rshift(i, 16), 255), band(rshift(i, 8), 255), band(i, 255))
    end

    from_u_int = function(s, endian, offset)
        offset = offset and tonumber(offset) or 0

        if type(s) ~= "string" then
            error"string required"
        end

        --if s:len()~=4 then error"this is not a uint" end
        local b1, b2, b3, b4 = byte(s, offset + (endian and 1 or 4)), byte(s, offset + (endian and 2 or 3)), byte(s, offset + (endian and 3 or 2)), byte(s, offset + (endian and 4 or 1))
        local n = b1 + b2 * 256 + b3 * 65536 + b4 * 16777216

        if n < 0 then
            error"conversion failure, garry/python sucks"
        end

        if n > 0xffffffff then
            error"conversion failure, garry/python sucks"
        end

        return n
    end
end

local d = 0xFFFFFF00
local a = 0x00FFFFFF
assert(from_u_int(to_u_int(a)) == a)
assert(from_u_int(to_u_int(d)) == d)
assert(from_u_int(to_u_int(d, true), true) == d)
assert(from_u_int(to_u_int(d, true), false) == a)

-- /binfuncs
--fileextras
if SERVER then
    AddCSLuaFile()
end

local File = FindMetaTable"File"
local visit_folders

visit_folders = function(init_path, scope, cb)
    scope = scope or 'GAME'

    local stack = {init_path,}

    -- "models/player"
    -- "models/player/fld1"
    -- "models/player/fld2"
    -- "models/player/fld1/asd"
    -- "models/player/fld1/qwe"
    -- "models/player/fld2"
    while stack[1] do
        local entry = stack[1]
        table.remove(stack, 1)
        local fi, fo = file.Find(entry .. '/*.*', scope)
        local ret = cb(entry .. '/', fi, fo)

        if ret == nil then
            for k, v in next, fo do
                table.insert(stack, 1, entry .. '/' .. v)
            end
        elseif ret == false then
            return
        end
    end
end

file.RecurseFolders = visit_folders
local tmp = {}

function File.ReadString(f, n, ch)
    n = n or 256
    ch = ch or '\0'
    local startpos = f:Tell()
    local offset = 0
    local tmpn = 0
    local sz = f:Size()

    --TODO: Use n and sz instead
    for i = 1, 1048576 do
        --	while true do
        if f:Tell() >= sz then return nil, "eof" end
        local str = f:Read(n)
        --if not str then return nil,"eof","wtf" end
        local pos = str:find(ch, 1, true)

        if pos then
            --offset = offset + pos
            --reset position
            f:Seek(startpos + offset + pos)
            tmp[tmpn + 1] = str:sub(1, pos - 1)

            return table.concat(tmp, '', 1, tmpn + 1)
        else
            tmpn = tmpn + 1
            tmp[tmpn] = str
            offset = offset + n
        end
    end

    return nil, "not found"
end

--/fileextras
local function from_int(s, ...)
    local size = 4
    local n = from_u_int(s, ...)
    if n >= 2 ^ (size * 8 - 1) then return n - 2 ^ (size * 8) end

    return n
end

-- Format: https:--developer.valvesoftware.com/wiki/MDL#File_format
local vstruct
local needvstruct

needvstruct = function()
    vstruct = vstruct or _G.vstruct

    if not vstruct then
        local ok, ret = pcall(require, 'vstruct')

        if ok then
            vstruct = ret or _G.vstruct
        end
    end

    needvstruct = function() return vstruct end

    return vstruct
end

MAX_FORMAT = 49
local MDL = {}

local _M = {
    __index = MDL,
    __tostring = function(self) return "MDL Parser" end
}

function Open(f)
    if isstring(f) then
        f = file.Open(f, 'rb', 'GAME')
    end

    if not f then
        error"invalid file"
    end

    local initial_offset = f:Tell()
    local hdr = f:Read(4)
    if hdr ~= 'IDST' then return nil, "notmdl" end
    local version = from_int(f:Read(4), true)
    if version > MAX_FORMAT then return nil, 'newformat', version end

    local T = {
        file = f,
        version = version,
        initial_offset = initial_offset
    }

    return setmetatable(T, _M)
end

function MDL:IsValid()
    return self.file and true or false
end

function MDL:GetFile()
    return self.file
end

function MDL:Close()
    local f = self.file
    f:Close()
    self.file = false
end

function MDL:_ParseFail(reason)
    self.parsed_header = false
    self.parse_error = reason or "?"
    self.error = "Parsing failed: " .. tostring(reason)

    return nil, reason
end

function MDL:GetError()
    return self.error
end

function MDL:HasFlag(f)
    local bit = ubit or bit

    return bit.band(self.flags, f) == f
end

local flaglist = {
    [0] = "AUTOGENERATED_HITBOX",
    "USES_ENV_CUBEMAP", "FORCE_OPAQUE", "TRANSLUCENT_TWOPASS", "STATIC_PROP", "USES_FB_TEXTURE", "HASSHADOWLOD", "USES_BUMPMAPPING", "USE_SHADOWLOD_MATERIALS", "OBSOLETE", "UNUSED", "NO_FORCED_FADE", "FORCE_PHONEME_CROSSFADE", "CONSTANT_DIRECTIONAL_LIGHT_DOT", "FLEXES_CONVERTED", "BUILT_IN_PREVIEW_MODE", "AMBIENT_BOOST", "DO_NOT_CAST_SHADOWS", "CAST_TEXTURE_SHADOWS",
}

function MDL:ListFlags()
    local t = {}

    for i = 0, #flaglist do
        if self:HasFlag(2 ^ i) then
            t[flaglist[i]] = true
        end
    end

    return t
end

function MDL:Validate(filesize)
    local size = self.dataLength
    local f = self.file
    --TODO: can be wrong
    local fsize = filesize or (f:Size() - self.initial_offset)
    if fsize ~= size then return nil, "size" end
    --local checksum = from_int(self.checksum,true)
    --local crc = util.CRC(dat)
    --dat = nil
    --
    --if tostring(checksum)~=tostring(crc) then
    --	return nil,"checksum","("..tostring(crc)..','..tostring(checksum)..")"
    --end

    return true
end

function MDL:ParseHeader()
    if self.parsed_header ~= nil then return self.parsed_header end
    self.parsed_header = false
    local f = self.file
    local res = self
    res.checksum = f:Read(4)
    local name = f:Read(64)
    name = name:match'^[^%z]*' or ""
    res.name = name
    local dataLength = from_int(f:Read(4), true)
    res.dataLength = dataLength
    -- TODO: skip Vectors, read elsewhere
    f:Seek(f:Tell() + 4 * 3 * 6)
    res.flags = from_int(f:Read(4), true)
    -- mstudiobone_t
    res.bone_count = from_int(f:Read(4), true) -- Number of data sections (of type mstudiobone_t)
    res.bone_offset = from_int(f:Read(4), true) -- Offset of first data section
    -- mstudiobonecontroller_t
    res.bonecontroller_count = from_int(f:Read(4), true)
    res.bonecontroller_offset = from_int(f:Read(4), true)
    -- mstudiohitboxset_t
    res.hitbox_count = from_int(f:Read(4), true)
    res.hitbox_offset = from_int(f:Read(4), true)
    -- mstudioanimdesc_t
    res.localanim_count = from_int(f:Read(4), true)
    res.localanim_offset = from_int(f:Read(4), true)
    -- mstudioseqdesc_t
    res.localseq_count = from_int(f:Read(4), true)
    res.localseq_offset = from_int(f:Read(4), true)
    res.activitylistversion = from_int(f:Read(4), true) -- ??
    res.eventsindexed = from_int(f:Read(4), true) -- ??
    -- VMT texture filenames
    -- mstudiotexture_t
    res.texture_count = from_int(f:Read(4), true)
    res.texture_offset = from_int(f:Read(4), true)
    -- This offset points to a series of ints.
    -- Each int value, in turn, is an offset relative to the start of this header/the-file,
    -- At which there is a null-terminated string.
    res.texturedir_count = from_int(f:Read(4), true)
    res.texturedir_offset = from_int(f:Read(4), true)
    -- Each skin-family assigns a texture-id to a skin location
    res.skinreference_count = from_int(f:Read(4), true)
    res.skinrfamily_count = from_int(f:Read(4), true)
    res.skinreference_index = from_int(f:Read(4), true)
    -- mstudiobodyparts_t
    res.bodypart_count = from_int(f:Read(4), true)
    res.bodypart_offset = from_int(f:Read(4), true)
    -- Local attachment points
    -- mstudioattachment_t
    res.attachment_count = from_int(f:Read(4), true)
    res.attachment_offset = from_int(f:Read(4), true)
    -- Node values appear to be single bytes, while their names are null-terminated strings.
    res.localnode_count = from_int(f:Read(4), true)
    res.localnode_index = from_int(f:Read(4), true)
    res.localnode_name_index = from_int(f:Read(4), true)
    -- mstudioflexdesc_t
    res.flexdesc_count = from_int(f:Read(4), true)
    res.flexdesc_index = from_int(f:Read(4), true)
    -- mstudioflexcontroller_t
    res.flexcontroller_count = from_int(f:Read(4), true)
    res.flexcontroller_index = from_int(f:Read(4), true)
    -- mstudioflexrule_t
    res.flexrules_count = from_int(f:Read(4), true)
    res.flexrules_index = from_int(f:Read(4), true)
    -- IK probably referse to inverse kinematics
    -- mstudioikchain_t
    res.ikchain_count = from_int(f:Read(4), true)
    res.ikchain_index = from_int(f:Read(4), true)
    -- Information about any "mouth" on the model for speech animation
    -- More than one sounds pretty creepy.
    -- mstudiomouth_t
    res.mouths_count = from_int(f:Read(4), true)
    res.mouths_index = from_int(f:Read(4), true)
    -- mstudioposeparamdesc_t
    res.localposeparam_count = from_int(f:Read(4), true)
    res.localposeparam_index = from_int(f:Read(4), true)
    --[[
	 * For anyone trying to follow along, as of this writing,
	 * the next "surfaceprop_index" value is at position 0x0134 (308)
	 * from the start of the file.
	 --]]
    -- Surface property value (single null-terminated string)
    res.surfaceprop_index = from_int(f:Read(4), true)
    -- Unusual: In this one index comes first, then count.
    -- Key-value data is a series of strings. If you can't find
    -- what you're interested in, check the associated PHY file as well.
    res.keyvalue_index = from_int(f:Read(4), true)
    res.keyvalue_count = from_int(f:Read(4), true)
    -- More inverse-kinematics
    -- mstudioiklock_t
    res.iklock_count = from_int(f:Read(4), true)
    res.iklock_index = from_int(f:Read(4), true)
    res.mass = f:ReadFloat() -- Mass of object (4-bytes)
    res.contents = from_int(f:Read(4), true) -- ??
    -- Other models can be referenced for re-used sequences and animations
    -- (See also: The $includemodel QC option.)
    -- mstudiomodelgroup_t
    res.includemodel_count = from_int(f:Read(4), true)
    res.includemodel_index = from_int(f:Read(4), true)
    res.virtualModel = from_int(f:Read(4), true) -- Placeholder for mutable-void*
    -- mstudioanimblock_t
    res.animblocks_name_index = from_int(f:Read(4), true)
    res.animblocks_count = from_int(f:Read(4), true)
    res.animblocks_index = from_int(f:Read(4), true)
    res.animblockModel = from_int(f:Read(4), true) -- Placeholder for mutable-void*
    -- Points to a series of bytes?
    res.bonetablename_index = from_int(f:Read(4), true)
    res.vertex_base = from_int(f:Read(4), true) -- Placeholder for void*
    res.offset_base = from_int(f:Read(4), true) -- Placeholder for void*
    -- Used with $constantdirectionallight from the QC
    -- Model should have flag #13 set if enabled
    res.directionaldotproduct = f:Read(1)
    res.rootLod = f:Read(1) -- Preferred rather than clamped
    -- 0 means any allowed, N means Lod 0 -> (N-1)
    res.numAllowedRootLods = f:Read(1)
    f:Read(1) --		unused; -- ??
    res.unused = from_int(f:Read(4), true) -- ??
    -- mstudioflexcontrollerui_t
    res.flexcontrollerui_count = from_int(f:Read(4), true)
    res.flexcontrollerui_index = from_int(f:Read(4), true)
    --[[*
	 * Offset for additional header information.
	 * May be zero if not present, or also 408 if it immediately
	 * follows this studiohdr_t
	 --]]
    -- studiohdr2_t
    res.studiohdr2index = from_int(f:Read(4), true)

    return true
end

local offsetreaderinfo_1 = {}
local offsetreaderinfo_2 = {}

function MDL:IncludedModels()
    local f = self.file
    local t = self.included_models
    if t then return t end
    local ok = self:SeekTo(self.includemodel_index)
    assert(ok)
    t = {}

    for i = 1, self.includemodel_count do
        local pos = self:Tell()
        local labelOffset = from_int(f:Read(4), true)
        local fileNameOffset = from_int(f:Read(4), true)
        offsetreaderinfo_1[i] = labelOffset + pos
        offsetreaderinfo_2[i] = fileNameOffset + pos
    end

    for i = 1, self.includemodel_count do
        local labelOffset = offsetreaderinfo_1[i]
        local fileNameOffset = offsetreaderinfo_2[i]
        --print(i,labelOffset,fileNameOffset)
        assert(self:SeekTo(labelOffset))
        local label = f:ReadString()
        assert(self:SeekTo(fileNameOffset))
        local fileName = f:ReadString()

        t[i] = {label, fileName}
    end

    self.included_models = t

    return t
end

local mstudioattachment_t_size = 4 + 4 + 4 + (3 * 4) * 4 + 4 * 8 -- int					sznameindex; -- unsigned int			flags; -- int					localbone; -- matrix3x4_t			local; // attachment point -- int					unused[8];

function MDL:offsetAttachment(i)
    assert(i >= 0 and i <= self.attachment_count)

    return self.attachment_offset + mstudioattachment_t_size * i
end

function MDL:SurfaceName()
    local f = self.file
    local name = self.surfaceprop_name
    if name then return name end
    assert(self:SeekTo(self.surfaceprop_index))
    name = f:ReadString()
    assert(name)
    self.surfaceprop_name = name

    return name
end

function MDL:Attachments()
    local f = self.file
    local t = self.attachment_nameslist
    if t then return t end
    t = {}

    -- mstudioattachment_t --
    for i = 0, self.attachment_count - 1 do
        local thispos = self:offsetAttachment(i)
        assert(self:SeekTo(thispos))
        local sznameindex = from_int(f:Read(4), true)
        local flags = from_u_int(f:Read(4), true)
        assert(self:SeekTo(thispos + sznameindex))
        local name = f:ReadString()

        t[#t + 1] = {name, flags}
    end

    self.attachment_nameslist = t

    return t
end

-----------------------------
local mstudiotexture_t_size = 4 + 4 + 4 + 4 + 4 + 4 + 4 * 10 -- int		sznameindex; -- int		flags; -- int		used; -- int		unused1; -- int		material; -- int		client_material; -- int	unused[10];

function MDL:offsetTexture(i)
    assert(i >= 0 and i <= self.texture_count)

    return self.texture_offset + mstudiotexture_t_size * i
end

function MDL:Textures()
    local f = self.file
    local t = self.texture_nameslist
    if t then return t end
    t = {}

    -- mstudiotexture_t --
    for i = 0, self.texture_count - 1 do
        local thispos = self:offsetTexture(i)
        assert(self:SeekTo(thispos))
        local sznameindex = from_int(f:Read(4), true)
        assert(self:SeekTo(thispos + sznameindex))
        local name = f:ReadString()

        t[#t + 1] = {name}
    end

    self.texture_nameslist = t

    return t
end

-----------------------------
function MDL:ParseSkins()
    if self.skintable then return self.skintable end
    local f = self.file
    local textures = self:Textures()
    local skintable = {}
    assert(self:SeekTo(self.skinreference_index))

    for i = 1, self.skinrfamily_count do
        skintable[i] = {}

        for j = 1, self.skinreference_count do
            local textureid = f:Read(1):byte() + f:Read(1):byte() * 256
            skintable[i][j] = textures[textureid + 1]
        end
    end

    self.skintable = skintable

    return skintable
end

-----------------------------
function MDL:TextureDirs()
    local f = self.file
    local t = self.texturedirs
    if t then return t end
    t = {}
    assert(self:SeekTo(self.texturedir_offset))
    local offsets = {}

    for i = 1, self.texturedir_count do
        local offset = from_int(f:Read(4), true)
        offsets[i] = offset
    end

    for _, offset in next, offsets do
        assert(self:SeekTo(offset))
        local name = f:ReadString()
        t[#t + 1] = name
    end

    self.texturedirs = t

    return t
end

-----------------------------
local mstudiobodyparts_t_size = 4 + 4 + 4 + 4 -- int	sznameindex; -- int	nummodels; -- int	base; -- int	modelindex; 

function MDL:offsetBodyPart(i)
    assert(i >= 0 and i <= self.bodypart_count)

    return self.bodypart_offset + mstudiobodyparts_t_size * i
end

function MDL:BodyParts()
    local f = self.file
    local t = self.bodyparts
    if t then return t end
    t = {}
    self:ParseHeader()

    -- mstudiobodyparts_t --
    for i = 0, self.bodypart_count - 1 do
        local thispos = self:offsetBodyPart(i)
        assert(self:SeekTo(thispos))
        local sznameindex = from_int(f:Read(4), true)
        local nummodels = from_u_int(f:Read(4), true)
        local base = from_u_int(f:Read(4), true)
        local modelindex = from_u_int(f:Read(4), true)
        assert(self:SeekTo(thispos + sznameindex))
        local name = f:ReadString()

        t[#t + 1] = {
            this = thispos,
            name = name,
            base = base,
            nummodels = nummodels,
            modelindex = modelindex
        }
    end

    self.bodyparts = t

    return t
end

-- bodypart model
local mstudiomodel_t_size = 64 + 4 + 4 + 4 + 4 + 4 + 4 + 4 + 4 + 4 + 4 + 4 + 4 + 4 + 4 * 8 -- char		name[64]; -- int		type; -- float	boundingradius; -- int		nummeshes;	 -- int		meshindex; -- int		numvertices;		 -- int		vertexindex;		 -- int		tangentsindex;		 -- int		numattachments; -- int		attachmentindex; -- int		numeyeballs; -- int		eyeballindex; -- void		*pVertexData; -- void		*pTangentData; -- int	unused[8];

function MDL:offsetBodyPartModel(part, i)
    local f = self.file
    assert(i >= 0 and i < part.nummodels)

    return part.this + part.modelindex + mstudiomodel_t_size * i
end

function MDL:BodyPartModel(part, i)
    local f = self.file
    local thispos = self:offsetBodyPartModel(part, i)
    assert(self:SeekTo(thispos))
    local name = f:Read(64):gsub("%z*$", "")
    local modeltype = from_u_int(f:Read(4), true)
    local boundingradius = f:ReadFloat()
    local nummeshes = from_u_int(f:Read(4), true)
    local meshindex = from_u_int(f:Read(4), true)
    local numvertices = from_u_int(f:Read(4), true)
    local vertexindex = from_u_int(f:Read(4), true)
    local tangentsindex = from_u_int(f:Read(4), true)
    local numattachments = from_u_int(f:Read(4), true)
    local attachmentindex = from_u_int(f:Read(4), true)
    local numeyeballs = from_u_int(f:Read(4), true)
    local eyeballindex = from_u_int(f:Read(4), true)
    local pVertexData = from_u_int(f:Read(4), true)
    local pTangentData = from_u_int(f:Read(4), true)
    f:Skip(4 * 8) -- unused

    local t = {
        name = name,
        modeltype = modeltype,
        boundingradius = boundingradius,
        nummeshes = nummeshes,
        meshindex = meshindex,
        numvertices = numvertices,
        vertexindex = vertexindex,
        tangentsindex = tangentsindex,
        numattachments = numattachments,
        attachmentindex = attachmentindex,
        numeyeballs = numeyeballs,
        eyeballindex = eyeballindex,
        pVertexData = pVertexData,
        pTangentData = pTangentData
    }

    return t
end

function MDL:BodyPartsEx()
    local t = self.bodypartsx
    if t then return t end
    self:ParseHeader()
    t = table.Copy(self:BodyParts())

    for _, part in next, t do
        for i = 0, part.nummodels - 1 do
            part.models = part.models or {}
            part.models[i + 1] = self:BodyPartModel(part, i)
        end
    end

    self.bodypartsx = t

    return t
end

-- bones
local bone_section_size = 4 + 4 + 4 * 6 + 4 * 3 + 4 * 4 + 4 * 3 + 4 * 3 + 4 * 3 + 48 + 4 * 4 + 4 + 4 + 4 + 4 + 4 + 4 + 4 + 4 * 7 -- int -- int parent --int					bonecontroller[6];	// bone controller index, -1 == none --Vector				pos; --Quaternion			quat; --RadianEuler			rot; --Vector				posscale; --Vector				rotscale; --matrix3x4_t			poseToBone; --Quaternion			qAlignment; --int					flags; --int					proctype; --int					procindex;		// procedural rule --mutable int			physicsbone;	// index into physically simulated bone --int					surfacepropidx;	// index into string tablefor property name --int					contents;		// See BSPFlags.h for the contents flags --int 					surfacepropLookup --int					unused[7];		// remove as appropriate

function MDL:offsetBone(i)
    assert(i >= 0 and i <= self.bone_count)

    return self.bone_offset + bone_section_size * i
end

function MDL:BoneNames()
    local f = self.file
    local t = self.bone_nameslist
    if t then return t end
    t = {}

    -- mstudiobone_t --
    for i = 0, self.bone_count - 1 do
        local thispos = self:offsetBone(i)
        assert(self:SeekTo(thispos))
        local nameoffset = from_int(f:Read(4), true)
        assert(self:SeekTo(thispos + nameoffset))
        local name = f:ReadString()
        t[#t + 1] = name
    end

    self.bone_nameslist = t

    return t
end

function MDL:SeekTo(offset)
    local f = self.file
    local off = self.initial_offset + offset
    if off > f:Size() then return false end --print("offset too big",off-f:Size())
    f:Seek(off)

    return f:Tell() == off
end

function MDL:Tell()
    return self.file:Tell() - self.initial_offset
end

-- bodygroup builder
local MT = {}

function MT:SetBodygroup(group, val)
    assert(group)
    assert(val)
    local bodypart = self.data[group]

    if not bodypart then
        for _, v in next, self.data do
            if v.name == group then
                bodypart = v
                break
            end
        end

        if not bodypart then return false, 1, 'bodypart missing' end
    end

    assert(bodypart.nummodels, "malformed data")
    if bodypart.base == 0 or bodypart.nummodels == 0 then return false, 2, 'no such part' end
    local cur = math.floor(self.bodynum / bodypart.base) % bodypart.nummodels
    if val >= bodypart.nummodels then return false, 3, "no such model number", cur end -- we could not set the right one
    self.bodynum = math.floor(self.bodynum - math.floor(cur * bodypart.base) + math.floor(val * bodypart.base))

    return true
end

MT.Set = MT.SetBodygroup

function MT:GetValue()
    return self.bodynum
end

function MT:Reset(m)
    self.bodynum = m or 0
end

function MT:GetData()
    return self.data
end

function BodyPartBuilder(t, cur)
    assert(t, "need bodypart data")

    return setmetatable({
        data = t,
        bodynum = cur or 0
    }, {
        __index = MT
    })
end

return _M
