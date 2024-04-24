local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local DataManager = require(ServerScriptService.Server.DataManager)
local CharacterService = require(ServerStorage.Modules.Services.CharacterService)

local Player = script.Parent.Parent.Parent.Parent

local Interface = script.Parent
local GamepassFrame = Interface:WaitForChild("Gamepasses")

local GamepassIDs = {
	["2xMoney"] = 181113861,
	["EarlyAccess"] = 181328039
}

for Name, Id in pairs(GamepassIDs) do
	if MarketplaceService:UserOwnsGamePassAsync(Player.UserId, Id) then
		if Name == "2xMoney" then
			DataManager:GetData(Player).DoubleMoney = true
		elseif Name == "EarlyAccess" then
			DataManager:GetData(Player).EarlyAccess = true
		end
	end
end

for Index, Gamepass in ipairs(GamepassFrame:GetChildren()) do
	if Gamepass:IsA("ImageLabel") then
		if MarketplaceService:UserOwnsGamePassAsync(Player.UserId, GamepassIDs[Gamepass.Name]) then
			Gamepass:WaitForChild("Buy"):WaitForChild("Price").Text = "Owned"
		else
			Gamepass:WaitForChild("Buy"):WaitForChild("Price").Text = "R$"..Gamepass:WaitForChild("Cost").Value
		end
		
		Gamepass:WaitForChild("Buy").MouseButton1Down:Connect(function()
			if not MarketplaceService:UserOwnsGamePassAsync(Player.UserId, GamepassIDs[Gamepass.Name]) then
				MarketplaceService:PromptGamePassPurchase(Player, GamepassIDs[Gamepass.Name])
				MarketplaceService.PromptGamePassPurchaseFinished:Wait()
				
				if MarketplaceService:UserOwnsGamePassAsync(Player.UserId, GamepassIDs[Gamepass.Name]) then
					Gamepass:WaitForChild("Buy"):WaitForChild("Price").Text = "Owned"
					
					if Gamepass.Name == "2xMoney" then
						DataManager:GetData(Player).DoubleMoney = true
					elseif Gamepass.Name == "EarlyAccess" then
						DataManager:GetData(Player).EarlyAccess = true
					end
				else
					Gamepass:WaitForChild("Buy"):WaitForChild("Price").Text = "R$"..Gamepass:WaitForChild("Cost").Value
				end
			end
		end)
	end
end