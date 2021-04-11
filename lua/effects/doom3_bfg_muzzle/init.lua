-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
EFFECT.mat = Material("sprites/doom3/bfg_mflash")
local exists = file.Exists("materials/sprites/doom3/bfg_mflash.vmt", "GAME")

function EFFECT:Init(data)
    self.Pos = data:GetOrigin()
    self.Time = 0
    self.Size = 32
end

function EFFECT:Think()
    self.Time = self.Time + FrameTime()
    self.Size = 64 * self.Time ^ .1

    return self.Time < .5
end

function EFFECT:Render()
    if self.mat == nil then return end
    render.SetMaterial(self.mat)

    if exists then
        self.mat:SetInt("$frame", math.Clamp(math.floor(self.Time * 64), 0, 31))
    end

    render.DrawSprite(self.Pos, 64, 64)
end