--[[
possible options:
pitch
crouchpitch
level
volume
channel

ent: emit from this ent instead of player
shared: emit on client without networking, assuming called in shared function
speech: move player lips (time to move lips, or auto if < 0)

]]

local meta = FindMetaTable("Player")

function meta:ExtEmitSound(sound, options)
	options = options or {}
	if SERVER or (options.shared and IsFirstTimePredicted()) then
		local pitch = self:Crouching() and ((options.crouchpitch or options.pitch) or 160) or (options.pitch or 100)
		options.pitch = nil
		options.crouchpitch = nil
		ExtSoundEmitSound(self, sound, pitch, options)
	end
end

meta = FindMetaTable("Entity")

function meta:ExtEmitSound(sound, options)
	if IsValid(self.Owner) then
		options = options or {}
		options.ent = self
		options.channel = options.channel or CHAN_WEAPON
		self.Owner:ExtEmitSound(sound, options)
	else
		print("Warning: ExtEmitSound from loose entity "..tostring(self))
	end
end