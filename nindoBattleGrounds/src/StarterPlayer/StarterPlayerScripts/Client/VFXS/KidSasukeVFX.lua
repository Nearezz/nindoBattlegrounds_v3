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

local Assets = RS:WaitForChild("Assets")
local Effects = Assets:WaitForChild("Effects")

local CharacterID = "KidSasuke"

local function Weld(part0, part1, position, name)
	local constraint = Instance.new("WeldConstraint")
	constraint.Name = name or "WeldConstraint"
	constraint.Part0 = part0
	constraint.Part1 = part1
	if typeof(position) == "CFrame" then
		constraint.Part1.CFrame = position
	elseif typeof(position) == "Vector3" then
		constraint.Part1.Position = position
	end
	constraint.Parent = part0

	return constraint
end

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

local function EmitAll(Ins,Count)
	for _, ins in pairs(Ins:GetDescendants()) do
		if ins:IsA("ParticleEmitter") then
			if not Count then
				ins:Emit(ins:GetAttribute("EmitCount"))
			else
				ins:Emit(Count)
			end
		end
	end
end

local function EnableAll(bool, obj)
	for _, v in ipairs(obj:GetDescendants()) do
		if v:IsA("ParticleEmitter") or v:IsA('Beam') or v:IsA('Trail') then
			v.Enabled = bool			
		end
	end 
end

local function GenerateJunkTable(CharacterID)
	local CleanUpService = require(RS.Modules.Services.CleanupService)
	return CleanUpService:GenerateJunkTable(CharacterID)
end

local JunkTable = GenerateJunkTable(CharacterID)

