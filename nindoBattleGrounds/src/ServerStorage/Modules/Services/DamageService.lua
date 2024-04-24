local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local SS2 = game:GetService("ServerScriptService")

local DamageService = {}

function DamageService:DamageEntities(Data)
	local Victim = Data.Victim
	local Attacker = Data.Attacker
	local StateService = require(RS.Modules.Services.StateService)
	local StateShortCuts = require(RS.Modules.Services.StateService.StateShortcuts)
	local RemoteComs = require(RS.Modules.Utility.RemoteNetwork)
	
	local Damage = Data.Damage
	local StateProfile = StateService:GetProfile(Victim)
	local Humanoid = Victim.Humanoid
	
	if not Humanoid or not Damage or not StateProfile or not Victim then return end
	
	local PointsService = require(SS.Modules.Services.PointsService)
	Humanoid:TakeDamage(Damage)
	
	StateProfile.StateData.LastAttacker.LastAttacker = Attacker
	StateProfile.StateData.LastAttacker.LastAttackTime = os.clock()
	
	RemoteComs:FireAllClientsEvent({FunctionName = "VFX"},{FName = "DamageIna",FData = {
		Damage = Damage,
		Victim = Victim,
	}})
	
	local Player = Players:GetPlayerFromCharacter(Attacker)
	
	if Player and not Data.NoPoints then
		PointsService:AddPoints(Players:GetPlayerFromCharacter(Attacker),Damage)
		Player.leaderstats.Damage.Value += Damage
	end
end

return DamageService