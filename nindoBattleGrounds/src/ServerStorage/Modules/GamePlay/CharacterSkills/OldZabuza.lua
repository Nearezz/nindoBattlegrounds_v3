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

local CharacterID = "OldZabuza"
local holding = {}

local OldZabuza; OldZabuza = {
	["FirstSkill"] = {
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
			local Player = Players:GetPlayerFromCharacter(Character)
			
			holding[Character] = true
			

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
			CombatService:SprintEnd(Character)

			local CheckFlag = false
			local HyperArmored = false

			SoundService:PlaySound("HandsignSound",{
				Parent = Character.PrimaryPart,
				Volume = 0.75,
			},{},{
				Range = 100,
				Origin = Character.PrimaryPart.CFrame.p
			})

			local sword = Character:FindFirstChild("Sword", true)
			sword.Transparency = 1
			
			RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
				Task = "PlayAnimation",
				AnimationData = {
					Name = RS.Assets.Animations.Shared.Zabuza["WaterBullet"].Name,
					AnimationSpeed = 1,
					Weight = 3.5,
					FadeTime = 0.25,
					Looped = false,
				}
			})
			

			task.spawn(function()
				while CheckFlag == false do
					if StateService:GetState(Character,"Stunned") then
						HyperArmored = true
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
			Util:SignalMarker(RS.Assets.Animations.Shared.Zabuza.WaterBullet,"CheckHyperArmor"):Connect(function()
				CheckFlag = true
			end)

			Util:SignalMarker(RS.Assets.Animations.Shared.Zabuza.WaterBullet,"Release"):Connect(function()
				if HyperArmored == true then return end
				StateService:SetState(Character,"UsingSkill",{
					LP = 55,
					Dur = 2,
				})
				StateService:SetState(Character,"CantRun",{
					LP = 55,
					Dur = 2,
				})
				StateService:SetState(Character,"CantM1",{
					LP = 55,
					Dur = 2,
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
				local Velocity = SkillData.WaterSpeed
				local Duration = SkillData.Duration
				local Acceleration = SkillData.WaterAcceleration
				local StartCFrame = CFrame.new(Character.PrimaryPart.CFrame.Position)
				local ForceEnd = false

				SkillService:FireClientVFX(Player,CharacterID,"FirstSkill","WaterCast",{
					Character = Character,
					StartPoint = StartPoint,
					Acceleration = Acceleration,
					Velocity = Velocity,
					Direction = Direction,
					Duration = SkillData.Duration,
					UID = SkillUID
				})

				local start = tick()
				local con = nil

				StateShortCuts:StunSpeed(Character,{
					Prior = 56,
					Duration = Duration,
					Speed = 0,
				})

				while tick()-start < Duration and holding[Character] == true do
					local HitBox = HitBoxService:CRepeatCFrame({
						BreakOnHit = true,
						MultHit = true,
						OffsetPart = Character.PrimaryPart,
						HitOnce = true,
						Offset = CFrame.new(0,0,-18.5),
						Size = Vector3.new(3.5,3.5,35),
						Dur = 0.1,
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

							if StateService:GetState(Character,"ZabuzaUlt") then
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
							BV.Velocity = Character.PrimaryPart.CFrame.LookVector * 4.5
							BV.Parent = Victim.PrimaryPart
							Debris:AddItem(BV,.15)

							StateShortCuts:StunCharacter({
								Victim = Victim,
								Attacker = Character,
								WasAttack = true,
								Duration = 1.75,
								Priority = 50,
								AttackID = "OldZabuza WaterBullet",
							})
							StateShortCuts:StunSpeed(Victim,{
								Prior = 55,
								Duration = SkillData.Stun * 1.5,
								Speed = 0,
							})

							--RemoteComs:FireAllClientsEvent({FunctionName = "VFX"},{FName = "RegM1Hit",FData = {
							--Character = Character,
							--Victim = Victim,
							--}})
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
								MaxDist = 3,
							})
						end
					end)

					HitBox:Start()

					task.wait(0.05)
				end
				sword.Transparency = 0
			end)
		end,
		["Release"] = function(Character)
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
			holding[Character] = nil
			StateShortCuts:StunSpeed(Character,{
				Prior = 56,
				Duration = 0.3,
				Speed = 0,
			})
			SkillService:FireClientVFX(Players:GetPlayerFromCharacter(Character),CharacterID,"FirstSkill","WaterEnd",{})
		end,
	},
	["SecondSkill"] = {
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
		end,
		["Release"] = function(Character)
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
				Hold = false
			})

			CooldownService:SetCooldown(Character,CharacterID,"SecondSkill",{
				CD = 15
			})
			
			RemoteComs:FireClientEvent(Player,{FunctionName = "AnimationService" },{
				Task = "PlayAnimation",
				AnimationData = {
					Name = RS.Assets.Animations.Shared.Zabuza["Mist"].Name,
					AnimationSpeed = 1,
					Weight = 3.5,
					FadeTime = 0.25,
					Looped = false,
				}
			})
			
			SkillService:FireClientVFX(Players:GetPlayerFromCharacter(Character),CharacterID,"SecondSkill","Cast",Character)
		end,
	},
	["ThirdSkill"] = {
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
		end,
		["Release"] = function(Character)
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

			local Player = Players:GetPlayerFromCharacter(Character)


			local CombatService = require(SS.Modules.Services.CombatService)

			CooldownService:SetCooldown(Character,CharacterID,"ThirdSkill",{
				Hold = false
			})

			CooldownService:SetCooldown(Character,CharacterID,"ThirdSkill",{
				CD = 15
			})

			SkillService:FireClientVFX(Players:GetPlayerFromCharacter(Character),CharacterID,"ThirdSkill","Striking Stab",Character)

		end,
	},
	["FourthSkill"] = {
		["Hold"] = function(Character)
			local SkillUID = "FourthSkillHold"..Character.Name..CharacterID..HTTPService:GenerateGUID(false)

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

		end,
		["Release"] = function(Character)
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

			local SkillData = require(SS.Modules.MetaData.CharacterData)[CharacterID]["SkillData"]["FourthSkill"]

			if not CooldownService:CheckCooldown(Character,CharacterID,"FourthSkill") then return end
			if StateService:GetState(Character,"Stunned") then return end
			if StateService:GetState(Character,"UsingSkill") then return end

			local Player = Players:GetPlayerFromCharacter(Character)

			local CombatService = require(SS.Modules.Services.CombatService)

			CooldownService:SetCooldown(Character,CharacterID,"FourthSkill",{
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
				CooldownService:SetCooldown(Character,CharacterID,"FourthSkill",{
					Hold = false
				})
				CooldownService:SetCooldown(Character,CharacterID,"FourthSkill",{
					CD = 0.5
				})
				return
			end

			Character.Archivable = true
			local Clone = Character:Clone()
			Character.Archivable = false


			local Script = SS.Modules.Scripts.ShadowCloneWater.Brain:Clone()
			Script.Length.Value = SkillData.Length
			Script.Damage.Value = SkillData.Damage
			Script.Target.Value = TargetPlayer
			Script.Caster.Value = Character

			Script.Parent = Clone
			Clone.PrimaryPart.CFrame = CFrame.lookAt((Character.PrimaryPart.CFrame * CFrame.new(-5,0,0)).Position,TargetPlayer.PrimaryPart.CFrame.Position)
			Clone.Parent = workspace.World.Entities
			RemoteComs:FireAllClientsEvent({FunctionName = "VFX"},{FName = "WaterSub",FData = {
				Pos = CFrame.lookAt((Character.PrimaryPart.CFrame * CFrame.new(-5,0,0)).Position,TargetPlayer.PrimaryPart.CFrame.Position),
				Log = true
			}})

			Script.Enabled = true

			CooldownService:SetCooldown(Character,CharacterID,"FourthSkill",{
				Hold = false
			})
			CooldownService:SetCooldown(Character,CharacterID,"FourthSkill",{
				CD = SkillData.Cooldown
			})




		end,
	},
	["UltimateSkill"] = {
		["Hold"] = function(Character)
			local SkillUID = "UltimateSkillHold"..Character.Name..CharacterID..HTTPService:GenerateGUID(false)

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

		end,
		["Release"] = function(Character)
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
					Dur = 00.1,
				})
				return
			end

			local CombatService = require(SS.Modules.Services.CombatService)

			PointsService:ResetUltPoints(Player)

			StateService:SetState(Character,"CantRun",{
				LP = 55,
				Dur = 20,
			})
			StateService:SetState(Character,"CantM1",{
				LP = 55,
				Dur = 20,
			})

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
				SkillService:FireClientVFX(Player,CharacterID,"UltimateSkill","ChidoriParticleOn",{
					Character = Character,
					UID = SkillUID
				})
			end)

			Util:SignalMarker(RS.Assets.Animations.Shared.Kakashi.ChidoriUlt,"WindOff"):Connect(function()
				SkillService:FireClientVFX(Player,CharacterID,"UltimateSkill","WindOff",{
					Character = Character,
					UID = SkillUID
				})
			end)

			Util:SignalMarker(RS.Assets.Animations.Shared.Kakashi.ChidoriUlt,"Teleport"):Connect(function()
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

			--SkillService:FireOneClientVFX(Player,CharacterID,"UltimateSkill","PlayCamera",{
			--	Character = Character,
			--	UID = SkillUID,
			--	Origin = Character.PrimaryPart.CFrame * CFrame.new(0,-3,0)
			--})

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

		end,
	}
}

return OldZabuza
