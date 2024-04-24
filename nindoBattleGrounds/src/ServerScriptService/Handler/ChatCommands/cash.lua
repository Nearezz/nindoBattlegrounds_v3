local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local DataManager = require(ServerScriptService.Server.DataManager)

local function FindPlayer(Name)
	local Target = nil
	
	for Index, Player in ipairs(Players:GetPlayers()) do
		if string.find(string.lower(Player.Name), string.lower(Name)) then
			Target = Player
		end
	end
	
	return Target
end

return function(Player, Arguments)
	local Target = Arguments[2]
	local Cash = Arguments[3] or 10
	
	if not Target then return end
	
	if string.lower(Target) == "all" then
		for Index, Target in ipairs(Players:GetPlayers()) do
			if Target.Character and Target.Character:FindFirstChild("Humanoid") then
				local PlayerData = DataManager:GetData(Target)
				PlayerData.Cash = Cash
				Target.PlayerGui.Interface.Money.Text = "S"..PlayerData.Cash
			end
		end
	elseif string.lower(Target) == "me" then
		if Player.Character and Player.Character:FindFirstChild("Humanoid") then
			local PlayerData = DataManager:GetData(Player)
			PlayerData.Cash = Cash
			Player.PlayerGui.Interface.Money.Text = "S"..PlayerData.Cash
		end
	elseif string.lower(Target) == "others" then
		for Index, Target in ipairs(Players:GetPlayers()) do
			if Target.UserId ~= Player.UserId then
				if Target.Character and Target.Character:FindFirstChild("Humanoid") then
					local PlayerData = DataManager:GetData(Target)
					PlayerData.Cash = Cash
					Target.PlayerGui.Interface.Money.Text = "S"..PlayerData.Cash
				end
			end
		end
	else
		Target = FindPlayer(Target)
		if not Target then return end
		
		if Target.Character and Target.Character:FindFirstChild("Humanoid") then
			local PlayerData = DataManager:GetData(Target)
			PlayerData.Cash = Cash
			Target.PlayerGui.Interface.Money.Text = "S"..PlayerData.Cash
		end
	end
end