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
	
	Target = FindPlayer(Target)
	
	if not Target then return end
	
	if Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
		Root.CFrame = Target.Character:FindFirstChild("HumanoidRootPart").CFrame
	end
end