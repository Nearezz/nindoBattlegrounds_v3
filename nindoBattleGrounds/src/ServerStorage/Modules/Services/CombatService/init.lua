local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local SS2 = game:GetService("ServerScriptService")
local Debris = game:GetService("Debris")

local CombatService = {}

local LastAnims = {}

function CombatService:RagDoll(Character: Instance)
	
end

function CombatService:ResetM1s(Character)
	local StateService = require(RS.Modules.Services.StateService)
	local StateShortCuts = require(RS.Modules.Services.StateService.StateShortcuts)
	local StateProfile = StateService:GetProfile(Character)

	local CharacterData = require(SS.Modules.MetaData.CharacterData)
	local CharVal = StateProfile.SelectedChar
	local CharacterCheck = (type(CharacterData) == "table") and (type(CharacterData[CharVal]) == "table")
	local CharData = CharacterData[CharVal]

	if not CharData then return end
	if not StateProfile then return end
	
	StateService:SetState(Character,"M1Cooldown",{
		Dur = 0.01,
		LP = 51
	})
	StateService:SetState(Character,"M1Count",{
		Value = 1,
	})
	
	StateProfile.StateData.AirCombo.Bool = false
end

function CombatService:Swing(Character, NpcData, SwingDelay)
	local StateService = require(RS.Modules.Services.StateService)
	local StateShortCuts = require(RS.Modules.Services.StateService.StateShortcuts)
	local StateProfile = StateService:GetProfile(Character)
	if not StateProfile then return end
	
	local CharacterData = require(SS.Modules.MetaData.CharacterData)
	local CharVal = StateProfile.SelectedChar
	local CharacterCheck = (type(CharacterData) == "table") and (type(CharacterData[CharVal]) == "table")
	local CharData = CharacterData[CharVal]
	
	if not CharData then return end
	if not StateProfile then return end
	if StateService:GetState(Character,"Stunned") then return end
	if StateService:GetState(Character,"Guardbroken") then return end
	if StateService:GetState(Character,"CantM1") then return end
	if StateService:GetState(Character,"M1Cooldown") then return end
	if StateService:GetState(Character,"Blocking") then return end
	if StateService:GetState(Character,"Dashing") then return end
	if StateService:GetState(Character,"UsingSkill") then return end
	
	local SoundService = require(RS.Modules.Services.SoundService)
	local HitBoxService = require(SS.Modules.Services.HitBoxService)
	
	local SwingDelay = (SwingDelay and SwingDelay < .1 and SwingDelay) or (SwingDelay and .1) or 0
	
	local Slam = false
	local AirC = false
	
	local M1MetaData = CharData.M1Data
	local M1Count = StateProfile.StateData.M1Count.Count
	local RemoteComs = require(RS.Modules.Utility.RemoteNetwork)
	local SpaceKey;
	
	if Players:GetPlayerFromCharacter(Character) then
		SpaceKey = RemoteComs:FireClientFunction(Players:GetPlayerFromCharacter(Character),{FunctionName = "UISKeyDown"},{Enum.KeyCode.Space},true)
	else
		SpaceKey = NpcData.Space
	end
	
	local Anim = M1MetaData.AnimationTable["Hit"..M1Count]
	local Cooldown = M1MetaData.AnimationTable["Hit"..M1Count.."CL"] - SwingDelay
	
	StateService:SetState(Character,"M1Cooldown",{
		Dur = Cooldown,
		LP = 49
	})
	
	StateService:SetState(Character,"Swing",{
		Dur = Cooldown * 1.5,
		LP = 49
	})
	
	local function DRayCheck(Ori)
		local Para = RaycastParams.new()
		Para.FilterType = Enum.RaycastFilterType.Include
		Para.FilterDescendantsInstances = {workspace.World.Map}
		local RayCas = workspace:Raycast(Ori,Vector3.new(0,-5,0),Para)
		if RayCas then
			return true
		else
			return false
		end
	end
	
	local function D2RayCheck(Ori)
		local Para = RaycastParams.new()
		Para.FilterType = Enum.RaycastFilterType.Include
		Para.FilterDescendantsInstances = {workspace.World.Map}
		local RayCas = workspace:Raycast(Ori,Vector3.new(0,-7.5,0),Para)
		if RayCas then
			return true
		else
			return false
		end
	end
	
	local HitCl;
	local HitConnect = false
	
	if StateProfile.StateData.AirCombo.HitConnect and M1Count == 5 then
		HitConnect = true
	end
	
	if M1Count <= 3 then
		StateService:SetState(Character,"M1Cooldown",{
			Dur = Cooldown,
			LP = 50
		})
		StateService:SetState(Character,"Swing",{
			Dur = Cooldown * 1.5,
			LP = 49
		})
		HitCl = M1MetaData.AnimationTable["Hit"..M1Count.."CL"]
		StateService:SetState(Character,"M1Count",{
			Value = M1Count + 1,
		})
	elseif M1Count == 4 and not SpaceKey or M1Count == 4 and DRayCheck(Character.PrimaryPart.CFrame.Position) == false then
		StateService:SetState(Character,"M1Cooldown",{
			Dur = Cooldown,
			LP = 50
		})
		StateService:SetState(Character,"Swing",{
			Dur = Cooldown * 1.5,
			LP = 49
		})
		HitCl = M1MetaData.AnimationTable["Hit"..M1Count.."CL"]
		StateService:SetState(Character,"M1Count",{
			Value = M1Count + 1,
		})
		StateProfile.StateData.AirCombo.Bool = false
	elseif M1Count == 4 and SpaceKey and DRayCheck(Character.PrimaryPart.CFrame.Position) then
		AirC = true
		StateProfile.StateData.AirCombo.Bool = true
		StateService:SetState(Character,"M1Cooldown",{
			Dur = M1MetaData.AnimationTable["AirCL"] - SwingDelay,
			LP = 50
		})
		StateService:SetState(Character,"Swing",{
			Dur = (M1MetaData.AnimationTable["AirCL"] - SwingDelay) * 1.5,
			LP = 49
		})
		StateService:SetState(Character,"M1Count",{
			Value = M1Count + 1,
		})
		HitCl = M1MetaData.AnimationTable["AirCL"]
		Anim = RS.Assets.Animations.Shared.Combat.UpTilt
	elseif not HitConnect and M1Count == 5 and StateProfile.StateData.AirCombo.Bool == false and D2RayCheck(Character.PrimaryPart.CFrame.Position) == true then
		StateService:SetState(Character,"M1Cooldown",{
			Dur = 1.5 - SwingDelay,
			LP = 50
		})
		StateService:SetState(Character,"Swing",{
			Dur = 1 - SwingDelay,
			LP = 49
		})
		StateService:SetState(Character,"M1Count",{
			Value = 1,
		})
		HitCl = M1MetaData.AnimationTable["Hit"..M1Count.."CL"]
		StateProfile.StateData.AirCombo.Bool = false
		StateProfile.StateData.AirCombo.HitConnect = false
	elseif HitConnect and M1Count == 5 and StateProfile.StateData.AirCombo.Bool == true or M1Count == 5 and  D2RayCheck(Character.PrimaryPart.CFrame.Position) == false then
		Slam = true
		Anim = RS.Assets.Animations.Shared.Combat.DownSlam
		StateService:SetState(Character,"M1Cooldown",{
			Dur = 1.5 - SwingDelay,
			LP = 50
		})
		StateService:SetState(Character,"Swing",{
			Dur = 1 - SwingDelay,
			LP = 49
		})
		StateService:SetState(Character,"M1Count",{
			Value = 1,
		})
		StateProfile.StateData.AirCombo.Bool = false
		StateProfile.StateData.AirCombo.HitConnect = false
		HitCl = M1MetaData.AnimationTable["Hit"..M1Count.."CL"]
	end
	
	task.delay(1, function()
		if M1Count ~= 5 then
			if StateProfile.StateData.M1Count.Count == M1Count + 1 then
				StateService:SetState(Character,"M1Cooldown",{
					Dur = 0.5,
					LP = 51
				})
				
				StateService:SetState(Character,"M1Count",{
					Value = 1,
				})
				
				StateProfile.StateData.AirCombo.Bool = false
			end
		end
	end)
	
	if LastAnims[Character] then
		if Players:GetPlayerFromCharacter(Character) then
			RemoteComs:FireClientEvent(Players:GetPlayerFromCharacter(Character),{FunctionName = "AnimationService" },{
				Task = "StopAnimation",
				AnimationData = {
					Name = LastAnims[Character].Name
				}
			})
		else
			Character.Humanoid.Animator:LoadAnimation(LastAnims[Character]):Stop()
		end
	end
	
	LastAnims[Character] = Anim
	
	if Players:GetPlayerFromCharacter(Character) then
		RemoteComs:FireClientEvent(Players:GetPlayerFromCharacter(Character),{FunctionName = "AnimationService" },{
			Task = "PlayAnimation",
			AnimationData = {
				Name = Anim.Name,
				AnimationSpeed = (Anim.Name == "DownSlam" and 2) or 1,
				Weight = 3.5,
				FadeTime = 0.25,
				Looped = false,
			}
		})
	else
		Character.Humanoid.Animator:LoadAnimation(Anim):Play(.25)
		
		if Anim.Name == "DownSlam" then
			Character.Humanoid.Animator:LoadAnimation(Anim):AdjustSpeed(2)
		end
	end
	
	SoundService:PlaySound("CombatSwing",{
		Parent = Character.PrimaryPart,
		Volume = 0.75,
	},{},{
		Range = 100,
		Origin = Character.PrimaryPart.CFrame.p
	})
	
	if not StateService:GetState(Character,"M1Cooldown") then return end
	
	task.wait(.2 - SwingDelay)
	local HitBox = HitBoxService:CRepeatCFrame({
		BreakOnHit = true,
		MultHit = false,
		OffsetPart = Character.PrimaryPart,
		HitOnce = true,
		Offset = M1MetaData.HitBoxData.Offset,
		Size = M1MetaData.HitBoxData.Size,
		Dur = .2,
		Visual = false,
		Caster = Character,
	})
	
	HitBox.OnHit:Connect(function(Victim)
		if StateService:GetState(Character,"Stunned") then return end
		
		if NpcData then
			if Character:FindFirstChild("Brain") then
				if Victim == Character:WaitForChild("Brain"):WaitForChild("Caster").Value then
					return
				end
			end
		end
		
		local hitresult = StateShortCuts:GetHitResult({
			Attacker = Character,
			Victim = Victim,
			HitData = {
				BlockBreak = (M1Count == 5 and true) or (false),
				PerfectBlock = true,
			}
		})
		
		if hitresult == "Hit" then
			require(script.Hit)({
				Character = Character,
				CurrentCount = M1Count,
				Victim = Victim,
				M1MetaData = M1MetaData,
				SpaceKey = SpaceKey,
				AirC = AirC,
				HitCl = HitCl,
				Slam = Slam,
				HitConnect = HitConnect,
			})
			if NpcData then
				if NpcData.Return then
					StateProfile.StateData["ShadowClone"].Value = true
				end
			end
		elseif hitresult == "Blocking" then
			require(script.Block)({
				Character = Character,
				CurrentCount = M1Count,
				Victim = Victim,
				M1MetaData = M1MetaData,
				SpaceKey = SpaceKey,
				AirC = AirC,
				HitCl = HitCl,
				Slam = Slam
			})
			if NpcData then
				if NpcData.Return then
					StateProfile.StateData["ShadowClone"].Value = true
				end
			end
		elseif hitresult == "GuardBreak" then
			CombatService:GuardBreak(Victim)
			
			if NpcData then
				if NpcData.Return then
					StateProfile.StateData["ShadowClone"].Value = true
				end
			end
		elseif hitresult == "PerfectBlock" then
			CombatService:PerfectBlock(Victim,Character,{
				CanTP = true,
				MaxDist = 16,
			})
			if NpcData then
				if NpcData.Return then
					StateProfile.StateData["ShadowClone"].Value = true
				end
			end
		elseif hitresult:match("Counter") then
			local SkillService = require(SS.Modules.Services.SkillService)
			local DataForCounter = hitresult:split("_")
			SkillService:CastCounter({
				Character = Victim,
				Victim = Character,
				CharCounterID = DataForCounter[2],
				SkillName = DataForCounter[3],
				SkillSlot = DataForCounter[4]
			})
			
			if NpcData then
				if NpcData.Return then
					StateProfile.StateData["ShadowClone"].Value = true
				end
			end
		end
		
	end)
	
	HitBox:Start()
