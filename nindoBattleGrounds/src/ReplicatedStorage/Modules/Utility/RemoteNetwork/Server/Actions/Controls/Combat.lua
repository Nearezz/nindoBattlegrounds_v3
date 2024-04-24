local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Combat = {}

function Combat:Swing(Player, Data)
	local Character = Player.Character
	local CombatService = require(ServerStorage.Modules.Services.CombatService)
	CombatService:Swing(Character, nil, (os.clock() - Data.SwingDelay))
end

function Combat:Dash(Player,Data)
	local Character = Player.Character
	local CombatService = require(ServerStorage.Modules.Services.CombatService)
	CombatService:Dash(Character,Data[1])
end

function Combat:Block(Player,Data)
	local Character = Player.Character
	local CombatService = require(ServerStorage.Modules.Services.CombatService)
	CombatService:Block(Character)
end

function Combat:BlockEnd(Player,Data)
	local Character = Player.Character
	local CombatService = require(ServerStorage.Modules.Services.CombatService)
	CombatService:BlockEnd(Character)
end

function Combat:SprintStart(Player,Data)
	local Character = Player.Character
	local CombatService = require(ServerStorage.Modules.Services.CombatService)
	CombatService:SprintStart(Character)
end

function Combat:SprintEnd(Player,Data)
	local Character = Player.Character
	local CombatService = require(ServerStorage.Modules.Services.CombatService)
	CombatService:SprintEnd(Character)
end

function Combat:InputBeganSkill(Player,Data)
	local Character = Player.Character
	local SkillService = require(ServerStorage.Modules.Services.SkillService)
	local StateService = require(ReplicatedStorage.Modules.Services.StateService)
	local StateProfile = StateService:GetProfile(Character)
	local CharVal = StateProfile.SelectedChar
	
	SkillService:CastSkill(Character,CharVal,Data.Slot,Data.Type)
end

return Combat