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
	
	local function RayCheck(Ori)
		local Para = RaycastParams.new()
		Para.FilterType = Enum.RaycastFilterType.Include
		Para.FilterDescendantsInstances = {workspace.World.Map}
		local RayCas = workspace:Raycast(Ori,Vector3.new(0,-10000,0),Para)
		if RayCas then
			return RayCas.Position + Vector3.new(0,3,0)
		else
			return Ori
		end
	end
	
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
	
	local ST = 0.35
	
	if HitCL ~= nil then
		ST = HitCL * 2.35
	end
	
	StateShortCuts:StunCharacter({
		Victim = Victim,
		Attacker = Character,
		WasAttack = true,
		Duration = 1.5,
		Priority = 50,
		AttackID = "NormalAttack",
	})
	StateShortCuts:StunSpeed(Victim,{
		Prior = 55,
		Duration = ST,
		Speed = 0,
	})
	
	local PointsService = require(SS.Modules.Services.PointsService)
	local DamageService = require(SS.Modules.Services.DamageService)
	
	if Players:GetPlayerFromCharacter(Character) then
		PointsService:AddToCombo(Players:GetPlayerFromCharacter(Character),1)
	end
	
	if CurrentCount <= 5 and StateProfile.StateData.AirCombo.Bool == false and AirC == false and Data.Slam == false then
		StateService:SetState(Character,"CanJump",{
			LP = 50,
			Dur = M1MetaData.StunTimes[CurrentCount] * 2
		})

		StateService:SetState(Victim,"CanJump",{
			LP = 50,
			Dur = M1MetaData.StunTimes[CurrentCount] * 2
		})

		for i,x in ipairs(Victim.PrimaryPart:GetChildren()) do
			if x:IsA("BodyPosition") and x.Name == "GroundM1BP" then
				x:Destroy()
			end
		end
		
		for i,x in ipairs(Victim.PrimaryPart:GetChildren()) do
			if x:IsA("BodyPosition") and x.Name == "SPBP" then
				x:Destroy()
			end
		end

		for i,x in ipairs(Character.PrimaryPart:GetChildren()) do
			if x:IsA("BodyPosition") and x.Name == "GroundM1BP" then
				x:Destroy()
			end
		end

		if SpaceKey then
			if (Vector3.new(0,RayCheck(HumRP.CFrame.Position).Y,0) - Vector3.new(0,HumRP.CFrame.Position.Y,0)).Magnitude >= 8 then
				local M1BP = Instance.new("BodyPosition")
				M1BP.Position = RayCheck(HumRP.CFrame.Position) + Vector3.new(0,10,0)
				M1BP.MaxForce = Vector3.new(0,20e4,0)
				M1BP.Parent = HumRP
				M1BP.Name = "GroundM1BP"
				Debris:AddItem(M1BP,.6)

				local M2BP = Instance.new("BodyPosition")
				M2BP.Position = RayCheck(HumRP.CFrame.Position) + Vector3.new(0,10,0)
				M2BP.MaxForce = Vector3.new(0,20e4,0)
				M2BP.Parent = VictimHumRP
				M2BP.Name = "GroundM1BP"
				Debris:AddItem(M2BP,.6)
			else
				local M1BP = Instance.new("BodyPosition")
				M1BP.Position = HumRP.CFrame.Position + Vector3.new(0,0.005,0)
				M1BP.MaxForce = Vector3.new(0,20e4,0)
				M1BP.Parent = HumRP
				M1BP.Name = "GroundM1BP"
				Debris:AddItem(M1BP,.6)

				local M2BP = Instance.new("BodyPosition")
				M2BP.Position = HumRP.CFrame.Position + Vector3.new(0,0.005,0)
				M2BP.MaxForce = Vector3.new(0,20e4,0)
				M2BP.Parent = VictimHumRP
				M2BP.Name = "GroundM1BP"
				Debris:AddItem(M2BP,.6)
			end
			
		elseif not SpaceKey then
			local M1BP = Instance.new("BodyPosition")
			M1BP.Position = Vector3.new(0,RayCheck(HumRP.CFrame.Position).Y,0)
			M1BP.MaxForce = Vector3.new(0,20e4,0)
			M1BP.Parent = HumRP
			M1BP.Name = "GroundM1BP"
			Debris:AddItem(M1BP,.4)

			local M2BP = Instance.new("BodyPosition")
			M2BP.Position = Vector3.new(0,RayCheck(HumRP.CFrame.Position).Y,0) + Vector3.new(0,0.005,0)
			M2BP.MaxForce = Vector3.new(0,20e4,0)
			M2BP.Parent = VictimHumRP
			M2BP.Name = "GroundM1BP"
			Debris:AddItem(M2BP,.4)
		end

		if CurrentCount ~= 5 then
			local M1BV = Instance.new("BodyVelocity")
			M1BV.Velocity = HumRP.CFrame.LookVector * 8
			M1BV.P = 2e4
			M1BV.MaxForce = Vector3.new(4e4,4e4,4e4)
			M1BV.Parent = HumRP
			Debris:AddItem(M1BV,.4)

			local M2BV = Instance.new("BodyVelocity")
			M2BV.Velocity = HumRP.CFrame.LookVector * 8
			M2BV.P = 2e4
			M2BV.MaxForce = Vector3.new(4e4,4e4,4e4)
			M2BV.Parent = VictimHumRP
			Debris:AddItem(M2BV,.4)
			
			RemoteComs:FireAllClientsEvent({FunctionName = "VFX"},{FName = "RegM1Hit",FData = {
				Character = Character,
				Victim = Victim,
			}})
			
			if Players:GetPlayerFromCharacter(Character) then
				RemoteComs:FireClientEvent(Players:GetPlayerFromCharacter(Character),{FunctionName = "VFX"},{FName = "RegM1HitSB",FData = {
					Character = Character,
					Victim = Victim,
				}})
			end
			
			if Players:GetPlayerFromCharacter(Victim) then
				RemoteComs:FireClientEvent(Players:GetPlayerFromCharacter(Victim),{FunctionName = "VFX"},{FName = "RegM1HitSB",FData = {
					Character = Character,
					Victim = Victim,
				}})
			end
			
			DamageService:DamageEntities({
				Attacker = Character,
				Victim = Victim,
				Damage = M1MetaData.Damage.Kb
			})
		elseif CurrentCount == 5 then
			for i,x in ipairs(Victim.PrimaryPart:GetChildren()) do
				if x:IsA("BodyPosition") or x:IsA("BodyVelocity") then
					x:Destroy()
				end
			end
			
			for i,x in ipairs(Character.PrimaryPart:GetChildren()) do
				if x:IsA("BodyPosition") then
					x:Destroy()
				end
			end
			
			DamageService:DamageEntities({
				Attacker = Character,
				Victim = Victim,
				Damage = M1MetaData.Damage.Reg
			})
			
			local M2BV = Instance.new("BodyVelocity")
			M2BV.Velocity = (HumRP.CFrame.LookVector * 75) + Vector3.new(0,10,0)
			M2BV.P = 2e4
			M2BV.MaxForce = Vector3.new(2e4, 2e4, 2e4)
			M2BV.Parent = VictimHumRP
			Debris:AddItem(M2BV, .35)
			
			RemoteComs:FireAllClientsEvent({FunctionName = "VFX"},{FName = "RegM5Hit",FData = {
				Character = Character,
				Victim = Victim,
			}})
		end
		
		if Players:GetPlayerFromCharacter(Character) then
			RemoteComs:FireClientEvent(Players:GetPlayerFromCharacter(Character),{FunctionName = "VFX"},{FName = "RegM5HitSB",FData = {
				Character = Character,
				Victim = Victim,
			}})
		end

		if Players:GetPlayerFromCharacter(Victim) then
			RemoteComs:FireClientEvent(Players:GetPlayerFromCharacter(Victim),{FunctionName = "VFX"},{FName = "RegM5HitSB",FData = {
				Character = Character,
				Victim = Victim,
			}})
		end
		
		local random_playbackspeed = CurrentCount ~= 5 and true or false
		
		if CurrentCount ~= 5 then
			SoundService:PlaySound("CombatHit",{
				Parent = Character.PrimaryPart,
				Volume = 1,
				PlaybackSpeed = random_playbackspeed and math.random(97, 103) / 100 or 1,
			},{},{
				Range = 100,
				Origin = Character.PrimaryPart.CFrame.p
			})
			
		else
			SoundService:PlaySound("CombatKnockback",{
				Parent = Character.PrimaryPart,
				Volume = 1,
				PlaybackSpeed = random_playbackspeed and math.random(97, 103) / 100 or 1,
			},{},{
				Range = 100,
				Origin = Character.PrimaryPart.CFrame.p
			})

		end
		
		if Players:GetPlayerFromCharacter(Victim) then
			RemoteComs:FireClientEvent(Players:GetPlayerFromCharacter(Victim),{FunctionName = "AnimationService" },{
				Task = "PlayAnimation",
				AnimationData = {
					Name = "Stun"..CurrentCount,
					AnimationSpeed = 1,
					Weight = 1,
					FadeTime = 0.25,
					Looped = false,
				}
			})
		else
			Victim.Humanoid.Animator:LoadAnimation(RS.Assets.Animations.Shared.Combat["Stun"..CurrentCount]):Play()
		end
	elseif CurrentCount == 4 and StateProfile.StateData.AirCombo.Bool == true or CurrentCount == 4 and AirC == true then
		DamageService:DamageEntities({
			Attacker = Character,
			Victim = Victim,
			Damage = M1MetaData.Damage.Reg
		})
		StateService:SetState(Character,"CanJump",{
			LP = 50,
			Dur = M1MetaData.StunTimes[CurrentCount] * 2
		})

		StateService:SetState(Victim,"CanJump",{
			LP = 50,
			Dur = M1MetaData.StunTimes[CurrentCount] * 2
		})

		for i,x in ipairs(Victim.PrimaryPart:GetChildren()) do
			if x:IsA("BodyPosition") and x.Name == "GroundM1BP" then
				x:Destroy()
			end
		end
		
		for i,x in ipairs(Character.PrimaryPart:GetChildren()) do
			if x:IsA("BodyPosition") and x.Name == "GroundM1BP" then
				x:Destroy()
			end
		end
		
		local random_playbackspeed = CurrentCount ~= 5 and true or false
		
		if CurrentCount ~= 5 then
			SoundService:PlaySound("CombatHit",{
				Parent = Character.PrimaryPart,
				Volume = 1,
				PlaybackSpeed = random_playbackspeed and math.random(97, 103) / 100 or 1,
			},{},{
				Range = 100,
				Origin = Character.PrimaryPart.CFrame.p
			})

		else
			SoundService:PlaySound("CombatKnockback",{
				Parent = Character.PrimaryPart,
				Volume = 1,
				PlaybackSpeed = random_playbackspeed and math.random(97, 103) / 100 or 1,
			},{},{
				Range = 100,
				Origin = Character.PrimaryPart.CFrame.p
			})
		end
		
		RemoteComs:FireAllClientsEvent({FunctionName = "VFX"},{FName = "RegM4Hit",FData = {
			Character = Character,
			Victim = Victim,
		}})
		
		local M1BP = Instance.new("BodyPosition")
		M1BP.Position = (HumRP.CFrame * CFrame.new(0,10,0)).Position
		M1BP.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
		M1BP.Parent = HumRP
		M1BP.P = 5e4
		M1BP.Name = "AirM1BP"
		Debris:AddItem(M1BP,1.7)

		local M2BP = Instance.new("BodyPosition")
		M2BP.Position = (HumRP.CFrame * CFrame.new(0,10,-4.5)).Position
		M2BP.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
		M2BP.Parent = VictimHumRP
		M2BP.Name = "AirM1BP"
		M2BP.P = 5e4
		Debris:AddItem(M2BP,1.7)
		
		StateProfile.StateData.AirCombo.HitConnect = true
		
		task.delay(1.5, function()
			StateProfile.StateData.AirCombo.HitConnect = false
		end)
		
		if Players:GetPlayerFromCharacter(Victim) then
			RemoteComs:FireClientEvent(Players:GetPlayerFromCharacter(Victim),{FunctionName = "AnimationService" },{
				Task = "PlayAnimation",
				AnimationData = {
					Name = "Stun"..CurrentCount,
					AnimationSpeed = 1,
					Weight = 1,
					FadeTime = 0.25,
					Looped = false,
				}
			})
		else
			Victim.Humanoid.Animator:LoadAnimation(RS.Assets.Animations.Shared.Combat["Stun"..CurrentCount]):Play()
		end
	elseif CurrentCount == 5 and Data.Slam == true then
		DamageService:DamageEntities({
			Attacker = Character,
			Victim = Victim,
			Damage = M1MetaData.Damage.Downslam
		})
		
		for i,x in pairs(Victim.PrimaryPart:GetChildren()) do
			if x:IsA("BodyPosition") then
				x:Destroy()
			end
		end
		
		for i,x in pairs(Character.PrimaryPart:GetChildren()) do
			if x:IsA("BodyPosition") then
				x:Destroy()
			end
		end
		
		StateProfile.StateData.AirCombo.HitConnect = false
		
		local DownSlam = require(SS.Modules.Services.DownSlamService).new({
			EndStun = 1.25,
			MaxTime = 5,
			MaxDist = 1000,
			Character = Victim,
			Speed = 300,
			StartCFrame = VictimHumRP.CFrame * CFrame.new(0,0.005,0),
			Vector = -(HumRP.CFrame.Position - (HumRP.CFrame.Position + (HumRP.CFrame.LookVector * 1000) + Vector3.new(0,-500,0))).Unit
		})
		
		local random_playbackspeed = CurrentCount ~= 5 and true or false
			SoundService:PlaySound("CombatHit",{
				Parent = Character.PrimaryPart,
				Volume = 1,
				PlaybackSpeed = random_playbackspeed and math.random(97, 103) / 100 or 1,
			},{},{
				Range = 100,
				Origin = Character.PrimaryPart.CFrame.p
			})
		
		if Players:GetPlayerFromCharacter(Character) then
			RemoteComs:FireClientEvent(Players:GetPlayerFromCharacter(Character),{FunctionName = "VFX"},{FName = "M5ScreenShake",FData = {
				Character = Character,
			}})
		end
		
		if Players:GetPlayerFromCharacter(Victim) then
			RemoteComs:FireClientEvent(Players:GetPlayerFromCharacter(Victim),{FunctionName = "VFX"},{FName = "M5ScreenShake",FData = {
				Character = Victim,
			}})
		end
		
		DownSlam:Start()
	end
end