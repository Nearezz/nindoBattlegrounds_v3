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

local CharacterID = "OldKakashi"

local OldKakashi; OldKakashi = {
	["FirstSkill"] = {
		["Release"] = function(Character)
		end,
		["Hold"] = function(Character)
			local SkillUID = "FirstSkillRelase"..Character.Name..CharacterID..HTTPService:GenerateGUID(false)
			
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
			
			CooldownService:SetCooldown(Character,CharacterID,"FirstSkill",{
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
				Volume = 0.75,
			},{},{
				Range = 100,
				Origin = Character.PrimaryPart.CFrame.p
			})
			
			RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
				Task = "PlayAnimation",
				AnimationData = {
					Name = RS.Assets.Animations.Shared.Kakashi["Fireball"].Name,
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
								Name = RS.Assets.Animations.Shared.Kakashi["Fireball"].Name,
								AnimationSpeed = 1,
								Weight = 3.5,
								FadeTime = 0.25,
								Looped = false,
							}
						})
						
						SoundService:StopSound("HandsignSound",{
							Parent = Character.PrimaryPart,
							Volume = 0.75,
						},{},{
							Range = 100,
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
			
			Util:SignalMarker(RS.Assets.Animations.Shared.Kakashi.Fireball,"CheckHyperArmor"):Connect(function()
				CheckFlag = true
			end)
			
			Util:SignalMarker(RS.Assets.Animations.Shared.Kakashi.Fireball,"Release"):Connect(function()
				if HyperArmored then return end
				
				StateService:SetState(Character,"UsingSkill",{
					LP = 55,
					Dur = .35,
				})
				StateService:SetState(Character,"CantRun",{
					LP = 55,
					Dur = 0.35,
				})
				StateService:SetState(Character,"CantM1",{
					LP = 55,
					Dur = .35,
				})
				
				CooldownService:SetCooldown(Character,CharacterID,"FirstSkill",{
					Hold = false
				})
				
				CooldownService:SetCooldown(Character,CharacterID,"FirstSkill",{
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
				local Points = FireballHitBox:GetRayCastSquarePoints(StartPoint,4.5,4.5)
				
				FireballHitBox.HitTask:Connect(function(HitTable)
					SkillService:FireClientVFX(Player,CharacterID,"FirstSkill","FireballHit",{
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
								AttackID = "OldKakaFireBall",
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
								Playing = true
							},{},{
								Range = 100,
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
					
					SoundService:PlaySoundAt("Fireball",{
						Parent = Character.PrimaryPart,
						Volume = 0.75,
						Playing = true
					},{
						CFrame = CFrame.new(HitPosition),
						TweenTime = 0.15,
					},{
						Range = 100,
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
									AttackID = "OldKakaFireBall",
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
								
								SoundService:PlaySound("CombatBlockhit",{
									Parent = Character.PrimaryPart,
									Volume = 0.75,
								},{},{
									Range = 100,
									Origin = Character.PrimaryPart.CFrame.p
								})
								
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
				
				SkillService:FireClientVFX(Player,CharacterID,"FirstSkill","FireballCast",{
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
			end)
		end,
	},
	["SecondSkill"] = {
		["Release"] = function(Character)
		end,
		["Hold"] = function(Character)
			local SkillUID = "SecondSkillRelase"..Character.Name..CharacterID..HTTPService:GenerateGUID(false)

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
			
			local CombatService = require(SS.Modules.Services.CombatService)
			
			CooldownService:SetCooldown(Character,CharacterID,"SecondSkill",{
				Hold = true
			})
			
			local PlayersInRange = HitBoxService:GetPlayersInRange({
				Range = 100,
				Caster = Character,
				CasterFacing = true
			})
			
			local ScreenToPoint = SkillService:ScreenToPoint(Player,PlayersInRange)
			
			local TargetPlayer = nil
			local Cloestest = nil
			local CloestestMag = nil

			for i,x in pairs(ScreenToPoint) do
				if Cloestest == nil then
					TargetPlayer = x[1].Parent
					CloestestMag = (x[1].Position - Character.PrimaryPart.Position).Magnitude
					Cloestest = x[3]
				elseif Cloestest >= x[3] then
					TargetPlayer = x[1].Parent
					CloestestMag = (x[1].Position - Character.PrimaryPart.Position).Magnitude
					Cloestest = x[3]
				end
			end
			
			if not TargetPlayer then
				CooldownService:SetCooldown(Character,CharacterID,"SecondSkill",{
					Hold = false
				})
				CooldownService:SetCooldown(Character,CharacterID,"SecondSkill",{
					CD = 0.5
				})
				return
			end
			
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
			
			local BP = Instance.new("BodyPosition")
			BP.Position = Character.PrimaryPart.CFrame.Position + Vector3.new(0,18,0)
			BP.MaxForce = Vector3.new(1e4,25e4,1e4)
			BP.Parent = Character.PrimaryPart
			
			RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
				Task = "PlayAnimation",
				AnimationData = {
					Name = RS.Assets.Animations.Shared.Kakashi["ShurikenThrow"].Name,
					AnimationSpeed = 1,
					Weight = 3.5,
					FadeTime = 0.25,
					Looped = false,
				}
			})
			
			local HyperFlag = false
			local CheckOver = false
			
			task.spawn(function()
				repeat
					if StateService:GetState(Character,"Stunned") then
						HyperFlag = true
						
						RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
							Task = "StopAnimation",
							AnimationData = {
								Name = RS.Assets.Animations.Shared.Kakashi["ShurikenThrow"].Name,
								AnimationSpeed = 1,
								Weight = 3.5,
								FadeTime = 0.25,
								Looped = false,
							}
						})
						
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
						
						if BP then
							BP:Destroy()
						end
					end
					RunService.Heartbeat:Wait()
				until HyperFlag or CheckOver
			end)
			
			Util:SignalMarker(RS.Assets.Animations.Shared.Kakashi.ShurikenThrow,"CheckHyperArmor"):Connect(function()
				CheckOver = true
			end)
			
			Util:SignalMarker(RS.Assets.Animations.Shared.Kakashi.ShurikenThrow,"Release"):Connect(function()
				if HyperFlag then return end
				
				task.spawn(function()
					for i = 1,3 do
						task.spawn(function()
							local StartPoint = Character.PrimaryPart.CFrame * CFrame.new(0,2,-2)
							local Goal = TargetPlayer.PrimaryPart.CFrame
							
							local Direction = (Goal.p - StartPoint.p).Unit
							local Velocity = SkillData.Speed
							local Duration = SkillData.Duration
							local Acceleration = SkillData.Acceleration
							local ShurikenHitBox = HitBoxService:AoeProjectile()
							local Points = ShurikenHitBox:GetRayCastSquarePoints(StartPoint,1.5,1.5)
							
							local random_playbackspeed = math.random(97, 103) / 100 or 1
							
							ShurikenHitBox.HitTask:Connect(function(HitTable)
								local HitParent = HitTable.HitInstance.Parent
								local Victim;
								
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
										StateShortCuts:StunSpeed(Victim,{
											Prior = 55,
											Duration = SkillData.Stun,
											Speed = 0,
										})
										DamageService:DamageEntities({
											Attacker = Character,
											Damage = SkillData.Damage,
											Victim = Victim,
										})
										
										SoundService:PlaySound("KakaShuriImpact",{
											Parent = Victim.PrimaryPart,
											Volume = 0.75,
											PlaybackSpeed = random_playbackspeed
										},{},{
											Range = 25,
											Origin = Victim.PrimaryPart.CFrame.p
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


										StateShortCuts:StunCharacter({
											Victim = Victim,
											Attacker = Character,
											WasAttack = true,
											Duration = SkillData.Stun,
											Priority = 55,
											AttackID = "OldKakaShurkien",
										})

										if Players:GetPlayerFromCharacter(Character) then
											PointsService:AddPoints(Players:GetPlayerFromCharacter(Character),SkillData.Points)
											PointsService:AddToCombo(Players:GetPlayerFromCharacter(Character),1)
										end


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
									elseif HitResult == "Blocking" then
										RemoteComs:FireAllClientsEvent({FunctionName = "VFX"},{FName = "RegBlockEffect",FData = {
											Character = Character,
											Victim = Victim,
										}})

										SoundService:PlaySound("CombatBlockhit",{
											Parent = Character.PrimaryPart,
											Volume = 0.75,
										},{},{
											Range = 100,
											Origin = Character.PrimaryPart.CFrame.p
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
								SkillService:FireClientVFX(Player,CharacterID,"SecondSkill","Stick",{
									UID = SkillUID,
									Character = Character,
									Position = HitTable.Position,
									Number = i,
									Stick = HitTable.HitInstance
								})
							end)
							
							SkillService:FireClientVFX(Player,CharacterID,"SecondSkill","ThrowObject",{
								Character = Character,
								Number = i,
								StartPoint = StartPoint,
								Acceleration = Acceleration,
								Velocity = Velocity,
								Direction = Direction,
								Duration = Duration,
								UID = SkillUID,
								TargetPlayer = TargetPlayer,
							})
							
							SoundService:PlaySound("KakaShuriThrow",{
								Parent = Character.PrimaryPart,
								Volume = 0.75,
								PlaybackSpeed = random_playbackspeed
							},{},{
								Range = 25,
								Origin = Character.PrimaryPart.CFrame.p
							})
							
							ShurikenHitBox:StartProjectile({
								BreakOnHit = true,
								Points = Points,
								Dur = Duration,
								Direction = Direction,
								Velocity = Velocity,
								VisualizeHitBox = false,
								Iterations = 200,
								IgnoreList = {workspace.World.Effects,Character},
								Acceleration = Acceleration,
							})
						end)
						task.wait(0.05)
					end	
				end)
				
				BP:Destroy()
				
				CooldownService:SetCooldown(Character,CharacterID,"SecondSkill",{
					Hold = false
				})
				CooldownService:SetCooldown(Character,CharacterID,"SecondSkill",{
					CD = SkillData.Cooldown
				})
				StateService:SetState(Character,"UsingSkill",{
					LP = 55,
					Dur = 0.25,
				})
				StateService:SetState(Character,"CantRun",{
					LP = 55,
					Dur = 0.25,
				})
				StateService:SetState(Character,"CantM1",{
					LP = 55,
					Dur = 0.25,
				})
			end)
		end,
	},
	["ThirdSkill"] = {
		["Release"] = function(Character)
		end,
		["Hold"] = function(Character)
			local SkillUID = "ThirdSkillRelase"..Character.Name..CharacterID..HTTPService:GenerateGUID(false)

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
			
			local SkillData = require(SS.Modules.MetaData.CharacterData)[CharacterID]["SkillData"]["ThirdSkill"]
			
			if not CooldownService:CheckCooldown(Character,CharacterID,"ThirdSkill") then return end
			if StateService:GetState(Character,"Stunned") then return end
			if StateService:GetState(Character,"UsingSkill") then return end
			if StateService:GetState(Character,"Swing") then return end
			
			local Player = Players:GetPlayerFromCharacter(Character)
			
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
			
			CooldownService:SetCooldown(Character,CharacterID,"ThirdSkill",{
				Hold = true
			})

			RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
				Task = "PlayAnimation",
				AnimationData = {
					Name = RS.Assets.Animations.Shared.Kakashi["KEarth Wall"].Name,
					AnimationSpeed = 1,
					Weight = 1,
					FadeTime = 0.25,
					Looped = false,
				}
			})
			
			StateService:SetState(Character,"CantRun",{
				LP = 60,
				Dur = 10,
			})
			
			StateService:SetState(Character,"UsingSkill",{
				LP = 50,
				Dur = 5,
			})
			
			local Flag = false
			
			Util:SignalMarker(RS.Assets.Animations.Shared.Kakashi["KEarth Wall"],"Release"):Connect(function()
				Flag = true
			end)
			
			local HyperArmor = false
			
			task.spawn(function()
				repeat
					if StateService:GetState(Character,"Stunned") then
						HyperArmor = true
						RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
							Task = "StopAnimation",
							AnimationData = {
								Name = RS.Assets.Animations.Shared.Kakashi["KEarth Wall"].Name,
								AnimationSpeed = 1,
								Weight = 1,
								FadeTime = 0.25,
								Looped = false,
							}
						})
						
						Character.Humanoid.AutoRotate = true
						
						CooldownService:SetCooldown(Character,CharacterID,"ThirdSkill",{
							Hold = false
						})
						CooldownService:SetCooldown(Character,CharacterID,"ThirdSkill",{
							CD = SkillData.Cooldown
						})
					end
					RunService.Heartbeat:Wait()
				until Flag or HyperArmor
				
				StateService:SetState(Character,"UsingSkill",{
					LP = 51,
					Dur = 0.2,
				})
				StateService:SetState(Character,"CantRun",{
					LP = 61,
					Dur = 0.2,
				})
				
				if HyperArmor then return end
				Character.Humanoid.AutoRotate = false
				Character.PrimaryPart.Anchored = true
				
				local WallCFrame = CFrame.lookAt(RayCheck(Character.PrimaryPart.CFrame.Position + Character.PrimaryPart.CFrame.LookVector * 9.5),Character.PrimaryPart.CFrame.Position + Character.PrimaryPart.CFrame.LookVector * -1000)
				
				local WallEffect = RS.Assets.Effects.Kakashi.MudWall:Clone()
				WallEffect.Parent = workspace.World.Map
				
				for i,x in ipairs(WallEffect:GetChildren()) do
					x.Transparency = 1
					if x.Name == "1" then
						x:Destroy()
					end
				end
				
				WallEffect.PrimaryPart.CFrame = WallCFrame * CFrame.new(0,16.62/2,0)
				
				SkillService:FireClientVFX(Player,CharacterID,"ThirdSkill","SummonEarthWall",{
					Character = Character,
					WallCFrame = WallCFrame * CFrame.new(0,-16.62/2,0)
				})
				
				SoundService:PlaySoundAt("Naruto Jutsu Sound Effect",{
					Parent = Character.PrimaryPart,
					Volume = 0.75,
				},{
					CFrame = CFrame.new(WallCFrame.Position)	
				},{
					Range = 25,
					Origin = Character.PrimaryPart.CFrame.p
				})
				
				SoundService:PlaySoundAt("Earth Rise",{
					Parent = Character.PrimaryPart,
					Volume = 1,
				},{
					CFrame = CFrame.new(WallCFrame.Position)	
				},{
					Range = 25,
					Origin = Character.PrimaryPart.CFrame.p
				})
				
				Debris:AddItem(WallEffect,5)
				task.delay(5,function()
					SoundService:PlaySoundAt("Earth fall",{
						Parent = Character.PrimaryPart,
						Volume = 1,
					},{
						CFrame = CFrame.new(WallCFrame.Position)	
					},{
						Range = 25,
						Origin = Character.PrimaryPart.CFrame.p
					})
				end)
				
				task.delay(0.5,function()
					Character.Humanoid.AutoRotate = true
					Character.PrimaryPart.Anchored = false
				end)
				
				CooldownService:SetCooldown(Character,CharacterID,"ThirdSkill",{
					Hold = false,
				})
				CooldownService:SetCooldown(Character,CharacterID,"ThirdSkill",{
					CD = SkillData.Cooldown,
				})
			end)
		end,
	},
	["FourthSkill"] = {
		["Release"] = function(Character)
		end,
		["Hold"] = function(Character)
			local SkillUID = "FourthSkillRelase"..Character.Name..CharacterID..HTTPService:GenerateGUID(false)

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
			
			local SkillData = require(SS.Modules.MetaData.CharacterData)[CharacterID]["SkillData"]["FourthSkill"]
			
			if not CooldownService:CheckCooldown(Character,CharacterID,"FourthSkill") then return end
			if StateService:GetState(Character,"Stunned") then return end
			if StateService:GetState(Character,"UsingSkill") then return end
			if StateService:GetState(Character,"Swing") then return end
			
			local Player = Players:GetPlayerFromCharacter(Character)
			
			local CombatService = require(SS.Modules.Services.CombatService)
			
			CooldownService:SetCooldown(Character,CharacterID,"FourthSkill",{
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
				Volume = 0.75,
			},{},{
				Range = 100,
				Origin = Character.PrimaryPart.CFrame.p
			})
			
			RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
				Task = "PlayAnimation",
				AnimationData = {
					Name = RS.Assets.Animations.Shared.Kakashi["ChidoriCharge"].Name,
					AnimationSpeed = 1,
					Weight = 3.5,
					FadeTime = 0.25,
					Looped = false,
				}
			})
			
			local ChidoriStarted = true
			local Stop = false
			
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
						CooldownService:SetCooldown(Character,CharacterID,"FourthSkill",{
							Hold = false
						})

						CooldownService:SetCooldown(Character,CharacterID,"FourthSkill",{
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
						Volume = 0.75,
					},{},{
						Range = 100,
						Origin = Character.PrimaryPart.CFrame.p
					})
				end)
				
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
				
				StateService:GetProfile(Character).StateData["RunID"].Name = "ChidoriRun"
				
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
				
				SkillService:FireClientVFX(Player,CharacterID,"FourthSkill","FireChidoriParticle",{
					Character = Character,
					UID = SkillUID
				})
				
				SoundService:PlaySound("ChidoriSound",{
					Parent = Character.PrimaryPart,
					Volume = 0.5,
				},{},{
					Range = 100,
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
							CooldownService:SetCooldown(Character,CharacterID,"FourthSkill",{
								Hold = false
							})
							CooldownService:SetCooldown(Character,CharacterID,"FourthSkill",{
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
							
							SkillService:FireClientVFX(Player,CharacterID,"FourthSkill","ChidoriParticleOff",{
								Character = Character,
								UID = SkillUID
							})
							break
						end
						RunService.Heartbeat:Wait()
					end
				end)
				
				task.delay(SkillData.Length,function()
					if ChidoriStarted then
						Stop = true
						Stop2 = true
						
						SoundService:StopSound("ChidoriSound",{
							Parent = Character.PrimaryPart,
							Volume = 0.5,
						},{},{
							Range = 100,
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
						
						CooldownService:SetCooldown(Character,CharacterID,"FourthSkill",{
							Hold = false
						})
						CooldownService:SetCooldown(Character,CharacterID,"FourthSkill",{
							CD = SkillData.Cooldown
						})
						
						StateService:GetProfile(Character).StateData["RunID"].Name = "DfRun"
						SkillService:FireClientVFX(Player,CharacterID,"FourthSkill","ChidoriParticleOff",{
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
										Name = "Chidori Hit Anim",
										AnimationSpeed = 1,
										Weight = 1,
										FadeTime = 0.25,
										Looped = false,
									}
								})
							else
								Victim.Humanoid.Animator:LoadAnimation(RS.Assets.Animations.Shared.Kakashi["Chidori Hit Anim"]):Play()
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
							Volume = 0.5,
						},{},{
							Range = 100,
							Origin = Character.PrimaryPart.CFrame.p
						})
						
						task.delay(0.4,function()
							SoundService:PlaySoundAt("Chidori Explosion",{
								Parent = Character.PrimaryPart,
								Volume = 0.5,
							},{
								CFrame = CFrame.new(Victim.PrimaryPart.CFrame.Position)	
							},{
								Range = 100,
								Origin = Character.PrimaryPart.CFrame.p
							})
						end)
						
						StateService:SetState(Character,"CantRun",{
							LP = 65,
							Dur = 0.3,
						})
						StateService:SetState(Character,"UsingSkill",{
							LP = 50,
							Dur = 0.3,
						})
						
						StateShortCuts:BoostSpeeds(Character,{
							Prior = 55,
							Dur = 0.01,
							WalkSpeed = 16,
							RunSpeed = 25,
						})
						CooldownService:SetCooldown(Character,CharacterID,"FourthSkill",{
							Hold = false
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
						
						CooldownService:SetCooldown(Character,CharacterID,"FourthSkill",{
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
						
						SkillService:FireClientVFX(Player,CharacterID,"FourthSkill","ChidoriHit",{
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
							AttackID = "Chidori",
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
							Volume = 0.5,
						},{},{
							Range = 100,
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
						
						CooldownService:SetCooldown(Character,CharacterID,"FourthSkill",{
							Hold = false
						})
						CooldownService:SetCooldown(Character,CharacterID,"FourthSkill",{
							CD = SkillData.Cooldown
						})
						
						StateService:GetProfile(Character).StateData["RunID"].Name = "DfRun"
						SkillService:FireClientVFX(Player,CharacterID,"FourthSkill","ChidoriParticleOff",{
							Character = Character,
							UID = SkillUID
						})
					elseif HitResult == "IFrame" then
						ChidoriStarted = false
						SoundService:StopSound("ChidoriSound",{
							Parent = Character.PrimaryPart,
							Volume = 0.5,
						},{},{
							Range = 100,
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
						CooldownService:SetCooldown(Character,CharacterID,"FourthSkill",{
							Hold = false
						})
						RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
							Task = "StopAnimation",
							AnimationData = {
								Name = RS.Assets.Animations.Shared.Kakashi["ChidoriIdle"].Name,
								AnimationSpeed = 1,
								Weight = 1,
								FadeTime = 0.25,
								Looped = true,
							}
						})
						RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
							Task = "StopAnimation",
							AnimationData = {
								Name = RS.Assets.Animations.Shared.Kakashi["ChidoriRun"].Name,
								AnimationSpeed = 1,
								Weight = 1,
								FadeTime = 0.25,
								Looped = true,
							}
						})
						CooldownService:SetCooldown(Character,CharacterID,"FourthSkill",{
							CD = SkillData.Cooldown
						})
						StateService:GetProfile(Character).StateData["RunID"].Name = "DfRun"
						SkillService:FireClientVFX(Player,CharacterID,"FourthSkill","ChidoriParticleOff",{
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
			
			StateService:SetState(Character,"UsingSkill",{
				LP = 56,
				Dur = 30,
			})
			
			local PlayersInRange = HitBoxService:GetPlayersInRange({
				Range = SkillData.MaxRange,
				Caster = Character,
				CasterFacing = true
			})

			local ScreenToPoint = SkillService:ScreenToPoint(Player,PlayersInRange)

			local TargetPlayer = nil
			local Cloestest = nil
			local CloestestMag = nil

			for i,x in pairs(ScreenToPoint) do
				if Cloestest == nil then
					TargetPlayer = x[1].Parent
					CloestestMag = (x[1].Position - Character.PrimaryPart.Position).Magnitude
					Cloestest = x[3]
				elseif Cloestest >= x[3] then
					TargetPlayer = x[1].Parent
					CloestestMag = (x[1].Position - Character.PrimaryPart.Position).Magnitude
					Cloestest = x[3]
				end
			end
			
			if not TargetPlayer then
				StateService:SetState(Character,"UsingSkill",{
					LP = 56,
					Dur = 0.5,
				})
				return
			end
			
			local CombatService = require(SS.Modules.Services.CombatService)
			PointsService:UltGain(Player,false)
			PointsService:ResetUltPoints(Player)
			
			StateService:SetState(Character,"CantRun",{
				LP = 55,
				Dur = 20,
			})
			StateService:SetState(Character,"CantM1",{
				LP = 55,
				Dur = 20,
			})
			
			local Checking = true
			local Stopped = false
			local Victim = TargetPlayer
			
			Character.PrimaryPart.Anchored = true
			Character.PrimaryPart.AssemblyLinearVelocity = Vector3.new(0,0,0)
			Character.PrimaryPart.AssemblyAngularVelocity = Vector3.new(0,0,0)
			
			--Victim.PrimaryPart.Anchored = true
			--Victim.PrimaryPart.AssemblyLinearVelocity = Vector3.new(0,0,0)
			--Victim.PrimaryPart.AssemblyAngularVelocity = Vector3.new(0,0,0)
			
			
			--Victim.Humanoid.AutoRotate = false
			Character.Humanoid.AutoRotate = false
			
			Character.PrimaryPart.CFrame = CFrame.new(Character.PrimaryPart.CFrame.p,Victim.PrimaryPart.CFrame.p)
			--Victim.PrimaryPart.CFrame = CFrame.new(Victim.PrimaryPart.CFrame.p,Character.PrimaryPart.CFrame.p)
			
			SoundService:PlaySound("ChidoriSound",{
				Parent = Character.PrimaryPart,
				Volume = 0.5,
			},{},{
				Range = 100,
				Origin = Character.PrimaryPart.CFrame.p
			})
			
			Util:SignalMarker(RS.Assets.Animations.Shared.Kakashi.ChidoriUlt,"ChidoriOn"):Connect(function()
				if Stopped then return end
				SkillService:FireClientVFX(Player,CharacterID,"UltimateSkill","ChidoriParticleOn",{
					Character = Character,
					UID = SkillUID
				})
			end)
			
			Util:SignalMarker(RS.Assets.Animations.Shared.Kakashi.ChidoriUlt,"WindOff"):Connect(function()
				if Stopped then return end
				SkillService:FireClientVFX(Player,CharacterID,"UltimateSkill","WindOff",{
					Character = Character,
					UID = SkillUID
				})
			end)
			
			task.spawn(function()
				while Checking do
					if StateService:GetState(Character,"Stunned") then
						Stopped = true
						
						Character.Humanoid.AutoRotate = true
						Character.PrimaryPart.Anchored = false
						
						RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
							Task = "StopAnimation",
							AnimationData = {
								Name = RS.Assets.Animations.Shared.Kakashi.ChidoriUlt.Name,
								AnimationSpeed = 1,
								Weight = 1,
								FadeTime = 0.25,
								Looped = false,
							}
						})
						SoundService:StopSound("KakaUlt",{
							Parent = Victim.PrimaryPart,
							Volume = 1.2,
						},{},{
							Range = 100,
							Origin = Victim.PrimaryPart.CFrame.p
						})
						StateService:SetState(Character,"CantRun",{
							LP = 55,
							Dur = 0.1,
						})
						StateService:SetState(Character,"CantM1",{
							LP = 55,
							Dur = 0.1,
						})
						StateService:SetState(Character,"UsingSkill",{
							LP = 56,
							Dur = 0.1,
						})
						SkillService:FireClientVFX(Player,CharacterID,"UltimateSkill","UltAuraOff",{
							Character = Character,
							UID = SkillUID
						})
						SkillService:FireOneClientVFX(Player,CharacterID,"UltimateSkill","CameraOff")
						break
					end
					RunService.Heartbeat:Wait()
				end
			end)
			
			Util:SignalMarker(RS.Assets.Animations.Shared.Kakashi.ChidoriUlt,"Teleport"):Connect(function()
				Checking = false
				if Stopped then return end
				
				local function Invis(char,Amount)
					for _, part in ipairs(char:GetDescendants()) do
						if part.Name ~= "HumanoidRootPart" and part:IsA('BasePart') or part:IsA('MeshPart') or part:IsA('Decal')  then
							part.Transparency = Amount
						end
					end
				end
				
				Invis(Character,1)
				
				RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
					Task = "StopAnimation",
					AnimationData = {
						Name = RS.Assets.Animations.Shared.Kakashi.ChidoriUlt.Name,
						AnimationSpeed = 1,
						Weight = 1,
						FadeTime = 0.25,
						Looped = false,
					}
				})
				local TeleCFrame = CFrame.lookAt((Victim.PrimaryPart.CFrame * CFrame.new(0,0.01,-5)).Position,Victim.PrimaryPart.CFrame.Position)
				Character.PrimaryPart.CFrame = TeleCFrame
				Invis(Character,0)
				Util:SignalMarker(RS.Assets.Animations.Shared.Kakashi["Chidori Hit Anim"],"Hit"):Connect(function()
					SoundService:StopSound("ChidoriSound",{
						Parent = Character.PrimaryPart,
						Volume = 0.5,
					},{},{
						Range = 100,
						Origin = Character.PrimaryPart.CFrame.p
					})
					StateService:SetState(Character,"CantRun",{
						LP = 55,
						Dur = 0.01,
					})
					StateService:SetState(Character,"CantM1",{
						LP = 55,
						Dur = 0.01,
					})
					StateService:SetState(Character,"UsingSkill",{
						LP = 56,
						Dur = 00.1,
					})
					task.delay(0.42,function()
						Victim.Humanoid.AutoRotate = true
						Character.Humanoid.AutoRotate = true
						Character.PrimaryPart.Anchored = false
						Victim.PrimaryPart.Anchored = false
					end)
					SoundService:PlaySound("Chidori Explosion",{
						Parent = Victim.PrimaryPart,
						Volume = 0.5,
					},{},{
						Range = 100,
						Origin = Victim.PrimaryPart.CFrame.p
					})
					SkillService:FireClientVFX(Player,CharacterID,"UltimateSkill","ChidoriHit",{
						Character = Character,
						Victim = Victim,
						DustPos = Character.HumanoidRootPart.CFrame * CFrame.new(0,-1,1) * CFrame.Angles(math.rad(90),0,0),
						UID = SkillUID
					})
					if Players:GetPlayerFromCharacter(Character) then
						PointsService:AddToCombo(Players:GetPlayerFromCharacter(Character),1)
						PointsService:AddPoints(Players:GetPlayerFromCharacter(Character),SkillData.Points)
					end
					if Players:GetPlayerFromCharacter(Victim) then
						RemoteComs:FireClientEvent(Players:GetPlayerFromCharacter(Victim),{FunctionName = "AnimationService" },{
							Task = "PlayAnimation",
							AnimationData = {
								Name = "Guardbreak",
								AnimationSpeed = 1,
								Weight = 1,
								FadeTime = 0.25,
								Looped = false,
							}
						})
					else
						Victim.Humanoid.Animator:LoadAnimation(RS.Assets.Animations.Shared.Combat.Guardbreak):Play()
					end
					DamageService:DamageEntities({
						Attacker = Character,
						Damage = SkillData.Damage,
						Victim = Victim,
						NoPoints = true,
					})
					StateShortCuts:StunCharacter({
						Victim = Victim,
						Attacker = Character,
						WasAttack = true,
						Duration = 1.75,
						Priority = 50,
						AttackID = "Chidori",
					})
					StateShortCuts:StunSpeed(Victim,{
						Prior = 55,
						Duration = 1.75,
						Speed = 0,
					})
					SkillService:FireClientVFX(Player,CharacterID,"UltimateSkill","UltAuraOff",{
						Character = Character,
						UID = SkillUID
					})
					Character.Humanoid:TakeDamage(Character.Humanoid.Health * 0.5)
				end)
				RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
					Task = "PlayAnimation",
					AnimationData = {
						Name = RS.Assets.Animations.Shared.Kakashi["Chidori Hit Anim"].Name,
						AnimationSpeed = 1,
						Weight = 1,
						FadeTime = 0.25,
						Looped = false,
					}
				})
			end)
			
			CombatService:ResetM1s(Character)
			
			SkillService:FireClientVFX(Player,CharacterID,"UltimateSkill","UltAura",{
				Character = Character,
				UID = SkillUID
			})
			
			SkillService:FireOneClientVFX(Player,CharacterID,"UltimateSkill","PlayCamera",{
				Character = Character,
				UID = SkillUID,
				Origin = Character.PrimaryPart.CFrame * CFrame.new(0,-3,0)
			})
			
			RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
				Task = "PlayAnimation",
				AnimationData = {
					Name = RS.Assets.Animations.Shared.Kakashi.ChidoriUlt.Name,
					AnimationSpeed = 1,
					Weight = 1,
					FadeTime = 0.25,
					Looped = false,
				}
			})
			
			SoundService:PlaySound("KakaUlt",{
				Parent = Victim.PrimaryPart,
				Volume = 1.2,
			},{},{
				Range = 100,
				Origin = Victim.PrimaryPart.CFrame.p
			})
			
			PointsService:UltGain(Player,true)
		end,
	}
}

return OldKakashi