end

function CombatService:PerfectBlock(Character,Victim,Data)
	local StateService = require(RS.Modules.Services.StateService)
	local StateProfile = StateService:GetProfile(Character)
	if not StateProfile then return end
	
	StateProfile.StateData["PerfectBlock"].CDTick = os.clock()
	StateProfile.StateData["PerfectBlock"].CD = 3
	
	StateService:SetState(Character,"IFrame",{
		LP = 55,
		Dur = 2,
	})
	
	if not Data.CanTP then return end
	local Dist = (Character.PrimaryPart.CFrame.Position - Victim.PrimaryPart.CFrame.Position).Magnitude
	if Dist > Data.MaxDist then return end
	local RemoteComs = require(RS.Modules.Utility.RemoteNetwork)
	local SoundService = require(RS.Modules.Services.SoundService)
	local TeleCFrame = CFrame.lookAt((Victim.PrimaryPart.CFrame * CFrame.new(0,2,8)).Position,Victim.PrimaryPart.CFrame.Position)
	RemoteComs:FireAllClientsEvent({FunctionName = "VFX"},{FName = "Sub",FData = {
		Pos = CFrame.new(Character.PrimaryPart.CFrame.Position)
	}})
	SoundService:PlaySound("PoofSound",{
		Parent = Victim.PrimaryPart,
		Volume = 0.75,
		Playing = true
	},{},{
		Range = 100,
		Origin = Victim.PrimaryPart.CFrame.p
	})
	
	
	Character.PrimaryPart.CFrame = TeleCFrame
	
