local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local SS2 = game:GetService("ServerScriptService")

local DataManager = require(SS2.Server.DataManager)

local CharacterService = {}

function CharacterService:BuyCharacter(Data)
	local Player = Data.Player
	local CharacterID = Data.CharacterID
	
	local RemoteComs = require(RS.Modules.Utility.RemoteNetwork)
	local DataManager = require(SS2.Server.DataManager)
	local PlayerData = DataManager:GetData(Player)
	Player.PlayerGui.Interface.Money.Text = "S"..PlayerData.Cash
	
	local CharacterData = require(SS.Modules.MetaData.CharacterData)
	local CharacterCheck = (type(CharacterData) == "table") and (type(CharacterData[CharacterID]) == "table")
	local CharData = CharacterData[CharacterID]
	
	if CharacterCheck and CharData then
		if PlayerData.Cash - CharData.Cost < 0 then return end
		PlayerData.Cash -= CharData.Cost
		table.insert(PlayerData.OwnedChars,CharacterID)
		RemoteComs:FireClientEvent(Player,{FunctionName = "PlayCashSound"},{})
		Player.PlayerGui.Interface.Money.Text = "S"..PlayerData.Cash
	end
end

function CharacterService:ChangeCharacter(Data)
	local StateService = require(RS.Modules.Services.StateService)
	local RemoteComs = require(RS.Modules.Utility.RemoteNetwork)
	
	local Player = Data.Player
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local Humanoid = Character:WaitForChild("Humanoid")
	
	local CharacterID = Data.ID
	local SkinNumber = Data.SkinNumber
	
	if StateService:GetProfile(Character).SelectedChar == CharacterID then return end
	
	if StateService:GetState(Character, "UsingSkill") then return end
	--if Humanoid.Health < Humanoid.MaxHealth then return end
	
	local NewCharacter = script.CharacterAssets:FindFirstChild(CharacterID)
	if not NewCharacter then return end

	for i,x in ipairs(Character:GetDescendants()) do
		if x:IsA("Script") or x:IsA("LocalScript") then
			x:Destroy()
		end
	end
	
	local PlayerData = DataManager:GetData(Player)
	PlayerData.CurrentCharacter = CharacterID
	StateService:GetProfile(Character).SelectedChar = CharacterID
	
	if Players:GetPlayerFromCharacter(Character) then
		local PointsService = require(SS.Modules.Services.PointsService)
		PointsService:ResetPoints(Players:GetPlayerFromCharacter(Character),{
			CharacterChange = true,
		})
		
		local CharacterData = require(SS.Modules.MetaData.CharacterData)
		local CharacterCheck = (type(CharacterData) == "table") and (type(CharacterData[CharacterID]) == "table")
		local CharData = CharacterData[CharacterID]
		
		if CharacterCheck and CharData then
			local SkillsUI = Players:GetPlayerFromCharacter(Character).PlayerGui.Interface.Abilities
			SkillsUI.FirstAbility.Ability.Text = CharData.SkillData.FirstSkill.Name
			SkillsUI.SecondAbility.Ability.Text = CharData.SkillData.SecondSkill.Name
			SkillsUI.ThirdAbility.Ability.Text = CharData.SkillData.ThirdSkill.Name
			SkillsUI.FourthAbility.Ability.Text = CharData.SkillData.FourthSkill.Name
		end
	end
	
	task.spawn(function()
		--[[
		if Character:FindFirstChild("Hats") then
			Character:FindFirstChild("Hats"):Destroy()
		end
		
		for i,x in ipairs(Character:GetDescendants()) do
			if x:IsA("LocalScript") or x:IsA("Script") or x:IsA("Decal") or x:IsA("BodyColors") then
				x:Destroy()
			end
			if x:IsA("Shirt") or x:IsA("Pants") then
				x:Destroy()
			end
		end
		
		local BodyColors = NewCharacter.Colors:Clone()
		BodyColors.Parent = Character
		local Face = NewCharacter.face:Clone()
		Face.Parent = Character.Head
		local Pants,Shirt = NewCharacter.Pants:Clone(),NewCharacter.Shirt:Clone()
		Pants.Parent = Character
		Shirt.Parent = Character
		local Hats = NewCharacter.Hats:Clone()
		Hats.Parent = Character
		for i,x in ipairs(Hats:GetChildren()) do
			if Character:FindFirstChild(x.Name) then
				local CorePart = Character:FindFirstChild(x.Name)
				for _,Part in pairs(x:GetChildren()) do
					if Part:FindFirstChild("WeldCFrame") then
						Part.Anchored = false
						Part.CanCollide = false
						Part.CFrame = CorePart.CFrame
						local Weld = Instance.new("Motor6D",Part)
						Weld.Part0 = CorePart
						Weld.Part1 = Part
						if Part:FindFirstChild("WeldCFrame"):IsA("Attachment") then
							Weld.C0 = Part:FindFirstChild("WeldCFrame").CFrame
						else
							Weld.C0 = Part:FindFirstChild("WeldCFrame").C0
						end
					end
				end
			end
		end
		]]--
		
		local Scripts = script:WaitForChild("CharScripts"):GetChildren()
		
		for i, x in ipairs(Scripts) do
			local S = x:Clone()
			S.Parent = Character
			S.Disabled = false
		end
	end)
	
	local StateService = require(RS.Modules.Services.StateService)
	local CooldownService = require(SS.Modules.Services.CooldownService)
	
	local StateProfile = StateService:GetProfile(Character)
	local CharVal = StateProfile.SelectedChar
	local CharacterData = require(SS.Modules.MetaData.CharacterData)
	Player:WaitForChild("UltimatePoints").MaxValue = CharacterData[CharVal].SkillData.UltPointsRequired
	
	CooldownService:SetCooldown(Character,CharacterID,"FirstSkill",{
		Hold = false
	})
	CooldownService:SetCooldown(Character,CharacterID,"FirstSkill",{
		CD = 0
	})
	
	CooldownService:SetCooldown(Character,CharacterID,"SecondSkill",{
		Hold = false
	})
	CooldownService:SetCooldown(Character,CharacterID,"SecondSkill",{
		CD = 0
	})
	
	CooldownService:SetCooldown(Character,CharacterID,"ThirdSkill",{
		Hold = false
	})
	CooldownService:SetCooldown(Character,CharacterID,"ThirdSkill",{
		CD = 0
	})
	
	CooldownService:SetCooldown(Character,CharacterID,"FourthSkill",{
		Hold = false
	})
	CooldownService:SetCooldown(Character,CharacterID,"FourthSkill",{
		CD = 0
	})
end

return CharacterService