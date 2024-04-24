local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local SS2 = game:GetService("ServerScriptService")
local HTTPService = game:GetService("HttpService")
local Debris = game:GetService("Debris")

local CharacterID = "KidSakura"
local function GenerateJunkTable(CharacterID)
	local CleanUpService = require(RS.Modules.Services.CleanupService)
	return CleanUpService:GenerateJunkTable(CharacterID)
end

local JunkTable = GenerateJunkTable(CharacterID)

local  KidSakura; KidSakura = {
	["FirstSkill"] = {
		["Smash"] = function(Data)
			local Character = Data.Character
			local UID = Data.UID
			print("Activated?")
			
		end,
	},
	["SecondSkill"] = {
		["Hold"] = function(Data)

		end,
	},
	["ThirdSkill"] = {
		["Hold"] = function(Data)

		end,
	},
	["FourthSkill"] = {
		["Hold"] = function(Data)

		end,
	},
	["UltimateSkill"] = {
		["Example1"] = function(Data)
			local Character = Data.Character
			local UID = Data.UID

		end,
		["Example2"] = function(Data)
			local Character = Data.Character
			local UID = Data.UID
		end,
	}
}

return KidSakura
