local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local SS2 = game:GetService("ServerScriptService")

local Responds = {
	["JumpState"] = function(Player,Data)
		local Character = Player.Character or Player.CharacterAdded:Wait()
		local Humanoid = Character:WaitForChild("Humanoid")
		Humanoid.Jump = false
	end,
	
	["Land"] = function(Player,Data)
		local Character = Player.Character or Player.CharacterAdded:Wait()
		local RemoteComs = require(RS.Modules.Utility.RemoteNetwork)
		RemoteComs:FireClientEvent(Players:GetPlayerFromCharacter(Character),{FunctionName = "AnimationService" },{
			Task = "PlayAnimation",
			AnimationData = {
				Name = "Land",
				AnimationSpeed = 1,
				Weight = 1,
				FadeTime = 0.25,
				Looped = false,
			}
		})
		
		local StateService = require(RS.Modules.Services.StateService)
		StateService:SetState(Character,"LandStun",{
			LP = 50,
			Dur = 0.5
		})
	end,
	
	["DB"] = function(Player,Data)
		local Character = Player.Character or Player.CharacterAdded:Wait()
		local RemoteComs = require(RS.Modules.Utility.RemoteNetwork)
		RemoteComs:FireClientEvent(Players:GetPlayerFromCharacter(Character),{FunctionName = "VFX"},{FName = "DB",FData = {
			Character = Character,
			Lifetime = .35
		}})
	end,
}

script.Parent.StateTransfer.OnServerEvent:Connect(function(Player,Name,Data)
	if Responds[Name] then
		task.spawn(function()
			Responds[Name](Player,Data)
		end)
	end
end)

return nil