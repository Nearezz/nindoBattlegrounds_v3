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
	
	if not Target then return end
	
	if string.lower(Target) == "all" then
		for Index, Target in ipairs(Players:GetPlayers()) do
			if Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
				for Index, BasePart in ipairs(Target.Character:GetDescendants()) do
					if BasePart:IsA("BasePart") then
						BasePart.Transparency = 1
					end
				end
			end
		end
	elseif string.lower(Target) == "me" then
		if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
			for Index, BasePart in ipairs(Player.Character:GetDescendants()) do
				if BasePart:IsA("BasePart") then
					BasePart.Transparency = 1
				end
			end
		end
	elseif string.lower(Target) == "others" then
		for Index, Target in ipairs(Players:GetPlayers()) do
			if Target.UserId ~= Player.UserId then
				if Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
					for Index, BasePart in ipairs(Target.Character:GetDescendants()) do
						if BasePart:IsA("BasePart") then
							BasePart.Transparency = 1
						end
					end
				end
			end
		end
	else
		Target = FindPlayer(Target)
		if not Target then return end
		
		if Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
			for Index, BasePart in ipairs(Target.Character:GetDescendants()) do
				if BasePart:IsA("BasePart") then
					BasePart.Transparency = 1
				end
			end
		end
	end
end