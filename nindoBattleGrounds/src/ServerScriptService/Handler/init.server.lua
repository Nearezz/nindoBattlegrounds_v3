local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PhysicsService = game:GetService("PhysicsService")

local Modules = {}

local BanList = {}

local ServerLiftime = math.random(21600, 36000)

local Group = PhysicsService:RegisterCollisionGroup("Clone")
PhysicsService:CollisionGroupSetCollidable("Clone", "Clone", false)

task.delay(ServerLiftime, function()
	for Index, Player in ipairs(Players:GetPlayers()) do
		Player:Kick("Server lifetime has expired. Please rejoin.")
	end
end)

task.spawn(function()
	for Index, Module in ipairs(script:GetDescendants()) do
		if Module:IsA("ModuleScript") and not Module.Parent:IsA("ModuleScript") then
			Modules[Module.Name] = require(Module)
		end
	end
end)

task.spawn(function()
	for Index, Entity in ipairs(workspace:WaitForChild("World"):WaitForChild("Entities"):GetChildren()) do
		for Index, Part in ipairs(Entity:GetDescendants()) do
			if Part:IsA("BasePart") then
				PhysicsService:SetPartCollisionGroup(Part, "Clone")
			end
		end
	end
end)

task.spawn(function()
	local Sounds = script:WaitForChild("SoundTracks"):GetChildren()
	
	local function Play()
		for Index, Track in ipairs(Sounds) do
			local New = Track:Clone()
			New.Name = "CurrentTrack"
			New.Parent = workspace
			
			task.wait(2)
			New:Play()
			
			task.wait(Track.TimeLength)
			New:Destroy()
		end
	end
	
	while true do
		Play()
	end
end)

Players.PlayerAdded:Connect(function(Player)
	if table.find(BanList, Player.UserId) then
		Player:Kick("You are banned.")
		return
	end
	
	Player.Chatted:Connect(function(Message)
		local Users = Modules.ChatCommands("GetUsers")
		if not table.find(Users, Player.UserId) then return end
		
		local Prefix = Modules.ChatCommands("GetPrefix")
		local Commands = Modules.ChatCommands("GetCommands")
		local SplitMessage = string.split(Message, " ")
		
		if string.sub(SplitMessage[1], 1, 1) == Prefix then
			local Command = string.sub(SplitMessage[1], 2, #SplitMessage[1])
			
			if Commands[string.lower(Command)] then
				Commands[string.lower(Command)](Player, SplitMessage)
			end
		end
	end)
end)