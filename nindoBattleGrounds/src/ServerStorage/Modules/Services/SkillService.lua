local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local SS2 = game:GetService("ServerScriptService")
local Debris = game:GetService("Debris")

local SkillService = {}

function SkillService:CastCounter(Data)
	local StateService = require(RS.Modules.Services.StateService)
	
	local Character = Data.Character
	local Victim = Data.Victim
	
	local CharCounterID = Data.CharCounterID
	local SkillName = Data.SkillName
	local Slot = Data.SkillSlot
	
	local StateProfile = StateService:GetProfile(Character)
	local VictimProfile = StateService:GetProfile(Victim)
	
	local CharacterData = require(SS.Modules.MetaData.CharacterData)
	local CharacterCheck = (type(CharacterData) == "table") and (type(CharacterData[CharCounterID]) == "table")
	local CharData = CharacterData[CharCounterID]
	
	if not CharacterCheck or not StateProfile or not VictimProfile then return end
	
	local CharacterSkills = require(SS.Modules.GamePlay.CharacterSkills)
	local SkillCheck = (type(CharacterSkills) == "table") and (type(CharacterSkills[CharCounterID]) == "table") and (type(CharacterSkills[CharCounterID][Slot][SkillName]) == "function")
	
	CharacterSkills[CharCounterID][Slot][SkillName](Character,Victim)
end

function SkillService:CastSkill(Character: Instance,CharacterID: string,Slot: string,InputType: string)
	local SkillService = require(SS.Modules.Services.SkillService)
	local StateService = require(RS.Modules.Services.StateService)
	local StateProfile = StateService:GetProfile(Character)
	
	local CharacterData = require(SS.Modules.MetaData.CharacterData)
	local CharacterCheck = (type(CharacterData) == "table") and (type(CharacterData[CharacterID]) == "table")
	local CharData = CharacterData[CharacterID]
	
	
	if not CharacterCheck or not StateProfile then return end
	
	local CharacterSkills = require(SS.Modules.GamePlay.CharacterSkills)
	local SkillCheck = (type(CharacterSkills) == "table") and (type(CharacterSkills[CharacterID]) == "table") and (type(CharacterSkills[CharacterID][Slot][InputType]) == "function")
	
	
	if not SkillCheck then return end
	
	CharacterSkills[CharacterID][Slot][InputType](Character)
end

function SkillService:FireClientVFX(Player,CharacterID,SkillSlot,FunctionName,Data)
	local RemoteComs = require(RS.Modules.Utility.RemoteNetwork)
	RemoteComs:FireAllClientsEvent({FunctionName = "SkillVFX"},{
		CharacterID = CharacterID,
		SkillSlot = SkillSlot,
		FuncName = FunctionName,
		Data = Data
	})
end

function SkillService:FireOneClientVFX(Player,CharacterID,SkillSlot,FunctionName,Data)
	local RemoteComs = require(RS.Modules.Utility.RemoteNetwork)
	RemoteComs:FireClientEvent(Player,{FunctionName = "SkillVFX"},{
		CharacterID = CharacterID,
		SkillSlot = SkillSlot,
		FuncName = FunctionName,
		Data = Data
	})
end

function SkillService:GetUISKey(Player)
	local RemoteComs = require(RS.Modules.Utility.RemoteNetwork)
	return RemoteComs:FireClientFunction(Player,{FunctionName = "UISKeyDown"},{Enum.KeyCode.Space},true)
end

function SkillService:GetMouse(Player)
	local RemoteComs = require(RS.Modules.Utility.RemoteNetwork)
	return RemoteComs:FireClientFunction(Player,{FunctionName = "GetMouse"},{},true)
end

function SkillService:ScreenToPoint(Player,Table)
	local RemoteComs = require(RS.Modules.Utility.RemoteNetwork)
	return RemoteComs:FireClientFunction(Player,{FunctionName = "SkillScreentoPoint"},{Table},true)
end



return SkillService