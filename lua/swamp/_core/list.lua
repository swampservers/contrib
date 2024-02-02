local listmeta = Table.List

table.Merge(listmeta, {
    -- too vague, use Push or Extend
    Append = function(self, obj)
        ErrorNoHaltWithStack("Use Push or Extend")
    end,
    --     if obj == nil then return end --     local len = self[0] + 1 --     self[len] = obj --     self[0] = len
    Push = function(self, obj)
        if obj == nil then return end
        local len = self[0] + 1
        self[len] = obj
        self[0] = len
    end,
    Pop = function(self)
        local len = self[0]
        if len == 0 then return nil end
        local v = self[len]
        self[len] = nil
        self[0] = len - 1

        return v
    end,
    Remove = function(self, i)
        local len = self[0]
        if i < 1 or i > len then return end
        self[0] = len - 1

        return table.remove(self, i)
    end,
    Top = function(self)
        local len = self[0]
        if len == 0 then return nil end

        return self[len]
    end,
    Size = function(self) return self[0] end,
    Length = function(self) return self[0] end,
    Sort = function(self, comparator)
        table.sort(self, comparator)

        return self
    end,
    Extend = function(self, other)
        local len = self[0]

        for i, v in ipairs(other) do
            len = len + 1
            self[len] = v
        end

        self[0] = len

        return self
    end,
    Map = function(self, callback)
        local loss, len = 0, self[0]

        for i, v in ipairs(self) do
            v = callback(v)

            if v == nil then
                loss = loss + 1
            else
                self[i - loss] = v
            end
        end

        self[0] = len - loss
        len = self[0] + 1

        while self[len] ~= nil do
            self[len] = nil
            len = len + 1
        end

        return self
    end,
    ToTable = function(self)
        self[0] = nil
        setmetatable(self, nil)

        return self
    end
})

listmeta.__index = listmeta
debug.getregistry().List = listmeta
--- Basically util.Stack but a little faster
List = listmeta

