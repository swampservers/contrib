-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
sv_GetVideoInfo = sv_GetVideoInfo or {}

sv_GetVideoInfo.neko = function(self, key, ply, onSuccess, onFailure)
    theater.GetVideoInfoClientside(self:GetClass(), key, ply, onSuccess, onFailure)
end