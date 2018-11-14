local meta = FindMetaTable("Player")
local entity = FindMetaTable( "Entity" )

if !meta then else

	if !meta.TrueName then

		meta.TrueName = meta.Nick 

	end

	function meta:Name()
		local st = self:TrueName()
		if self:IsBot() then st="Kleiner" end
		if st=="Swamp" and self:SteamID()~="STEAM_0:0:38422842" then st="Onions" end
		return st
	end

	meta.Nick = meta.Name
	meta.GetName = meta.Name

	if !meta.TrueSetModel then
		local meta2 = FindMetaTable( "Entity" )
		meta.TrueSetModel = meta2.SetModel
	end

	function meta:SetModel(modelName)
		self:TrueSetModel(modelName)
		if GAMEMODE.FolderName=="spades" then return end
		
		if isPonyModel(modelName) then

			if self.ponydata==nil then
				PPM.setupPony(self) 
			end
			PPM.setPonyValues(self) 
			PPM.setBodygroups(self)

			self:SetViewOffset(Vector(0,0,self:GetModelScale()*42))
			self:SetViewOffsetDucked(Vector(0,0,self:GetModelScale()*32))
			if GAMEMODE.FolderName=="cinema" then self:SetJumpPower(160) end
			if modelName=="models/mlp/player_celestia.mdl" then
				self:SetViewOffset(Vector(0,0,self:GetModelScale()*66))
				self:SetViewOffsetDucked(Vector(0,0,self:GetModelScale()*55))
			end
			if modelName=="models/mlp/player_luna.mdl" then
				self:SetViewOffset(Vector(0,0,self:GetModelScale()*58))
				self:SetViewOffsetDucked(Vector(0,0,self:GetModelScale()*47))
			end
		else
			PPM:pi_UnequipAll(self)
		--	if self.ponydata~=nil and IsValid(self.ponydata.clothes1) then
		--		self.ponydata.clothes1:Remove()
		--	end

			self:SetViewOffset(Vector(0,0,self:GetModelScale()*64))
			self:SetViewOffsetDucked(Vector(0,0,self:GetModelScale()*28))
			if GAMEMODE.FolderName=="cinema" then self:SetJumpPower(144) end
			if modelName=="models/garfield/garfield.mdl" then
				self:SetViewOffset(Vector(0,0,self:GetModelScale()*40))
				self:SetViewOffsetDucked(Vector(0,0,self:GetModelScale()*18))
			end
			if modelName=="models/player/ztp_nickwilde.mdl" then
				self:SetViewOffset(Vector(0,0,self:GetModelScale()*52))
				self:SetViewOffsetDucked(Vector(0,0,self:GetModelScale()*24))
			end
			if modelName:StartWith("models/player/minion/") then
				self:SetViewOffset(Vector(0,0,self:GetModelScale()*36))
				self:SetViewOffsetDucked(Vector(0,0,self:GetModelScale()*8))
			end
		end
		self:SetSubMaterial()
	end

	function meta:IsPony()
		return isPonyModel(self:GetModel())
	end

	function meta:PonyNoseOffsetBone(ang)
		local pd = PPM.PonyData[self]
		if pd then pd=pd[2] end
		if pd==nil then
			pd = self.ponydata
		end
		if pd and pd.gender==2 then
			return ang:Forward()*1.9 + ang:Right()*1.2
		end
		return Vector(0,0,0)
	end

	function meta:PonyNoseOffsetAttach(ang)
		local pd = PPM.PonyData[self]
		if pd then pd=pd[2] end
		if pd==nil then
			pd = self.ponydata
		end
		if pd and pd.gender==2 then
			return ang:Forward()*1.8 + ang:Up()*0.8
		end
		return Vector(0,0,0)
	end

	function meta:IsAFK()
		return self:GetNWBool("afk",false)
	end

	function meta:StaffControlTheater()
		--[[ local min = 2
		if self:GetTheater() and self:GetTheater():Name()=="Movie Theater" then
			min = 1
		end ]]
		return self:GetRank() >= 1
	end
end

function isPonyModel(modelName)
	modelName = modelName:sub(1,17)	
	if modelName=="models/ppm/player" then return true end
	if modelName=="models/mlp/player" then return true end
	return false
end
