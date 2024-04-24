local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local SS2 = game:GetService("ServerScriptService")


local ContentProvider = game:GetService("ContentProvider")

local Player = Players.LocalPlayer

local CleanupService = {}

CleanupService.SkillJunkTables = {
	
}

if RunService:IsClient() then
	task.spawn(function()
		ContentProvider:PreloadAsync(RS.Assets.Effects:GetChildren())
		warn("Loaded All Assets")
	end)
	function CleanupService:GenerateJunkTable(CharacterID)
		CleanupService.SkillJunkTables[CharacterID] = {}
		return CleanupService.SkillJunkTables[CharacterID]
	end
	function CleanupService:ClearJunkTable(CharacterID)
		CleanupService.SkillJunkTables[CharacterID] = {}
	end
end

return CleanupService
