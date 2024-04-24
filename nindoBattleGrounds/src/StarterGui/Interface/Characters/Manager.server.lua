local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local DataManager = require(ServerScriptService.Server.DataManager)
local CharacterService = require(ServerStorage.Modules.Services.CharacterService)

local Player = script.Parent.Parent.Parent.Parent

local MainImage = script.Parent:WaitForChild("ImageLabel")
local CharacterName = script.Parent:WaitForChild("SkinName")
local Buy = script.Parent:WaitForChild("Buy")
local Price = Buy:WaitForChild("Price")
local SkinType = script.Parent:WaitForChild("SkinType")

local CurrentVal = nil

MainImage.Visible = false
CharacterName.Visible = false
Buy.Visible = false
SkinType.Visible = false

local EarlyAccess = {"KidNeji"}

for Index, Character in ipairs(script.Parent:WaitForChild("ScrollingFrame"):GetChildren()) do
	if Character:IsA("ImageButton") then
		local CharVal = Character.Name
		local CharacterData = require(ServerStorage.Modules.MetaData.CharacterData)
		local CharacterCheck = (type(CharacterData) == "table") and (type(CharacterData[CharVal]) == "table")
		local CharData = CharacterData[CharVal]
		
		if CharacterCheck and CharVal then
			Character.MouseButton1Click:Connect(function()
				if Character.ImageTransparency ~= 0 then return end
				
				MainImage.Visible = true
				CharacterName.Visible = true
				Buy.Visible = true
				SkinType.Visible = true
				
				local DataManager = require(ServerScriptService.Server.DataManager)
				CurrentVal = CharVal
				MainImage.Image = Character.Image
				CharacterName.Text = tostring(CharData.DisplayName)
				
				local PlayerData = DataManager:GetData(Player)
				
				if not table.find(PlayerData.OwnedChars, CharVal) then
					if table.find(EarlyAccess, CharVal) then
						Price.Text = "[EARLY ACCESS]"
					else
						Price.Text = "$"..tostring(CharData.Cost)
					end
				else
					Price.Text = "Select"
				end
			end)
		end
	end
end

Buy.MouseButton1Click:Connect(function()
	if CurrentVal then
		local PlayerData = DataManager:GetData(Player)
		
		local CharacterData = require(ServerStorage.Modules.MetaData.CharacterData)
		local CharacterCheck = (type(CharacterData) == "table") and (type(CharacterData[CurrentVal]) == "table")
		local CharData = CharacterData[CurrentVal]
		
		if not table.find(PlayerData.OwnedChars, CurrentVal) then
			if table.find(EarlyAccess, CurrentVal) then
				if MarketplaceService:UserOwnsGamePassAsync(Player.UserId, 181328039) then
					CharacterService:BuyCharacter({
						Player = Player,
						CharacterID = CurrentVal
					})
					
					task.delay(.1,function()
						if table.find(PlayerData.OwnedChars, CurrentVal) then
							Price.Text = "Select"
						end
					end)
				else
					MarketplaceService:PromptGamePassPurchase(Player, 181328039)
					MarketplaceService.PromptGamePassPurchaseFinished:Wait()
					
					if MarketplaceService:UserOwnsGamePassAsync(Player.UserId, 181328039) then
						CharacterService:BuyCharacter({
							Player = Player,
							CharacterID = CurrentVal
						})
						
						task.delay(.1,function()
							if table.find(PlayerData.OwnedChars, CurrentVal) then
								Price.Text = "Select"
							end
						end)
					end
				end
			else
				CharacterService:BuyCharacter({
					Player = Player,
					CharacterID = CurrentVal
				})
				
				task.delay(.1,function()
					if table.find(PlayerData.OwnedChars, CurrentVal) then
						Price.Text = "Select"
					end
				end)
			end
		else
			CharacterService:ChangeCharacter({
				Player = Player,
				ID = CurrentVal
			})
		end
	end
end)