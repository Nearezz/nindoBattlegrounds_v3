local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

local StateService = require(ReplicatedStorage.Modules.Services.StateService)
StateService:GenerateProfile(script.Parent)

StateService:GetProfile(script.Parent).SelectedChar = "OldKakashi"
StateService:GetProfile(script.Parent).StateData["PerfectBlock"].AllOn = true

script.Parent.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
script.Parent.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

local CombatService = require(ServerStorage.Modules.Services.CombatService)

while true do
	if not StateService:GetState(script.Parent, "Blocking") then
		CombatService:Block(script.Parent)
	end
	RunService.Heartbeat:Wait()
end