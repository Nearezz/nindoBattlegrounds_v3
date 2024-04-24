local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local SS2 = game:GetService("ServerScriptService")
local HTTPService = game:GetService("HttpService")
local Debris = game:GetService("Debris")

local CharacterID = "KidSasuke"

local GetPosition = RS.GetPosition

local KidSasuke; KidSasuke = {
	["FirstSkill"] = {
		["Release"] = function(Character)
		end,
		["Hold"] = function(Character)
			local SkillUID = "FirstSkillHold"..Character.Name..CharacterID..HTTPService:GenerateGUID(false)

			local SkillService = require(SS.Modules.Services.SkillService)
			local StateService = require(RS.Modules.Services.StateService)

			local StateShortCuts = require(RS.Modules.Services.StateService.StateShortcuts)
			local SoundService = require(RS.Modules.Services.SoundService)

			local HitBoxService = require(SS.Modules.Services.HitBoxService)
			local RemoteComs = require(RS.Modules.Utility.RemoteNetwork)
			local Util = require(RS.Modules.Utility.Util)

			local CooldownService = require(SS.Modules.Services.CooldownService)
			local PointsService = require(SS.Modules.Services.PointsService)
			local DamageService = require(SS.Modules.Services.DamageService)

			local SkillData = require(SS.Modules.MetaData.CharacterData)[CharacterID]["SkillData"]["FirstSkill"]

			if not CooldownService:CheckCooldown(Character,CharacterID,"FirstSkill") then return end
			if StateService:GetState(Character,"Stunned") then return end
			if StateService:GetState(Character,"UsingSkill") then return end
			if StateService:GetState(Character,"Swing") then return end
			
			local Player = Players:GetPlayerFromCharacter(Character)
			
			local CombatService = require(SS.Modules.Services.CombatService)
			
			CooldownService:SetCooldown(Character,CharacterID,"FirstSkill",{
				Hold = true
			})
			
			StateService:SetState(Character,"CantRun",{
				LP = 65,
				Dur = 10,
			})
			StateService:SetState(Character,"UsingSkill",{
				LP = 50,
				Dur = 10,
			})
			
			StateShortCuts:StunSpeed(Character,{
				Prior = 55,
				Duration = 5,
				Speed = 5,
			})
			
			SoundService:PlaySound("HandsignSound",{
				Parent = Character.PrimaryPart,
				Volume = 1,
			},{},{
				Range = 50,
				Origin = Character.PrimaryPart.CFrame.p
			})
			
			local ChidoriStarted = true
			local Stop = false
			
			RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
				Task = "PlayAnimation",
				AnimationData = {
					Name = "ChidoriCharge",
					AnimationSpeed = 1,
					Weight = 3.5,
					FadeTime = 0.25,
					Looped = false,
				}
			})
			
			task.spawn(function()
				while not Stop do
					if ChidoriStarted and StateService:GetState(Character,"Stunned") then
						ChidoriStarted = false
						Stop = true
						
						RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
							Task = "StopAnimation",
							AnimationData = {
								Name = "ChidoriCharge",
								AnimationSpeed = 1,
								Weight = 3.5,
								FadeTime = 0.25,
								Looped = false,
							}
						})
						
						SoundService:StopSound("HandsignSound",{
							Parent = Character.PrimaryPart,
							Volume = 1,
						},{},{
							Range = 50,
							Origin = Character.PrimaryPart.CFrame.p
						})
						
						StateService:SetState(Character,"CantRun",{
							LP = 65,
							Dur = 0.01,
						})
						StateService:SetState(Character,"UsingSkill",{
							LP = 50,
							Dur = 0.01,
						})
						StateShortCuts:BoostSpeeds(Character,{
							Prior = 55,
							Dur = 0.01,
							WalkSpeed = 16,
							RunSpeed = 25,
						})
						CooldownService:SetCooldown(Character,CharacterID,"FirstSkill",{
							Hold = false
						})
						
						CooldownService:SetCooldown(Character,CharacterID,"FirstSkill",{
							CD = SkillData.Cooldown
						})
						break
					end
					RunService.Heartbeat:Wait()
				end
			end)
			
			Util:SignalMarker(RS.Assets.Animations.Shared.Kakashi["ChidoriCharge"],"Release"):Connect(function()
				if not ChidoriStarted then return end
				Stop = true
				
				task.delay(1,function()
					SoundService:StopSound("HandsignSound",{
						Parent = Character.PrimaryPart,
						Volume = 1,
					},{},{
						Range = 50,
						Origin = Character.PrimaryPart.CFrame.p
					})
				end)
				
				StateService:GetProfile(Character).StateData["RunID"].Name = "ChidoriRun"
				
				RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
					Task = "PlayAnimation",
					AnimationData = {
						Name = "ChidoriRun",
						AnimationSpeed = 1,
						Weight = 1,
						FadeTime = 0.25,
						Looped = true,
					}
				})
				
				StateService:SetState(Character,"CantRun",{
					LP = 66,
					Dur = 0.01,
				})
				StateService:SetState(Character,"UsingSkill",{
					LP = 50,
					Dur = SkillData.Length,
				})
				StateShortCuts:StunSpeed(Character,{
					Prior = 56,
					Duration = 0.01,
					Speed = 14,
				})
				StateShortCuts:BoostSpeeds(Character,{
					Prior = 55,
					Dur = SkillData.Length,
					WalkSpeed = SkillData.SpeedBoost,
					RunSpeed = SkillData.SpeedBoost,
				})
				
				SkillService:FireClientVFX(Player,CharacterID,"FirstSkill","FireChidoriParticle",{
					Character = Character,
					UID = SkillUID
				})
				
				SoundService:PlaySound("ChidoriSound",{
					Parent = Character.PrimaryPart,
					Volume = 1,
				},{},{
					Range = 50,
					Origin = Character.PrimaryPart.CFrame.p
				})
				
				local Stop2 = false
				
				task.spawn(function()
					while not Stop2 do
						if ChidoriStarted and StateService:GetState(Character,"Stunned") then
							ChidoriStarted = false
							Stop = true
							Stop2 = true
							
							SoundService:StopSound("ChidoriSound",{
								Parent = Character.PrimaryPart,
								Volume = 1,
							},{},{
								Range = 50,
								Origin = Character.PrimaryPart.CFrame.p
							})
							StateService:SetState(Character,"CantRun",{
								LP = 65,
								Dur = 0.01,
							})
							StateService:SetState(Character,"UsingSkill",{
								LP = 50,
								Dur = 0.01,
							})
							StateShortCuts:BoostSpeeds(Character,{
								Prior = 55,
								Dur = 0.01,
								WalkSpeed = 16,
								RunSpeed = 25,
							})
							CooldownService:SetCooldown(Character,CharacterID,"FirstSkill",{
								Hold = false
							})
							CooldownService:SetCooldown(Character,CharacterID,"FirstSkill",{
								CD = SkillData.Cooldown
							})
							
							RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
								Task = "StopAnimation",
								AnimationData = {
									Name = "ChidoriRun",
									AnimationSpeed = 1,
									Weight = 1,
									FadeTime = 0.25,
									Looped = true,
								}
							})
							
							StateService:GetProfile(Character).StateData["RunID"].Name = "DfRun"
							
							SkillService:FireClientVFX(Player,CharacterID,"FirstSkill","ChidoriParticleOff",{
								Character = Character,
								UID = SkillUID
							})
							break
						end
						RunService.Heartbeat:Wait()
					end
				end)
				
				task.delay(SkillData.Length, function()
					if ChidoriStarted then
						Stop = true
						Stop2 = true
						
						SoundService:StopSound("ChidoriSound",{
							Parent = Character.PrimaryPart,
							Volume = 1,
						},{},{
							Range = 50,
							Origin = Character.PrimaryPart.CFrame.p
						})
						StateService:SetState(Character,"CantRun",{
							LP = 65,
							Dur = 0.01,
						})
						StateService:SetState(Character,"UsingSkill",{
							LP = 50,
							Dur = 0.01,
						})
						StateShortCuts:BoostSpeeds(Character,{
							Prior = 55,
							Dur = 0.01,
							WalkSpeed = 16,
							RunSpeed = 25,
						})
						CooldownService:SetCooldown(Character,CharacterID,"FirstSkill",{
							Hold = false
						})
						CooldownService:SetCooldown(Character,CharacterID,"FirstSkill",{
							CD = SkillData.Cooldown
						})
						
						RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
							Task = "StopAnimation",
							AnimationData = {
								Name = "ChidoriRun",
								AnimationSpeed = 1,
								Weight = 1,
								FadeTime = 0.25,
								Looped = true,
							}
						})
						
						StateService:GetProfile(Character).StateData["RunID"].Name = "DfRun"
						
						SkillService:FireClientVFX(Player,CharacterID,"FirstSkill","ChidoriParticleOff",{
							Character = Character,
							UID = SkillUID
						})
					end
				end)
				
				local HitBox = HitBoxService:CRepeatCFrame({
					BreakOnHit = true,
					MultHit = false,
					OffsetPart = Character.PrimaryPart,
					HitOnce = true,
					Offset = CFrame.new(0,0,-4.5),
					Size = Vector3.new(4.5,4.5,6.5),
					Dur = SkillData.Length - 0.05,
					Visual = false,
					Caster = Character,
				})
				
				HitBox.OnHit:Connect(function(Victim)
					if not ChidoriStarted then return end
					
					task.delay(1, function()
						ChidoriStarted = false
						Stop = true
						Stop2 = true
					end)
					
					local HitResult = StateShortCuts:GetHitResult({
						Attacker = Character,
						Victim = Victim,
						HitData = {
							BlockBreak = true,
							CanPB = false,
						},
					})
					
					if HitResult == "Hit" or HitResult == "GuardBreak" then
						if HitResult == "GuardBreak" then
							CombatService:GuardBreak(Victim)
						else
							if Players:GetPlayerFromCharacter(Victim) then
								RemoteComs:FireClientEvent(Players:GetPlayerFromCharacter(Victim),{FunctionName = "AnimationService" },{
									Task = "PlayAnimation",
									AnimationData = {
										Name = "Stun1",
										AnimationSpeed = 1,
										Weight = 1,
										FadeTime = 0.25,
										Looped = false,
									}
								})
							else
								Victim.Humanoid.Animator:LoadAnimation(RS.Assets.Animations.Shared.Combat.Stun1):Play()
							end
						end
						
						DamageService:DamageEntities({
							Attacker = Character,
							Damage = SkillData.Damage,
							Victim = Victim
						})
						
						if Players:GetPlayerFromCharacter(Character) then
							PointsService:AddToCombo(Players:GetPlayerFromCharacter(Character),1)
							PointsService:AddPoints(Players:GetPlayerFromCharacter(Character),SkillData.Points)
						end
						
						SoundService:StopSound("ChidoriSound",{
							Parent = Character.PrimaryPart,
							Volume = 1,
						},{},{
							Range = 50,
							Origin = Character.PrimaryPart.CFrame.p
						})
						
						task.delay(0.4,function()
							SoundService:PlaySound("Chidori Explosion",{
								Parent = Character.PrimaryPart,
								Volume = 1,
							},{},{
								Range = 50,
								Origin = Character.PrimaryPart.CFrame.p
							})
						end)
						
						StateService:SetState(Character,"CantRun",{
							LP = 65,
							Dur = .5,
						})
						StateService:SetState(Character,"UsingSkill",{
							LP = 50,
							Dur = .5,
						})
						
						StateShortCuts:BoostSpeeds(Character,{
							Prior = 55,
							Dur = 0.01,
							WalkSpeed = 16,
							RunSpeed = 25,
						})
						
						StateService:GetProfile(Character).StateData["RunID"].Name = "DfRun"
						RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
							Task = "StopAnimation",
							AnimationData = {
								Name = "ChidoriRun",
								AnimationSpeed = 1,
								Weight = 1,
								FadeTime = 0.25,
								Looped = true,
							}
						})
						RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
							Task = "PlayAnimation",
							AnimationData = {
								Name = RS.Assets.Animations.Shared.Kakashi["Chidori Hit Anim"].Name,
								AnimationSpeed = 1,
								Weight = 2,
								FadeTime = 0.25,
								Looped = false,
							}
						})
						
						CooldownService:SetCooldown(Character,CharacterID,"FirstSkill",{
							Hold = false
						})
						
						CooldownService:SetCooldown(Character,CharacterID,"FirstSkill",{
							CD = SkillData.Cooldown
						})
						
						Victim.Humanoid.AutoRotate = false
						Character.Humanoid.AutoRotate = false
						Character.PrimaryPart.Anchored = true
						
						task.delay(0.8,function()
							if Victim and Victim.Humanoid then
								Victim.Humanoid.AutoRotate = true
							end
							
							Character.Humanoid.AutoRotate = true
							Character.PrimaryPart.Anchored = false
						end)
						
						Victim.PrimaryPart.CFrame = CFrame.new(Victim.PrimaryPart.CFrame.Position,Character.PrimaryPart.CFrame.Position)
						
						SkillService:FireClientVFX(Player,CharacterID,"FirstSkill","ChidoriHit",{
							Character = Character,
							DustPos = Character.HumanoidRootPart.CFrame * CFrame.new(0,-1,1) * CFrame.Angles(math.rad(90),0,0),
							Victim = Victim,
							UID = SkillUID
						})
						
						StateShortCuts:StunCharacter({
							Victim = Victim,
							Attacker = Character,
							WasAttack = true,
							Duration = 1.75,
							Priority = 50,
							AttackID = "KidSasukeChidori",
						})
						StateShortCuts:StunSpeed(Victim,{
							Prior = 55,
							Duration = 1.75,
							Speed = 0,
						})
					elseif HitResult == "PerfectBlock" then
						CombatService:PerfectBlock(Victim,Character,{
							CanTP = true,
							MaxDist = 16,
						})
						
						SoundService:StopSound("ChidoriSound",{
							Parent = Character.PrimaryPart,
							Volume = 1,
						},{},{
							Range = 50,
							Origin = Character.PrimaryPart.CFrame.p
						})
						StateService:SetState(Character,"CantRun",{
							LP = 65,
							Dur = 0.01,
						})
						StateService:SetState(Character,"UsingSkill",{
							LP = 50,
							Dur = 0.01,
						})
						StateShortCuts:BoostSpeeds(Character,{
							Prior = 55,
							Dur = 0.01,
							WalkSpeed = 16,
							RunSpeed = 25,
						})
						CooldownService:SetCooldown(Character,CharacterID,"FirstSkill",{
							Hold = false
						})
						CooldownService:SetCooldown(Character,CharacterID,"FirstSkill",{
							CD = SkillData.Cooldown
						})
						
						RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
							Task = "StopAnimation",
							AnimationData = {
								Name = "ChidoriRun",
								AnimationSpeed = 1,
								Weight = 1,
								FadeTime = 0.25,
								Looped = true,
							}
						})
						
						StateService:GetProfile(Character).StateData["RunID"].Name = "DfRun"
						
						SkillService:FireClientVFX(Player,CharacterID,"FirstSkill","ChidoriParticleOff",{
							Character = Character,
							UID = SkillUID
						})
					elseif HitResult == "IFrame" then
						ChidoriStarted = false
						SoundService:StopSound("ChidoriSound",{
							Parent = Character.PrimaryPart,
							Volume = 1,
						},{},{
							Range = 50,
							Origin = Character.PrimaryPart.CFrame.p
						})
						StateService:SetState(Character,"CantRun",{
							LP = 65,
							Dur = 0.01,
						})
						StateService:SetState(Character,"UsingSkill",{
							LP = 50,
							Dur = 0.01,
						})
						CooldownService:SetCooldown(Character,CharacterID,"FirstSkill",{
							Hold = false
						})
						
						RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
							Task = "StopAnimation",
							AnimationData = {
								Name = "ChidoriRun",
								AnimationSpeed = 1,
								Weight = 1,
								FadeTime = 0.25,
								Looped = true,
							}
						})
						CooldownService:SetCooldown(Character,CharacterID,"FirstSkill",{
							CD = SkillData.Cooldown
						})
						StateService:GetProfile(Character).StateData["RunID"].Name = "DfRun"
						SkillService:FireClientVFX(Player,CharacterID,"FirstSkill","ChidoriParticleOff",{
							Character = Character,
							UID = SkillUID
						})
					elseif HitResult:match("Counter") then
						local SkillService = require(SS.Modules.Services.SkillService)
						local DataForCounter = HitResult:split("_")
						SkillService:CastCounter({
							Character = Victim,
							Victim = Character,
							CharCounterID = DataForCounter[2],
							SkillName = DataForCounter[3],
							SkillSlot = DataForCounter[4],
						})
					end
				end)
				
				HitBox:Start()
			end)
		end,
	},
	["SecondSkill"] = {
		["Release"] = function(Character)
		end,
		["Hold"] = function(Character)
			local SkillUID = "SecondSkillHold"..Character.Name..CharacterID..HTTPService:GenerateGUID(false)

			local SkillService = require(SS.Modules.Services.SkillService)
			local StateService = require(RS.Modules.Services.StateService)

			local StateShortCuts = require(RS.Modules.Services.StateService.StateShortcuts)
			local SoundService = require(RS.Modules.Services.SoundService)

			local HitBoxService = require(SS.Modules.Services.HitBoxService)
			local RemoteComs = require(RS.Modules.Utility.RemoteNetwork)
			local Util = require(RS.Modules.Utility.Util)

			local CooldownService = require(SS.Modules.Services.CooldownService)
			local PointsService = require(SS.Modules.Services.PointsService)
			local DamageService = require(SS.Modules.Services.DamageService)

			local SkillData = require(SS.Modules.MetaData.CharacterData)[CharacterID]["SkillData"]["SecondSkill"]
			
			if not CooldownService:CheckCooldown(Character,CharacterID,"SecondSkill") then return end
			if StateService:GetState(Character,"Stunned") then return end
			if StateService:GetState(Character,"UsingSkill") then return end
			if StateService:GetState(Character,"Swing") then return end
			
			local Player = Players:GetPlayerFromCharacter(Character)

			CooldownService:SetCooldown(Character,CharacterID,"SecondSkill",{
				Hold = true
			})

			local CombatService = require(SS.Modules.Services.CombatService)

			StateService:SetState(Character,"UsingSkill",{
				LP = 55,
				Dur = 10,
			})
			StateService:SetState(Character,"CantRun",{
				LP = 55,
				Dur = 10,
			})
			StateService:SetState(Character,"CantM1",{
				LP = 55,
				Dur = 10,
			})
			
			local CheckFlag = false
			local HyperArmored = false
			
			SoundService:PlaySound("HandsignSound",{
				Parent = Character.PrimaryPart,
				Volume = 1,
			},{},{
				Range = 50,
				Origin = Character.PrimaryPart.CFrame.p
			})
			
			RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
				Task = "PlayAnimation",
				AnimationData = {
					Name = "Fireball",
					AnimationSpeed = 1,
					Weight = 3.5,
					FadeTime = 0.25,
					Looped = false,
				}
			})
			
			task.spawn(function()
				while not CheckFlag do
					if StateService:GetState(Character,"Stunned") then
						HyperArmored = true
						RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
							Task = "StopAnimation",
							AnimationData = {
								Name = "Fireball",
								AnimationSpeed = 1,
								Weight = 3.5,
								FadeTime = 0.25,
								Looped = false,
							}
						})
						SoundService:StopSound("HandsignSound",{
							Parent = Character.PrimaryPart,
							Volume = 1,
						},{},{
							Range = 50,
							Origin = Character.PrimaryPart.CFrame.p
						})
						StateService:SetState(Character,"UsingSkill",{
							LP = 55,
							Dur = 2,
						})
						StateService:SetState(Character,"CantRun",{
							LP = 55,
							Dur = 0.1,
						})
						StateService:SetState(Character,"CantM1",{
							LP = 55,
							Dur = 1,
						})
						CooldownService:SetCooldown(Character,CharacterID,"SecondSkill",{
							Hold = false
						})
						CooldownService:SetCooldown(Character,CharacterID,"SecondSkill",{
							CD = SkillData.Cooldown
						})
						break
					end
					RunService.Heartbeat:Wait()
				end
			end)
			Util:SignalMarker(RS.Assets.Animations.Shared.Kakashi.Fireball,"CheckHyperArmor"):Connect(function()
				CheckFlag = true
			end)
			
			Util:SignalMarker(RS.Assets.Animations.Shared.Kakashi.Fireball,"Release"):Connect(function()
				if HyperArmored then return end
				StateService:SetState(Character,"UsingSkill",{
					LP = 55,
					Dur = 1,
				})
				StateService:SetState(Character,"CantRun",{
					LP = 55,
					Dur = 0.1,
				})
				StateService:SetState(Character,"CantM1",{
					LP = 55,
					Dur = 1,
				})
				
				CooldownService:SetCooldown(Character,CharacterID,"SecondSkill",{
					Hold = false
				})
				
				CooldownService:SetCooldown(Character,CharacterID,"SecondSkill",{
					CD = SkillData.Cooldown
				})
				
				local MouseHit = SkillService:GetMouse(Players:GetPlayerFromCharacter(Character))

				local StartPoint = Character.PrimaryPart.CFrame * CFrame.new(0,2,-2)
				local Goal = StartPoint * CFrame.new(0,0,-200)

				local Direction = (Goal.p - StartPoint.p).Unit
				local Velocity = SkillData.FireballSpeed
				local Duration = SkillData.Duration
				local Acceleration = SkillData.FireballAcceleration
				local FireballHitBox = HitBoxService:AoeProjectile()
				local Points = FireballHitBox:GetRayCastSquarePoints(StartPoint,6.5,6.5)
				
				FireballHitBox.HitTask:Connect(function(HitTable)
					SkillService:FireClientVFX(Player,CharacterID,"SecondSkill","FireballHit",{
						Character = Character,
						UID = SkillUID
					})
					
					local HitParent = HitTable.HitInstance.Parent
					local Victim
					
					if not (HitParent:FindFirstChild("IsShadowClone") and HitParent:FindFirstChild("Brain") and HitParent:FindFirstChild("Brain").Caster.Value == Character ) and HitParent:FindFirstChild("Humanoid") and HitParent:FindFirstChild("Humanoid").Health > 0 and HitParent:IsDescendantOf(workspace.World.Entities) then
						Victim = HitParent
						local HitResult = StateShortCuts:GetHitAoeResult({
							Attacker = Character,
							Victim = Victim,
							Origin	= HitTable.Position,
							HitData = {
								BlockBreak = false,
								CanPB = false,
							},
						})
						
						if HitResult == "Hit" then
							DamageService:DamageEntities({
								Attacker = Character,
								Damage = SkillData.Damage,
								Victim = Victim,
							})
							
							if Players:GetPlayerFromCharacter(Victim) == nil and Victim and Players:GetPlayerFromCharacter(Character) then
								if Victim.PrimaryPart and Victim.PrimaryPart.Anchored == false then
									for _,v in ipairs(Victim:GetChildren()) do
										if v:IsA("BasePart") and v.Anchored == false then
											v:SetNetworkOwner(Players:GetPlayerFromCharacter(Character))
										end
									end
								end
							end
							
							local Velo = Instance.new("BodyVelocity")
							Velo.Velocity = Vector3.new(0,10,0) + (Victim.PrimaryPart.Position - HitTable.Position).Unit * 80
							Velo.MaxForce = Vector3.new(10e4,10e4,10e4)
							Velo.Parent = Victim.PrimaryPart
							Debris:AddItem(Velo,.15)
							
							StateShortCuts:StunCharacter({
								Victim = Victim,
								Attacker = Character,
								WasAttack = true,
								Duration = SkillData.Stun,
								Priority = 55,
								AttackID = "KidSasukeFireBall",
							})
							
							if Players:GetPlayerFromCharacter(Character) then
								PointsService:AddPoints(Players:GetPlayerFromCharacter(Character),SkillData.Points)
								PointsService:AddToCombo(Players:GetPlayerFromCharacter(Character),1)
							end
							
							if Players:GetPlayerFromCharacter(Victim) then
								RemoteComs:FireClientEvent(Players:GetPlayerFromCharacter(Victim),{FunctionName = "AnimationService" },{
									Task = "PlayAnimation",
									AnimationData = {
										Name = "Stun1",
										AnimationSpeed = 1,
										Weight = 1,
										FadeTime = 0.25,
										Looped = false,
									}
								})
							else
								Victim.Humanoid.Animator:LoadAnimation(RS.Assets.Animations.Shared.Combat["Stun1"]):Play()
							end
						elseif HitResult == "Blocking" then
							RemoteComs:FireAllClientsEvent({FunctionName = "VFX"},{FName = "RegBlockEffect",FData = {
								Character = Character,
								Victim = Victim,
							}})
							
							SoundService:PlaySound("CombatBlockhit",{
								Parent = Victim.PrimaryPart,
								Volume = 0.75,
							},{},{
								Range = 25,
								Origin = Victim.PrimaryPart.CFrame.p
							})
						elseif HitResult == "PerfectBlock" then
							CombatService:PerfectBlock(Victim,Character,{
								CanTP = true,
								MaxDist = 16,
							})
						elseif HitResult:match("Counter") then
							local SkillService = require(SS.Modules.Services.SkillService)
							local DataForCounter = HitResult:split("_")
							SkillService:CastCounter({
								Character = Victim,
								Victim = Character,
								CharCounterID = DataForCounter[2],
								SkillName = DataForCounter[3],
								SkillSlot = DataForCounter[4],
							})
						end
					end
					
					local HitPosition = HitTable.Position
					
					SoundService:PlaySoundAt("Explosion",{
						Parent = Character.PrimaryPart,
						Volume = 1,
					},{
						CFrame = CFrame.new(Character.PrimaryPart.CFrame.p)
					},{
						Range = 50,
						Origin = Character.PrimaryPart.CFrame.p
					})
					
					local HitBox = HitBoxService:CRepeatCFrame({
						BreakOnHit = false,
						MultHit = true,
						CFrame = CFrame.new(HitTable.Position),
						HitOnce = true,
						Offset = CFrame.new(0,0,-5.5),
						Size = Vector3.new(20,20,20),
						Dur = 0.01,
						Visual = true,
						Caster = Character,
					})

					HitBox.OnHit:Connect(function(AoeVictim)
						if Victim ~= AoeVictim then
							local HitResult = StateShortCuts:GetHitAoeResult({
								Attacker = Character,
								Victim = AoeVictim,
								Origin	= HitTable.Position,
								HitData = {
									BlockBreak = false,
									CanPB = false,
								},
							})
							
							if HitResult == "Hit" then
								if Players:GetPlayerFromCharacter(AoeVictim) == nil and AoeVictim and Players:GetPlayerFromCharacter(Character) then
									if AoeVictim.PrimaryPart and AoeVictim.PrimaryPart.Anchored == false then
										for _,v in ipairs(AoeVictim:GetChildren()) do
											if v:IsA("BasePart") and v.Anchored == false then
												v:SetNetworkOwner(Players:GetPlayerFromCharacter(Character))
											end
										end
									end
								end

								local Velo = Instance.new("BodyVelocity")
								Velo.Velocity = Vector3.new(0,10,0) + (AoeVictim.PrimaryPart.Position - HitPosition).Unit * 80
								Velo.MaxForce = Vector3.new(10e4,10e4,10e4)
								Velo.Parent = AoeVictim.PrimaryPart
								Debris:AddItem(Velo,.15)
								
								DamageService:DamageEntities({
									Attacker = Character,
									Damage = SkillData.Damage,
									Victim = AoeVictim,
								})
								
								StateShortCuts:StunCharacter({
									Victim = AoeVictim,
									Attacker = Character,
									WasAttack = true,
									Duration = SkillData.Stun/2,
									Priority = 55,
									AttackID = "KidSasukeFireBall",
								})
								
								if Players:GetPlayerFromCharacter(Character) then
									PointsService:AddPoints(Players:GetPlayerFromCharacter(Character),SkillData.Points/4)
									PointsService:AddToCombo(Players:GetPlayerFromCharacter(Character),1)
								end
								
								if Players:GetPlayerFromCharacter(AoeVictim) then
									RemoteComs:FireClientEvent(Players:GetPlayerFromCharacter(AoeVictim),{FunctionName = "AnimationService" },{
										Task = "PlayAnimation",
										AnimationData = {
											Name = "Stun1",
											AnimationSpeed = 1,
											Weight = 1,
											FadeTime = 0.25,
											Looped = false,
										}
									})
								else
									AoeVictim.Humanoid.Animator:LoadAnimation(RS.Assets.Animations.Shared.Combat["Stun1"]):Play()
								end
							elseif HitResult == "Blocking" then
								RemoteComs:FireAllClientsEvent({FunctionName = "VFX"},{FName = "RegBlockEffect",FData = {
									Character = Character,
									Victim = AoeVictim,
								}})
								
								if Victim and Victim.PrimaryPart then
									SoundService:PlaySound("CombatBlockhit",{
										Parent = Victim.PrimaryPart,
										Volume = 0.75,
									},{},{
										Range = 25,
										Origin = Victim.PrimaryPart.CFrame.p
									})
								end
							elseif HitResult == "PerfectBlock" then
								CombatService:PerfectBlock(AoeVictim,Character,{
									CanTP = true,
									MaxDist = 16,
								})
							elseif HitResult:match("Counter") then
								local SkillService = require(SS.Modules.Services.SkillService)
								local DataForCounter = HitResult:split("_")
								SkillService:CastCounter({
									Character = Victim,
									Victim = Character,
									CharCounterID = DataForCounter[2],
									SkillName = DataForCounter[3],
									SkillSlot = DataForCounter[4],
								})
							end
						end
					end)
					HitBox:Start()
				end)
				
				SkillService:FireClientVFX(Player,CharacterID,"SecondSkill","FireballCast",{
					Character = Character,
					StartPoint = StartPoint,
					Acceleration = Acceleration,
					Velocity = Velocity,
					Direction = Direction,
					Duration = SkillData.Duration,
					UID = SkillUID
				})
				
				FireballHitBox:StartProjectile({
					BreakOnHit = true,
					Points = Points,
					Dur = SkillData.Duration,
					Direction = Direction,
					Velocity = Velocity,
					VisualizeHitBox = false,
					Iterations = 200,
					IgnoreList = {workspace.World.Effects,Character},
					Acceleration = Acceleration,
				})
				
				SoundService:PlaySoundAt("Fireball",{
					Parent = Character.PrimaryPart,
					Volume = 1,
				},{
					CFrame = CFrame.new(Character.PrimaryPart.CFrame.p)
				},{
					Range = 50,
					Origin = Character.PrimaryPart.CFrame.p
				})
			end)
		end,
	},
	["ThirdSkill"] = {
		["Release"] = function(Character)
		end,
		["Hold"] = function(Character)
			local SkillUID = "ThirdSkillHold"..Character.Name..CharacterID..HTTPService:GenerateGUID(false)

			local SkillService = require(SS.Modules.Services.SkillService)
			local StateService = require(RS.Modules.Services.StateService)

			local StateShortCuts = require(RS.Modules.Services.StateService.StateShortcuts)
			local SoundService = require(RS.Modules.Services.SoundService)

			local HitBoxService = require(SS.Modules.Services.HitBoxService)
			local RemoteComs = require(RS.Modules.Utility.RemoteNetwork)
			local Util = require(RS.Modules.Utility.Util)

			local CooldownService = require(SS.Modules.Services.CooldownService)
			local PointsService = require(SS.Modules.Services.PointsService)
			local DamageService = require(SS.Modules.Services.DamageService)

			local SkillData = require(SS.Modules.MetaData.CharacterData)[CharacterID]["SkillData"]["ThirdSkill"]
			
			if not CooldownService:CheckCooldown(Character,CharacterID,"ThirdSkill") then return end
			if StateService:GetState(Character,"Stunned") then return end
			if StateService:GetState(Character,"UsingSkill") then return end
			if StateService:GetState(Character,"Swing") then return end
			
			local Player = Players:GetPlayerFromCharacter(Character)
			
			local CombatService = require(SS.Modules.Services.CombatService)
			
			CooldownService:SetCooldown(Character,CharacterID,"ThirdSkill",{
				Hold = true
			})
			
			StateService:SetState(Character,"UsingSkill",{
				LP = 65,
				Dur = SkillData.Duration,
			})
			StateService:SetState(Character,"CantRun",{
				LP = 65,
				Dur = SkillData.Duration,
			})
			StateService:SetState(Character,"CantM1",{
				LP = 65,
				Dur = SkillData.Duration,
			})
			
			StateShortCuts:StunSpeed(Character,{
				Prior = 65,
				Duration = SkillData.Duration,
				Speed = 1,
			})
			StateShortCuts:CounterTimeFrame({
				Caster = Character,
				
				CounterID = "KidSasuke_LionCombo_ThirdSkill",
				Range = SkillData.Range,
				Projectiles = false,
				ProjectilesOnly = false,
				
				Priortiy = 55,
				Duration = SkillData.Duration,
			})

			RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
				Task = "PlayAnimation",
				AnimationData = {
					Name = RS.Assets.Animations.Shared.Sasuke["CounterPose"].Name,
					AnimationSpeed = 1,
					Weight = 3.5,
					FadeTime = 0.25,
					Looped = true,
				}
			})
			
			task.delay(SkillData.Duration, function()
				if not StateService:GetState(Character,"UsingSkill") then
					StateService:SetState(Character,"CantRun",{
						LP = 65,
						Dur = SkillData.EndLag,
					})
					StateService:SetState(Character,"CantM1",{
						LP = 65,
						Dur = SkillData.EndLag,
					})
					
					StateShortCuts:StunSpeed(Character,{
						Prior = 65,
						Duration = SkillData.EndLag,
						Speed = 1,
					})
				end
				
				CooldownService:SetCooldown(Character,CharacterID,"ThirdSkill",{
					Hold = false
				})
				CooldownService:SetCooldown(Character,CharacterID,"ThirdSkill",{
					CD = SkillData.Cooldown
				})
				RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
					Task = "StopAnimation",
					AnimationData = {
						Name = RS.Assets.Animations.Shared.Sasuke["CounterPose"].Name,
						AnimationSpeed = 1,
						Weight = 3.5,
						FadeTime = 0.25,
						Looped = true,
					}
				})
			end)
		end,
		["LionCombo"] = function(Character,Victim)
			if Victim:FindFirstChild("Brain") then Victim:Destroy() return end
			
			local SkillUID = "LionCombo"..Character.Name..CharacterID..HTTPService:GenerateGUID(false)

			local SkillService = require(SS.Modules.Services.SkillService)
			local StateService = require(RS.Modules.Services.StateService)

			local StateShortCuts = require(RS.Modules.Services.StateService.StateShortcuts)
			local SoundService = require(RS.Modules.Services.SoundService)

			local HitBoxService = require(SS.Modules.Services.HitBoxService)
			local RemoteComs = require(RS.Modules.Utility.RemoteNetwork)
			local Util = require(RS.Modules.Utility.Util)

			local CooldownService = require(SS.Modules.Services.CooldownService)
			local PointsService = require(SS.Modules.Services.PointsService)
			local DamageService = require(SS.Modules.Services.DamageService)

			local SkillData = require(SS.Modules.MetaData.CharacterData)[CharacterID]["SkillData"]["ThirdSkill"]
			
			local Player = Players:GetPlayerFromCharacter(Character)
			
			local CombatService = require(SS.Modules.Services.CombatService)
			
			StateShortCuts:CounterTimeFrame({
				Caster = Character,

				CounterID = "None",
				Range = -1,
				Projectiles = false,
				ProjectilesOnly = false,

				Priortiy = 55,
				Duration = 0.01,
			})	
			StateService:SetState(Character,"UsingSkill",{
				LP = 66,
				Dur = 10,
			})
			StateService:SetState(Character,"CantRun",{
				LP = 66,
				Dur = 10,
			})
			StateService:SetState(Character,"CantM1",{
				LP = 65,
				Dur = 10,
			})
			StateShortCuts:StunSpeed(Character,{
				Prior = 65,
				Duration = 10,
				Speed = 1,
			})
			
			StateService:SetState(Victim,"CantRun",{
				LP = 66,
				Dur = 10,
			})
			StateService:SetState(Victim,"CantM1",{
				LP = 65,
				Dur = 10,
			})
			StateService:SetState(Victim,"Stunned",{
				LP = 65,
				Dur = 10,
			})
			StateShortCuts:StunSpeed(Victim,{
				Prior = 65,
				Duration = 10,
				Speed = 1,
			})
			
			Character.PrimaryPart.AssemblyLinearVelocity = Vector3.new(0,0,0)
			Character.PrimaryPart.AssemblyAngularVelocity = Vector3.new(0,0,0)
			Character.PrimaryPart.Anchored = true
			Character.Humanoid.AutoRotate = false
			
			Victim.PrimaryPart.AssemblyLinearVelocity = Vector3.new(0,0,0)
			Victim.PrimaryPart.AssemblyAngularVelocity = Vector3.new(0,0,0)
			Victim.PrimaryPart.Anchored = true
			Victim.Humanoid.AutoRotate = false
			Victim.PrimaryPart.CFrame = CFrame.new(Victim.PrimaryPart.CFrame.p,Character.PrimaryPart.CFrame.p)
			
			local TeleCFrame = CFrame.lookAt((Victim.PrimaryPart.CFrame * CFrame.new(0,0,4.5)).Position,Victim.PrimaryPart.CFrame.Position)
			
			RemoteComs:FireAllClientsEvent({FunctionName = "VFX"},{FName = "Sub",FData = {
				Pos = CFrame.new(Character.PrimaryPart.CFrame.Position)
			}})
			SoundService:PlaySound("PoofSound",{
				Parent = Victim.PrimaryPart,
				Volume = 1,
			},{
				CFrame = CFrame.new(Character.PrimaryPart.CFrame.Position)
			},{
				Range = 25,
				Origin = Victim.PrimaryPart.CFrame.p
			})
			
			Character.PrimaryPart.CFrame = TeleCFrame
			
			local VictimTiming = (66/30) - (13/30)
			local AttackerTiming = (61/30) - (34/30)
			
			if Players:GetPlayerFromCharacter(Victim) then
				RemoteComs:FireClientEvent(Players:GetPlayerFromCharacter(Victim),{FunctionName = "AnimationService" },{
					Task = "PlayAnimation",
					AnimationData = {
						Name = "LionCounterVic",
						AnimationSpeed = SkillData.SpeedFactor,
						Weight = 3,
						FadeTime = 0.25,
						Looped = false,
					}
				})
			else
				local A = Victim.Humanoid.Animator:LoadAnimation(RS.Assets.Animations.Shared.Sasuke.LionCounterVic)
				A:Play()
				A:AdjustSpeed(SkillData.SpeedFactor)
			end
			
			RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
				Task = "PlayAnimation",
				AnimationData = {
					Name = "LionCounterAttacker",
					AnimationSpeed = SkillData.SpeedFactor,
					Weight = 3,
					FadeTime = 0.25,
					Looped = false,
				}
			})
			
			Util:SignalMarker(RS.Assets.Animations.Shared.Sasuke.LionCounterVic,"StartUp",SkillData.SpeedFactor):Connect(function()
				local Tween = TweenService:Create(Victim.PrimaryPart,TweenInfo.new(VictimTiming,Enum.EasingStyle.Cubic,Enum.EasingDirection.Out),{
					CFrame = Victim.PrimaryPart.CFrame * CFrame.new(0,25,0)
				})
				Tween:Play()
				Tween:Play()
			end)
			Util:SignalMarker(RS.Assets.Animations.Shared.Sasuke.LionCounterAttacker,"StartUp",SkillData.SpeedFactor):Connect(function()
				local Tween = TweenService:Create(Character.PrimaryPart,TweenInfo.new(AttackerTiming,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut),{
					CFrame = Character.PrimaryPart.CFrame * CFrame.new(0,25,0)
				})
				Tween:Play()
				Tween:Play()
			end)
			
			Util:SignalMarker(RS.Assets.Animations.Shared.Sasuke.LionCounterAttacker,"Free",SkillData.SpeedFactor):Connect(function()
				Character.PrimaryPart.Anchored = false
				Character.Humanoid.AutoRotate = true
				
				StateService:SetState(Character,"UsingSkill",{
					LP = 67,
					Dur = 0.2,
				})
				StateService:SetState(Character,"CantRun",{
					LP = 67,
					Dur = 0.2,
				})
				StateService:SetState(Character,"CantM1",{
					LP = 66,
					Dur = 0.2,
				})
				
				StateShortCuts:StunSpeed(Character,{
					Prior = 66,
					Duration = 0.01,
					Speed = 14,
				})
			end)
			
			Util:SignalMarker(RS.Assets.Animations.Shared.Sasuke.LionCounterAttacker,"DamageTick",SkillData.SpeedFactor):Connect(function()
				DamageService:DamageEntities({
					Attacker = Character,
					Damage = SkillData.Damage/2,
					Victim = Victim,
				})
				PointsService:AddPoints(Player,SkillData.Points/2)
				PointsService:AddToCombo(Player,1)
				RemoteComs:FireAllClientsEvent({FunctionName = "VFX"},{FName = "RegM1Hit",FData = {
					Character = Character,
					Victim = Victim,
				}})
				SoundService:PlaySound("CombatHit",{
					Parent = Victim.PrimaryPart,
					Volume = 1,
				},{},{
					Range = 100,
					Origin = Victim.PrimaryPart.CFrame.p
				})
			end)
			Util:SignalMarker(RS.Assets.Animations.Shared.Sasuke.LionCounterAttacker,"DamageTick2",SkillData.SpeedFactor):Connect(function()
				DamageService:DamageEntities({
					Attacker = Character,
					Damage = SkillData.Damage/2,
					Victim = Victim,
				})
				PointsService:AddPoints(Player,SkillData.Points/2)
				PointsService:AddToCombo(Player,1)
				RemoteComs:FireAllClientsEvent({FunctionName = "VFX"},{FName = "RegM1Hit",FData = {
					Character = Character,
					Victim = Victim,
				}})
				SoundService:PlaySound("CombatHit",{
					Parent = Victim.PrimaryPart,
					Volume = 1,
				},{},{
					Range = 100,
					Origin = Victim.PrimaryPart.CFrame.p
				})
			end)
			
			Util:SignalMarker(RS.Assets.Animations.Shared.Sasuke.LionCounterVic,"Downslam",SkillData.SpeedFactor):Connect(function()
				local DownSlam = require(SS.Modules.Services.DownSlamService).new({
					EndStun = 1.25,
					MaxTime = 5,
					MaxDist = 1000,
					Character = Victim,
					Speed = 300,
					Connect = true,
					StartCFrame = Victim.PrimaryPart.CFrame * CFrame.new(0,0.005,0),
					Vector = ((Victim.PrimaryPart.CFrame * CFrame.new(0,-300,0)).p - Victim.PrimaryPart.CFrame.p).Unit
				})
				DownSlam.HitTask:Connect(function()
					Victim.Humanoid.AutoRotate = true
					StateService:SetState(Victim,"CantRun",{
						LP = 67,
						Dur = SkillData.Stun,
					})
					StateService:SetState(Victim,"CantM1",{
						LP = 66,
						Dur = SkillData.Stun,
					})
					StateShortCuts:StunCharacter({
						Victim = Victim,
						Attacker = Character,
						WasAttack = true,
						Duration = SkillData.Stun,
						Priority = 66,
						AttackID = "KidSasukeLionCombo",
					})
					StateShortCuts:StunSpeed(Victim,{
						Prior = 66,
						Duration = SkillData.Stun,
						Speed = 1,
					})
				end)
				DownSlam:Start()
			end)
		end,
	},
	["FourthSkill"] = {
		["Release"] = function(Character)
		end,
		["Hold"] = function(Character)
			local SkillUID = "FourthSkillRelease"..Character.Name..CharacterID..HTTPService:GenerateGUID(false)

			local SkillService = require(SS.Modules.Services.SkillService)
			local StateService = require(RS.Modules.Services.StateService)

			local StateShortCuts = require(RS.Modules.Services.StateService.StateShortcuts)
			local SoundService = require(RS.Modules.Services.SoundService)

			local HitBoxService = require(SS.Modules.Services.HitBoxService)
			local RemoteComs = require(RS.Modules.Utility.RemoteNetwork)
			local Util = require(RS.Modules.Utility.Util)

			local CooldownService = require(SS.Modules.Services.CooldownService)
			local PointsService = require(SS.Modules.Services.PointsService)
			local DamageService = require(SS.Modules.Services.DamageService)
			
			local CombatService = require(SS.Modules.Services.CombatService)
			
			local SkillData = require(SS.Modules.MetaData.CharacterData)[CharacterID]["SkillData"]["FourthSkill"]
			
			if not CooldownService:CheckCooldown(Character,CharacterID,"FourthSkill") then return end
			if StateService:GetState(Character,"Stunned") then return end
			if StateService:GetState(Character,"UsingSkill") then return end
			if StateService:GetState(Character,"Swing") then return end
			
			local Player = Players:GetPlayerFromCharacter(Character)
			
			StateService:SetState(Character,"UsingSkill",{
				LP = 55,
				Dur = 10,
			})
			
			Character.Humanoid.AutoRotate = false
			
			local Stop = false
			
			RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
				Task = "PlayAnimation",
				AnimationData = {
					Name = "Demon Shuriken",
					AnimationSpeed = 1,
					Weight = 3.5,
					FadeTime = 0.25,
					Looped = false,
				}
			})
			
			task.spawn(function()
				while not Stop do
					if StateService:GetState(Character,"Stunned") then
						Stop = true
						Character.Humanoid.AutoRotate = true
						
						RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
							Task = "StopAnimation",
							AnimationData = {
								Name = "Demon Shuriken",
								AnimationSpeed = 1,
								Weight = 3.5,
								FadeTime = 0.25,
								Looped = false,
							}
						})
						
						StateService:SetState(Character,"UsingSkill",{
							LP = 55,
							Dur = 0.01,
						})
						
						CooldownService:SetCooldown(Character,CharacterID,"FourthSkill",{
							CD = SkillData.Cooldown
						})
						break
					end
					RunService.Heartbeat:Wait()
				end
			end)
			
			task.spawn(function()
				Util:SignalMarker(RS.Assets.Animations.Shared.Sasuke["Demon Shuriken"],"Throw"):Wait()
				
				if Stop then return end
				Stop = true
				
				local MouseHit = SkillService:GetMouse(Players:GetPlayerFromCharacter(Character))
				Character.PrimaryPart.CFrame = CFrame.lookAt(Character.PrimaryPart.Position, MouseHit.p)
				
				local BP = Instance.new("BodyPosition")
				BP.Position = (Character.PrimaryPart.CFrame * CFrame.new(0,3,20)).p
				BP.MaxForce = Vector3.new(5e4,25e4,5e4)
				BP.Parent = Character.PrimaryPart
				Debris:AddItem(BP,.5)
				
				local StartPoint = Character.PrimaryPart.CFrame * CFrame.new(0,0,-3.5)  --(CFrame.new(Character["Right Arm"].CFrame.p) * CFrame.new(0,0.5,0))
				local End = MouseHit
				
				local Goal = StartPoint * CFrame.new(0,0,-200)
				local Direction = (End.p - StartPoint.p).Unit
				local Velocity = SkillData.ShurikenSpeed
				local Duration = SkillData.Duration
				local ShurikeHitBox = HitBoxService:AoeProjectile()
				local Points = ShurikeHitBox:GetRayCastSquarePoints(StartPoint,4.5,4.5)
				
				local function CloneAttack(Position,Target,Dt)
					Position = Position + Vector3.new(0,3,0)
					
					local Goal2 = CFrame.new(Target.PrimaryPart.Position)
					
					local StartPoint2 = CFrame.lookAt(Position, Goal2.p)
					local Direction2 = (Goal2.p - StartPoint2.p).Unit
					local Velocity2 = SkillData.KunaiSpeed
					local Duration2 = SkillData.KDuration
					local KunaiHitBox = HitBoxService:AoeProjectile()
					local Points2 = KunaiHitBox:GetRayCastSquarePoints(StartPoint2,1,1)
					
					task.spawn(function()
						KunaiHitBox.HitTask:Connect(function(HitTable)
							local HitParent = HitTable.HitInstance.Parent
							local Victim
							
							if not (HitParent:FindFirstChild("IsShadowClone") and HitParent:FindFirstChild("Brain") and HitParent:FindFirstChild("Brain").Caster.Value == Character ) and HitParent:FindFirstChild("Humanoid") and HitParent:FindFirstChild("Humanoid").Health > 0 and HitParent:IsDescendantOf(workspace.World.Entities) then
								Victim = HitParent
								
								local HitResult = StateShortCuts:GetHitAoeResult({
									Attacker = Character,
									Victim = Victim,
									Origin	= HitTable.Position,
									HitData = {
										BlockBreak = false,
										CanPB = true,
									},
								})
								
								if HitResult == "Hit" then
									DamageService:DamageEntities({
										Attacker = Character,
										Damage = SkillData.KDamage,
										Victim = Victim,
									})
									
									SoundService:PlaySound("KakaShuriImpact",{
										Parent = Victim.PrimaryPart,
										Volume = 0.75,
									},{},{
										Range = 25,
										Origin = Victim.PrimaryPart.CFrame.p
									})
									
									StateShortCuts:StunCharacter({
										Victim = Victim,
										Attacker = Character,
										WasAttack = true,
										Duration = SkillData.Stun,
										Priority = 55,
										AttackID = "KidSasukeFireBall",
									})

									if Players:GetPlayerFromCharacter(Character) then
										PointsService:AddPoints(Players:GetPlayerFromCharacter(Character),SkillData.Points)
										PointsService:AddToCombo(Players:GetPlayerFromCharacter(Character),1)
									end

									if Players:GetPlayerFromCharacter(Victim) then
										RemoteComs:FireClientEvent(Players:GetPlayerFromCharacter(Victim),{FunctionName = "AnimationService" },{
											Task = "PlayAnimation",
											AnimationData = {
												Name = "Stun1",
												AnimationSpeed = 1,
												Weight = 1,
												FadeTime = 0.25,
												Looped = false,
											}
										})
									else
										Victim.Humanoid.Animator:LoadAnimation(RS.Assets.Animations.Shared.Combat["Stun1"]):Play()
									end
								elseif HitResult == "Blocking" then
									RemoteComs:FireAllClientsEvent({FunctionName = "VFX"},{FName = "RegBlockEffect",FData = {
										Character = Character,
										Victim = Victim,
									}})
									
									SoundService:PlaySound("CombatBlockhit",{
										Parent = Victim.PrimaryPart,
										Volume = 0.75,
									},{},{
										Range = 25,
										Origin = Victim.PrimaryPart.CFrame.p
									})
								elseif HitResult == "PerfectBlock" then
									CombatService:PerfectBlock(Victim,Character,{
										CanTP = true,
										MaxDist = 16,
									})
								elseif HitResult:match("Counter") then
									local SkillService = require(SS.Modules.Services.SkillService)
									local DataForCounter = HitResult:split("_")
									SkillService:CastCounter({
										Character = Victim,
										Victim = Character,
										CharCounterID = DataForCounter[2],
										SkillName = DataForCounter[3],
										SkillSlot = DataForCounter[4],
									})
								end
							end
							
							SkillService:FireClientVFX(Player,CharacterID,"FourthSkill","Demon Shuriken KunaiD",{
								Character = Character,
								UID = SkillUID,
							})
						end)
					end)
					
					task.spawn(function()
						SkillService:FireClientVFX(Player,CharacterID,"FourthSkill","Demon Shuriken Kunai",{
							Character = Character,
							UID = SkillUID,
							Speed = Velocity2,
							Direction = Direction2,
							Dur = Duration2,
							Pos = StartPoint2,
						})
						Util:SignalMarker(RS.Assets.Animations.Shared.Sasuke.CloneKunaiThrow,"Throw"):Wait()
						KunaiHitBox:StartProjectile({
							BreakOnHit = true,
							BreakOnMap = true,
							Points = Points2,
							Dur = SkillData.KDuration,
							Direction = Direction2,
							Velocity = Velocity2,
							VisualizeHitBox = false,
							Iterations = 200,
							IgnoreList = {workspace.World.Effects,Character},
							Acceleration = 0
						})	
						SoundService:PlaySound("KakaShuriThrow",{
							Parent = Character.PrimaryPart,
							Volume = 1,
						},{},{
							Range = 25,
							Origin = Character.PrimaryPart.CFrame.p
						})
					end)
				end
				
				local HitVictim;
				local ProjectileBreak = false
				
				task.spawn(function()
					ShurikeHitBox.HitTask:Connect(function(HitTable)
						local HitParent = HitTable.HitInstance.Parent
						local Victim
						
						if not(HitParent:FindFirstChild("IsShadowClone") and HitParent:FindFirstChild("Brain") and HitParent:FindFirstChild("Brain").Caster.Value == Character ) and HitParent:FindFirstChild("Humanoid") and HitParent:FindFirstChild("Humanoid").Health > 0 and HitParent:IsDescendantOf(workspace.World.Entities) then
							Victim = HitParent
							
							local HitResult = StateShortCuts:GetHitAoeResult({
								Attacker = Character,
								Victim = Victim,
								Origin = HitTable.Position,
								HitData = {
									BlockBreak = false,
									CanPB = true,
								},
							})
							
							if ProjectileBreak == false then
								ProjectileBreak = true
								SkillService:FireClientVFX(Player,CharacterID,"FourthSkill","Demon Shuriken Destory",{
									Character = Character,
									UID = SkillUID,
								})
								
								if Victim then
									local Position = Victim.PrimaryPart.Position + (Character.PrimaryPart.CFrame.LookVector * 10)
									CloneAttack(Position,Victim,Duration)
								end
							end
							
							if HitResult == "Hit" then
								HitVictim = Victim
								
								SoundService:PlaySound("KakaShuriImpact",{
									Parent = Victim.PrimaryPart,
									Volume = 0.75,
								},{},{
									Range = 25,
									Origin = Victim.PrimaryPart.CFrame.p
								})
								
								DamageService:DamageEntities({
									Attacker = Character,
									Damage = SkillData.Damage,
									Victim = Victim,
								})

								StateShortCuts:StunCharacter({
									Victim = Victim,
									Attacker = Character,
									WasAttack = true,
									Duration = SkillData.Stun,
									Priority = 55,
									AttackID = "KidSasukeFireBall",
								})

								if Players:GetPlayerFromCharacter(Character) then
									PointsService:AddPoints(Players:GetPlayerFromCharacter(Character),SkillData.Points)
									PointsService:AddToCombo(Players:GetPlayerFromCharacter(Character),1)
								end

								if Players:GetPlayerFromCharacter(Victim) then
									RemoteComs:FireClientEvent(Players:GetPlayerFromCharacter(Victim),{FunctionName = "AnimationService" },{
										Task = "PlayAnimation",
										AnimationData = {
											Name = "Stun1",
											AnimationSpeed = 1,
											Weight = 1,
											FadeTime = 0.25,
											Looped = false,
										}
									})
								else
									Victim.Humanoid.Animator:LoadAnimation(RS.Assets.Animations.Shared.Combat["Stun1"]):Play()
								end
							elseif HitResult == "Blocking" then
								HitVictim = Victim
								RemoteComs:FireAllClientsEvent({FunctionName = "VFX"},{FName = "RegBlockEffect",FData = {
									Character = Character,
									Victim = Victim,
								}})
								
								SoundService:PlaySound("CombatBlockhit",{
									Parent = Victim.PrimaryPart,
									Volume = 0.75,
								},{},{
									Range = 25,
									Origin = Victim.PrimaryPart.CFrame.p
								})
							elseif HitResult == "PerfectBlock" then
								CombatService:PerfectBlock(Victim,Character,{
									CanTP = true,
									MaxDist = 16,
								})
							elseif HitResult:match("Counter") then
								local SkillService = require(SS.Modules.Services.SkillService)
								local DataForCounter = HitResult:split("_")
								SkillService:CastCounter({
									Character = Victim,
									Victim = Character,
									CharCounterID = DataForCounter[2],
									SkillName = DataForCounter[3],
									SkillSlot = DataForCounter[4],
								})
							end
						end
						
						if HitTable.BreakHit == true and ProjectileBreak == false then
							ProjectileBreak = true
							SkillService:FireClientVFX(Player,CharacterID,"FourthSkill","Demon Shuriken Destory",{
								Character = Character,
								UID = SkillUID,
							})
						end
					end)
				end)
				
				task.delay(0.45,function()
					Character.Humanoid.AutoRotate = true
				end)
				
				task.delay(SkillData.Duration,function()
					if not ProjectileBreak then
						ProjectileBreak = true
						SkillService:FireClientVFX(Player,CharacterID,"FourthSkill","Demon Shuriken Destory",{
							Character = Character,
							UID = SkillUID,
						})
					end
				end)
				
				SkillService:FireClientVFX(Player,CharacterID,"FourthSkill","Demon Shuriken",{
					Character = Character,
					UID = SkillUID,
					Speed = SkillData.ShurikenSpeed,
					Direction = (End.p - StartPoint.p).Unit,
					Dur = SkillData.Duration,
					Pos = StartPoint,
				})
				
				ShurikeHitBox:StartProjectile({
					BreakOnHit = false,
					BreakOnMap = true,
					Points = Points,
					Dur = SkillData.Duration,
					Direction = Direction,
					Velocity = Velocity,
					VisualizeHitBox = false,
					Iterations = 200,
					IgnoreList = {workspace.World.Effects,Character},
					Acceleration = 0
				})
				
				SoundService:PlaySound("KakaShuriThrow",{
					Parent = Character.PrimaryPart,
					Volume = 1,
				},{},{
					Range = 25,
					Origin = Character.PrimaryPart.CFrame.p
				})
				
				StateService:SetState(Character,"UsingSkill",{
					LP = 55,
					Dur = 0.01,
				})
				
				CooldownService:SetCooldown(Character,CharacterID,"FourthSkill",{
					CD = SkillData.Cooldown
				})
			end)
		end,
	},
	["UltimateSkill"] = {
		["Release"] = function(Character)
		end,
		["Hold"] = function(Character)
			local SkillUID = "UltimateSkillRelease"..Character.Name..CharacterID..HTTPService:GenerateGUID(false)

			local SkillService = require(SS.Modules.Services.SkillService)
			local StateService = require(RS.Modules.Services.StateService)

			local StateShortCuts = require(RS.Modules.Services.StateService.StateShortcuts)
			local SoundService = require(RS.Modules.Services.SoundService)

			local HitBoxService = require(SS.Modules.Services.HitBoxService)
			local RemoteComs = require(RS.Modules.Utility.RemoteNetwork)
			local Util = require(RS.Modules.Utility.Util)

			local CooldownService = require(SS.Modules.Services.CooldownService)
			local PointsService = require(SS.Modules.Services.PointsService)
			local DamageService = require(SS.Modules.Services.DamageService)

			local SkillData = require(SS.Modules.MetaData.CharacterData)[CharacterID]["SkillData"]["Ultimate"]
			
			local Player = Players:GetPlayerFromCharacter(Character)

			if not PointsService:CanUseUlt(Player) then return end
			if StateService:GetState(Character,"Stunned") then return end
			if StateService:GetState(Character,"UsingSkill") then return end
			if StateService:GetState(Character,"Swing") then return end
			
			local CombatService = require(SS.Modules.Services.CombatService)
			
			local function RayCheck(Ori)
				local Para = RaycastParams.new()
				Para.FilterType = Enum.RaycastFilterType.Include
				Para.FilterDescendantsInstances = {workspace.World.Map}
				
				local RayCas = workspace:Raycast(Ori,Vector3.new(0,-10000,0),Para)
				
				if RayCas then
					return RayCas.Position
				else
					return Ori
				end
			end
			
			PointsService:UltGain(Player,false)
			PointsService:ResetUltPoints(Player)
			
			StateService:SetState(Character,"UsingSkill",{
				LP = 55,
				Dur = 10,
			})
			StateService:SetState(Character,"CantRun",{
				LP = 55,
				Dur = 10,
			})
			StateService:SetState(Character,"CantM1",{
				LP = 55,
				Dur = 10,
			})
			
			Character.PrimaryPart.AssemblyLinearVelocity = Vector3.new(0,0,0)
			Character.PrimaryPart.AssemblyAngularVelocity = Vector3.new(0,0,0)
			Character.PrimaryPart.Anchored = true
			Character.Humanoid.AutoRotate = false
			
			local X,Y,Z = Character.PrimaryPart.CFrame:ToEulerAnglesXYZ()
			local Origin = CFrame.new(GetPosition:InvokeClient(Player))
			Character.PrimaryPart.CFrame = Origin * CFrame.Angles(X,Y,Z)
			
			RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
				Task = "PlayAnimation",
				AnimationData = {
					Name = "UltKidSasuke",
					AnimationSpeed = 1,
					Weight = 6.5,
					FadeTime = 0.25,
					Looped = false,
				}
			})
			
			SkillService:FireClientVFX(Player,CharacterID,"UltimateSkill","UltAura",{
				Character = Character,
				UID = SkillUID
			})
			
			local TickStart = true
			local Stop = false
			
			task.spawn(function()
				while not Stop do
					if TickStart and StateService:GetState(Character,"Stunned") then
						TickStart = false
						Stop = true
						
						Character.PrimaryPart.Anchored = false
						Character.Humanoid.AutoRotate = true
						
						RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
							Task = "StopAnimation",
							AnimationData = {
								Name = "UltKidSasuke",
								AnimationSpeed = 1,
								Weight = 6.5,
								FadeTime = 0.25,
								Looped = false,
							}
						})
						
						SkillService:FireClientVFX(Player,CharacterID,"UltimateSkill","UltAuraOff",{
							Character = Character,
							UID = SkillUID
						})
						SkillService:FireClientVFX(Player,CharacterID,"UltimateSkill","CastFieldOff",{
							Character = Character,
							UID = SkillUID,
							Pos = RayCheck(Origin.p)
						})
						
						StateService:SetState(Character,"UsingSkill",{
							LP = 55,
							Dur = 0.01,
						})
						StateService:SetState(Character,"CantRun",{
							LP = 55,
							Dur = 0.01,
						})
						StateService:SetState(Character,"CantM1",{
							LP = 55,
							Dur = 0.01,
						})
						PointsService:UltGain(Player,true)
						break
					end
					RunService.Heartbeat:Wait()
				end
			end)
			
			Util:SignalMarker(RS.Assets.Animations.Shared.Sasuke.UltKidSasuke,"Start"):Connect(function()
				if not TickStart then return end
				
				SkillService:FireClientVFX(Player,CharacterID,"UltimateSkill","CastField",{
					Character = Character,
					UID = SkillUID,
					Pos = RayCheck(Origin.p)
				})
				
				task.spawn(function()
					task.delay(0.05,function()
						while TickStart do
							task.spawn(function()
								local Hitbox = HitBoxService:BoxCFrame()
								local HitTable = Hitbox:Fire({
									BreakOnHit = false,
									MultHit = true,
									CFrame = Origin * CFrame.new(0,3,0),
									HitOnce = true,
									Offset = CFrame.new(0,0,0),
									Size = SkillData.HitboxSize,
									Caster = Character,
									Visual = false
								})
								for _,Victim in pairs(HitTable) do
									local HitResult = StateShortCuts:GetHitAoeResult({
										Attacker = Character,
										Victim = Victim,
										Origin	= (Origin * CFrame.new(0,3,0)).p,
										HitData = {
											BlockBreak = true,
											CanPB = false,
											CantBeCountered = true,
										},
									})
									
									if HitResult == "IFrame" then
									elseif HitResult == "Hit" or HitResult == "GuardBreak" then
										if HitResult == "GuardBreak" then
											CombatService:GuardBreak(Victim)
										else
											if Players:GetPlayerFromCharacter(Victim) then
												RemoteComs:FireClientEvent(Players:GetPlayerFromCharacter(Victim),{FunctionName = "AnimationService" },{
													Task = "PlayAnimation",
													AnimationData = {
														Name = "Stun"..math.random(1,2),
														AnimationSpeed = 1,
														Weight = 1,
														FadeTime = 0.25,
														Looped = false,
													}
												})
											else
												Victim.Humanoid.Animator:LoadAnimation(RS.Assets.Animations.Shared.Combat["Stun"..math.random(1,2)]):Play()
											end
										end
										StateShortCuts:StunSpeed(Victim,{
											Prior = 57,
											Duration = SkillData.Stun,
											Speed = 0,
										})
										DamageService:DamageEntities({
											Attacker = Character,
											Damage = SkillData.Damage,
											Victim = Victim,
										})
										
										if StateService:GetState(Character,"NejiUlt") then
											DamageService:DamageEntities({
												Attacker = Character,
												Damage = SkillData.Damage * 1.5,
												Victim = Victim,
											})
										else
											DamageService:DamageEntities({
												Attacker = Character,
												Damage = SkillData.Damage,
												Victim = Victim,
											})
										end
										
										if Players:GetPlayerFromCharacter(Victim) == nil and Victim and Players:GetPlayerFromCharacter(Character) then
											if Victim.PrimaryPart and Victim.PrimaryPart.Anchored == false then
												for _,v in ipairs(Victim:GetChildren()) do
													if v:IsA("BasePart") and v.Anchored == false then
														v:SetNetworkOwner(Players:GetPlayerFromCharacter(Character))
													end
												end
											end
										end
										
										local BV = Instance.new("BodyVelocity")
										BV.MaxForce = Vector3.new(4e4,4e4,4e4)
										BV.Velocity = (Victim.PrimaryPart.CFrame.p - Origin.Position).Unit * 3.5
										BV.Parent = Victim.PrimaryPart
										Debris:AddItem(BV,.1)
										
										StateShortCuts:StunCharacter({
											Victim = Victim,
											Attacker = Character,
											WasAttack = true,
											Duration = SkillData.Stun,
											Priority = 55,
											AttackID = "KidNejiRotation",
										})
									elseif HitResult == "PerfectBlock" then
										CombatService:PerfectBlock(Victim,Character,{
											CanTP = true,
											MaxDist = 16,
										})
									end
								end
							end)
							
							task.wait(SkillData.TickRate)
						end
						Stop = true
					end)
				end)
			end)
			
			Util:StopMarker(RS.Assets.Animations.Shared.Sasuke.UltKidSasuke):Connect(function()
				if not TickStart then return end
				TickStart = false
				
				SkillService:FireClientVFX(Player,CharacterID,"UltimateSkill","UltAuraOff",{
					Character = Character,
					UID = SkillUID
				})
				SkillService:FireClientVFX(Player,CharacterID,"UltimateSkill","CastFieldOff",{
					Character = Character,
					UID = SkillUID,
					Pos = RayCheck(Origin.p)
				})
				Character.PrimaryPart.Anchored = false
				Character.Humanoid.AutoRotate = true
				StateService:SetState(Character,"UsingSkill",{
					LP = 55,
					Dur = 0.2,
				})
				StateService:SetState(Character,"CantRun",{
					LP = 55,
					Dur = 0.2,
				})
				StateService:SetState(Character,"CantM1",{
					LP = 55,
					Dur = 0.2,
				})
				PointsService:UltGain(Player,true)
			end)
		end,
	}
}

return KidSasuke