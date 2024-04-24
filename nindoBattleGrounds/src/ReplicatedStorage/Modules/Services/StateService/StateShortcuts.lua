local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local SS2 = game:GetService("ServerScriptService")
local StateShortcuts = {}

function StateShortcuts:CounterTimeFrame(Data)
	local StateService = require(RS.Modules.Services.StateService)
	
	--- Example Counter ID = "KidSasuke_LionCombo_ThirdSkill"
	--- CharID_SkillName_SkillSlot
	
	
	local Caster = Data.Caster
	
	local StateProfile = StateService:GetProfile(Caster)
	
	if not StateProfile then return end
	
	local Priority = Data.Priortiy
	local Duration = Data.Duration
	
	local CounterID = Data.CounterID 
	local Projectiles = Data.Projectiles 
	local ProjectilesOnly = Data.ProjectilesOnly
	local Range = Data.Range 
	
	
	StateProfile.StateData["Counter"].CounterID = CounterID
	StateProfile.StateData["Counter"].Projectiles = Projectiles
	StateProfile.StateData["Counter"].ProjectilesOnly = ProjectilesOnly
	StateProfile.StateData["Counter"].Range = Range
	
	StateService:SetState(Caster,"Counter",{
		LP = Priority,
		Dur = Duration,
	})
end

function StateShortcuts:StunCharacter(Data)
	local StateService = require(RS.Modules.Services.StateService)
	
	local Stunned = Data.Victim
	local Attacker = Data.Attacker
	local Dur = Data.Duration or 0
	local WasAttack = Data.WasAttack
	local Priority = Data.Priority or 0
	local AttackID = Data.AttackID or "NormalAttack"
	
	StateService:SetState(Stunned,"Stunned",{
		LP = Priority,
		Dur = Dur,
	})
	
	StateService:SetState(Stunned,"CanJump",{
		LP = Priority,
		Dur = Dur,
	})
	
	if WasAttack and Attacker then
		StateService:SetState(Stunned,"LastAttacker",{
			LastAttackTime = os.clock(),
			LastAttacker = Attacker,
			LastAttackID = AttackID,
		})
	end
end

function StateShortcuts:GetHitAoeResult(Data)
	local StateManager = require(RS.Modules.Services.StateService)
	
	local Victim = Data.Victim
	local Attacker = Data.Attacker

	local VictimProfile = StateManager:GetProfile(Victim)
	local AttackerProfile = StateManager:GetProfile(Attacker)

	if not VictimProfile or not AttackerProfile then return end

	local HitData = Data.HitData

	local BlockBreak = HitData.BlockBreak
	local CanPB = HitData.PerfectBlock
	local CantBeCountered = HitData.CantBeCountered
	
	
	local AttackOrigin = Data.Origin
	
	local AttackVector = (AttackOrigin - Victim.PrimaryPart.Position).Unit
	local LookVector2 = Victim.PrimaryPart.CFrame.LookVector
	
	
	
	local DotProduct = math.deg(math.acos(LookVector2:Dot(AttackVector)))
	
	local ResultofHit = "Hit"
	

	if StateManager:GetState(Victim,"IFrame") then
		ResultofHit = "IFrame"
	elseif VictimProfile.StateData["PerfectBlock"].AllOn == true and os.clock() - VictimProfile.StateData["PerfectBlock"].CDTick >= VictimProfile.StateData["PerfectBlock"].CD then
		ResultofHit = "PerfectBlock"
	else
		
		if VictimProfile.StateData["Counter"].Projectiles == true and not CantBeCountered and StateManager:GetState(Victim,"Counter") and (Victim.PrimaryPart.Position - Attacker.PrimaryPart.Position).Magnitude <= VictimProfile.StateData["Counter"].Range then
			ResultofHit = "Counter_"..VictimProfile.StateData["Counter"].CounterID
			
		else
			if StateManager:GetState(Victim,"Blocking") and DotProduct <= 93 then
				if BlockBreak then
					ResultofHit = "GuardBreak"
				else
					if CanPB and DotProduct <= 93 and StateManager:GetState(Victim,"PerfectBlock") and os.clock() - VictimProfile.StateData["PerfectBlock"].CDTick >= VictimProfile.StateData["PerfectBlock"].CD then
						ResultofHit = "PerfectBlock"
					else
						if VictimProfile.StateData["PerfectBlock"].Perm == true then
							ResultofHit = "PerfectBlock"
						else
							ResultofHit = "Blocking"
						end
					end
				end
			else
				ResultofHit = "Hit"
			end
		end
	end



	return ResultofHit
	
end

