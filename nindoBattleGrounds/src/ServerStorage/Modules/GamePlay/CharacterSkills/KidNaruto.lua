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

local CharacterID = "KidNaruto"

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
			
			local CombatService = require(SS.Modules.Services.CombatService)
			
			if not CooldownService:CheckCooldown(Character,CharacterID,"FirstSkill") then return end
			if StateService:GetState(Character,"Stunned") then return end
			if StateService:GetState(Character,"UsingSkill") then return end
			if StateService:GetState(Character,"Swing") then return end

			local Player = Players:GetPlayerFromCharacter(Character)

			local ChargeTime = SkillData.ChargeTime
			Character.PrimaryPart.Anchored = true
			Character.Humanoid.AutoRotate = false

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
			StateService:SetState(Character,"CantM1",{
				LP = 55,
				Dur = 20,
			})
			
			SkillService:FireClientVFX(Player,CharacterID,"FirstSkill","CloneSpawn",{
				Character = Character,
				ChargeTime = ChargeTime,
				UID = SkillUID
			})
			
			RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
				Task = "PlayAnimation",
				AnimationData = {
					Name = RS.Assets.Animations.Shared.KidNaruto.ChargeReg.Name,
					AnimationSpeed = 1,
					Weight = 3.5,
					FadeTime = 0.25,
					Looped = true,
				}
			})
			
			SoundService:PlaySound("KidNarutoRasCharge",{
				Parent = Character.PrimaryPart,
				Volume = 0.75,
			},{},{
				Range = 100,
				Origin = Character.PrimaryPart.CFrame.p
			})
			
			local RaseStart = true
			local Start = os.clock()
			
			task.spawn(function()
				while (os.clock() - Start) < ChargeTime do
					if RaseStart and StateService:GetState(Character,"Stunned") then
						RaseStart = false
						
						RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
							Task = "StopAnimation",
							AnimationData = {
								Name = RS.Assets.Animations.Shared.KidNaruto.ChargeReg.Name,
								AnimationSpeed = 1,
								Weight = 3.5,
								FadeTime = 0.25,
								Looped = false,
							}
						})
						
						Character.PrimaryPart.Anchored = false
						Character.Humanoid.AutoRotate = true
						
						CooldownService:SetCooldown(Character,CharacterID,"FirstSkill",{
							Hold = false
						})
						CooldownService:SetCooldown(Character,CharacterID,"FirstSkill",{
							CD = SkillData.Cooldown
						})
						
						StateService:SetState(Character,"CantRun",{
							LP = 65,
							Dur = 0.01,
						})
						StateService:SetState(Character,"UsingSkill",{
							LP = 50,
							Dur = 0.01,
						})
						StateService:SetState(Character,"CantM1",{
							LP = 55,
							Dur = 0.01,
						})
						
						SkillService:FireClientVFX(Player,CharacterID,"FirstSkill","RaseOff",{
							Character = Character,
							UID = SkillUID
						})
						break
					end
					RunService.Heartbeat:Wait()
				end
			end)
			
			task.delay(ChargeTime/4,function()
				if not RaseStart then return end
				
				SkillService:FireClientVFX(Player,CharacterID,"FirstSkill","Rase",{
					Character = Character,
					UID = SkillUID
				})
			end)
			
			task.delay(ChargeTime,function()
				if not RaseStart then return end
				
				RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
					Task = "StopAnimation",
					AnimationData = {
						Name = RS.Assets.Animations.Shared.KidNaruto.ChargeReg.Name,
						AnimationSpeed = 1,
						Weight = 3.5,
						FadeTime = 0.25,
						Looped = false,
					}
				})
				
				Character.PrimaryPart.Anchored = false
				Character.Humanoid.AutoRotate = true
				
				RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
					Task = "PlayAnimation",
					AnimationData = {
						Name = "RasgRun",
						AnimationSpeed = 1,
						Weight = 1,
						FadeTime = 0.25,
						Looped = true,
					}
				})
				
				StateService:GetProfile(Character).StateData["RunID"].Name = "RasgRun"
				
				StateService:SetState(Character,"CantRun",{
					LP = 66,
					Dur = 0.01,
				})
				StateService:SetState(Character,"CantM1",{
					LP = 57,
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
				
				local Start = os.clock()
				
				task.spawn(function()
					while (os.clock() - Start) < SkillData.Length do
						if RaseStart and StateService:GetState(Character,"Stunned") then
							RaseStart = false
							
							StateService:SetState(Character,"CantRun",{
								LP = 66,
								Dur = 0.01,
							})
							StateService:SetState(Character,"UsingSkill",{
								LP = 50,
								Dur = 0.01,
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
									Name = "RasgRun",
									AnimationSpeed = 1,
									Weight = 1,
									FadeTime = 0.25,
									Looped = true,
								}
							})
							
							StateService:GetProfile(Character).StateData["RunID"].Name = "DfRun"
							SkillService:FireClientVFX(Player,CharacterID,"FirstSkill","RaseOff",{
								Character = Character,
								UID = SkillUID
							})
							
							StateShortCuts:BoostSpeeds(Character,{
								Prior = 56,
								Dur = 0.01,
								WalkSpeed = 16,
								RunSpeed = 25,
							})
							break
						end
						RunService.Heartbeat:Wait()
					end
				end)
				
				task.delay(SkillData.Length,function()
					if RaseStart then
						StateService:SetState(Character,"CantRun",{
							LP = 66,
							Dur = 0.01,
						})
						StateService:SetState(Character,"UsingSkill",{
							LP = 50,
							Dur = 0.01,
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
								Name = "RasgRun",
								AnimationSpeed = 1,
								Weight = 1,
								FadeTime = 0.25,
								Looped = true,
							}
						})
						
						StateService:GetProfile(Character).StateData["RunID"].Name = "DfRun"
						SkillService:FireClientVFX(Player,CharacterID,"FirstSkill","RaseOff",{
							Character = Character,
							UID = SkillUID
						})
						
						StateShortCuts:BoostSpeeds(Character,{
							Prior = 56,
							Dur = 0.01,
							WalkSpeed = 16,
							RunSpeed = 25,
						})
					end
				end)
				
				local HitBox = HitBoxService:CRepeatCFrame({
					BreakOnHit = true,
					MultHit = false,
					OffsetPart = Character.PrimaryPart,
					HitOnce = true,
					Offset = CFrame.new(0,0,-4.5),
					Size = Vector3.new(4.5,4.5,7.5),
					Dur = SkillData.Length - 0.05,
					Visual = false,
					Caster = Character,
				})
				
				HitBox.OnHit:Connect(function(Victim)
					if not RaseStart then return end
					
					task.delay(1, function()
						RaseStart = false
					end)
					
					local HitResult = StateShortCuts:GetHitResult({
						Attacker = Character,
						Victim = Victim,
						HitData = {
							BlockBreak = true,
							CanPB = true,
						},
					})
					
					if HitResult == "Hit" or HitResult == "GuardBreak" then
						if Players:GetPlayerFromCharacter(Victim) == nil and Victim and Players:GetPlayerFromCharacter(Character) then
							if Victim.PrimaryPart and Victim.PrimaryPart.Anchored == false then
								for _,v in ipairs(Victim:GetChildren()) do
									if v:IsA("BasePart") and v.Anchored == false then
										v:SetNetworkOwner(Players:GetPlayerFromCharacter(Character))
									end
								end
							end
						end

						Victim.Humanoid.AutoRotate = false
						Character.Humanoid.AutoRotate = false
						Character.PrimaryPart.Anchored = true
						Victim.PrimaryPart.Anchored = true

						--local TeleCFrame = CFrame.lookAt((Victim.PrimaryPart.CFrame * CFrame.new(0,0.01,-5)).Position,Victim.PrimaryPart.CFrame.Position)
						--Victim.PrimaryPart.CFrame = CFrame.new(Victim.PrimaryPart.CFrame.Position,Character.PrimaryPart.CFrame.Position)
						--Character.PrimaryPart.CFrame = TeleCFrame
						Victim.PrimaryPart.CFrame = CFrame.new(Victim.PrimaryPart.CFrame.Position,Character.PrimaryPart.CFrame.Position)
						
						task.delay(.05, function()
							if Victim and Victim.PrimaryPart then
								Victim.PrimaryPart.Anchored = false
								Victim.Humanoid.AutoRotate = true
							end
							
							Character.Humanoid.AutoRotate = true
							Character.PrimaryPart.Anchored = false

							if HitResult == "GuardBreak" then
								CombatService:GuardBreak(Victim)
							else
								if Players:GetPlayerFromCharacter(Victim) then
									RemoteComs:FireClientEvent(Players:GetPlayerFromCharacter(Victim),{FunctionName = "AnimationService" },{
										Task = "PlayAnimation",
										AnimationData = {
											Name = "RasVictimHit",
											AnimationSpeed = 1,
											Weight = 1,
											FadeTime = 0.25,
											Looped = false,
										}
									})
								else
									Victim.Humanoid.Animator:LoadAnimation(RS.Assets.Animations.Shared.KidNaruto.RasVictimHit):Play()
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
							
							StateService:SetState(Character,"CantRun",{
								LP = 66,
								Dur = 0.01,
							})
							StateService:SetState(Character,"UsingSkill",{
								LP = 50,
								Dur = 0.01,
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
									Name = "RasgRun",
									AnimationSpeed = 1,
									Weight = 1,
									FadeTime = 0.25,
									Looped = false,
								}
							})
							StateService:GetProfile(Character).StateData["RunID"].Name = "DfRun"
							
							SkillService:FireClientVFX(Player,CharacterID,"FirstSkill","RaseHit",{
								Character = Character,
								Victim = Victim,
								UID = SkillUID
							})
							
							StateShortCuts:StunCharacter({
								Victim = Victim,
								Attacker = Character,
								WasAttack = true,
								Duration = SkillData.Stun,
								Priority = 50,
								AttackID = "KidNarutoRase",
							})
							StateShortCuts:StunSpeed(Victim,{
								Prior = 55,
								Duration = SkillData.Stun,
								Speed = 0,
							})

							StateShortCuts:BoostSpeeds(Character,{
								Prior = 56,
								Dur = 0.01,
								WalkSpeed = 16,
								RunSpeed = 25,
							})

							if HitResult ~= "GuardBreak" then
								local Velocity = Instance.new("BodyVelocity")
								Velocity.MaxForce = Vector3.new(20e4,20e4,20e4)
								Velocity.Velocity = Vector3.new(0,2,0) + Character.PrimaryPart.CFrame.LookVector * 75
								Velocity.Parent = Victim.PrimaryPart
								Debris:AddItem(Velocity,.55)
							end
						end)
					elseif HitResult == "PerfectBlock" then
						CombatService:PerfectBlock(Victim,Character,{
							CanTP = true,
							MaxDist = 16,
						})
						
						StateService:SetState(Character,"CantRun",{
							LP = 66,
							Dur = 0.01,
						})
						StateService:SetState(Character,"UsingSkill",{
							LP = 50,
							Dur = 0.01,
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
								Name = "RasgRun",
								AnimationSpeed = 1,
								Weight = 1,
								FadeTime = 0.25,
								Looped = true,
							}
						})
						StateService:GetProfile(Character).StateData["RunID"].Name = "DfRun"
						SkillService:FireClientVFX(Player,CharacterID,"FirstSkill","RaseOff",{
							Character = Character,
							UID = SkillUID
						})
						
						StateShortCuts:BoostSpeeds(Character,{
							Prior = 56,
							Dur = 0.01,
							WalkSpeed = 16,
							RunSpeed = 25,
						})
					elseif HitResult == "IFrame" then
						StateService:SetState(Character,"CantRun",{
							LP = 66,
							Dur = 0.01,
						})
						StateService:SetState(Character,"UsingSkill",{
							LP = 50,
							Dur = 0.01,
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
								Name = "RasgRun",
								AnimationSpeed = 1,
								Weight = 1,
								FadeTime = 0.25,
								Looped = true,
							}
						})
						StateService:GetProfile(Character).StateData["RunID"].Name = "DfRun"

						
						SkillService:FireClientVFX(Player,CharacterID,"FirstSkill","RaseOff",{
							Character = Character,
							UID = SkillUID
						})


						StateShortCuts:BoostSpeeds(Character,{
							Prior = 56,
							Dur = 0.01,
							WalkSpeed = 16,
							RunSpeed = 25,
						})
					elseif HitResult:match("Counter") then
						StateService:SetState(Character,"CantRun",{
							LP = 66,
							Dur = 0.01,
						})
						StateService:SetState(Character,"UsingSkill",{
							LP = 50,
							Dur = 0.01,
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
								Name = "RasgRun",
								AnimationSpeed = 1,
								Weight = 1,
								FadeTime = 0.25,
								Looped = true,
							}
						})
						
						StateService:GetProfile(Character).StateData["RunID"].Name = "DfRun"
						
						SkillService:FireClientVFX(Player,CharacterID,"FirstSkill","RaseOff",{
							Character = Character,
							UID = SkillUID
						})
						
						StateShortCuts:BoostSpeeds(Character,{
							Prior = 56,
							Dur = 0.01,
							WalkSpeed = 16,
							RunSpeed = 25,
						})
						
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

			local SkillData = require(SS.Modules.MetaData.CharacterData)[CharacterID]["SkillData"]["SecondSkill"]

			if not CooldownService:CheckCooldown(Character,CharacterID,"SecondSkill") then return end
			if StateService:GetState(Character,"Stunned") then return end
			if StateService:GetState(Character,"UsingSkill") then return end
			
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
					CD = 1
				})
				return
			end
			
			Character.Archivable = true
			
			local Clone = Character:Clone()
			Clone.PrimaryPart.Anchored = false
			Character.Archivable = false
			
			for Index, Part in ipairs(Clone:GetDescendants()) do
				if Part:IsA("BasePart") then
					PhysicsService:SetPartCollisionGroup(Part, "Clone")
				end
			end
			
			local Script = SS.Modules.Scripts.ShadowClone.Brain:Clone()
			Script.Length.Value = SkillData.Length
			Script.Damage.Value = SkillData.Damage
			Script.Target.Value = TargetPlayer
			Script.Caster.Value = Character
			
			Script.Parent = Clone
			Clone.PrimaryPart.CFrame = CFrame.lookAt((Character.PrimaryPart.CFrame * CFrame.new(5,0,-2)).Position,TargetPlayer.PrimaryPart.CFrame.Position)
			Clone.Parent = workspace.World.Effects
			
			RemoteComs:FireAllClientsEvent({FunctionName = "VFX"},{FName = "Sub",FData = {
				Pos = CFrame.lookAt((Character.PrimaryPart.CFrame * CFrame.new(5,0,-2)).Position,TargetPlayer.PrimaryPart.CFrame.Position),
				Log = true,
			}})
			
			Script.Enabled = true
			
			CooldownService:SetCooldown(Character,CharacterID,"SecondSkill",{
				Hold = false
			})
			CooldownService:SetCooldown(Character,CharacterID,"SecondSkill",{
				CD = SkillData.Cooldown
			})
			
			task.delay(SkillData.Length, function()
				PhysicsService:UnregisterCollisionGroup("Clone")
			end)
		end,
	},
	["ThirdSkill"] = {
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
			
			local CombatService = require(SS.Modules.Services.CombatService)
			
			local SkillData = require(SS.Modules.MetaData.CharacterData)[CharacterID]["SkillData"]["ThirdSkill"]
			
			if not CooldownService:CheckCooldown(Character,CharacterID,"ThirdSkill") then return end
			if StateService:GetState(Character,"Stunned") then return end
			if StateService:GetState(Character,"UsingSkill") then return end
			if StateService:GetState(Character,"Swing") then return end
			
			local Player = Players:GetPlayerFromCharacter(Character)

			CooldownService:SetCooldown(Character,CharacterID,"ThirdSkill",{
				Hold = true
			})

			StateService:SetState(Character,"CantRun",{
				LP = 55,
				Dur = 1,
			})
			StateService:SetState(Character,"UsingSkill",{
				LP = 55,
				Dur = 1,
			})
			StateService:SetState(Character,"CantM1",{
				LP = 55,
				Dur = 1,
			})
			
			RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
				Task = "PlayAnimation",
				AnimationData = {
					Name = "GrabForUzi",
					AnimationSpeed = 1,
					Weight = 3,
					FadeTime = 0.25,
					Looped = false,
				}
			})
			
			local HitBox = HitBoxService:CRepeatCFrame({
				BreakOnHit = true,
				MultHit = false,
				OffsetPart = Character.PrimaryPart,
				HitOnce = true,
				Offset = CFrame.new(0,0,-5.5),
				Size = SkillData.GrabHitBox,
				Dur = 0.3,
				Visual = false,
				Caster = Character,
			})
			
			task.spawn(function()
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
						local function Clone(char)
							char.Archivable = true
							
							local Clone = char:Clone()
							char.Archivable = false
							
							for Index, Part in ipairs(Clone:GetDescendants()) do
								if Part:IsA("BasePart") then
									Part.CanCollide = false
									PhysicsService:SetPartCollisionGroup(Part, "Clone")
								end
							end
							
							return Clone
						end
						
						local AirClone = Clone(Character)
						AirClone.Parent = workspace.World.Effects
						
						Character.PrimaryPart.Anchored = true
						Character.Humanoid.AutoRotate = false
						
						Victim.PrimaryPart.Anchored = true
						Victim.Humanoid.AutoRotate = false
						Victim.PrimaryPart.AssemblyLinearVelocity = Vector3.new(0,0,0)
						Victim.PrimaryPart.AssemblyAngularVelocity = Vector3.new(0,0,0)
						
						local X,Y,Z = Victim.PrimaryPart.CFrame:ToEulerAnglesXYZ()
						
						local Offset = Vector3.new(-0.92681884765625, 0.9724082946777344, -1.4127197265625)
						local AirDummyLocation = CFrame.new(Victim.PrimaryPart.CFrame.Position + (Character.PrimaryPart.CFrame.LookVector * 10) + Vector3.new(0,25,0)) * CFrame.Angles(X,Y,Z)
						local AirVicLocation = CFrame.new(AirDummyLocation.p + Vector3.new(-0.92681884765625, 0.9724082946777344, -1.4127197265625)) * CFrame.Angles(X,Y,Z)
						
						local AnimationSpeedFactor = 0.1666
						
						if Victim.PrimaryPart:FindFirstChild("GroundM1BP") then
							Victim.PrimaryPart:FindFirstChild("GroundM1BP"):Destroy()
						end
						
						if Victim.PrimaryPart:FindFirstChild("AirM1BP") then
							Victim.PrimaryPart:FindFirstChild("AirM1BP"):Destroy()
						end
						
						if Players:GetPlayerFromCharacter(Victim) then
							RemoteComs:FireClientEvent(Players:GetPlayerFromCharacter(Victim),{FunctionName = "AnimationService" },{
								Task = "PlayAnimation",
								AnimationData = {
									Name = "VictimGrab",
									AnimationSpeed = AnimationSpeedFactor,
									Weight = 1,
									FadeTime = 0.25,
									Looped = false,
								}
							})
						else
							task.spawn(function()
								local Anim = Victim.Humanoid.Animator:LoadAnimation(RS.Assets.Animations.Shared.KidNaruto.VictimGrab)
								Anim:Play()
								Anim:AdjustSpeed(AnimationSpeedFactor)
							end)
						end
						
						Util:SignalMarker(RS.Assets.Animations.Shared.KidNaruto.VictimGrab,"AirComboStart"):Connect(function()
							Character.PrimaryPart.Anchored = false
							Character.Humanoid.AutoRotate = true
							
							RemoteComs:FireAllClientsEvent({FunctionName = "VFX"},{FName = "Sub",FData = {
								Pos = AirDummyLocation,
								Log = true,
							}})
							SoundService:PlaySoundAt("PoofSound",{
								Parent = Victim.PrimaryPart,
								Volume = 0.75,
							},{
								CFrame = CFrame.new(AirDummyLocation.p)
							},{
								Range = 100,
								Origin = Victim.PrimaryPart.CFrame.p
							})
							
							task.spawn(function()
								local Anim = AirClone.Humanoid.Animator:LoadAnimation(RS.Assets.Animations.Shared.KidNaruto.AirClone)
								Util:StopMarker(RS.Assets.Animations.Shared.KidNaruto.AirClone):Connect(function()
									RemoteComs:FireAllClientsEvent({FunctionName = "VFX"},{FName = "Sub",FData = {
										Pos = AirDummyLocation,
										Log = true,
									}})
									SoundService:PlaySoundAt("PoofSound",{
										Parent = Victim.PrimaryPart,
										Volume = 0.75,

									},{
										CFrame = CFrame.new(AirDummyLocation.p)
									},{
										Range = 100,
										Origin = Victim.PrimaryPart.CFrame.p
									})
									AirClone:Destroy()
								end)
								
								Anim:Play()
								DamageService:DamageEntities({
									Attacker = Character,
									Damage = SkillData.Damage/3,
									Victim = Victim,
								})
								PointsService:AddPoints(Player,SkillData.Points/3)
								PointsService:AddToCombo(Player,1)
							end)
						end)
						Util:SignalMarker(RS.Assets.Animations.Shared.KidNaruto.VictimGrab,"KbStarted"):Connect(function()
							SoundService:PlaySoundAt("Swoosh_2",{
								Parent = Victim.PrimaryPart,
								Volume = 0.75,
							},{
								CFrame = CFrame.new(AirDummyLocation.p)
							},{
								Range = 100,
								Origin = Victim.PrimaryPart.CFrame.p
							})
							local DowmSlamEndPos = AirDummyLocation.p + (Character.PrimaryPart.CFrame.LookVector * 100) + Vector3.new(0,-100,0)
							local DownSlam = require(SS.Modules.Services.DownSlamService).new({
								EndStun = 1.25,
								MaxTime = 5,
								MaxDist = 1000,
								Character = Victim,
								Speed = 300,
								Connect = true,
								StartCFrame = Victim.PrimaryPart.CFrame * CFrame.new(0,0.005,0),
								Vector = (DowmSlamEndPos - AirDummyLocation.p).Unit
							})
							DownSlam.HitTask:Connect(function()
								Victim.PrimaryPart.Anchored = false
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
									AttackID = "UzumakiCombo",
								})
								StateShortCuts:StunSpeed(Victim,{
									Prior = 66,
									Duration = SkillData.Stun,
									Speed = 1,
								})
								DamageService:DamageEntities({
									Attacker = Character,
									Damage = SkillData.Damage/3,
									Victim = Victim,
								})
								PointsService:AddPoints(Player,SkillData.Points/3)
								PointsService:AddToCombo(Player,1)
							end)
							DownSlam:Start()
						end)
						AirClone.PrimaryPart.Anchored = true
						AirClone.PrimaryPart.CFrame = AirDummyLocation
						local CloneLPos = CFrame.lookAt((Victim.PrimaryPart.CFrame * CFrame.new(3,0,2)).Position,Victim.PrimaryPart.CFrame.Position)
						local CloneRPos = CFrame.lookAt((Victim.PrimaryPart.CFrame * CFrame.new(-3,0,2)).Position,Victim.PrimaryPart.CFrame.Position)
						SkillService:FireClientVFX(Player,CharacterID,"ThirdSkill","Start",{
							Character = Character,
							UID = SkillUID,
							Victim = Victim,
							CloneLPos = CloneLPos,
							CloneRPos = CloneRPos,
						})
						RemoteComs:FireAllClientsEvent({FunctionName = "VFX"},{FName = "Sub",FData = {
							Pos = CloneLPos,
							Log = true,
						}})
						RemoteComs:FireAllClientsEvent({FunctionName = "VFX"},{FName = "Sub",FData = {
							Pos = CloneRPos,
							Log = true,
						}})
						SoundService:PlaySoundAt("PoofSound",{
							Parent = Victim.PrimaryPart,
							Volume = 0.75,
						},{
							CFrame = CFrame.new(CloneLPos.p)
						},{
							Range = 100,
							Origin = Victim.PrimaryPart.CFrame.p
						})
						SoundService:PlaySoundAt("PoofSound",{
							Parent = Victim.PrimaryPart,
							Volume = 0.75,
						},{
							CFrame = CFrame.new(CloneRPos.p)
						},{
							Range = 100,
							Origin = Victim.PrimaryPart.CFrame.p
						})
						local TweenUp = TweenService:Create(Victim.PrimaryPart,TweenInfo.new((7/60) * 6,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{
							["CFrame"] = AirVicLocation
						})
						TweenUp:Play()
						DamageService:DamageEntities({
							Attacker = Character,
							Damage = SkillData.Damage/3,
							Victim = Victim,
						})
						PointsService:AddPoints(Player,SkillData.Points/3)
						PointsService:AddToCombo(Player,1)
					elseif HitResult == "PerfectBlock" then
						CombatService:PerfectBlock(Victim,Character,{
							CanTP = true,
							MaxDist = 16,
						})
					elseif HitResult == "IFrame" then
					elseif HitResult:match("Counter") then
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
			end)
			
			HitBox:Start()
			
			CooldownService:SetCooldown(Character,CharacterID,"ThirdSkill",{
				Hold = false
			})
			CooldownService:SetCooldown(Character,CharacterID,"ThirdSkill",{
				CD = SkillData.Cooldown
			})
		end,
	},
	["FourthSkill"] = {
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
			
			local CombatService = require(SS.Modules.Services.CombatService)
			CombatService:SprintEnd(Character)
			
			local SkillData = require(SS.Modules.MetaData.CharacterData)[CharacterID]["SkillData"]["FourthSkill"]
			
			if not CooldownService:CheckCooldown(Character,CharacterID,"FourthSkill") then return end
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
					return RayCas.Position + Vector3.new(0,3,0)
				else
					return Ori
				end
			end
			
			CooldownService:SetCooldown(Character,CharacterID,"FourthSkill",{
				Hold = true
			})
			
			StateService:SetState(Character,"CantRun",{
				LP = 65,
				Dur = 5,
			})
			StateService:SetState(Character,"UsingSkill",{
				LP = 55,
				Dur = 5,
			})
			StateService:SetState(Character,"CantM1",{
				LP = 55,
				Dur = 5,
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
					Name = "Transform4th",
					AnimationSpeed = 1,
					Weight = 3.5,
					FadeTime = 0.25,
					Looped = false,
				}
			})
			
			local Started = true
			local Stopped = false
			
			task.spawn(function()
				while Started do
					if not Stopped and StateService:GetState(Character,"Stunned") then
						Stopped = true
						
						CooldownService:SetCooldown(Character,CharacterID,"FourthSkill",{
							Hold = false
						})
						CooldownService:SetCooldown(Character,CharacterID,"FourthSkill",{
							CD = SkillData.Cooldown
						})
						StateService:SetState(Character,"CantRun",{
							LP = 67,
							Dur = 0.01,
						})
						
						StateService:SetState(Character,"UsingSkill",{
							LP = 57,
							Dur = 0.01,
						})
						
						StateService:SetState(Character,"CantM1",{
							LP = 57,
							Dur = 0.01,
						})
						break
					end
					RunService.Heartbeat:Wait()
				end
			end)
			
			Util:StopMarker(RS.Assets.Animations.Shared.KidNaruto.Transform4th):Connect(function()
				if Stopped then return end
				Started = false
				
				Character.PrimaryPart.Anchored = true
				Character.PrimaryPart.CFrame = CFrame.new(GetPosition:InvokeClient(Player))
				Character.Humanoid.AutoRotate = false
				
				SkillService:FireClientVFX(Player,CharacterID,"FourthSkill","Love",{
					Character = Character,
					UID = SkillUID,
				})
				
				SoundService:PlaySound("PoofSound",{
					Parent = Character.PrimaryPart,
					Volume = 0.75,

				},{},{
					Range = 100,
					Origin = Character.PrimaryPart.CFrame.p
				})
				
				RemoteComs:FireAllClientsEvent({FunctionName = "VFX"},{FName = "Sub",FData = {
					Pos = CFrame.new(GetPosition:InvokeClient(Player)),
					Log = true,
				}})
				
				Util:StopMarker(RS.Assets.Animations.Shared.KidNaruto.Transform4thDone):Connect(function()
					Character.PrimaryPart.Anchored = false
					Character.Humanoid.AutoRotate = true
					RemoteComs:FireAllClientsEvent({FunctionName = "VFX"},{FName = "Sub",FData = {
						Pos = CFrame.new(GetPosition:InvokeClient(Player)),
						Log = true,
					}})
					
					CooldownService:SetCooldown(Character,CharacterID,"FourthSkill",{
						Hold = false
					})
					CooldownService:SetCooldown(Character,CharacterID,"FourthSkill",{
						CD = SkillData.Cooldown
					})
				end)
				
				local PlayersInRange = HitBoxService:GetPlayersInRange({
					Range = SkillData.Range,
					Caster = Character,
					CasterFacing = false
				})
				
				local HitTargets = {}
				
				for _, Root in ipairs(PlayersInRange) do
					local Victim = Root.Parent
					local HitResult =  StateShortCuts:GetHitResult({
						Attacker = Character,
						Victim = Victim,
						HitData = {
							BlockBreak = false,
							CanPB = false,
							CantBeCountered = true,
						},
					})
					
					if HitResult == "Hit" then
						table.insert(HitTargets,Victim)
						task.spawn(function()
							StateShortCuts:StunCharacter({
								Victim = Victim,
								Attacker = Character,
								WasAttack = true,
								Duration = SkillData.Stun,
								Priority = 55,
								AttackID = "KidNarutoTransform",
							})
							
							PointsService:AddToCombo(Player,1)
							
							StateShortCuts:StunSpeed(Victim,{
								Prior = 55,
								Duration = SkillData.Stun,
								Speed = 0,
							})
							
							Victim.Humanoid.AutoRotate = false
							Victim.PrimaryPart.CFrame = CFrame.lookAt(Victim.PrimaryPart.CFrame.p, Character.PrimaryPart.CFrame.p)
							
							if Players:GetPlayerFromCharacter(Victim) then
								RemoteComs:FireClientEvent(Players:GetPlayerFromCharacter(Victim),{FunctionName = "AnimationService" },{
									Task = "PlayAnimation",
									AnimationData = {
										Name = "Guardbreak",
										AnimationSpeed = 1,
										Weight = 3,
										FadeTime = 0.25,
										Looped = false,
									}
								})
							else
								Victim.Humanoid.Animator:LoadAnimation(RS.Assets.Animations.Shared.Combat.Guardbreak):Play()
							end
							
							task.delay(SkillData.Stun,function()
								if Victim and Victim.PrimaryPart then
									Victim.Humanoid.AutoRotate = true
									Victim.PrimaryPart.CFrame = CFrame.lookAt(Victim.PrimaryPart.CFrame.p,Character.PrimaryPart.CFrame.p)
								end
							end)
						end)
					elseif HitResult == "Blocking" then
						task.spawn(function()
							RemoteComs:FireAllClientsEvent({FunctionName = "VFX"},{FName = "RegBlockEffect",FData = {
								Character = Character,
								Victim = Victim,
							}})
							
							SoundService:PlaySound("CombatBlockhit",{
								Parent = Victim.PrimaryPart,
								Volume = 0.75,
							},{},{
								Range = 100,
								Origin = Victim.PrimaryPart.CFrame.p
							})
						end)
					elseif HitResult == "PerfectBlock" then
						CombatService:PerfectBlock(Victim,Character,{
							CanTP = true,
							MaxDist = 16,
						})
					end
				end
				
				SkillService:FireClientVFX(Player,CharacterID,"FourthSkill","LoveHit",{
					Character = Character,
					UID = SkillUID,
					HitTargets = HitTargets
				})
				
				StateService:SetState(Character,"CantRun",{
					LP = 67,
					Dur = 0.15,
				})
				
				StateService:SetState(Character,"UsingSkill",{
					LP = 57,
					Dur = 0.15,
				})
				
				StateService:SetState(Character,"CantM1",{
					LP = 57,
					Dur = 0.15,
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
			local OdamaLastTime;
			PointsService:UltGain(Player,false)
			PointsService:ResetUltPoints(Player)
			
			local HyperArmor = false
			local ChargeTime = SkillData.ChargeTime
			Character.PrimaryPart.Anchored = true
			Character.Humanoid.AutoRotate = false
			
			StateService:SetState(Character,"CantRun",{
				LP = 65,
				Dur = 10,
			})
			StateService:SetState(Character,"UsingSkill",{
				LP = 50,
				Dur = 10,
			})
			StateService:SetState(Character,"CantM1",{
				LP = 55,
				Dur = 20,
			})
			
			SkillService:FireClientVFX(Player,CharacterID,"UltimateSkill","CloneSpawn",{
				Character = Character,
				ChargeTime = ChargeTime,
				UID = SkillUID
			})

			RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
				Task = "PlayAnimation",
				AnimationData = {
					Name = RS.Assets.Animations.Shared.KidNaruto.ChargeReg.Name,
					AnimationSpeed = 1,
					Weight = 3.5,
					FadeTime = 0.25,
					Looped = true,
				}
			})
			
			SoundService:PlaySound("KidNarutoRasCharge",{
				Parent = Character.PrimaryPart,
				Volume = 0.75,
			},{},{
				Range = 100,
				Origin = Character.PrimaryPart.CFrame.p
			})
			
			local RaseStart = true
			local Start = os.clock()
			
			task.spawn(function()
				while (os.clock() - Start) < ChargeTime do
					if RaseStart and StateService:GetState(Character,"Stunned") then
						RaseStart = false
						
						SoundService:StopSound("KidNarutoOdaRasCharge",{
							Parent = Character.PrimaryPart,
							Volume = 0.75,
						},{},{
							Range = 100,
							Origin = Character.PrimaryPart.CFrame.p
						})
						
						RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
							Task = "StopAnimation",
							AnimationData = {
								Name = RS.Assets.Animations.Shared.KidNaruto.ChargeReg.Name,
								AnimationSpeed = 1,
								Weight = 3.5,
								FadeTime = 0.25,
								Looped = false,
							}
						})
						
						Character.PrimaryPart.Anchored = false
						Character.Humanoid.AutoRotate = true
						
						StateService:SetState(Character,"CantRun",{
							LP = 65,
							Dur = 0.01,
						})
						StateService:SetState(Character,"CantM1",{
							LP = 55,
							Dur = 0.01,
						})
						StateService:SetState(Character,"UsingSkill",{
							LP = 50,
							Dur = 0.01,
						})
						
						SkillService:FireClientVFX(Player,CharacterID,"UltimateSkill","RaseOff",{
							Character = Character,
							UID = SkillUID
						})
						
						SkillService:FireClientVFX(Player,CharacterID,"UltimateSkill","UltAuraOff",{
							Character = Character,
							UID = SkillUID
						})
						
						PointsService:UltGain(Player,true)
					end
					RunService.Heartbeat:Wait()
				end
			end)
			
			task.delay(ChargeTime/4,function()
				if not RaseStart then return end
				
				SkillService:FireClientVFX(Player,CharacterID,"UltimateSkill","Rase",{
					Character = Character,
					UID = SkillUID
				})
				
				SkillService:FireClientVFX(Player,CharacterID,"UltimateSkill","UltAura",{
					Character = Character,
					UID = SkillUID
				})
			end)
			
			task.delay(ChargeTime,function()
				if not RaseStart then return end
				
				SoundService:StopSound("KidNarutoOdaRasCharge",{
					Parent = Character.PrimaryPart,
					Volume = 0.75,
				},{},{
					Range = 100,
					Origin = Character.PrimaryPart.CFrame.p
				})
				
				RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
					Task = "StopAnimation",
					AnimationData = {
						Name = RS.Assets.Animations.Shared.KidNaruto.ChargeReg.Name,
						AnimationSpeed = 1,
						Weight = 3.5,
						FadeTime = 0.25,
						Looped = false,
					}
				})

				Character.PrimaryPart.Anchored = false
				Character.Humanoid.AutoRotate = true
				
				RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
					Task = "PlayAnimation",
					AnimationData = {
						Name = "RasgRun",
						AnimationSpeed = 1,
						Weight = 1,
						FadeTime = 0.25,
						Looped = true,
					}
				})
				
				StateService:GetProfile(Character).StateData["RunID"].Name = "RasgRun"
				
				StateService:SetState(Character,"CantRun",{
					LP = 66,
					Dur = 0.01,
				})
				StateService:SetState(Character,"CantM1",{
					LP = 57,
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
				
				local Start = os.clock()
				
				task.spawn(function()
					while (os.clock() - Start) < SkillData.Length do
						if RaseStart and StateService:GetState(Character,"Stunned") then
							RaseStart = false
							
							StateService:SetState(Character,"CantRun",{
								LP = 66,
								Dur = 0.01,
							})
							StateService:SetState(Character,"CantM1",{
								LP = 57,
								Dur = 0.01,
							})
							StateService:SetState(Character,"UsingSkill",{
								LP = 50,
								Dur = 0.01,
							})
							RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
								Task = "StopAnimation",
								AnimationData = {
									Name = "RasgRun",
									AnimationSpeed = 1,
									Weight = 1,
									FadeTime = 0.25,
									Looped = false,
								}
							})
							
							StateService:GetProfile(Character).StateData["RunID"].Name = "DfRun"
							
							SkillService:FireClientVFX(Player,CharacterID,"UltimateSkill","RaseOff",{
								Character = Character,
								UID = SkillUID
							})
							SkillService:FireClientVFX(Player,CharacterID,"UltimateSkill","UltAuraOff",{
								Character = Character,
								UID = SkillUID
							})
							StateShortCuts:BoostSpeeds(Character,{
								Prior = 56,
								Dur = 0.01,
								WalkSpeed = 16,
								RunSpeed = 25,
							})
							PointsService:UltGain(Player,true)
						end
						RunService.Heartbeat:Wait()
					end
				end)
				
				task.delay(SkillData.Length,function()
					if RaseStart then
						StateService:SetState(Character,"CantRun",{
							LP = 66,
							Dur = 0.01,
						})
						StateService:SetState(Character,"CantM1",{
							LP = 57,
							Dur = 0.01,
						})
						StateService:SetState(Character,"UsingSkill",{
							LP = 50,
							Dur = 0.01,
						})
						RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
							Task = "StopAnimation",
							AnimationData = {
								Name = "RasgRun",
								AnimationSpeed = 1,
								Weight = 1,
								FadeTime = 0.25,
								Looped = true,
							}
						})
						StateService:GetProfile(Character).StateData["RunID"].Name = "DfRun"
						SkillService:FireClientVFX(Player,CharacterID,"UltimateSkill","RaseOff",{
							Character = Character,
							UID = SkillUID
						})
						
						SkillService:FireClientVFX(Player,CharacterID,"UltimateSkill","UltAuraOff",{
							Character = Character,
							UID = SkillUID
						})
						StateShortCuts:BoostSpeeds(Character,{
							Prior = 56,
							Dur = 0.01,
							WalkSpeed = 16,
							RunSpeed = 25,
						})
						PointsService:UltGain(Player,true)
					end
				end)
				
				local HitBox = HitBoxService:CRepeatCFrame({
					BreakOnHit = true,
					MultHit = false,
					OffsetPart = Character.PrimaryPart,
					HitOnce = true,
					Offset = CFrame.new(0,0,-4.5),
					Size = Vector3.new(6.5,6.5,8.5),
					Dur = SkillData.Length - 0.05,
					Visual = false,
					Caster = Character,
				})
				
				HitBox.OnHit:Connect(function(Victim)
					if not RaseStart then return end
					
					task.delay(1, function()
						RaseStart = false
					end)
					
					local HitResult = StateShortCuts:GetHitResult({
						Attacker = Character,
						Victim = Victim,
						HitData = {
							BlockBreak = true,
							CanPB = true,
						},
					})
					
					if HitResult == "Hit" or HitResult == "GuardBreak" then
						if Players:GetPlayerFromCharacter(Victim) == nil and Victim and Players:GetPlayerFromCharacter(Character) then
							if Victim.PrimaryPart and Victim.PrimaryPart.Anchored == false then
								for _,v in ipairs(Victim:GetChildren()) do
									if v:IsA("BasePart") and v.Anchored == false then
										v:SetNetworkOwner(Players:GetPlayerFromCharacter(Character))
									end
								end
							end
						end

						Victim.Humanoid.AutoRotate = false
						Character.Humanoid.AutoRotate = false
						Character.PrimaryPart.Anchored = true
						Victim.PrimaryPart.Anchored = true
						Victim.PrimaryPart.CFrame = CFrame.new(Victim.PrimaryPart.CFrame.Position,Character.PrimaryPart.CFrame.Position)

						task.delay(.05, function()
							if Victim and Victim.PrimaryPart then
								Victim.PrimaryPart.Anchored = false
								Victim.Humanoid.AutoRotate = true
							end
							
							Character.Humanoid.AutoRotate = true
							Character.PrimaryPart.Anchored = false
							
							if HitResult == "GuardBreak" then
								CombatService:GuardBreak(Victim)
							else
								if Players:GetPlayerFromCharacter(Victim) then
									RemoteComs:FireClientEvent(Players:GetPlayerFromCharacter(Victim),{FunctionName = "AnimationService" },{
										Task = "PlayAnimation",
										AnimationData = {
											Name = "RasVictimHit",
											AnimationSpeed = 1,
											Weight = 1,
											FadeTime = 0.25,
											Looped = false,
										}
									})
								else
									Victim.Humanoid.Animator:LoadAnimation(RS.Assets.Animations.Shared.KidNaruto.RasVictimHit):Play()
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

							StateService:SetState(Character,"CantRun",{
								LP = 66,
								Dur = 0.01,
							})
							StateService:SetState(Character,"UsingSkill",{
								LP = 50,
								Dur = 0.01,
							})
							RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
								Task = "StopAnimation",
								AnimationData = {
									Name = "RasgRun",
									AnimationSpeed = 1,
									Weight = 1,
									FadeTime = 0.25,
									Looped = false,
								}
							})
							StateService:GetProfile(Character).StateData["RunID"].Name = "DfRun"

							SkillService:FireClientVFX(Player,CharacterID,"UltimateSkill","RaseHit",{
								Character = Character,
								Victim = Victim,
								UID = SkillUID
							})
							
							SkillService:FireClientVFX(Player,CharacterID,"UltimateSkill","UltAuraOff",{
								Character = Character,
								UID = SkillUID
							})
							
							StateShortCuts:StunCharacter({
								Victim = Victim,
								Attacker = Character,
								WasAttack = true,
								Duration = 1.75,
								Priority = 50,
								AttackID = "KidNarutoRase",
							})
							StateShortCuts:StunSpeed(Victim,{
								Prior = 55,
								Duration = 1.75,
								Speed = 0,
							})

							StateShortCuts:BoostSpeeds(Character,{
								Prior = 56,
								Dur = 0.01,
								WalkSpeed = 16,
								RunSpeed = 25,
							})
							
							if HitResult ~= "GuardBreak" then
								local Velocity = Instance.new("BodyVelocity")
								Velocity.MaxForce = Vector3.new(20e4,20e4,20e4)
								Velocity.Velocity = Vector3.new(0,2,0) + Character.PrimaryPart.CFrame.LookVector * 75
								Velocity.Parent = Victim.PrimaryPart
								Debris:AddItem(Velocity,.55)
							end
							
							PointsService:UltGain(Player,true)
						end)
					elseif HitResult == "PerfectBlock" then
						CombatService:PerfectBlock(Victim,Character,{
							CanTP = true,
							MaxDist = 16,
						})
						
						StateService:SetState(Character,"CantRun",{
							LP = 66,
							Dur = 0.01,
						})
						StateService:SetState(Character,"UsingSkill",{
							LP = 50,
							Dur = 0.01,
						})
						RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
							Task = "StopAnimation",
							AnimationData = {
								Name = "RasgRun",
								AnimationSpeed = 1,
								Weight = 1,
								FadeTime = 0.25,
								Looped = true,
							}
						})
						StateService:GetProfile(Character).StateData["RunID"].Name = "DfRun"
						SkillService:FireClientVFX(Player,CharacterID,"UltimateSkill","RaseOff",{
							Character = Character,
							UID = SkillUID
						})

						SkillService:FireClientVFX(Player,CharacterID,"UltimateSkill","UltAuraOff",{
							Character = Character,
							UID = SkillUID
						})
						StateShortCuts:BoostSpeeds(Character,{
							Prior = 56,
							Dur = 0.01,
							WalkSpeed = 16,
							RunSpeed = 25,
						})
						PointsService:UltGain(Player,true)
					elseif HitResult == "IFrame" then
						StateService:SetState(Character,"CantRun",{
							LP = 66,
							Dur = 0.01,
						})
						StateService:SetState(Character,"UsingSkill",{
							LP = 50,
							Dur = 0.01,
						})
						RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
							Task = "StopAnimation",
							AnimationData = {
								Name = "RasgRun",
								AnimationSpeed = 1,
								Weight = 1,
								FadeTime = 0.25,
								Looped = true,
							}
						})
						StateService:GetProfile(Character).StateData["RunID"].Name = "DfRun"
						
						task.spawn(function()
							SkillService:FireClientVFX(Player,CharacterID,"UltimateSkill","UltAuraOff",{
								Character = Character,
								UID = SkillUID
							})
						end)
						
						SkillService:FireClientVFX(Player,CharacterID,"UltimateSkill","RaseOff",{
							Character = Character,
							UID = SkillUID
						})
						
						StateShortCuts:BoostSpeeds(Character,{
							Prior = 56,
							Dur = 0.01,
							WalkSpeed = 16,
							RunSpeed = 25,
						})
						
						PointsService:UltGain(Player,true)
					elseif HitResult:match("Counter") then
						StateService:SetState(Character,"CantRun",{
							LP = 66,
							Dur = 0.01,
						})
						StateService:SetState(Character,"UsingSkill",{
							LP = 50,
							Dur = 0.01,
						})
						RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
							Task = "StopAnimation",
							AnimationData = {
								Name = "RasgRun",
								AnimationSpeed = 1,
								Weight = 1,
								FadeTime = 0.25,
								Looped = true,
							}
						})
						
						task.spawn(function()
							SkillService:FireClientVFX(Player,CharacterID,"UltimateSkill","UltAuraOff",{
								Character = Character,
								UID = SkillUID
							})
						end)
						
						StateService:GetProfile(Character).StateData["RunID"].Name = "DfRun"
						
						SkillService:FireClientVFX(Player,CharacterID,"UltimateSkill","RaseOff",{
							Character = Character,
							UID = SkillUID
						})
						
						StateShortCuts:BoostSpeeds(Character,{
							Prior = 56,
							Dur = 0.01,
							WalkSpeed = 16,
							RunSpeed = 25,
						})
						
						PointsService:UltGain(Player,true)
						
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
	}
}

return OldKakashi