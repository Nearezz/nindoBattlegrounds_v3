local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local SS2 = game:GetService("ServerScriptService")

return function()
	local CharacterData = require(SS.Modules.MetaData.CharacterData)
	local SendTable = {}
	
	for CharID,CharacterData in pairs(CharacterData) do
		SendTable[CharID] = {
			FirstSkill = {
				Cooldown = 0,
				StartTime = os.clock(),
				HoldCooldown = false,
			},
			SecondSkill = {
				Cooldown = 0,
				StartTime = os.clock(),
				HoldCooldown = false,
			},
			ThirdSkill = {
				Cooldown = 0,
				StartTime = os.clock(),
				HoldCooldown = false,
			},
			FourthSkill = {
				Cooldown = 0,
				StartTime = os.clock(),
				HoldCooldown = false,
			},
			Ultimate = {
				Cooldown = 0,
				StartTime = os.clock(),
				HoldCooldown = false,
			}
		}
	end
	
	return SendTable
end