function StateShortcuts:GetHitResult(Data)
	local StateManager = require(RS.Modules.Services.StateService)

	local Victim = Data.Victim
	local Attacker = Data.Attacker

	local VictimProfile = StateManager:GetProfile(Victim)
	local AttackerProfile = StateManager:GetProfile(Attacker)

	if not VictimProfile or not AttackerProfile then return end
	
	local HitData = Data.HitData

	local BlockBreak = HitData.BlockBreak
	local CanPB = HitData.PerfectBlock
	local CantBeCountered = HitData.CantBeCountered


	local ResultofHit = "Hit"

	local LookVector1 = (Victim.PrimaryPart.Position - Attacker.PrimaryPart.Position).unit
	local LookVector2 = Victim.PrimaryPart.CFrame.LookVector
	local DotProduct = math.acos(LookVector2:Dot(LookVector1))

	
	
	if StateManager:GetState(Victim,"IFrame") then
		ResultofHit = "IFrame"
	elseif VictimProfile.StateData["PerfectBlock"].AllOn == true and os.clock() - VictimProfile.StateData["PerfectBlock"].CDTick >= VictimProfile.StateData["PerfectBlock"].CD then
		ResultofHit = "PerfectBlock"
	else
		if VictimProfile.StateData["Counter"].ProjectilesOnly == false and not CantBeCountered and StateManager:GetState(Victim,"Counter") and (Victim.PrimaryPart.Position - Attacker.PrimaryPart.Position).Magnitude <= VictimProfile.StateData["Counter"].Range then
			ResultofHit = "Counter_"..VictimProfile.StateData["Counter"].CounterID
		else
			if StateManager:GetState(Victim,"Blocking") and DotProduct > 1 then
				if BlockBreak then
					ResultofHit = "GuardBreak"
				else
					if CanPB and DotProduct > 1 and StateManager:GetState(Victim,"PerfectBlock") and os.clock() - VictimProfile.StateData["PerfectBlock"].CDTick >= VictimProfile.StateData["PerfectBlock"].CD then
						ResultofHit = "PerfectBlock"
					else
						if VictimProfile.StateData["PerfectBlock"].Perm == true then
							ResultofHit = "PerfectBlock"
						else
							ResultofHit = "Blocking"
						end
					end
				end
			else
				ResultofHit = "Hit"
			end
		end
	end
	


	return ResultofHit

end

function StateShortcuts:GetLastAttacker(Character: Instance)
	local StateManager = require(RS.Modules.Services.StateService)
	local StateProfile = StateManager:GetProfile(Character)
	if not StateProfile then return end
	
	return StateProfile.StateData["LastAttacker"]
end

function StateShortcuts:StunSpeed(Character: Instance,Data)
	local StateManager = require(RS.Modules.Services.StateService)
	local StateProfile = StateManager:GetProfile(Character)
	if not StateProfile then return end
	
	if Data.Prior >= StateProfile.SpeedValues.StunSpeed.Prior then
		StateProfile.SpeedValues.StunSpeed.Dur = Data.Duration
		StateProfile.SpeedValues.StunSpeed.Speed = Data.Speed
		StateProfile.SpeedValues.StunSpeed.DurTick = os.clock()
	end
end

function StateShortcuts:BoostSpeeds(Character: Instance,Data)
	local StateManager = require(RS.Modules.Services.StateService)
	local StateProfile = StateManager:GetProfile(Character)
	if not StateProfile then return end
	
	if Data.WalkSpeed then
		StateProfile.SpeedValues.WalkSpeedP = Data.Prior
		StateProfile.SpeedValues.WalkSpeedDur = Data.Dur
		StateProfile.SpeedValues.WalkSpeed = Data.WalkSpeed
		StateProfile.SpeedValues.WalkSpeedT = os.clock()
		
		--[[
		if Data.Prior >= StateProfile.SpeedValues.WalkSpeedP or os.clock() - StateProfile.SpeedValues.WalkSpeedT > StateProfile.SpeedValues.WalkSpeedDur then
			StateProfile.SpeedValues.WalkSpeedP = Data.Prior
			StateProfile.SpeedValues.WalkSpeedDur = Data.Dur
			StateProfile.SpeedValues.WalkSpeed = Data.WalkSpeed
			StateProfile.SpeedValues.WalkSpeedT = os.clock()
		end
		]]--
	end
	
	if Data.RunSpeed then
		StateProfile.SpeedValues.RunSpeedP = Data.Prior
		StateProfile.SpeedValues.RunSpeedDur = Data.Dur
		StateProfile.SpeedValues.RunSpeed = Data.RunSpeed
		StateProfile.SpeedValues.RunSpeedT = os.clock()
		
		--[[
		if Data.Prior >= StateProfile.SpeedValues.RunSpeedP or os.clock() - StateProfile.SpeedValues.RunSpeedT > StateProfile.SpeedValues.RunSpeedP then
			StateProfile.SpeedValues.RunSpeedP = Data.Prior
			StateProfile.SpeedValues.RunSpeedDur = Data.Dur
			StateProfile.SpeedValues.RunSpeed = Data.RunSpeed
			StateProfile.SpeedValues.RunSpeedT = os.clock()
		end
		]]--
	end
end

return StateShortcuts