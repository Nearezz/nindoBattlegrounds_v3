local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StateService = require(ReplicatedStorage.Modules.Services.StateService)
StateService:GenerateProfile(script.Parent)

script.Parent.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
script.Parent.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

script.Parent.Humanoid.Died:Connect(function()
	task.wait(2)
	local Norm = ReplicatedStorage.Dummies.Normal:Clone()
	Norm.Parent = workspace.World.Entities
	
	script.Parent:Destroy()
end)