local KidSasuke; KidSasuke = {
	["FirstSkill"] = {
		["FireChidoriParticle"] = function(Data)
			local Character = Data.Character
			local UID = Data.UID

			local Chidori = RS.Assets.Effects.Kakashi.Chidori:WaitForChild('Chidori'):Clone()
			Chidori.CFrame = Character["Left Arm"].CFrame * CFrame.new(0,-1,0)
			Chidori.Parent = workspace.World.Effects
			Weld(Chidori, Character["Left Arm"],Character["Left Arm"].CFrame)
			EnableAll(true, Chidori)

			local Light = TweenService:Create(Chidori.Attachment.PointLight, TweenInfo.new(1), {Brightness = 5})
			Light:Play()
			Light:Destroy()

			if JunkTable["KidSasukeChidori"..UID] ~= nil then
				JunkTable["KidSasukeChidori"..UID]:Destory()
				JunkTable["KidSasukeChidori"..UID] = nil
			end
			JunkTable["KidSasukeChidori"..UID] = Chidori


		end,

		["ChidoriParticleOff"] = function(Data)
			local Character = Data.Character
			local UID = Data.UID


			if JunkTable["KidSasukeChidori"..UID] ~= nil then
				EnableAll(false,JunkTable["KidSasukeChidori"..UID])
				JunkTable["KidSasukeChidori"..UID]:Destroy()
				JunkTable["KidSasukeChidori"..UID] = nil
			end

		end,
		["ChidoriHit"] = function(Data)
			local Character = Data.Character
			local Victim = Data.Victim
			local UID = Data.UID

			local Chidori = JunkTable["KidSasukeChidori"..UID]

			local LightOut = TweenService:Create(Chidori.Attachment.PointLight, TweenInfo.new(.5), {Brightness = 0})
			LightOut:Play()
			LightOut:Destroy()

			EnableAll(false, Chidori)
			Debris:AddItem(Chidori, 1)

			local Dust = RS.Assets.Effects.Kakashi.Chidori:WaitForChild('Dust'):Clone()
			Dust.CFrame = Data.DustPos
			Dust.Parent = workspace.World.Effects	
			EmitAll(Dust)
			Debris:AddItem(Dust, 1)

			local ChidoriHit = RS.Assets.Effects.Kakashi.Chidori:WaitForChild('ChidoriHit'):Clone()
			ChidoriHit.CFrame = Victim.HumanoidRootPart.CFrame
			ChidoriHit.Parent = workspace.World.Effects

			EmitAll(ChidoriHit)	
			Debris:AddItem(ChidoriHit, 2)

			JunkTable["Chidori"..UID] = nil



		end,
	},
	["SecondSkill"] = {
		["FireballCast"] = function(Data)
			--[[
					Character = Character,
					StartPoint = StartPoint,
					Acceleration = Acceleration,
					Velocity = Velocity,
					Direction = Direction,
					Duration = SkillData.Duration,
			]]
			local Character = Data.Character
			local UID = Data.UID

			local SoundService = require(RS.Modules.Services.SoundService)

			local FireBall = RS.Assets.Effects.Kakashi.FireBomb:WaitForChild("Fireball"):Clone()
			JunkTable["Fireball_KidSasuke"..Character.Name..UID] = FireBall

			FireBall.CFrame = Data.StartPoint
			FireBall.Parent = workspace.World.Effects

			EnableAll(true, FireBall)

			local FireTween = TweenService:Create(FireBall.PointLight, TweenInfo.new(1), { Brightness = 15})
			FireTween:Play()
			FireTween:Destroy()

			local FinalVelocity = Data.Velocity + (Data.Acceleration * Data.Duration)

			local Velocity = Instance.new("BodyVelocity")
			Velocity.Velocity = (Data.Direction * Data.Velocity)
			Velocity.MaxForce = Vector3.new(math.huge,math.huge,math.huge)

			local AccelTween = TweenService:Create(Velocity,TweenInfo.new(Data.Duration),{
				Velocity = (Data.Direction * FinalVelocity)
			})

			Velocity.Parent = FireBall
			FireBall.Anchored = false
			AccelTween:Play()
			Debris:AddItem(Velocity,Data.Duration)


			task.delay(Data.Duration + 0.05,function()
				KidSasuke["SecondSkill"]["FireballHit"]({
					Character = Character,
					UID = UID,
				})
			end)


			--local TotalDistance = (Data.Velocity)*(Data.Duration) + (0.5)*(Data.Acceleration)*(Data.Duration^2)
			--local FinalPosition = CFrame.new(Data.StartPoint.Position + (Data.Direction * TotalDistance))

			--local MovementTween = TweenService:Create(FireBall, TweenInfo.new(Data.Duration), {CFrame = FinalPosition})

			--MovementTween:Play()
			--MovementTween:Destroy()
			--print(TotalDistance)

		end,
		["FireballHit"] = function(Data)
			local Character = Data.Character
			local UID = Data.UID

			if JunkTable["Fireball_KidSasuke"..Character.Name..UID] ~= nil then
				local Fire= JunkTable["Fireball_KidSasuke"..Character.Name..UID]
				JunkTable["Fireball_KidSasuke"..Character.Name..UID] = nil

				local FireExplosion = RS.Assets.Effects.Kakashi.FireBomb:WaitForChild("Explosion"):Clone()
				FireExplosion.CFrame = Fire.CFrame
				FireExplosion.Parent = workspace.World.Effects

				EmitAll(FireExplosion)
				EnableAll(false, Fire)
				Debris:AddItem(Fire, 1)
				Debris:AddItem(FireExplosion, 2)

				local FireTween = TweenService:Create(Fire.PointLight, TweenInfo.new(1), { Brightness = 0})
				FireTween:Play()
				FireTween:Destroy()

				local BrightOut = TweenService:Create(FireExplosion.Attachment.PointLight, TweenInfo.new(1), { Brightness = 5})
				BrightOut:Play()
				BrightOut:Destroy()
				task.delay(1, function()
					local FireOut = TweenService:Create(FireExplosion.Attachment.PointLight, TweenInfo.new(1), { Brightness = 0})
					FireOut:Play()
					FireOut:Destroy()
				end)
			end
		end,
	},
	["ThirdSkill"] = {
		["Hold"] = function(Data)

		end,
	},
	["FourthSkill"] = {
		["Demon Shuriken"] = function(Data)
			local Character = Data.Character
			local UID = Data.UID
			
			local RightArm = Character["Right Arm"]
			
			local Shuriken = Effects.Sasuke:WaitForChild("Shuriken"):Clone()
			Shuriken.CFrame = Data.Pos
			Shuriken.CFrame = CFrame.lookAt(Shuriken.CFrame.p,Shuriken.CFrame.p + (Data.Direction * 300))
			Shuriken.Parent = workspace.World.Effects
			
			local BodyVelocity = Instance.new("BodyVelocity")
			BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
			BodyVelocity.Velocity = Data.Direction * Data.Speed
			BodyVelocity.Parent = Shuriken
			if JunkTable[UID..Character.Name.."DemShuriken"] ~= nil then
				JunkTable[UID..Character.Name.."DemShuriken"]:Destroy()
				JunkTable[UID..Character.Name.."DemShuriken"] = nil
			end
			JunkTable[UID..Character.Name.."DemShuriken"] = Shuriken
			
		end,
		["Demon Shuriken Destory"] = function(Data)
			local Character = Data.Character
			local UID = Data.UID
			if JunkTable[UID..Character.Name.."DemShuriken"] ~= nil then
				JunkTable[UID..Character.Name.."DemShuriken"]:Destroy()
				JunkTable[UID..Character.Name.."DemShuriken"] = nil
			end
		end,
		["Demon Shuriken KunaiD"] = function(Data)
			local Character = Data.Character
			local UID = Data.UID
			if JunkTable[UID..Character.Name.."DemShurikenKunai"] ~= nil then
				JunkTable[UID..Character.Name.."DemShurikenKunai"]:Destroy()
				JunkTable[UID..Character.Name.."DemShurikenKunai"] = nil
			end
		end,
		["Demon Shuriken Kunai"] = function(Data)
			local Character = Data.Character
			local UID = Data.UID
			
			Character.Archivable = true
			
			local Clone = Character:Clone()
			
			for _,Part in ipairs(Clone:GetChildren()) do
				if Part:IsA("BasePart") or Part:IsA("MeshPart") or Part:IsA("Union") then
					Part.CanCollide = false
				end
			end
			
			Character.Archivable = false
			Clone.PrimaryPart.Anchored = true
			
			local ClonePoof = RS.Assets.Effects.Sasuke.ClonePoof:Clone()
			ClonePoof.Parent = workspace.World.Effects
			
			local CloneCFrame = Data.Pos
			
			ClonePoof.CFrame = CloneCFrame
			EmitAll(ClonePoof,10)
			Debris:AddItem(ClonePoof,3)
			Clone.PrimaryPart.CFrame = CloneCFrame
			Clone.Parent = workspace.World.Effects
			
			local Anim = Clone.Humanoid:LoadAnimation(RS.Assets.Animations.Shared.Sasuke.CloneKunaiThrow)
			local Tween = TweenService:Create(Clone.PrimaryPart,TweenInfo.new(8/60,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{
				["CFrame"] = Data.Pos * CFrame.new(0,0,-3)
			})
			Tween:Play()
			Tween:Destroy()
			
			Anim.Stopped:Connect(function()
				local ClonePoof2 = RS.Assets.Effects.Sasuke.ClonePoof:Clone()
				ClonePoof2.CFrame = CloneCFrame
				ClonePoof2.Parent = workspace.World.Effects
				EmitAll(ClonePoof2)
				Debris:AddItem(ClonePoof2,3)
				Clone:Destroy()
			end)
			Anim:Play()
			Anim:GetMarkerReachedSignal("Throw"):Connect(function()
				local Shuriken = Effects.Sasuke:WaitForChild("Kunai"):Clone()
				JunkTable[UID..Character.Name.."DemShurikenKunai"] = Shuriken
				Shuriken.PrimaryPart.CFrame = Clone.PrimaryPart.CFrame
				Shuriken.PrimaryPart.CFrame = CFrame.lookAt(Shuriken.PrimaryPart.Position, Data.Pos.p)
				Shuriken.Parent = workspace.World.Effects

				local BodyVelocity = Instance.new("BodyVelocity")
				BodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
				BodyVelocity.Velocity = Data.Direction * Data.Speed
				BodyVelocity.Parent = Shuriken.PrimaryPart
				
				Shuriken.Union.Trail.Enabled = true
				
				task.delay(0.01,function()
					if Shuriken and Shuriken.PrimaryPart then
						Shuriken.PrimaryPart.Anchored = false
					end
				end)
				
				task.delay(Data.Dur,function()
					if JunkTable[UID..Character.Name.."DemShurikenKunai"] ~= nil then
						JunkTable[UID..Character.Name.."DemShurikenKunai"]:Destroy()
						JunkTable[UID..Character.Name.."DemShurikenKunai"] = nil
					end
				end)
			end)
		end,
		
	},
	["UltimateSkill"] = {
		["UltAura"] = function(Data)
			local Character = Data.Character
			local UID = Data.UID
			

			for i,x in pairs(Character:GetChildren()) do
				if x:IsA("BasePart") or x:IsA("MeshPart") then
					for _,Aura in pairs(script.Aura:GetChildren()) do
						local New = Aura:Clone()
						New.Parent = x
					end
				end
			end

		end,
		
		["CastField"] = function(Data)
			local Character = Data.Character
			local UID = Data.UID
			
			if JunkTable["KidSasukeUlt"..UID..Character.Name] ~= nil then
				JunkTable["KidSasukeUlt"..UID..Character.Name]:Destroy()
				JunkTable["KidSasukeUlt"..UID..Character.Name] = nil
			end
			
			local LightningSkill = Effects.Sasuke["Sasuke Lightning Skill"]:Clone()
			JunkTable["KidSasukeUlt"..UID..Character.Name] = LightningSkill
			EnableAll(false,LightningSkill)

			LightningSkill.CFrame = CFrame.new(Data.Pos)
			LightningSkill.Parent = workspace.World.Effects
		
			EnableAll(true,LightningSkill)
			local Tween = TweenService:Create(LightningSkill.Attachment2.PointLight,TweenInfo.new(1),{
				Range = 39,
				Brightness = 3,
			})
			Tween:Play()
			Tween:Destroy()
			
			task.delay(20,function()
				JunkTable["KidSasukeUlt"..UID..Character.Name] = nil
				Debris:AddItem(LightningSkill,0.01)
			end)
			
		end,
		
		["CastFieldOff"] = function(Data)
			local Character = Data.Character
			local UID = Data.UID
			
			if JunkTable["KidSasukeUlt"..UID..Character.Name] == nil then return end

			local LightningSkill = JunkTable["KidSasukeUlt"..UID..Character.Name]
			JunkTable["KidSasukeUlt"..UID..Character.Name] = nil
			
			EnableAll(false,LightningSkill)
			local Tween = TweenService:Create(LightningSkill.Attachment2.PointLight,TweenInfo.new(2),{
				Range = 0,
				Brightness = 0,
			})
			Tween:Play()
			Tween:Destroy()
			Debris:AddItem(LightningSkill,3)

		end,
		
		["UltAuraOff"] = function(Data)
			local Character = Data.Character
			local UID = Data.UID

			for i,x in pairs(Character:GetDescendants()) do
				if x.Name == "KSISAura" then
					x:Destroy()
				end
			end
		end,
		
	}
}

return KidSasuke
