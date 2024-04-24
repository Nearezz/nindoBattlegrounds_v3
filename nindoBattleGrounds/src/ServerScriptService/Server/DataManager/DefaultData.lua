local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")

return {
	DataVersion = RS:WaitForChild("GameVersion").Value,
	FirstLogin = os.date(),
	
	Cash = 0,
	
	Music = true,
	
	Wins = 0,
	Loses = 0,
	Rank = "Genin",
	Level = "F-",
	
	DoubleMoney = false,
	EarlyAccess = false,
	
	CurrentCharacter = "KidNaruto",
	OwnedChars = {
		"KidNaruto"
	},
}