

local AniObj = {}

AniObj.__index = AniObj


function AniObj.new(Data)
	local AniIns = {}
	setmetatable(AniIns,AniObj)
	AniIns.Animation = Data.Animation
	local Ani = Data.Humanoid.Animator:LoadAnimation(Data.Animation)
	AniIns.LoadedAni = Ani
	AniIns.Aj = 1
	return AniIns
end

function AniObj:AdjustSpeed(Num)
	self.Aj = Num
end

function AniObj:Play(Num)
	self.LoadedAni:Play(Num)
	self.LoadedAni:AdjustSpeed(self.Aj)

end

function AniObj:Stop()
	self.LoadedAni:Stop()
--	print("Stopping")
end

function AniObj:IsPlaying()
	return self.LoadedAni.IsPlaying
end

function AniObj:ReturnLoaded()
	return self.LoadedAni
end

function AniObj:Destroy()
	self = nil
end

function AniObj:GetMarkerReachedSignal(Name)
	return self.LoadedAni:GetMarkerReachedSignal(Name)
end

function AniObj:Stopped()
	return self.LoadedAni.Stopped
end

return AniObj