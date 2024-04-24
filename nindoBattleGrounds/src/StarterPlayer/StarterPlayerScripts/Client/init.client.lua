local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ClientHandler = require(script.ClientHandler)
local AnimationService = require(ReplicatedStorage.Modules.Services.AnimationService)

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local GetPosition = ReplicatedStorage.GetPosition

local RemoteComs = require(ReplicatedStorage.Modules.Utility.RemoteNetwork)
RemoteComs:Init()

for _, MovementHandle in ipairs(script.Movement:GetDescendants()) do
	if MovementHandle:IsA("ModuleScript") then
		require(MovementHandle)
	end
end

AnimationService.CreateProfile(Character)

GetPosition.OnClientInvoke = function()
	return Character:WaitForChild("HumanoidRootPart").CFrame.Position
end