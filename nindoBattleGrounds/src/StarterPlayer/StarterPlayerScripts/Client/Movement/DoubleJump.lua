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

local ClientManager = require(Player.PlayerScripts:WaitForChild("Client").ClientHandler)

local can_double_jump = false
local double_jumped = false

local hum = Character:WaitForChild('Humanoid')

state_changed = function(old, new)
	if new == Enum.HumanoidStateType.Jumping and not double_jumped then
		task.wait(.2)
		can_double_jump = true
		task.wait(1)
		double_jumped = false
		can_double_jump = false
	end
end

UIS.InputBegan:Connect(function(input, typing)
	local AnimationService = require(RS.Modules.Services.AnimationService)
	if input.KeyCode == Enum.KeyCode.Space and not typing then
		if can_double_jump then
			RS.Modules.Services.StateService.StateTransfer:FireServer("DB",{false})
			can_double_jump = false
			double_jumped = true
			AnimationService:PlayAnimation(Character,{
				Name = "DoubleJump",
				AnimationSpeed = 1,
				Weight = 3,
				FadeTime = 0.25,
				Looped = false,
			})
			
			local OldJump = hum.JumpPower
			hum.JumpPower *= 1.5
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
			
			hum.JumpPower = OldJump
		end
	end
end)

hum.StateChanged:Connect(state_changed)

Player.CharacterAdded:Connect(function(new)
	Character = new
	hum = Character:WaitForChild('Humanoid')
	hum.StateChanged:Connect(state_changed)
end)

return nil