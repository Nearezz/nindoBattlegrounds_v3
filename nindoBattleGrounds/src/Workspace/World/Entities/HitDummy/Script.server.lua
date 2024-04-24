local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local StateService = require(ReplicatedStorage.Modules.Services.StateService)
StateService:GenerateProfile(script.Parent)

StateService:GetProfile(script.Parent).SelectedChar = "OldKakashi"
script.Parent.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
script.Parent.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

local CombatService = require(ServerStorage.Modules.Services.CombatService)

while true do
	CombatService:Swing(script.Parent, {
		Space = false
	})
	task.wait(0.2)
end