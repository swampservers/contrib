
sv_GetVideoInfo = sv_GetVideoInfo or {}

sv_GetVideoInfo.soundcloud = function(self, key, ply, onSuccess, onFailure)
	theater.GetVideoInfoClientside(self:GetClass(), key, ply, onSuccess, onFailure)
end