local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local SS2 = game:GetService("ServerScriptService")
local HTTPService = game:GetService("HttpService")

local PointsService = {}
PointsService.Profiles = {}

function PointsService.GenerateProfile(Player)
	PointsService.Profiles[Player] = {
		TotalMatchPoints = 0,
		UltNeededPoints = 0,
		CurrentCombo = 0,
		ComboID = "",
		CanEarnUlt = true,
	}
	
	local Value = Instance.new("IntConstrainedValue")
	Value.Name = "UltimatePoints"
	Value.MinValue = 0
	Value.MaxValue = 10
	Value.Value = 0
	Value.Parent = Player
end

function PointsService:RemoveProfile(Player)
	if PointsService.Profiles[Player] then
		PointsService.Profiles[Player] = nil
		Player:WaitForChild("UltimatePoints"):Destroy()
	end
end

function PointsService:AddPoints(Player,Points)
	local Character = Player.Character
	local StateService = require(RS.Modules.Services.StateService)
	local StateProfile = StateService:GetProfile(Character)
	local CharVal = StateProfile.SelectedChar
	local CharacterData = require(SS.Modules.MetaData.CharacterData)
	local CharacterCheck = (type(CharacterData) == "table") and (type(CharacterData[CharVal]) == "table")
	
	if not CharacterCheck or not PointsService.Profiles[Player] then return end
	PointsService.Profiles[Player].TotalMatchPoints += Points
	Player.leaderstats.Points.Value += Points
	
	if CharacterData[CharVal].SkillData.UltPointsRequired > PointsService.Profiles[Player].UltNeededPoints + Points then
		if PointsService.Profiles[Player].CanEarnUlt == true then
			PointsService.Profiles[Player].UltNeededPoints += Points
		end
	elseif CharacterData[CharVal].SkillData.UltPointsRequired <= PointsService.Profiles[Player].UltNeededPoints + Points then
		if PointsService.Profiles[Player].CanEarnUlt == true then
			PointsService.Profiles[Player].UltNeededPoints = CharacterData[CharVal].SkillData.UltPointsRequired
		end
	end
	
	Player:WaitForChild("UltimatePoints").Value = PointsService.Profiles[Player].UltNeededPoints
end

function PointsService:AddToCombo(Player,Amount)
	local Character = Player.Character
	local StateService = require(RS.Modules.Services.StateService)
	local StateProfile = StateService:GetProfile(Character)
	local CharVal = StateProfile.SelectedChar
	local CharacterData = require(SS.Modules.MetaData.CharacterData)
	local CharacterCheck = (type(CharacterData) == "table") and (type(CharacterData[CharVal]) == "table")

	if not CharacterCheck or not PointsService.Profiles[Player] then return end
	local Multipler = PointsService.Profiles[Player].CurrentCombo * 0.125
	
	local PointsToAdd = math.round(Amount * Multipler)
	
	local ComboID = CharVal..HTTPService:GenerateGUID(false)
	PointsService.Profiles[Player].ComboID = ComboID
	PointsService.Profiles[Player].CurrentCombo += Amount
	Player.PlayerGui.Hits.Holder.Hits.Value = PointsService.Profiles[Player].CurrentCombo
	PointsService:AddPoints(Player,PointsToAdd)
	
	task.delay(2,function()
		if PointsService.Profiles[Player].ComboID == ComboID then
			PointsService.Profiles[Player].CurrentCombo = 0
			
			if Player.PlayerGui then
				Player.PlayerGui.Hits.Holder.Hits.Value = PointsService.Profiles[Player].CurrentCombo
			end
		end
	end)
end

function PointsService:UltGain(Player,Bool: boolean)
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local StateService = require(RS.Modules.Services.StateService)
	local StateProfile = StateService:GetProfile(Character)
	local CharVal = StateProfile.SelectedChar
	local CharacterData = require(SS.Modules.MetaData.CharacterData)
	local CharacterCheck = (type(CharacterData) == "table") and (type(CharacterData[CharVal]) == "table")

	if not CharacterCheck or not PointsService.Profiles[Player] then return end
	
	PointsService.Profiles[Player].CanEarnUlt = Bool
end

function PointsService:ResetPoints(Player,Data)
	local Character = Player.Character
	local StateService = require(RS.Modules.Services.StateService)
	local StateProfile = StateService:GetProfile(Character)
	local CharVal = StateProfile.SelectedChar
	local CharacterData = require(SS.Modules.MetaData.CharacterData)
	local CharacterCheck = (type(CharacterData) == "table") and (type(CharacterData[CharVal]) == "table")

	if not CharacterCheck or not PointsService.Profiles[Player] then return end
	
	if Data.CharacterChange then
		PointsService.Profiles[Player].UltNeededPoints = 0
	elseif Data.GameReset then
		PointsService.Profiles[Player].TotalMatchPoints = 0
		Player.leaderstats.Points.Value = 0
		Player.leaderstats.Damage.Value = 0
		PointsService.Profiles[Player].UltNeededPoints = 0
	end
	
	Player:WaitForChild("UltimatePoints").Value = PointsService.Profiles[Player].UltNeededPoints
end

function PointsService:CanUseUlt(Player)
	local Character = Player.Character
	local StateService = require(RS.Modules.Services.StateService)
	local StateProfile = StateService:GetProfile(Character)
	local CharVal = StateProfile.SelectedChar
	local CharacterData = require(SS.Modules.MetaData.CharacterData)
	local CharacterCheck = (type(CharacterData) == "table") and (type(CharacterData[CharVal]) == "table")

	if not CharacterCheck or not PointsService.Profiles[Player] then return end
	
	if PointsService.Profiles[Player].UltNeededPoints >= CharacterData[CharVal].SkillData.UltPointsRequired then
		return true
	else
		return nil
	end
end

function PointsService:ResetUltPoints(Player)
	local Character = Player.Character
	local StateService = require(RS.Modules.Services.StateService)
	local StateProfile = StateService:GetProfile(Character)
	local CharVal = StateProfile.SelectedChar
	local CharacterData = require(SS.Modules.MetaData.CharacterData)
	local CharacterCheck = (type(CharacterData) == "table") and (type(CharacterData[CharVal]) == "table")
	
	if not CharacterCheck or not PointsService.Profiles[Player] then return end
	
	PointsService.Profiles[Player].UltNeededPoints = 0
	Player:WaitForChild("UltimatePoints").Value = PointsService.Profiles[Player].UltNeededPoints
end

return PointsService