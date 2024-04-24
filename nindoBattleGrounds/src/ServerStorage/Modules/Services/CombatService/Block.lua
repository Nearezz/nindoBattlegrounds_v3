local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local SS2 = game:GetService("ServerScriptService")
local Debris = game:GetService("Debris")

return function(Data)
	local Victim = Data.Victim
	local Character = Data.Character

	local CurrentCount = Data.CurrentCount
	local M1MetaData = Data.M1MetaData
	local SpaceKey = Data.SpaceKey
	local AirC = Data.AirC
	local HitCL = Data.HitCl

	local RemoteComs = require(RS.Modules.Utility.RemoteNetwork)
	local SoundService = require(RS.Modules.Services.SoundService)
	local StateService = require(RS.Modules.Services.StateService)
	local StateShortCuts = require(RS.Modules.Services.StateService.StateShortcuts)
	local StateProfile = StateService:GetProfile(Character)

	if not StateProfile then return end
	if not StateService:GetProfile(Victim) then return end
	local HumRP = Character.PrimaryPart
	local VictimHumRP = Victim.PrimaryPart
	if Players:GetPlayerFromCharacter(Victim) == nil and Victim and Players:GetPlayerFromCharacter(Character) then
		if VictimHumRP and VictimHumRP.Anchored == false then
			for _,v in ipairs(Victim:GetChildren()) do
				if v:IsA("BasePart") and v.Anchored == false then
					v:SetNetworkOwner(Players:GetPlayerFromCharacter(Character))
				end
			end
		end
	end
	
	RemoteComs:FireAllClientsEvent({FunctionName = "VFX"},{FName = "RegBlockEffect",FData = {
		Character = Character,
		Victim = Victim,
	}})
	
	local random_playbackspeed = CurrentCount ~= 5 and true or false

	SoundService:PlaySound("CombatBlockhit",{
		Parent = Character.PrimaryPart,
		Volume = 1,
		PlaybackSpeed = random_playbackspeed and math.random(97, 103) / 100 or 1,
	},{},{
		Range = 100,
		Origin = Character.PrimaryPart.CFrame.p
	})

	StateService:SetState(Character,"CanJump",{
		LP = 50,
		Dur = M1MetaData.StunTimes[CurrentCount] * 2
	})
end