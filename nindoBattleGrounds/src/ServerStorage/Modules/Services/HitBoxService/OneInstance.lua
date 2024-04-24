local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local SS2 = game:GetService("ServerScriptService")

local Debris = game:GetService("Debris")

local module = {}

module.__index = module

function module.new()
	local T = {}
	T.HitTask = require(script.Parent.HitTask).new()
	setmetatable(T,module)
	return T
end

function module:Fire(Data)
	local Frame = Data.CFrame
	local Size = Data.Size
	local Offset = Data.Offset or CFrame.new(0,0,0)
	local FilterList = Data.FilterList or {workspace.World.Entities}
	local FilterType = Data.FilterType or Enum.RaycastFilterType.Include
	local Caster = Data.Caster
	local OffsetPart = Data.OffsetPart
	
	local BreakOnHit = Data.BreakOnHit or false
	local MultHit = Data.MultHit or false
	local HitOnce = Data.HitOnce or false
	
	local Vis = Data.Visual or false
	
	local Para = OverlapParams.new()
	Para.FilterType = FilterType
	Para.FilterDescendantsInstances = FilterList
	
	local TargetFrame = Frame
	
	if OffsetPart then
		TargetFrame = OffsetPart.CFrame * Data.Offset
	end
	
	local HitboxPart = Instance.new("Part")
	HitboxPart.Color = Color3.fromRGB(255, 0, 0)
	HitboxPart.Anchored = true
	HitboxPart.Material = Enum.Material.ForceField
	HitboxPart.CanCollide = false
	HitboxPart.CanQuery = true
	HitboxPart.CanTouch = false
	HitboxPart.Size = Size
	HitboxPart.CFrame = TargetFrame
	HitboxPart.Parent = workspace.World.Effects
	Debris:AddItem(HitboxPart, 5)
	
	local HitBox = workspace:GetPartsInPart(HitboxPart, Para)
	local HitLar = false
	
	local CheckHit = {}
	local TableToReturn = {}
	local TriggerBreak = false
	
	if Vis then
		HitboxPart.Transparency = 0
	else
		HitboxPart.Transparency = 1
	end
	
	for _, Character in pairs(HitBox) do
		if not (Character.Parent:FindFirstChild("IsShadowClone") and Character.Parent:FindFirstChild("Brain") and Character.Parent:FindFirstChild("Brain").Caster.Value == Character  and Character.Parent:FindFirstChild("Brain") and Character.Parent:FindFirstChild("Brain").Caster.Value == Caster) and not CheckHit[Character.Parent] and Caster ~= Character.Parent and Character.Parent:FindFirstChild("Humanoid") and Character.Parent:FindFirstChild("Humanoid").Health > 0 and Character.Parent.PrimaryPart and TriggerBreak == false then
			if HitOnce == true then
				table.insert(FilterList,Character.Parent)
				CheckHit[Character.Parent] = true
			end
			if MultHit == false then
				HitLar = false
			end
			if BreakOnHit == true then
				TriggerBreak = true
			end
			table.insert(TableToReturn,Character.Parent)
		end
	end
	
	return TableToReturn
end

return module