end

function CombatService:Block(Character)
	local StateService = require(RS.Modules.Services.StateService)
	local StateProfile = StateService:GetProfile(Character)
	if not StateProfile then return end
	if StateService:GetState(Character,"Stunned") then return end
	if StateService:GetState(Character,"Guardbroken") then return end
	if StateService:GetState(Character,"CantBlock") then return end
	if StateService:GetState(Character,"BlockCooldown") then return end
	if StateService:GetState(Character,"Blocking") then return end
	
	local RemoteComs = require(RS.Modules.Utility.RemoteNetwork)
	local Humanoid = Character.Humanoid
	
	StateService:SetState(Character,"Blocking",{
		Value = true
	})
	
	StateService:SetState(Character,"PerfectBlock",{
		Dur = .35,
		LP = 50,
	})
	
	if Players:GetPlayerFromCharacter(Character) then
		RemoteComs:FireClientEvent(Players:GetPlayerFromCharacter(Character),{FunctionName = "AnimationService" },{
			Task = "PlayAnimation",
			AnimationData = {
				Name = "Melee_Block",
				AnimationSpeed = 1,
				Weight = 1,
				FadeTime = 0.1,
				Looped = true,
			}
		})
	else
		Humanoid:LoadAnimation(RS.Assets.Animations.Shared.Combat.Melee_Block):Play()
	end