setmetatable(List, {
    __call = function(_list, tab)
        if tab then
            tab[0] = #tab
        else
            tab = {
                [0] = 0
            }
        end

        return setmetatable(tab, listmeta)
    end
})
-- makes list() callable
-- setmetatable(list, {
--     __call = function(_list, tab) 
--         ErrorNoHaltWithStack("rename to List") 
--         return List(tab) end
-- })
-- function list0(tab)
--     local list0meta = {
--         Push = function(self, obj)
--             local len = self[0] + 1
--             self[len] = obj
--             self[0] = len
--         end,
--         Pop = function(self)
--             local len = self[0]
--             if len == 0 then return nil end
--             local v = self[len]
--             self[len] = nil
--             self[0] = len - 1
--             return v
--         end
--     }
--     list0meta.__index = list0meta
--     return setmetatable({
--         [0] = 0
--     }, list0meta)
-- end
-- function list1(tab)
--     local list1meta = {
--         Push = function(self, obj)
--             local len = self[true] + 1
--             self[len] = obj
--             self[true] = len
--         end,
--         Pop = function(self)
--             local len = self[true]
--             if len == 0 then return nil end
--             local v = self[len]
--             self[len] = nil
--             self[true] = len - 1
--             return v
--         end
--     }
--     list1meta.__index = list1meta
--     return setmetatable({
--         [true] = 0
--     }, list1meta)
-- end
-- function list2(tab)
--     local list2meta = {
--         Push = function(self, obj)
--             local len = self.len + 1
--             self[len] = obj
--             self.len = len
--         end,
--         Pop = function(self)
--             local len = self.len
--             if self.len == 0 then return nil end
--             local v = self[len]
--             self[len] = nil
--             self.len = len - 1
--             return v
--         end
--     }
--     list2meta.__index = list2meta
--     return setmetatable({
--         len = 0
--     }, list2meta)
-- end
-- function list3(tab)
--     local len = 0
--     local list3meta = {
--         Push = function(self, obj)
--             self[len] = obj
--             len = len + 1
--         end,
--         Pop = function(self)
--             local v = self[len]
--             self[len] = nil
--             if len > 0 then
--                 len = len - 1
--             end
--             return v
--         end
--     }
--     list3meta.__index = list3meta
--     return setmetatable({}, list3meta)
-- end
-- print("\n\n\n\n\n")
-- local function testt(l)
--     local x=l() for i=1,10000 do x:Push(i) end while x:Pop() do end 
-- end
-- -- self[0] is faster than self.len, same as self[true]. upvalue is fastest but would be slow to construct
-- for i=1,5 do
--     bench({
--         zero=function() testt(list0) end,
--         tru=function() testt(list1) end,
--         len=function() testt(list2) end,
--         upv=function() testt(list3) end
--     })
-- end
-- if CLIENT then
-- for k,maker in pairs({
--     list=list,
--     -- list2=list2,
--     -- list3=list3,
--     -- stack=util.Stack
-- }) do
--     print(k, maker)
--     bench(function()
--         for i=1,1000 do
--             local stack = List()
--             for j=1,1000 do
--                 -- stack:Push(j)
--                 listmeta.Push(stack,j) 
--             end
--             stack:Filter(function(x) return x%2==0 end)
--         end
--     end)
-- end
-- end
-- local meta = getmetatable( "" )
-- function meta:__index( key )
-- 	local val = string[ key ]
-- 	if  val ~= nil  then
-- 		return val
-- 	elseif ( tonumber( key ) ) then
-- 		return self:sub( key, key )
-- 	end
-- end
-- local sub=string.sub 
-- SUB=string.sub
-- local function thing()
-- T=List() for i=1,5 do local x="" for i=1,1000 do x=x..(math.random()>0.5 and "." or "a") end T:Push(x) end
-- a,b,c,d,e = unpack(T)
-- print(table.concat(T, "/"))
-- -- return T
-- -- end
-- -- local t = {{{{{{{{{{{{}}}}}}}}}}}}
-- local sw = string.StartWith
-- local ss = string.sub
-- local sl = string.len
-- function sw3( String, Start )
-- 	return ss( String, 1, #Start ) == Start
-- end
-- bench({
-- --     metasub=  function() x=0 for i=1,1000000 do if T[i]:sub(1,1)=="." then x=x+1 end  end end ,
-- --     metaindex=  function() x=0 for i=1,1000000 do if T[i][1]=="." then x=x+1 end  end  end ,
-- -- --     -- ( function() x=0 T:Filter(function(v) if v[1]=="." then x=x+1 end return v end) end ),
-- -- --     glo=( function() x=0 thing():Filter(function(v) if SUB(v,1,1)=="." then x=x+1 end return v end) end ),
-- -- --     loc=( function() x=0 thing():Filter(function(v) if sub(v,1,1)=="." then x=x+1 end return v end) end ),
-- --     SUB =  function() x=0 for i=1,1000000 do if SUB(T[i],1,1)=="." then x=x+1 end  end  end ,
--     -- sw1 =  function() x=0 for i=1,1000000 do if T[i]:StartWith(".") then x=x+1 end  end end ,
--     sw2 =  function() x=0 for i=1,1000 do if a.."/"..b.."/"..c.."/"..d.."/"..e then x=x+1 end  end end ,
--     s =  function() x=0 for i=1,1000 do if table.concat(T, "/") then x=x+1 end  end end ,
-- -- --     -- ( function() x=0 T:Filter(function(v) if string.StartWith(v,".") then x=x+1 end return v end) end ),
-- -- --     -- ( function() x=0 T:Filter(function(v) if v:StartWith(".") then x=x+1 end return v end) end ),    
--     -- function() x=0 for i=1,1000000 do if t[1][1][1][1][1] then x=x+1 end end end,
--     -- function() x=0 local s=t[1][1][1][1][1] for i=1,1000000 do if s then x=x+1 end end end 
-- })
-- bench(function() x=0 T:Filter(function(v) if v[1]=="." then x=x+1 end return v end) end)
-- bench(function() x=0 T:Filter(function(v) if v[1]=="." then x=x+1 end return v end) end)
