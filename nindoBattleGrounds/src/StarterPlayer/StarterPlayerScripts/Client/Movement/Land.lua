task.wait(2)
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local SS2 = game:GetService("ServerScriptService")

local UIS = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local ClientControls = require(RS.Modules.MetaData.ClientControls)
local ClientManager = require(Player.PlayerScripts:WaitForChild("Client").ClientHandler)

local can_double_jump = false
local double_jumped = false

local hum = Character:WaitForChild('Humanoid')

state_changed = function(old, new)
	if new == Enum.HumanoidStateType.Jumping then
		RS.Modules.Services.StateService.StateTransfer:FireServer("JumpState",{false})
	end
	if new == Enum.HumanoidStateType.Landed then
		RS.Modules.Services.StateService.StateTransfer:FireServer("Land")
	end
end

hum.StateChanged:Connect(state_changed)

Player.CharacterAdded:Connect(function(new)
	Character = new
	hum = Character:WaitForChild('Humanoid')
	hum.StateChanged:Connect(state_changed)
end)

return nil