end

function CombatService:BlockEnd(Character)
	local StateService = require(RS.Modules.Services.StateService)
	local StateProfile = StateService:GetProfile(Character)
	if not StateProfile then return end
	if not StateService:GetState(Character,"Blocking") then return end

	local RemoteComs = require(RS.Modules.Utility.RemoteNetwork)
	local Humanoid = Character.Humanoid

	StateService:SetState(Character,"Blocking",{
		Value = false
	})

	if Players:GetPlayerFromCharacter(Character) then
		RemoteComs:FireClientEvent(Players:GetPlayerFromCharacter(Character),{FunctionName = "AnimationService" },{
			Task = "StopAnimation",
			AnimationData = {
				Name = "Melee_Block",
				AnimationSpeed = 1,
				Weight = 1,
				FadeTime = 0.1,
				Looped = true,
			}
		})
	else
		for i,v in pairs(Character.Humanoid.Animator:GetPlayingAnimationTracks()) do
			v:Stop()
		end
	end
end

function CombatService:SprintStart(Character)
	local StateService = require(RS.Modules.Services.StateService)
	local StateProfile = StateService:GetProfile(Character)
	if not StateProfile then return end
	if StateService:GetState(Character,"Running") then return end
	if StateService:GetState(Character,"Stunned") then return end
	if StateService:GetState(Character,"Guardbroken") then return end
	if StateService:GetState(Character,"CantRun") then return end
	if StateService:GetState(Character,"Dashing") then return end
	
	local RemoteComs = require(RS.Modules.Utility.RemoteNetwork)
	local Humanoid = Character.Humanoid
	
	StateService:SetState(Character,"Running",{
		Value = true
	})
	
	RemoteComs:FireClientEvent(Players:GetPlayerFromCharacter(Character),{FunctionName = "AnimationService" },{
		Task = "PlayAnimation",
		AnimationData = {
			Name = "DfRun",
			AnimationSpeed = 1,
			Weight = 3,
			FadeTime = 0.1,
			Looped = true,
		}
	})
	
	--RemoteComs:FireClientEvent(Players:GetPlayerFromCharacter(Character),{FunctionName = "RunFov" },{Val = true})
	
	task.spawn(function()
		local Playing = true
		
		while StateService:GetState(Character,"Running") or Character.PrimaryPart ~= nil do
			if StateService:GetState(Character, "Swing") or StateService:GetState(Character, "UsingSkill") then
				if Playing == true then
					Playing = false
					CombatService:SprintEnd(Character)
					break
				end
			end
			
			if Humanoid.MoveDirection == Vector3.new() or StateService:GetState(Character,"Blocking") or StateService:GetState(Character,"Stunned") or (StateService:GetState(Character,"UsingSkill") and StateProfile.StateData["RunID"].Name ~= "DfRun") then
				if Playing == true then
					Playing = false
					RemoteComs:FireClientEvent(Players:GetPlayerFromCharacter(Character),{FunctionName = "AnimationService" },{
						Task = "StopAnimation",
						AnimationData = {
							Name = "DfRun",
							AnimationSpeed = 1,
							Weight = 1,
							FadeTime = 0.25,
							Looped = true,
						}
					})
				end
			else
				if StateProfile.StateData["RunID"].Name ~= "DfRun" then
					StateProfile.StateData["RunID"].Name = "DfRun"
				end
				
				if Playing == false then
					Playing = true
					RemoteComs:FireClientEvent(Players:GetPlayerFromCharacter(Character),{FunctionName = "AnimationService" },{
						Task = "PlayAnimation",
						AnimationData = {
							Name = "DfRun",
							AnimationSpeed = 1,
							Weight = 3,
							FadeTime = 0.25,
							Looped = true,
						}
					})
				end
			end
			
			if Humanoid.FloorMaterial == Enum.Material.Air then
				RemoteComs:FireClientEvent(Players:GetPlayerFromCharacter(Character),{FunctionName = "AnimationService" },{
					Task = "StopAnimation",
					AnimationData = {
						Name = "DfRun",
						AnimationSpeed = 1,
						Weight = 1,
						FadeTime = 0.25,
						Looped = true,
					}
				})
				
				Playing = false
				
				local State; State = Humanoid.StateChanged:Connect(function(oldstate,newstate)
					if newstate == Enum.HumanoidStateType.Landed then
						if Humanoid.MoveDirection ~= Vector3.new()  then
							task.wait(0.5)
							if StateService:GetState(Character,"Running") then
								RemoteComs:FireClientEvent(Players:GetPlayerFromCharacter(Character),{FunctionName = "AnimationService" },{
									Task = "PlayAnimation",
									AnimationData = {
										Name = "DfRun",
										AnimationSpeed = 1,
										Weight = 1,
										FadeTime = 0.25,
										Looped = true,
									}
								})
								Playing = true
							end
						end
						
						if State then
							State:Disconnect()
							State = nil
						end
					end
				end)
			end
			
			if not StateService:GetState(Character,"Running") then
				break
			end
			RunService.Heartbeat:Wait()
		end
	end)
