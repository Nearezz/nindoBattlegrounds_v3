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
	local KickMessage = "You have been kicked from the game for: "
	
	if not Target then return end
	
	for Index, Argument in ipairs(Arguments) do
		if Index > 2 then
			KickMessage = KickMessage..Argument.." "
		end
	end
	
	if KickMessage == "You have been kicked from the game for: " then
		KickMessage = KickMessage.." [No Reason Given]."
	end
	
	KickMessage = KickMessage.." {By "..Player.Name.."}"
	
	if string.lower(Target) == "all" then
		for Index, Target in ipairs(Players:GetPlayers()) do
			Target:Kick(KickMessage)
		end
	elseif string.lower(Target) == "me" then
		Player:Kick(KickMessage)
	elseif string.lower(Target) == "others" then
		for Index, Target in ipairs(Players:GetPlayers()) do
			if Target.UserId ~= Player.UserId then
				Target:Kick(KickMessage)
			end
		end
	else
		Target = FindPlayer(Target)
		if not Target then return end
		
		Target:Kick(KickMessage)
	end
end