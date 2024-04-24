local Players = game:GetService("Players")

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
	local Health = tonumber(Arguments[3]) or 120
	
	if not Target then return end
	
	if string.lower(Target) == "all" then
		for Index, Target in ipairs(Players:GetPlayers()) do
			if Target.Character and Target.Character:FindFirstChild("Humanoid") then
				if Health > Target.Character:FindFirstChild("Humanoid").MaxHealth then
					Target.Character:FindFirstChild("Humanoid").MaxHealth = Health
				end
				
				Target.Character:FindFirstChild("Humanoid").Health = Health
			end
		end
	elseif string.lower(Target) == "me" then
		if Player.Character and Player.Character:FindFirstChild("Humanoid") then
			if Health > Player.Character:FindFirstChild("Humanoid").MaxHealth then
				Player.Character:FindFirstChild("Humanoid").MaxHealth = Health
			end
			
			Player.Character:FindFirstChild("Humanoid").Health = Health
		end
	elseif string.lower(Target) == "others" then
		for Index, Target in ipairs(Players:GetPlayers()) do
			if Target.UserId ~= Player.UserId then
				if Target.Character and Target.Character:FindFirstChild("Humanoid") then
					if Health > Target.Character:FindFirstChild("Humanoid").MaxHealth then
						Target.Character:FindFirstChild("Humanoid").MaxHealth = Health
					end
					
					Target.Character:FindFirstChild("Humanoid").Health = Health
				end
			end
		end
	else
		Target = FindPlayer(Target)
		if not Target then return end
		
		if Target.Character and Target.Character:FindFirstChild("Humanoid") then
			if Health > Target.Character:FindFirstChild("Humanoid").MaxHealth then
				Target.Character:FindFirstChild("Humanoid").MaxHealth = Health
			end
			
			Target.Character:FindFirstChild("Humanoid").Health = Health
		end
	end
end