end

function CombatService:SprintEnd(Character)
	local StateService = require(RS.Modules.Services.StateService)
	local StateProfile = StateService:GetProfile(Character)
	if not StateProfile then return end
	if not StateService:GetState(Character,"Running") then return end
	local RemoteComs = require(RS.Modules.Utility.RemoteNetwork)
	
	--RemoteComs:FireClientEvent(Players:GetPlayerFromCharacter(Character),{FunctionName = "RunFov" },{Val = false})
	
	StateService:SetState(Character,"Running",{
		Value = false
	})
	
	RemoteComs:FireClientEvent(Players:GetPlayerFromCharacter(Character),{FunctionName = "AnimationService" },{
		Task = "StopAnimation",
		AnimationData = {
			Name = "DfRun",
			AnimationSpeed = 1,
			Weight = 0,
			FadeTime = 0.1,
			Looped = true,
		}
	})
end

function CombatService:Dash(Character,Dir: string)
	local StateService = require(RS.Modules.Services.StateService)
	local StateProfile = StateService:GetProfile(Character)
	if StateService:GetState(Character,"Stunned") then return end
	if StateService:GetState(Character,"Guardbroken") then return end
	if StateService:GetState(Character,"CantDash") then return end
	if StateService:GetState(Character,"DashCooldown") then return end
	if StateService:GetState(Character,"Dashing") then return end
	if StateService:GetState(Character,"UsingSkill") then return end
	
	local Hum = Character.Humanoid
	local HumRP = Character.PrimaryPart
	
	local RemoteComs = require(RS.Modules.Utility.RemoteNetwork)
	
	StateService:SetState(Character,"DashCooldown",{
		LP = 50,
		Dur = 1.25,
	})
	
	local DashDirs = {
		["FrontDash"] = {60,0},
		["RightDash"] = {0,-60},
		["LeftDash"] = {0,60},
		["BackDash"] = {-60,0}
	}
	
	local new_cframe = Character.PrimaryPart.CFrame
	local lookvector_force = DashDirs[Dir][1]
	local rightvector_force = DashDirs[Dir][2]
	
	local AnimName = "FrontDash" --RS.Assets.Animations.Shared.Dashs[Dir]
	
	RemoteComs:FireClientEvent(Players:GetPlayerFromCharacter(Character),{FunctionName = "AnimationService" },{
		Task = "PlayAnimation",
		AnimationData = {
			Name = AnimName,
			AnimationSpeed = 2,
			Weight = 3,
			FadeTime = 0,
			Looped = false,
		}
	})
	
	local Velocity = (new_cframe.LookVector * lookvector_force) + (new_cframe.RightVector * rightvector_force)
	
	local Velo = Instance.new("BodyVelocity")
	Velo.P = 2e4
	Velo.MaxForce = Vector3.new(4e4,0,4e4)
	Velo.Velocity = Velocity
	Velo.Parent = Character.PrimaryPart
	
	Debris:AddItem(Velo,.4)

	StateService:SetState(Character,"Dashing",{
		Dur = .4,
	})
	
	RemoteComs:FireClientEvent(Players:GetPlayerFromCharacter(Character),{FunctionName = "VFX"},{FName = "DB",FData = {
		Character = Character,
		Lifetime = .25
	}})
