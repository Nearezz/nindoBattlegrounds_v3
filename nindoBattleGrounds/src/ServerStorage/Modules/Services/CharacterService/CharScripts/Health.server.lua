--{{Services}}--
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local SS2 = game:GetService("ServerScriptService")

local RegenTick = os.clock()
local StateService = require(RS.Modules.Services.StateService)
local RemoteComs = require(RS.Modules.Utility.RemoteNetwork)
local DataManager = require(SS2.Server.DataManager)

local Player = Players:GetPlayerFromCharacter(script.Parent)

task.spawn(function()
	local Char = script.Parent
	
	while true do
		local StateProfile = StateService.Profiles[Char]
		
		if StateProfile then
			Char.Humanoid.WalkSpeed = StateService:GetCurrentSpeed(Char)
			
			if StateService:GetState(Char,"CanJump") or StateService:GetState(Char,"M1Cooldown") or StateService:GetState(Char,"JumpCooldown") then
				Char.Humanoid.JumpPower = 0
			else
				Char.Humanoid.JumpPower = 50
			end
		end
		
		RunService.Heartbeat:Wait()
	end
end)
