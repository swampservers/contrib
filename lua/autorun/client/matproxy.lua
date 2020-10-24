-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

-- function render.DrawingScreen()
-- 	local t = render.GetRenderTarget()
-- 	return (t==nil) or (tostring(t)=="[NULL Texture]")
-- end

--[[
local op = Material('swamponions/wall/orangeplaster')
op:SetFloat('$detailscale', 1)
]]
matproxy.Add( {
	name = "PlayerWeaponColor2",

	init = function( self, mat, values )

		self.ResultTo = values.resultvar

	end,

	bind = function( self, mat, ent )

		if ( !IsValid( ent ) ) then return end

		local owner = ent:GetOwner()
		if ( !IsValid( owner ) or !owner:IsPlayer() ) then return end

		local col = owner:GetPlayerColor() --should be waepon color
		if ( !isvector( col ) ) then return end

		--local mul = ( 1 + math.sin( CurTime() * 5 ) ) * 0.5

		mat:SetVector( self.ResultTo, col ) --+ col * mul )

	end
} )

matproxy.Add( {
	name = "ArcadeSignColor",

	init = function( self, mat, values )

		self.ResultTo = values.resultvar

	end,

	bind = function( self, mat, ent )
		
		mat:SetVector( self.ResultTo, LerpVector((math.sin(CurTime())+1)/2,Vector(1,0,(118/255)),Vector(0,0.25,1) ))

	end
} )

matproxy.Add( {
	name = "PlayerColor",

	init = function( self, mat, values )
		-- Store the name of the variable we want to set
		self.ResultTo = values.resultvar
	end,

	bind = function( self, mat, ent )
		if ( !IsValid( ent ) ) then return end

		-- If entity is a ragdoll try to convert it into the player
		-- ( this applies to their corpses )
		if ( ent:IsRagdoll() ) then
			local owner = ent:GetRagdollOwner()
			if ( IsValid( owner ) ) then ent = owner end
		end

		-- If the target ent has a function called GetPlayerColor then use that
		-- The function SHOULD return a Vector with the chosen player's colour.
		if ( ent.GetPlayerColor ) then
			local col = ent:GetPlayerColor()
			if ( isvector( col ) ) then
				col = Vector(math.Clamp(col.x,0,1),math.Clamp(col.y,0,1),math.Clamp(col.z,0,1))
				mat:SetVector( self.ResultTo, col )
			end
		else
			mat:SetVector( self.ResultTo, Vector( 62 / 255, 88 / 255, 106 / 255 ) )
		end
	end
} )


matproxy.Add( {
	name = "ToggleSelfillum",
	init = function( self, mat, values )
		self.light = values.lightname.."_on"
	end,
	bind = function( self, mat, ent )
		local on = GetGlobalBool(self.light, true)
		local flags = mat:GetInt("$flags")
		if (bit.band(flags,64)>0)~=on then
			mat:SetInt("$flags", bit.bxor(flags,64))
		end
	end
} )

matproxy.Add( {
	name = "ToggleEmissiveBlend",
	init = function( self, mat, values )
		self.light = values.lightname.."_on"
	end,
	bind = function( self, mat, ent )
		local on = GetGlobalBool(self.light, true)
		mat:SetInt("$emissiveBlendEnabled", on and 1 or 0)
		-- local flags = mat:GetInt("$flags")
		-- if (bit.band(flags,64)>0)~=on then
		-- 	mat:SetInt("$flags", bit.bxor(flags,64))
		-- end
	end
} )