end

function CombatService:GuardBreak(Character)
	local StateService = require(RS.Modules.Services.StateService)
	local StateShortCuts = require(RS.Modules.Services.StateService.StateShortcuts)
	local StateProfile = StateService:GetProfile(Character)
	if not StateProfile then return end
	local RemoteComs = require(RS.Modules.Utility.RemoteNetwork)
	
	StateService:SetState(Character,"Guardbroken",{
		LP = 60,
		Dur = 3,
	})
	StateService:SetState(Character,"Stunned",{
		LP = 50,
		Dur = 3,
	})
	StateService:SetState(Character,"CantBlock",{
		LP = 60,
		Dur = 3,
	})

	CombatService:BlockEnd(Character)
	
	if Players:GetPlayerFromCharacter(Character) then
		RemoteComs:FireClientEvent(Players:GetPlayerFromCharacter(Character),{FunctionName = "AnimationService" },{
			Task = "StopAnimation",
			AnimationData = {
				Name = "Melee_Block",
				AnimationSpeed = 1,
				Weight = 1,
				FadeTime = 0.25,
				Looped = true,
			}
		})
	else
		for i,v in pairs(Character.Humanoid.Animator:GetPlayingAnimationTracks()) do
			v:Stop()
		end
	end
	
	StateShortCuts:StunSpeed(Character,{
		Prior = 60,
		Duration = 3,
		Speed = 0,
	})
	
	RemoteComs:FireAllClientsEvent({FunctionName = "VFX"},{FName = "GuardBreak",FData = {
		Character = Character,
	}})
	
	if Players:GetPlayerFromCharacter(Character) then
		RemoteComs:FireClientEvent(Players:GetPlayerFromCharacter(Character),{FunctionName = "AnimationService" },{
			Task = "PlayAnimation",
			AnimationData = {
				Name = "Guardbreak",
				AnimationSpeed = 1,
				Weight = 1,
				FadeTime = 0.25,
				Looped = true,
			}
		})
	else
		Character.Humanoid.Animator:LoadAnimation(RS.Assets.Animations.Shared.Combat.Guardbreak):Play()
	end
	
	task.delay(3, function()
		if Players:GetPlayerFromCharacter(Character) then
			RemoteComs:FireClientEvent(Players:GetPlayerFromCharacter(Character),{FunctionName = "AnimationService" },{
				Task = "StopAnimation",
				AnimationData = {
					Name = "Guardbreak",
					AnimationSpeed = 1,
					Weight = 1,
					FadeTime = 0.25,
					Looped = true,
				}
			})
		else
			Character.Humanoid.Animator:LoadAnimation(RS.Assets.Animations.Shared.Combat.Guardbreak):Stop()
		end
	end)
end

return CombatService