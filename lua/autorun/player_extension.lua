-- This file is subject to copyright - contact swampservers@gmail.com for more information.
local meta = FindMetaTable("Player")
local entity = FindMetaTable("Entity")

if not meta then
else
    function meta:GetLocation()  return self:GetDTInt(0) or 0 end
    function meta:GetLastLocation() return self.LastLocation or -1 end 
    function meta:GetLocationName() return Location.GetLocationNameByIndex(self:GetLocation()) end
    function meta:SetLocation(locationId) self.LastLocation = self:GetLocation() return self:SetDTInt(0, locationId) end


    if not meta.TrueName then
        meta.TrueName = meta.Nick
    end

    function meta:Name()
        local st = self:TrueName()

        if self:IsBot() then
            st = "Kleiner"
        end

        if st == "Swamp" and self:SteamID() ~= "STEAM_0:0:38422842" then
            st = "Onions"
        end

        return st
    end

    meta.Nick = meta.Name
    meta.GetName = meta.Name

    if SERVER then
        if not meta.TrueSetPos then
            meta.TrueSetPos = entity.SetPos
        end

        -- prevents teleporting out with it
        function meta:SetPos(pos)
            self:StripWeapon("weapon_kekidol")
            self:TrueSetPos(pos)
        end
    end

    if not meta.TrueSetModel then
        meta.TrueSetModel = entity.SetModel
    end

    function meta:SetModel(modelName)
        self:TrueSetModel(modelName)
        if GAMEMODE.FolderName == "spades" then return end

        if isPonyModel(modelName) then
            if PPM.setPonyValues then
                if self.ponydata == nil then
                    PPM.setupPony(self)
                end

                PPM.setPonyValues(self)
                PPM.setBodygroups(self)
            end

            self:SetViewOffset(Vector(0, 0, self:GetModelScale() * 42))
            self:SetViewOffsetDucked(Vector(0, 0, self:GetModelScale() * 32))

            if modelName == "models/mlp/player_celestia.mdl" then
                self:SetViewOffset(Vector(0, 0, self:GetModelScale() * 66))
                self:SetViewOffsetDucked(Vector(0, 0, self:GetModelScale() * 55))
            end

            if modelName == "models/mlp/player_luna.mdl" then
                self:SetViewOffset(Vector(0, 0, self:GetModelScale() * 58))
                self:SetViewOffsetDucked(Vector(0, 0, self:GetModelScale() * 47))
            end
        else
            PPM:pi_UnequipAll(self)
            --	if self.ponydata~=nil and IsValid(self.ponydata.clothes1) then
            --		self.ponydata.clothes1:Remove()
            --	end
            self:SetViewOffset(Vector(0, 0, self:GetModelScale() * 64))
            self:SetViewOffsetDucked(Vector(0, 0, self:GetModelScale() * 28))

            if modelName == "models/garfield/garfield.mdl" then
                self:SetViewOffset(Vector(0, 0, self:GetModelScale() * 40))
                self:SetViewOffsetDucked(Vector(0, 0, self:GetModelScale() * 18))
            end

            if modelName == "models/player/ztp_nickwilde.mdl" then
                self:SetViewOffset(Vector(0, 0, self:GetModelScale() * 52))
                self:SetViewOffsetDucked(Vector(0, 0, self:GetModelScale() * 24))
            end

            if modelName:StartWith("models/player/minion/") then
                self:SetViewOffset(Vector(0, 0, self:GetModelScale() * 36))
                self:SetViewOffsetDucked(Vector(0, 0, self:GetModelScale() * 8))
            end
        end

        self:SetSubMaterial()
        self:SetDefaultJumpPower()
    end

    function meta:SetDefaultJumpPower()
        self:SetJumpPower(self:IsPony() and 160 or 144)
    end

    function meta:IsPony()
        return isPonyModel(self:GetModel())
    end

    function meta:PonyNoseOffsetBone(ang)
        local pd = PPM.PonyData[self]

        if pd then
            pd = pd[2]
        end

        if pd == nil then
            pd = self.ponydata
        end

        if pd and pd.gender == 2 then return ang:Forward() * 1.9 + ang:Right() * 1.2 end

        return Vector(0, 0, 0)
    end

    function meta:PonyNoseOffsetAttach(ang)
        local pd = PPM.PonyData[self]

        if pd then
            pd = pd[2]
        end

        if pd == nil then
            pd = self.ponydata
        end

        if pd and pd.gender == 2 then return ang:Forward() * 1.8 + ang:Up() * 0.8 end

        return Vector(0, 0, 0)
    end

    function meta:IsAFK()
        return self:GetNWBool("afk", false)
    end

    function meta:StaffControlTheater()
        local minn = 2

        if not CH then
            while minn do
                minn = minn + 1
            end
        end

        if self:GetTheater() and self:GetTheater():Name() == "Movie Theater" then
            minn = 1
        end

        return self:GetRank() >= minn
    end
end

function isPonyModel(modelName)
    modelName = modelName:sub(1, 17)
    if modelName == "models/ppm/player" then return true end
    if modelName == "models/mlp/player" then return true end

    return false
end