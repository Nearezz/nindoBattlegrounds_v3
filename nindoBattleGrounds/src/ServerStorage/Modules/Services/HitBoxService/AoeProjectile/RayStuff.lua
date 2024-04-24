local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local RS = game:GetService("ReplicatedStorage")
local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local RayStuff = {}


function RayStuff:Cast(Goal, Origin,FilterType, RayList ,IgnoreWater, CollisionGroup)
	local EndPosition = typeof(Goal) == "CFrame" and Goal.Position or Goal
	local StartPosition = typeof(Origin) == "CFrame" and Origin.Position or Origin
	

	local Diff= EndPosition - StartPosition
	
	local Direction = Diff.Unit
	local Distance = Diff.Magnitude
	
	
	local RayC = RaycastParams.new()
	
	RayC.FilterDescendantsInstances = RayList or {workspace.World.Effects}
	
	RayC.FilterType = FilterType or Enum.RaycastFilterType.Blacklist
	
	RayC.IgnoreWater = IgnoreWater or true

	return workspace:Raycast(StartPosition, Direction * Distance, RayC)
end

function RayStuff:CreateVis(StartPosition, EndPosition, PartColor)
	local StartPosition = typeof(StartPosition) == "CFrame" and StartPosition.Position or StartPosition
	local EndPosition = typeof(EndPosition) == "CFrame" and EndPosition.Position or EndPosition
	local Distance = (EndPosition - StartPosition).Magnitude

	local RayPart = Instance.new("Part")
	RayPart.Size = Vector3.new(0.1,0.1,Distance)
	RayPart.CFrame = CFrame.new(StartPosition, EndPosition) * CFrame.new(0,0,-Distance/2)
	RayPart.Anchored = true
	RayPart.Locked = true
	RayPart.CanCollide = false
	RayPart.CanQuery = false
	RayPart.Parent = workspace.World.Effects
	RayPart.Color = PartColor or Color3.fromRGB(170, 0, 0)
	RayPart.Material = Enum.Material.Neon
	
	Debris:AddItem(RayPart,25)
	
end


return RayStuff
