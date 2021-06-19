util.AddNetworkString("setcntry")

net.Receive("setcntry", function(len, ply)
    if ply:GetNWString("cntry", "UNSET") == "UNSET" then
        st = net.ReadString()

        if string.len(st) == 2 then
            ply:SetNWString("cntry", st)
        end
    end
end)

local function AppropriateNavArea(ply,area)
    local mins,maxs = ply:GetCollisionBounds()
    if(area:GetSizeX() < maxs.x*2 or area:GetSizeY() < maxs.z*2)then return false end
    return true 
end
     


local meta = FindMetaTable("Player")

function meta:IsStuck()
    return !self:OnGround() and self:GetVelocity() == Vector(0,0,-4.5)

end

function meta:Unstick()
    if(!self:IsStuck())then 
        self:ChatPrint("I don't think you're stuck")
        return 
    end
    local testedareas = 0
    local bestarea 
    local bestareapos = Vector(0,0,160000)
    local areas = navmesh.Find( self:GetPos(), 512, 512, 64 )
    
    
    for k,area in pairs(areas)do
        if( AppropriateNavArea(self,area) )then
            if (bestarea == nil or self:GetPos():Distance(area:GetCenter()) < self:GetPos():Distance(bestareapos))then
            bestarea = area
            bestareapos = area:GetCenter()
            end
        else
            testedareas = testedareas + 1
        end
    end

    if(!bestarea)then areas = navmesh.GetAllNavAreas()
        for k,area in pairs(areas)do
            if( AppropriateNavArea(self,area) )then
                if (bestarea == nil or self:GetPos():Distance(area:GetCenter()) < self:GetPos():Distance(bestareapos))then
                bestarea = area
                bestareapos = area:GetCenter()
                end
            else
                testedareas = testedareas + 1
            end
        end
    end


    if(bestarea)then
        self:SetPos(bestarea:GetCenter() + Vector(0,0,16))
    else
        self:ChatPrint("Unstick Fail!!! #"..testedareas)
    end
end