--{{Services}}--
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local SS2 = game:GetService("ServerScriptService")

local StateService = {}
local Client = {
	Profiles = {}
}


StateService.Profiles = {}

function StateService:Init()
	require(script.Stun)
end

function StateService:GenerateProfile(Char)
	local Util = require(RS.Modules.Utility.Util)
	StateService.Profiles[Char] = {
		SelectedChar = "None",
		InitiatedTick = os.clock(),
		StateData = Util.CopyTable(require(script.States)),
		EquipVal = Util.CopyTable(require(script.Equip)),
		SpeedValues = Util.CopyTable(require(script.Speed)),
	}
	if not Players:GetPlayerFromCharacter(Char) then
		StateService.Profiles[Char].AIStats = {
			FruitName = "None",
		}
	end
end

function StateService:ClearProfile(Char)
	if StateService.Profiles[Char]then
		StateService.Profiles[Char] = nil
	end
end

function StateService:GetState(Char: Instance,State: string)
	local Send = nil
	if StateService.Profiles[Char] then
		local StateProfile = StateService.Profiles[Char]
		if StateProfile.StateData[State] then
			if StateProfile.StateData[State].Type == "Boolean" then
				Send = StateProfile.StateData[State].Bool
			end
			if StateProfile.StateData[State].Type == "UniqueBoolean" then
				Send = StateProfile.StateData[State].Bool
			end
			if StateProfile.StateData[State].Type == "UniqueNumberValue" then
				if os.clock() - StateProfile.StateData[State].StartTime < StateProfile.StateData[State].Duration then
					Send = true
				else
					Send = false
				end
			end
			if StateProfile.StateData[State].Type == "NumberValue" then
				if os.clock() - StateProfile.StateData[State].StartTime < StateProfile.StateData[State].Duration then
					Send = true
				else
					Send = false
				end
			end
			if StateProfile.StateData[State].Type == "SPNumberValue" then
				Send = StateProfile.StateData[State].Count
			end
		end
	end
	return Send
end

function StateService:GetProfile(Char)
	if not StateService.Profiles[Char] then
		StateService:GenerateProfile(Char)
	end
	
	return StateService.Profiles[Char]
end

function StateService:SetState(Char: Instance, State: string, Table)
	if StateService.Profiles[Char] then
		local StateProfile = StateService.Profiles[Char]
		
		if StateProfile.StateData[State] then
			if StateProfile.StateData[State].Type == "Boolean" then
				StateProfile.StateData[State].Bool = Table.Value
			end
			
			if StateProfile.StateData[State].Type == "UniqueBoolean" then
				StateProfile.StateData[State].Bool = Table.Value
			end
			
			if StateProfile.StateData[State].Type == "NumberValue" then
				StateProfile.StateData[State].Duration = Table.Dur
				StateProfile.StateData[State].StartTime = os.clock()
			end
			
			if StateProfile.StateData[State].Type == "UniqueNumberValue" then
				Table.LP = Table.LP or 999
				
				local Start = os.clock()
				
				if StateProfile.StateData[State].LastPriority > Table.LP then return end
				StateProfile.StateData[State].Duration = Table.Dur
				StateProfile.StateData[State].StartTime = Start
				StateProfile.StateData[State].LastPriority = Table.LP
				
				task.delay(Table.Dur, function()
					if StateProfile.StateData[State].StartTime == Start then
						StateProfile.StateData[State].LastPriority = 0
					end
				end)
			end
			
			if StateProfile.StateData[State].Type == "SPNumberValue" then
				StateProfile.StateData[State].Count = Table.Value
			end
			if StateProfile.StateData[State].Type == "CustomState" then
				for index,Value in pairs(Table) do
					if StateProfile.StateData[State][index] then
						StateProfile.StateData[State][index] = Value
					end
				end
			end
		end
	end
end

function StateService:StunCharacter(Data)
	local Char = Data.Char
	local LP = Data.Priority
	local Dur = Data.Duration
	StateService:SetState(Char,"Stunned",{LP = LP,Dur = Dur})
end

function StateService:GetCurrentSpeed(Char)
	local Send = 14
	local Profile = StateService.Profiles[Char]
	
	if Profile then
		if os.clock() - Profile.SpeedValues.StunSpeed.DurTick < Profile.SpeedValues.StunSpeed.Dur then
			Send = Profile.SpeedValues.StunSpeed.Speed or 14
		else
			if StateService:GetState(Char,"LandStun") then
				Send = 4
			else
				if StateService:GetState(Char,"Blocking") then
					Send = 3
				else
					if StateService:GetState(Char,"Running") then	
						Send = Profile.SpeedValues.RunSpeed
						
						--[[
						if os.clock() -  Profile.SpeedValues.RunSpeedT <= Profile.SpeedValues.RunSpeedDur then
							Send = Profile.SpeedValues.RunSpeed
						else
							if not StateService:GetState(Char,"UsingSkill") then	
								Send = Profile.SpeedValues.DRunSpeed
							end
						end
						]]--
					else
						Send = Profile.SpeedValues.WalkSpeed
						
						--[[
						if os.clock() -  Profile.SpeedValues.WalkSpeedT <= Profile.SpeedValues.WalkSpeedDur then
							Send = Profile.SpeedValues.WalkSpeed
						else
							if not StateService:GetState(Char,"UsingSkill") then
								Send = Profile.SpeedValues.DWalkSpeed
							end
						end
						]]--
					end
				end
			end
		end
	end
	return Send
end

return StateService