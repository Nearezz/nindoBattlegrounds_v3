local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local DataManager = require(ServerScriptService.Server.DataManager)

local Player = script.Parent.Parent.Parent.Parent

local Interface = script.Parent
local Frame = Interface:WaitForChild("ScrollingFrame")
local WinsLabel = Frame:WaitForChild("Setting"):WaitForChild("Win"):WaitForChild("TextLabel")
local LosesLabel = Frame:WaitForChild("Setting"):WaitForChild("Lost"):WaitForChild("TextLabel")
local RankLabel = Frame:WaitForChild("Rank"):WaitForChild("ActualRanking")
local LevelLabel = Frame:WaitForChild("Level"):WaitForChild("Actual Level")

local function Update()
	local PlayerData = DataManager:GetData(Player)
	
	if PlayerData then
		WinsLabel.Text = PlayerData.Wins or 0
		LosesLabel.Text = PlayerData.Loses or 0
		RankLabel.Text = PlayerData.Rank or "..."
		LevelLabel.Text = PlayerData.Level or "..."
	end
end

task.spawn(function()
	while true do
		Update()
		task.wait(1)
	end
end)