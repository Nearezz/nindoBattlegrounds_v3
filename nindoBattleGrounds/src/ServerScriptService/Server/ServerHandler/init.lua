local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local SS2 = game:GetService("ServerScriptService")

local ServerHandler = {}

function ServerHandler:Init()
	local PlayersProcessed = {}
	
	local CharacterLoader = require(script.CharLoader)
	local DataManager = require(script.Parent.DataManager)
	local PointsService = require(SS.Modules.Services.PointsService)
	local StateService = require(RS.Modules.Services.StateService)
	StateService:Init()
	
	Players.PlayerAdded:Connect(function(Player)
		task.spawn(function()
			DataManager:PlayerAdded(Player)
			PointsService.GenerateProfile(Player)
			
			CharacterLoader:LoadCharacter(Player)
			
			local PlayerData = DataManager:GetData(Player)
			
			Player:SetAttribute("Music", PlayerData.Music)
			Player:SetAttribute("AFK", false)
			Player:SetAttribute("FastMode", false)
			
			local function Create()
				local leaderstats = Instance.new("Folder")
				leaderstats.Name = "leaderstats"
				leaderstats.Parent = Player

				local Damage = Instance.new("NumberValue")
				Damage.Name = "Damage"
				Damage.Parent = leaderstats

				local Points = Instance.new("NumberValue")
				Points.Name = "Points"
				Points.Parent = leaderstats
			end
			
			repeat task.wait()
				local Success, Warning = pcall(function()
					Create()
				end)
			until Success
		end)
		
		Player.CharacterRemoving:Connect(function(Char)
			CharacterLoader:RemoveCharacter(Char)
			task.wait(1)
			CharacterLoader:RespawnCharacter(Player)
		end)
	end)
	
	Players.PlayerRemoving:Connect(function(Player)
		PointsService.RemoveProfile(Player)
		DataManager:PlayerRemoved(Player)
	end)
end

return ServerHandler