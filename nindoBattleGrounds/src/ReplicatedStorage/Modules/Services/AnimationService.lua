local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local SS2 = game:GetService("ServerScriptService")

local AnimationService = {}

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

function AnimationService.CreateProfile(Character)
	local Profile = AnimationService[Character.Name]
	if Profile then return end
	
	AnimationService[Character.Name] = {
		LoadedAnimations = {},
		LoadedAll = false,
	}
end

function AnimationService:StopAnimationAllBlocking(Character,Data)
	for i,x in pairs(AnimationService[Character.Name].LoadedAnimations) do
		if string.lower(i):match("Blocking") then
			x:Stop()
		end
	end
end

function AnimationService:LoadAnimations(Character, Instances)
	local Util = require(RS.Modules.Utility.Util)
	local Filtered = Util.Filter(Instances,"Animation")
	
	local Humanoid = Character:WaitForChild("Humanoid")
	local Animator = Humanoid:FindFirstChild("Animator") or Humanoid
	
	for i, x in Filtered do
		if x.AnimationId ~= nil and x.AnimationId ~= "" then
			if not AnimationService[Character.Name].LoadedAnimations[x.Name] then
				AnimationService[Character.Name].LoadedAnimations[x.Name] = Animator:LoadAnimation(x)
			end
		end
	end
end

function AnimationService:PlayAnimation(Character, AnimationData)
	local Profile = AnimationService[Character.Name]
	if not Profile then return end
	
	if not AnimationService[Character.Name].LoadedAll then
		AnimationService[Character.Name].LoadedAll = true
		AnimationService:LoadAnimations(Character, RS.Assets.Animations.Shared:GetDescendants())
	end
	
	if AnimationService[Character.Name].LoadedAnimations[AnimationData.Name] then
		if AnimationData.Name == "DfRun" then
			AnimationService[Character.Name].LoadedAnimations[AnimationData.Name].Priority = Enum.AnimationPriority.Action2
		end
		
		AnimationService[Character.Name].LoadedAnimations[AnimationData.Name]:Play(AnimationData.FadeTime, AnimationData.Weight)
		AnimationService[Character.Name].LoadedAnimations[AnimationData.Name]:AdjustSpeed(AnimationData.AnimationSpeed)
		AnimationService[Character.Name].LoadedAnimations[AnimationData.Name].Looped = AnimationData.Looped
	end
end

function AnimationService:StopAnimation(Character,AnimationData)
	local Profile = AnimationService[Character.Name]
	if not Profile then return end
	
	if not AnimationService[Character.Name].LoadedAll then
		AnimationService[Character.Name].LoadedAll = true
		AnimationService:LoadAnimations(Character,RS.Assets.Animations.Shared:GetDescendants())
	end
	
	if AnimationService[Character.Name].LoadedAnimations[AnimationData.Name] and AnimationService[Character.Name].LoadedAnimations[AnimationData.Name].IsPlaying then
		AnimationService[Character.Name].LoadedAnimations[AnimationData.Name]:Stop(AnimationData.FadeTime, AnimationData.Weight)
	end
end

function AnimationService:StopAllAnimation(Character, AnimationData)
	local Profile = AnimationService[Character.Name]
	if not Profile then return end
	
	if not AnimationService[Character.Name].LoadedAll then
		AnimationService[Character.Name].LoadedAll = true
		AnimationService:LoadAnimations(Character, RS.Assets.Animations.Shared:GetDescendants())
	end
	
	for i, x in pairs(AnimationService[Character.Name].LoadedAnimations) do
		x:Stop()
	end
end

function AnimationService:RemoveProfile()
	local Profile = AnimationService[Character.Name]
	if not Profile then return end
	
	for AnimationName, _ in pairs(Profile.LoadedAnimations) do
		Profile.LoadedAnimations[AnimationName] = nil
	end
	
	AnimationService[Character.Name] = nil
end

task.spawn(function()
	AnimationService.CreateProfile(Character)
	AnimationService:LoadAnimations(Character, RS.Assets.Animations.Shared:GetDescendants())
	
	Player.CharacterAdded:Connect(function(NewCharacter)
		Character = NewCharacter
		AnimationService.CreateProfile(NewCharacter)
		AnimationService:LoadAnimations(Character, RS.Assets.Animations.Shared:GetDescendants())
	end)
	
	Player.CharacterRemoving:Connect(function()
		AnimationService.RemoveProfile(Character)
	end)
end)

return AnimationService