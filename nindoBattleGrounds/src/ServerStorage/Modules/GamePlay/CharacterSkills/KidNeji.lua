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

local CharacterID = "KidNeji"

local GetPosition = RS.GetPosition

local OldKakashi; OldKakashi = {
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
			CombatService:SprintEnd(Character)
			
			local HyperArmor = false
			local CheckOver = false
			
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
			CooldownService:SetCooldown(Character,CharacterID,"FirstSkill",{
				Hold = true
			})
			
			StateShortCuts:BoostSpeeds(Character,{
				Prior = 55,
				Dur = 25,
				WalkSpeed = 0,
				RunSpeed = 0,
			})
			
			Character.PrimaryPart.AssemblyLinearVelocity = Vector3.new(0,0,0)
			Character.PrimaryPart.AssemblyAngularVelocity = Vector3.new(0,0,0)
			Character.PrimaryPart.Anchored = true
			Character.Humanoid.AutoRotate = false
			
			RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
				Task = "PlayAnimation",
				AnimationData = {
					Name = RS.Assets.Animations.Shared.Neji.NejiRotation.Name,
					AnimationSpeed = 1,
					Weight = 3.5,
					FadeTime = 0.25,
					Looped = false,
				}
			})
			
			task.spawn(function()
				repeat
					if StateService:GetState(Character,"Stunned") then
						HyperArmor = true
						Character.PrimaryPart.Anchored = false
						Character.Humanoid.AutoRotate = true
						
						RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
							Task = "StopAnimation",
							AnimationData = {
								Name = RS.Assets.Animations.Shared.Neji.NejiRotation.Name,
								AnimationSpeed = 1,
								Weight = 3.5,
								FadeTime = 0.25,
								Looped = false,
							}
						})
						
						StateService:SetState(Character,"UsingSkill",{
							LP = 55,
							Dur = 0.5,
						})
						StateService:SetState(Character,"CantRun",{
							LP = 55,
							Dur = 0.1,
						})
						StateService:SetState(Character,"CantM1",{
							LP = 55,
							Dur = 0.2,
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
					end
					RunService.Heartbeat:Wait()
				until HyperArmor or CheckOver
			end)
			
			Util:SignalMarker(RS.Assets.Animations.Shared.Neji.NejiRotation,"HyperArmor"):Connect(function()
				CheckOver = true
			end)
			
			local RotationGoing = true
			
			Util:SignalMarker(RS.Assets.Animations.Shared.Neji.NejiRotation,"Start"):Connect(function()
				if HyperArmor then return end
				
				SkillService:FireOneClientVFX(Player,CharacterID,"FirstSkill","CameraEffect",{
					Character = Character,
					UID = SkillUID
				})
				
				StateService:SetState(Character,"IFrame",{
					LP = 65,
					Dur = 20,
				})
				
				task.spawn(function()
					local RotationLocation = GetPosition:InvokeClient(Player)
					SkillService:FireClientVFX(Player,CharacterID,"FirstSkill","SpawnRotation",{
						Character = Character,
						UID = SkillUID
					})
					
					local GuardBreakTable = {}
					local TickCD = os.clock()
					
					repeat
						task.spawn(function()
							local Hitbox = HitBoxService:BoxCFrame()
							local HitTable = Hitbox:Fire({
								BreakOnHit = false,
								MultHit = true,
								CFrame = CFrame.new(RotationLocation),
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
									Origin	= Character.PrimaryPart.CFrame.Position,
									HitData = {
										BlockBreak = true,
										CanPB = false,
									},
								})
								
								if HitResult == "IFrame" then
								elseif HitResult == "Hit" or HitResult == "GuardBreak" then
									if HitResult == "GuardBreak" then
										CombatService:GuardBreak(Victim)
										GuardBreakTable[Victim] = Victim
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
									
									if os.clock() - TickCD > 0.15 then
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
							
							if os.clock() - TickCD > 0.15 then
								TickCD = os.clock()
							end
						end)
						task.wait(SkillData.TickRate)
					until not RotationGoing
					
					local Hitbox = HitBoxService:BoxCFrame()
					local HitTable = Hitbox:Fire({
						BreakOnHit = false,
						MultHit = true,
						CFrame = CFrame.new(RotationLocation),
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
							Origin	= RotationLocation,
							HitData = {
								BlockBreak = true,
								CanPB = false,
							},
						})

						if HitResult == "IFrame" then
						elseif HitResult == "Hit" or HitResult == "GuardBreak" then
							if HitResult == "GuardBreak" then
								CombatService:GuardBreak(Victim)
								GuardBreakTable[Victim] = Victim
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

							--if os.clock() - TickCD > 0.15 then
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
							--end

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
								AttackID = "KidNejiRotation",
							})
							
							if GuardBreakTable[Victim] == nil then
								local Velo = Instance.new("BodyVelocity")
								Velo.Velocity = Vector3.new(0,5,0) + (Victim.PrimaryPart.Position - RotationLocation).Unit * 95
								Velo.MaxForce = Vector3.new(10e4,10e4,10e4)
								Velo.Parent = Victim.PrimaryPart
								Debris:AddItem(Velo,.1)
							end
						elseif HitResult == "PerfectBlock" then
							CombatService:PerfectBlock(Victim,Character,{
								CanTP = true,
								MaxDist = 16,
							})
						end
					end
					
					for _,Victim in pairs(GuardBreakTable) do
						StateShortCuts:StunSpeed(Victim,{
							Prior = 57,
							Duration = SkillData.Stun,
							Speed = 0,
						})
						StateShortCuts:StunCharacter({
							Victim = Victim,
							Attacker = Character,
							WasAttack = true,
							Duration = SkillData.Stun * 2,
							Priority = 55,
							AttackID = "KidNejiRotation",
						})
					end
					
					Character.PrimaryPart.Anchored = false
					Character.Humanoid.AutoRotate = true
					
					StateService:SetState(Character,"UsingSkill",{
						LP = 55,
						Dur = 0.35,
					})
					StateService:SetState(Character,"CantRun",{
						LP = 55,
						Dur = 0.35,
					})
					StateService:SetState(Character,"CantM1",{
						LP = 55,
						Dur = 0.35,
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
					StateService:SetState(Character,"IFrame",{
						LP = 66,
						Dur = 0.01,
					})
				end)
			end)
			
			Util:SignalMarker(RS.Assets.Animations.Shared.Neji.NejiRotation,"End"):Connect(function()
				RotationGoing = false
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
			CombatService:SprintEnd(Character)
			
			local HyperArmor = false
			local CheckOver = false
			
			StateService:SetState(Character,"UsingSkill",{
				LP = 55,
				Dur = 20,
			})
			StateService:SetState(Character,"CantRun",{
				LP = 55,
				Dur = 20,
			})
			StateService:SetState(Character,"CantM1",{
				LP = 55,
				Dur = 20,
			})
			CooldownService:SetCooldown(Character,CharacterID,"SecondSkill",{
				Hold = true
			})
			
			Character.PrimaryPart.AssemblyLinearVelocity = Vector3.new(0,0,0)
			Character.PrimaryPart.AssemblyAngularVelocity = Vector3.new(0,0,0)
			Character.PrimaryPart.Anchored = true
			Character.Humanoid.AutoRotate = false
			
			local StartCFrame = CFrame.new(GetPosition:InvokeClient(Player))
			
			RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
				Task = "PlayAnimation",
				AnimationData = {
					Name = RS.Assets.Animations.Shared.Neji["64 palms"]["64Start"].Name,
					AnimationSpeed = 1,
					Weight = 3.5,
					FadeTime = 0.25,
					Looped = false,
				}
			})
			SkillService:FireClientVFX(Player,CharacterID,"SecondSkill","SpawnPlam",{
				Character = Character,
				Location = StartCFrame,
				UID = SkillUID
			})
			
			task.spawn(function()
				repeat
					if StateService:GetState(Character,"Stunned") then
						HyperArmor = true
						
						Character.PrimaryPart.Anchored = false
						Character.Humanoid.AutoRotate = true
						
						RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
							Task = "StopAnimation",
							AnimationData = {
								Name = RS.Assets.Animations.Shared.Neji["64 palms"]["64Start"].Name,
								AnimationSpeed = 1,
								Weight = 3.5,
								FadeTime = 0.25,
								Looped = false,
							}
						})
						
						SkillService:FireClientVFX(Player,CharacterID,"SecondSkill","RemovePlam",{
							Character = Character,
							UID = SkillUID
						})
						
						StateService:SetState(Character,"UsingSkill",{
							LP = 55,
							Dur = 0.5,
						})
						StateService:SetState(Character,"CantRun",{
							LP = 55,
							Dur = 0.1,
						})
						StateService:SetState(Character,"CantM1",{
							LP = 55,
							Dur = 0.2,
						})
						StateShortCuts:BoostSpeeds(Character,{
							Prior = 55,
							Dur = 0.01,
							WalkSpeed = 16,
							RunSpeed = 25,
						})
						CooldownService:SetCooldown(Character,CharacterID,"SecondSkill",{
							Hold = false
						})
						CooldownService:SetCooldown(Character,CharacterID,"SecondSkill",{
							CD = SkillData.Cooldown
						})
					end
					RunService.Heartbeat:Wait()
				until HyperArmor or CheckOver
			end)
			
			Util:StopMarker(RS.Assets.Animations.Shared.Neji["64 palms"]["64Start"]):Connect(function()
				if HyperArmor then return end
				CheckOver = true
				
				RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
					Task = "PlayAnimation",
					AnimationData = {
						Name = RS.Assets.Animations.Shared.Neji["64 palms"]["64During"].Name,
						AnimationSpeed = 1,
						Weight = 3.5,
						FadeTime = 0.25,
						Looped = true,
					}
				})
				
				local ForceEnd = false
				
				StateShortCuts:StunSpeed(Character,{
					Prior = 60,
					Duration = 10,
					Speed = 8,
				})
				
				Character.PrimaryPart.Anchored = false
				Character.Humanoid.AutoRotate = true
				
				StateShortCuts:BoostSpeeds(Character,{
					Prior = 55,
					Dur = 20,
					WalkSpeed = 0,
					RunSpeed = 0,
				})
				
				for i = 1,64 do
					if (Character.PrimaryPart.Position - StartCFrame.p).Magnitude >= SkillData.PalmRange then
						ForceEnd = true
						break
					end
					
					local HitBox = HitBoxService:CRepeatCFrame({
						BreakOnHit = true,
						MultHit = true,
						OffsetPart = Character.PrimaryPart,
						HitOnce = true,
						Offset = CFrame.new(0,0,-3.5),
						Size = Vector3.new(4.5,4.5,5.5),
						Dur = SkillData.Rate/2,
						Visual = false,
						Caster = Character,
					})
					
					HitBox.OnHit:Connect(function(Victim)
						local HitResult = StateShortCuts:GetHitResult({
							Attacker = Character,
							Victim = Victim,
							HitData = {
								BlockBreak = false,
								CanPB = true,
							},
						})
						
						if HitResult == "Hit" then
							if StateService:GetState(Character,"NejiUlt") then
								DamageService:DamageEntities({
									Attacker = Character,
									Damage = SkillData.Damage * 1.5,
									Victim = Victim
								})
							else
								DamageService:DamageEntities({
									Attacker = Character,
									Damage = SkillData.Damage,
									Victim = Victim
								})
							end
							
							if Players:GetPlayerFromCharacter(Character) then
								PointsService:AddPoints(Players:GetPlayerFromCharacter(Character),SkillData.Points)
							end
							
							local BV = Instance.new("BodyVelocity")
							BV.MaxForce = Vector3.new(4e4,4e4,4e4)
							BV.Velocity = Character.PrimaryPart.CFrame.LookVector * 3.5
							BV.Parent = Victim.PrimaryPart
							Debris:AddItem(BV,.15)
							
							local BV2 = Instance.new("BodyVelocity")
							BV2.MaxForce = Vector3.new(4e4,4e4,4e4)
							BV2.Velocity = Character.PrimaryPart.CFrame.LookVector * 3.5
							BV2.Parent = Character.PrimaryPart
							Debris:AddItem(BV2,.15)
							
							StateShortCuts:StunCharacter({
								Victim = Victim,
								Attacker = Character,
								WasAttack = true,
								Duration = SkillData.Stun,
								Priority = 50,
								AttackID = "Kid Neji 64 Palms",
							})
							StateShortCuts:StunSpeed(Victim,{
								Prior = 55,
								Duration = SkillData.Stun,
								Speed = 0,
							})
							
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
							
							if Players:GetPlayerFromCharacter(Victim) == nil and Victim and Players:GetPlayerFromCharacter(Character) then
								if Victim.PrimaryPart and Victim.PrimaryPart.Anchored == false then
									for _,v in ipairs(Victim:GetChildren()) do
										if v:IsA("BasePart") and v.Anchored == false then
											v:SetNetworkOwner(Players:GetPlayerFromCharacter(Character))
										end
									end
								end
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
								Parent = Victim.PrimaryPart,
								Volume = 1,
							},{},{
								Range = 100,
								Origin = Victim.PrimaryPart.CFrame.p
							})
						elseif HitResult == "PerfectBlock" then
							CombatService:PerfectBlock(Victim,Character,{
								CanTP = true,
								MaxDist = 16,
							})
						end
					end)
					
					HitBox:Start()
					task.wait(SkillData.Rate)
				end
				
				RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
					Task = "StopAnimation",
					AnimationData = {
						Name = RS.Assets.Animations.Shared.Neji["64 palms"]["64During"].Name,
						AnimationSpeed = 1,
						Weight = 3.5,
						FadeTime = 0.25,
						Looped = true,
					}
				})
				
				if not ForceEnd then
					Util:SignalMarker(RS.Assets.Animations.Shared.Neji["64 palms"]["64End"],"Hit"):Connect(function()
						local HitBox = HitBoxService:CRepeatCFrame({
							BreakOnHit = true,
							MultHit = true,
							OffsetPart = Character.PrimaryPart,
							HitOnce = true,
							Offset = CFrame.new(0,0,-5.5),
							Size = Vector3.new(4,4,6.5),
							Dur = .2,
							Visual = false,
							Caster = Character,
						})
						
						HitBox.OnHit:Connect(function(Victim)
							local HitResult = StateShortCuts:GetHitResult({
								Attacker = Character,
								Victim = Victim,
								HitData = {
									BlockBreak = false,
									CanPB = true,
								},
							})
							
							if HitResult == "Hit" then
								DamageService:DamageEntities({
									Attacker = Character,
									Damage = SkillData.Damage * 6,
									Victim = Victim
								})

								if Players:GetPlayerFromCharacter(Character) then
									PointsService:AddPoints(Players:GetPlayerFromCharacter(Character),SkillData.Points)
								end

								local BV = Instance.new("BodyVelocity")
								BV.MaxForce = Vector3.new(4e4,4e4,4e4)
								BV.Velocity = (Character.PrimaryPart.CFrame.LookVector * 60.5) + Vector3.new(0,3,0)
								BV.Parent = Victim.PrimaryPart
								Debris:AddItem(BV,.15)
								
								StateShortCuts:StunCharacter({
									Victim = Victim,
									Attacker = Character,
									WasAttack = true,
									Duration = SkillData.Stun,
									Priority = 50,
									AttackID = "Kid Neji 64 Palms",
								})
								StateShortCuts:StunSpeed(Victim,{
									Prior = 55,
									Duration = SkillData.Stun,
									Speed = 0,
								})

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
								
								if Players:GetPlayerFromCharacter(Victim) == nil and Victim and Players:GetPlayerFromCharacter(Character) then
									if Victim.PrimaryPart and Victim.PrimaryPart.Anchored == false then
										for _,v in ipairs(Victim:GetChildren()) do
											if v:IsA("BasePart") and v.Anchored == false then
												v:SetNetworkOwner(Players:GetPlayerFromCharacter(Character))
											end
										end
									end
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
									Parent = Victim.PrimaryPart,
									Volume = 1,
								},{},{
									Range = 100,
									Origin = Victim.PrimaryPart.CFrame.p
								})
							elseif HitResult == "PerfectBlock" then
								CombatService:PerfectBlock(Victim,Character,{
									CanTP = true,
									MaxDist = 16,
								})
							end
						end)
						HitBox:Start()
					end)

					RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
						Task = "PlayAnimation",
						AnimationData = {
							Name = RS.Assets.Animations.Shared.Neji["64 palms"]["64End"].Name,
							AnimationSpeed = 1,
							Weight = 3.5,
							FadeTime = 0.25,
							Looped = false,
						}
					})
				else
				end
				
				Character.PrimaryPart.Anchored = false
				Character.Humanoid.AutoRotate = true
				
				StateShortCuts:StunSpeed(Character,{
					Prior = 61,
					Duration = 0.01,
					Speed = 14,
				})
				StateService:SetState(Character,"UsingSkill",{
					LP = 55,
					Dur = 0.35,
				})
				StateService:SetState(Character,"CantRun",{
					LP = 55,
					Dur = 0.35,
				})
				StateService:SetState(Character,"CantM1",{
					LP = 55,
					Dur = 0.35,
				})
				StateShortCuts:BoostSpeeds(Character,{
					Prior = 55,
					Dur = 0.01,
					WalkSpeed = 16,
					RunSpeed = 25,
				})
				CooldownService:SetCooldown(Character,CharacterID,"SecondSkill",{
					Hold = false
				})
				CooldownService:SetCooldown(Character,CharacterID,"SecondSkill",{
					CD = SkillData.Cooldown
				})
				SkillService:FireClientVFX(Player,CharacterID,"SecondSkill","RemovePlam",{
					Character = Character,
					UID = SkillUID
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
			
			local SkillData = require(SS.Modules.MetaData.CharacterData)[CharacterID]["SkillData"]["ThirdSkill"]

			if not CooldownService:CheckCooldown(Character,CharacterID,"ThirdSkill") then return end
			if StateService:GetState(Character,"Stunned") then return end
			if StateService:GetState(Character,"UsingSkill") then return end
			if StateService:GetState(Character,"Swing") then return end
			
			local Player = Players:GetPlayerFromCharacter(Character)
			
			local CombatService = require(SS.Modules.Services.CombatService)
			
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
			
			CooldownService:SetCooldown(Character,CharacterID,"ThirdSkill",{
				Hold = true
			})
			
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
			
			local MouseHit = SkillService:GetMouse(Players:GetPlayerFromCharacter(Character))
			
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
						CooldownService:SetCooldown(Character,CharacterID,"ThirdSkill",{
							Hold = false
						})
						CooldownService:SetCooldown(Character,CharacterID,"ThirdSkill",{
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
				
				local StartPoint = Character.PrimaryPart.CFrame * CFrame.new(0,2,-2)
				local Goal = (MouseHit.p)

				local Direction = (MouseHit.p - StartPoint.p).Unit
				local Velocity = SkillData.Speed
				local Duration = SkillData.Duration
				local Acceleration = SkillData.Acceleration
				
				if StateService:GetState(Character,"NejiUlt") then
					StartPoint = Character.PrimaryPart.CFrame * CFrame.new(0,2,-2)
					Goal = TargetPlayer.PrimaryPart.CFrame
					Direction = (Goal.p - StartPoint.p).Unit
					Velocity = SkillData.SpeedUlt
					Duration = SkillData.DurationUlt
					Acceleration = SkillData.AccelerationUlt
				end
				
				local ShurikenHitBox = HitBoxService:AoeProjectile()
				local Points = ShurikenHitBox:GetRayCastSquarePoints(StartPoint,1,1)
				
				ShurikenHitBox.HitTask:Connect(function(HitTable)
					local HitParent = HitTable.HitInstance.Parent
					local Victim
					
					SoundService:PlaySoundAt("Explosion",{
						Parent = Character.PrimaryPart,
						Volume = 0.75,
					},{
						CFrame = CFrame.new(HitTable.Position)
					},{
						Range = 25,
						Origin = Character.PrimaryPart.CFrame.p
					})
					
					if not HitParent:FindFirstChild("IsShadowClone") and HitParent:FindFirstChild("Humanoid") and HitParent:FindFirstChild("Humanoid").Health > 0 and HitParent:IsDescendantOf(workspace.World.Entities) then
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
								Duration = 1.24,
								Speed = 0,
							})
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
								Parent = Victim.PrimaryPart,
								Volume = 1,
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
					local Hitbox = HitBoxService:BoxCFrame()
					local HitTable2 = Hitbox:Fire({
						BreakOnHit = false,
						MultHit = true,
						CFrame = CFrame.new(HitTable.Position),
						HitOnce = true,
						Offset = CFrame.new(0,0,0),
						Size = SkillData.HitboxSize,
						Caster = Character,
						Visual = false
					})
					for _,AVictim in pairs(HitTable2) do
						local HitResult = StateShortCuts:GetHitAoeResult({
							Attacker = Character,
							Victim = AVictim,
							Origin	= HitTable.Position,
							HitData = {
								BlockBreak = false,
								CanPB = false,
							},
						})
						if HitResult == "Hit" then
							StateShortCuts:StunSpeed(AVictim,{
								Prior = 55,
								Duration = 1.24,
								Speed = 0,
							})
							DamageService:DamageEntities({
								Attacker = Character,
								Damage = SkillData.Damage,
								Victim = AVictim,
							})
							
							local Velo = Instance.new("BodyVelocity")
							Velo.Velocity = Vector3.new(0,8,0) + (AVictim.PrimaryPart.Position - HitTable.Position).Unit * 40
							Velo.MaxForce = Vector3.new(10e4,10e4,10e4)
							Velo.Parent = AVictim.PrimaryPart
							Debris:AddItem(Velo,.15)
							
							if Players:GetPlayerFromCharacter(AVictim) == nil and AVictim and Players:GetPlayerFromCharacter(Character) then
								if AVictim.PrimaryPart and AVictim.PrimaryPart.Anchored == false then
									for _,v in ipairs(AVictim:GetChildren()) do
										if v:IsA("BasePart") and v.Anchored == false then
											v:SetNetworkOwner(Players:GetPlayerFromCharacter(Character))
										end
									end
								end
							end


							StateShortCuts:StunCharacter({
								Victim = AVictim,
								Attacker = Character,
								WasAttack = true,
								Duration = SkillData.Stun,
								Priority = 55,
								AttackID = "KidNejiExplosion",
							})

							if Players:GetPlayerFromCharacter(Character) then
								PointsService:AddPoints(Players:GetPlayerFromCharacter(Character),SkillData.Points)
								PointsService:AddToCombo(Players:GetPlayerFromCharacter(Character),1)
							end


							if Players:GetPlayerFromCharacter(AVictim) then
								RemoteComs:FireClientEvent(Players:GetPlayerFromCharacter(AVictim),{FunctionName = "AnimationService" },{
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
								AVictim.Humanoid.Animator:LoadAnimation(RS.Assets.Animations.Shared.Combat["Stun"..math.random(1,2)]):Play()
							end
						elseif HitResult == "Blocking" then
							RemoteComs:FireAllClientsEvent({FunctionName = "VFX"},{FName = "RegBlockEffect",FData = {
								Character = Character,
								Victim = AVictim,
							}})

							SoundService:PlaySound("CombatBlockhit",{
								Parent = Victim.PrimaryPart,
								Volume = 1,
							},{},{
								Range = 100,
								Origin = Victim.PrimaryPart.CFrame.p
							})
						elseif HitResult == "PerfectBlock" then
							CombatService:PerfectBlock(AVictim,Character,{
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
					SkillService:FireClientVFX(Player,CharacterID,"ThirdSkill","ExpKunai",{
						Character = Character,
						Location = HitTable.Position,
						UID = SkillUID
					})
				end)
				
				SkillService:FireClientVFX(Player,CharacterID,"ThirdSkill","SpawnKunai",{
					Character = Character,
					StartPoint = StartPoint,
					Acceleration = Acceleration,
					Velocity = Velocity,
					Direction = Direction,
					Duration = Duration,
					UID = SkillUID
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
				
				SoundService:PlaySound("KakaShuriThrow",{
					Parent = Character.PrimaryPart,
					Volume = 0.75,
				},{},{
					Range = 25,
					Origin = Character.PrimaryPart.CFrame.p
				})
				
				BP:Destroy()
				BP = nil
				CombatService:ResetM1s(Character)
				CooldownService:SetCooldown(Character,CharacterID,"ThirdSkill",{
					Hold = false
				})
				CooldownService:SetCooldown(Character,CharacterID,"ThirdSkill",{
					CD = SkillData.Cooldown
				})
				StateService:SetState(Character,"UsingSkill",{
					LP = 55,
					Dur = 0.01,
				})
				StateService:SetState(Character,"CantRun",{
					LP = 55,
					Dur = 0.1,
				})
				StateService:SetState(Character,"CantM1",{
					LP = 55,
					Dur = 0.01,
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
			
			local CombatService = require(SS.Modules.Services.CombatService)
			
			local Player = Players:GetPlayerFromCharacter(Character)
			if not CooldownService:CheckCooldown(Character,CharacterID,"FourthSkill") then return end
			if StateService:GetState(Character,"Stunned") then return end
			if StateService:GetState(Character,"UsingSkill") then return end
			if StateService:GetState(Character,"Swing") then return end
			
			CooldownService:SetCooldown(Character,CharacterID,"FourthSkill",{
				Hold = true
			})

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
			StateShortCuts:StunSpeed(Character,{
				Prior = 60,
				Duration = 10,
				Speed = 8
			})
			
			StateShortCuts:BoostSpeeds(Character,{
				Prior = 55,
				Dur = 5,
				WalkSpeed = 0,
				RunSpeed = 0,
			})
			
			RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
				Task = "PlayAnimation",
				AnimationData = {
					Name = RS.Assets.Animations.Shared.Neji.Neji4th.Name,
					AnimationSpeed = 1,
					Weight = 8,
					FadeTime = 0.05,
					Looped = false,
				}
			})
			
			local CheckOver = false
			local HyperArmor = false
			
			task.spawn(function()
				repeat
					if StateService:GetState(Character,"Stunned") then
						HyperArmor = true
						
						RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
							Task = "StopAnimation",
							AnimationData = {
								Name = RS.Assets.Animations.Shared.Neji.Neji4th.Name,
								AnimationSpeed = 1,
								Weight = 8,
								FadeTime = 0.05,
								Looped = false,
							}
						})
						
						StateService:SetState(Character,"UsingSkill",{
							LP = 55,
							Dur = 0.5,
						})
						StateService:SetState(Character,"CantRun",{
							LP = 55,
							Dur = 0.1,
						})
						StateService:SetState(Character,"CantM1",{
							LP = 55,
							Dur = 0.2,
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
						StateShortCuts:StunSpeed(Character,{
							Prior = 60,
							Duration = 0.1,
							Speed = 8
						})
					end
					RunService.Heartbeat:Wait()
				until CheckOver or HyperArmor
			end)
			
			Util:SignalMarker(RS.Assets.Animations.Shared.Neji.Neji4th,"HyperArmor"):Connect(function()
				CheckOver = true
			end)
			
			Util:SignalMarker(RS.Assets.Animations.Shared.Neji.Neji4th,"Fire"):Connect(function()
				if HyperArmor then return end
				
				local Velo = Instance.new("BodyVelocity")
				Velo.Velocity = Character.PrimaryPart.CFrame.LookVector * 65
				Velo.MaxForce = Vector3.new(10e4,10e4,10e4)
				Velo.Parent = Character.PrimaryPart
				Debris:AddItem(Velo,.15)
				
				local HitBox = HitBoxService:CRepeatCFrame({
					BreakOnHit = true,
					MultHit = true,
					OffsetPart = Character.PrimaryPart,
					HitOnce = true,
					Offset = CFrame.new(0,0,-5.5),
					Size = Vector3.new(5,5,6.5),
					Dur = .3,
					Visual = false,
					Caster = Character,
				})
				
				HitBox.OnHit:Connect(function(Victim)
					local HitResult = StateShortCuts:GetHitResult({
						Attacker = Character,
						Victim = Victim,
						HitData = {
							BlockBreak = true,
							CanPB = true,
						},
					})
					
					if HitResult == "Hit" or HitResult == "GuardBreak" then
						DamageService:DamageEntities({
							Attacker = Character,
							Damage = SkillData.Damage,
							Victim = Victim
						})

						if Players:GetPlayerFromCharacter(Character) then
							PointsService:AddPoints(Players:GetPlayerFromCharacter(Character),SkillData.Points)
						end

						if HitResult == "Hit" then
							local BV = Instance.new("BodyVelocity")
							BV.MaxForce = Vector3.new(4e4,4e4,4e4)
							BV.Velocity = (Character.PrimaryPart.CFrame.LookVector * 60.5) + Vector3.new(0,3,0)
							BV.Parent = Victim.PrimaryPart
							Debris:AddItem(BV,.15)
						else
							CombatService:GuardBreak(Victim)
						end

						StateShortCuts:StunCharacter({
							Victim = Victim,
							Attacker = Character,
							WasAttack = true,
							Duration = 1.75,
							Priority = 50,
							AttackID = "Kid Neji Shotei",
						})
						
						StateShortCuts:StunSpeed(Victim,{
							Prior = 55,
							Duration = SkillData.Stun,
							Speed = 0,
						})

						if HitResult == "Hit" then
							RemoteComs:FireAllClientsEvent({FunctionName = "VFX"},{FName = "RegM1Hit",FData = {
								Character = Character,
								Victim = Victim,
							}})
						end
						
						SoundService:PlaySound("CombatHit",{
							Parent = Victim.PrimaryPart,
							Volume = 1,
						},{},{
							Range = 100,
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
				end)
				
				HitBox:Start()
				
				StateService:SetState(Character,"UsingSkill",{
					LP = 55,
					Dur = 0.15,
				})
				StateService:SetState(Character,"CantRun",{
					LP = 55,
					Dur = 0.1,
				})
				StateService:SetState(Character,"CantM1",{
					LP = 55,
					Dur = 0.05,
				})
				StateShortCuts:BoostSpeeds(Character,{
					Prior = 55,
					Dur = 0.01,
					WalkSpeed = 16,
					RunSpeed = 25,
				})
				StateShortCuts:StunSpeed(Character,{
					Prior = 60,
					Duration = 0.1,
					Speed = 8
				})
				CooldownService:SetCooldown(Character,CharacterID,"FourthSkill",{
					Hold = false
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
			
			PointsService:UltGain(Player,false)
			PointsService:ResetUltPoints(Player)
			
			StateService:SetState(Character,"NejiUlt",{
				Value = true
			})
			
			local UltActive = true
			
			SkillService:FireClientVFX(Player,CharacterID,"UltimateSkill","UltAura",{
				Character = Character,
				UID = SkillUID
			})
			
			SkillService:FireOneClientVFX(Player,CharacterID,"UltimateSkill","EyeOn",{
				Character = Character,
				UID = SkillUID
			})
			
			Character.Humanoid.Died:Connect(function()
				if UltActive == true then
					PointsService:UltGain(Player,true)
					SkillService:FireClientVFX(Player,CharacterID,"UltimateSkill","UltAuraOff",{
						Character = Character,
						UID = SkillUID
					})
					SkillService:FireOneClientVFX(Player,CharacterID,"UltimateSkill","EyeOff",{
						Character = Character,
						UID = SkillUID
					})
					UltActive = false
					StateService:SetState(Character,"NejiUlt",{
						Value = false
					})
				end
			end)
			
			local SkillsUI = Players:GetPlayerFromCharacter(Character).PlayerGui.Interface.Abilities
			SkillsUI.FirstAbility.Ability:GetPropertyChangedSignal("Text"):Connect(function()
				UltActive = false
				PointsService:UltGain(Player,true)
				StateService:SetState(Character,"NejiUlt",{
					Value = false
				})
				SkillService:FireClientVFX(Player,CharacterID,"UltimateSkill","UltAuraOff",{
					Character = Character,
					UID = SkillUID
				})
				SkillService:FireOneClientVFX(Player,CharacterID,"UltimateSkill","EyeOff",{
					Character = Character,
					UID = SkillUID
				})
			end)
			
			task.delay(30, function()
				UltActive = false
				PointsService:UltGain(Player,true)
				StateService:SetState(Character,"NejiUlt",{
					Value = false
				})
				SkillService:FireClientVFX(Player,CharacterID,"UltimateSkill","UltAuraOff",{
					Character = Character,
					UID = SkillUID
				})
				SkillService:FireOneClientVFX(Player,CharacterID,"UltimateSkill","EyeOff",{
					Character = Character,
					UID = SkillUID
				})
			end)
		end,
	}
}

return OldKakashi
