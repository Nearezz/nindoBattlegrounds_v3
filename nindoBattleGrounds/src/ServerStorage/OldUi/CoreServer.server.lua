local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local SS2 = game:GetService("ServerScriptService")
local Debris = game:GetService("Debris")

task.wait(5)
local StateService = require(RS.Modules.Services.StateService)
--local CharacterData = require(SS.Modules.MetaData.CharacterData)
local PointsService = require(SS.Modules.Services.PointsService)


local UltBar = script.Parent:WaitForChild("HealthBarUI")["Ultimate Bar1"]["Ultimate Bar"]
local UltBarMain = script.Parent:WaitForChild("HealthBarUI")["Ultimate Bar1"]

task.spawn(function()
	while true do
		if script.Parent.Parent then
			local Player = script.Parent.Parent
			local Character = Player.Character
			if Character and Character:FindFirstChild("Humanoid") and Character:FindFirstChild("Humanoid").Health > 0 then
				local StateProfile = StateService:GetProfile(Character)
				local CharVal = StateProfile.SelectedChar
				local CharacterCheck = (type(CharacterData) == "table") and (type(CharacterData[CharVal]) == "table")
				if CharacterCheck then
					local Ratio = PointsService.Profiles[Player].UltNeededPoints/CharacterData[CharVal].SkillData.UltPointsRequired
					UltBar:TweenSize(UDim2.new(Ratio,0,1,0),Enum.EasingDirection.Out,Enum.EasingStyle.Linear,0.07,true)
					if PointsService.Profiles[Player].UltNeededPoints >= CharacterData[CharVal].SkillData.UltPointsRequired then
						UltBarMain["Press G"].Visible = true
					else
						UltBarMain["Press G"].Visible = false
					end
				end		
			end	
		end
		RunService.Heartbeat:Wait()
	end
end)