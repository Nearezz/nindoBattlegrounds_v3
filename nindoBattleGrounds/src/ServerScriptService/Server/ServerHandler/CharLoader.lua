local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local CharacterService = require(ServerStorage.Modules.Services.CharacterService)
local DataManager = require(ServerScriptService.Server.DataManager)

local CharsParent = workspace.World.Entities

local CharacterLoader = {}

function CharacterLoader:LoadCharacter(Player)
	local DataManager = require(ServerScriptService.Server.DataManager)
	local StateService = require(RS.Modules.Services.StateService)
	local CooldownService = require(ServerStorage.Modules.Services.CooldownService)
	
	local Character = Player.Character or Player.CharacterAdded:Wait()
	StateService:GenerateProfile(Character)
	CooldownService.GenerateProfile(Character)
	
	local PlayerData = DataManager:GetData(Player)
	Player:WaitForChild("PlayerGui"):WaitForChild("Interface"):WaitForChild("Money").Text = "S"..PlayerData.Cash
	
	task.delay(0.1,function()
		Character.PrimaryPart = Character:WaitForChild("HumanoidRootPart")
		Character.Parent = CharsParent
	end)
	
	for Index, Part in ipairs(Character:GetDescendants()) do
		if Part:IsA("BasePart") then
			PhysicsService:SetPartCollisionGroup(Part, "Clone")
		end
	end
	
	CharacterService:ChangeCharacter({
		Player = Player,
		ID = DataManager:GetData(Player).CurrentCharacter
	})
end

function CharacterLoader:RemoveCharacter(Character)
	local StateService = require(RS.Modules.Services.StateService)
	local CooldownService = require(ServerStorage.Modules.Services.CooldownService)
	
	local StateProfile = StateService:GetProfile(Character)
	
	if StateProfile.StateData.LastAttacker.LastAttacker ~= "None" then
		if (os.clock() - StateProfile.StateData.LastAttacker.LastAttackTime) >= 30 then return end
		
		local Player = Players:GetPlayerFromCharacter(StateProfile.StateData.LastAttacker.LastAttacker)
		
		if Player then
			local PlayerData = DataManager:GetData(Player)
			local CashToGive = math.random(10, 25)
			
			print(Player.Name.." was the last attacker of "..Character.Name)
			
			if PlayerData.DoubleMoney then
				CashToGive *= 2
			end
			
			PlayerData.Cash += CashToGive
			Player:WaitForChild("PlayerGui"):WaitForChild("Interface"):WaitForChild("Money").Text = "S"..PlayerData.Cash
		end
	end
	
	StateService:ClearProfile(Character)
	CooldownService:RemoveProfile(Character)
	
	Character:Destroy()
end

function CharacterLoader:RespawnCharacter(Player)
	local DataManager = require(ServerScriptService.Server.DataManager)
	local StateService = require(RS.Modules.Services.StateService)
	local CooldownService = require(ServerStorage.Modules.Services.CooldownService)
	
	local Character = Player.Character or Player.CharacterAdded:Wait()
	StateService:GenerateProfile(Character)
	CooldownService.GenerateProfile(Character)

	local PlayerData = DataManager:GetData(Player)
	Player:WaitForChild("PlayerGui"):WaitForChild("Interface"):WaitForChild("Money").Text = "S"..PlayerData.Cash

	task.delay(0.1,function()
		Character.PrimaryPart = Character:WaitForChild("HumanoidRootPart")
		Character.Parent = CharsParent
	end)
	
	for Index, Part in ipairs(Character:GetDescendants()) do
		if Part:IsA("BasePart") then
			PhysicsService:SetPartCollisionGroup(Part, "Clone")
		end
	end
	
	CharacterService:ChangeCharacter({
		Player = Player,
		ID = DataManager:GetData(Player).CurrentCharacter
	})
end

return CharacterLoader