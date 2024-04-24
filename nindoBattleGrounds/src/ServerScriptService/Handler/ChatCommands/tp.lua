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
	local Character = Player.Character
	if not Character then return end
	
	local Root = Character:WaitForChild("HumanoidRootPart")
	local Target = Arguments[2]
	
	if not Target then return end
	
	local EndPoint = FindPlayer(Arguments[3])
	if not EndPoint then return end
	
	if EndPoint.Character and EndPoint.Character:FindFirstChild("HumanoidRootPart") then
		EndPoint = EndPoint.Character:FindFirstChild("HumanoidRootPart").CFrame
	end
	
	if string.lower(Target) == "all" then
		for Index, Target in ipairs(Players:GetPlayers()) do
			if Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
				Target.Character:FindFirstChild("HumanoidRootPart").CFrame = EndPoint
			end
		end
	elseif string.lower(Target) == "me" then
		if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
			Player.Character:FindFirstChild("HumanoidRootPart").CFrame = EndPoint
		end
	elseif string.lower(Target) == "others" then
		for Index, Target in ipairs(Players:GetPlayers()) do
			if Target.UserId ~= Player.UserId then
				if Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
					Target.Character:FindFirstChild("HumanoidRootPart").CFrame = EndPoint
				end
			end
		end
	else
		Target = FindPlayer(Target)
		if not Target then return end
		
		if Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
			Target.Character:FindFirstChild("HumanoidRootPart").CFrame = EndPoint
		end
	end
end