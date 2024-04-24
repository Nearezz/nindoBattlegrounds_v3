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
	Para.FilterType = Enum.RaycastFilterType.Whitelist
	Para.FilterDescendantsInstances = {workspace.World.Map}
	local RayCas = workspace:Raycast(Ori,Vector3.new(0,-10000,0),Para)
	if RayCas then
		return RayCas.Position
	else
		return Ori
	end
end

local function EmitAll(Ins)
	for _, ins in pairs(Ins:GetDescendants()) do
		if ins:IsA("ParticleEmitter") then
			ins:Emit(ins:GetAttribute("EmitCount"))
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

local OldKakashi; OldKakashi = {
	["FirstSkill"] = {
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
			JunkTable["Fireball_Kakashi"..Character.Name..UID] = FireBall
			
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
				OldKakashi["FirstSkill"]["FireballHit"]({
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
			
			if JunkTable["Fireball_Kakashi"..Character.Name..UID] then
				local Fire= JunkTable["Fireball_Kakashi"..Character.Name..UID]
				JunkTable["Fireball_Kakashi"..Character.Name..UID] = nil
				
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
	["SecondSkill"] = {
		["ThrowObject"] = function(Data)
			local Character = Data.Character
			local UID = Data.UID
			
			local Shuriken = RS.Assets.Effects.Kakashi.Shuriken:Clone()
			JunkTable["KakashiShuri"..Character.Name.."_"..Data.Number..Data.UID] = Shuriken
			
			Shuriken.CFrame = Data.StartPoint
			Shuriken.Parent = workspace.World.Effects
			Shuriken.Trail.Enabled = true
			
			
			local FinalVelocity = Data.Velocity + (Data.Acceleration * Data.Duration)

			local Velocity = Instance.new("BodyVelocity")
			Velocity.Velocity = (Data.Direction * Data.Velocity)
			Velocity.MaxForce = Vector3.new(math.huge,math.huge,math.huge)

			local AccelTween = TweenService:Create(Velocity,TweenInfo.new(Data.Duration),{
				Velocity = (Data.Direction * FinalVelocity)
			})

			Velocity.Parent = Shuriken
			Shuriken.Anchored = false
			AccelTween:Play()
			Debris:AddItem(Velocity,Data.Duration)
			task.delay(Data.Duration + 0.01,function()
				if JunkTable["KakashiShuri"..Character.Name.."_"..Data.Number..Data.UID] ~= nil then
					JunkTable["KakashiShuri"..Character.Name.."_"..Data.Number..Data.UID]:Destroy()
					JunkTable["KakashiShuri"..Character.Name.."_"..Data.Number..Data.UID] = nil
				end
			end)
		end,
		["Stick"] = function(Data)
			local Character = Data.Character
			local UID = Data.UID
			if JunkTable["KakashiShuri"..Character.Name.."_"..Data.Number..Data.UID] ~= nil then
				JunkTable["KakashiShuri"..Character.Name.."_"..Data.Number..Data.UID]:Destroy()
				JunkTable["KakashiShuri"..Character.Name.."_"..Data.Number..Data.UID] = nil
			end
			local Shuriken = RS.Assets.Effects.Kakashi.Shuriken:Clone()
			Shuriken.CFrame = CFrame.new(Data.Position) * CFrame.Angles(math.rad(math.random(-25,25)),math.rad(math.random(-100,100)),math.rad(math.random(-100,100)))
			Shuriken.Parent = workspace.World.Effects
			Weld(Shuriken,Data.Stick,Data.Stick.CFrame)
			Debris:AddItem(Shuriken,5)
		end,
	},
	["ThirdSkill"] = {
		["SummonEarthWall"] = function(Data)
	
			
			local Character = Data.Character
			local WallCFrame = Data.WallCFrame
			
			local function getRandomInPart(part)
				local random = Random.new()
				local randomCFrame = part.CFrame * CFrame.new(random:NextNumber(-part.Size.X/2,part.Size.X/2), random:NextNumber(-part.Size.Y/2,part.Size.Y/2), random:NextNumber(-part.Size.Z/2,part.Size.Z/2))
				return randomCFrame
			end
			
			local function EarthWallBreak(Part)
				local random = Random.new()
				
				local Wall = script.W:Clone()
				Wall.Anchored = true
				Wall.Size = Vector3.new(Part.Size.X/2,Part.Size.Y/2,Part.Size.Z/2)
				Wall.CFrame = getRandomInPart(Part) * CFrame.Angles(math.rad(random:NextNumber(-360,360)),math.rad(random:NextNumber(-360,360)),math.rad(random:NextNumber(-360,360)))
				
				local Wall2 = script.W:Clone()
				Wall2.Anchored = true
				Wall2.Size = Vector3.new(Part.Size.X/2,Part.Size.Y/2,Part.Size.Z/2)
				Wall2.CFrame = getRandomInPart(Part) * CFrame.Angles(math.rad(random:NextNumber(-360,360)),math.rad(random:NextNumber(-360,360)),math.rad(random:NextNumber(-360,360)))
				
				local Wall3 = script.W:Clone()
				Wall3.Anchored = true
				Wall3.Size = Vector3.new(Part.Size.X/2,Part.Size.Y/2,Part.Size.Z/2)
				Wall3.CFrame = getRandomInPart(Part) * CFrame.Angles(math.rad(random:NextNumber(-360,360)),math.rad(random:NextNumber(-360,360)),math.rad(random:NextNumber(-360,360)))
				
				
				Wall.Parent = workspace.World.Effects
				Wall2.Parent = workspace.World.Effects
				Wall3.Parent = workspace.World.Effects
				
				Wall.Anchored = false
				Wall2.Anchored = false
				Wall3.Anchored = false
				
				Part:Destroy()
				
				Debris:AddItem(Wall,5)
				Debris:AddItem(Wall2,5)
				Debris:AddItem(Wall3,5)
			end
			
			local WallEffect = RS.Assets.Effects.Kakashi.MudWall:Clone()
			
			WallEffect.PrimaryPart.CFrame = WallCFrame
			WallEffect.Parent = workspace.World.Effects
			
			local Tween = TweenService:Create(WallEffect.PrimaryPart,TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut),{
				["CFrame"] = WallCFrame * CFrame.new(0,16.62,0)
			})
			
			Tween:Play()
			Tween:Destroy()
			
			
			
			task.delay(5,function()
				for i,x in pairs(WallEffect:GetChildren()) do
					EarthWallBreak(x)
				end
			end)
			
		end,
	},
	["FourthSkill"] = {
		["Hold"] = function(Data)

		end,
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
			
			if JunkTable["Chidori"..UID] ~= nil then
				JunkTable["Chidori"..UID]:Destory()
				JunkTable["Chidori"..UID] = nil
			end
			JunkTable["Chidori"..UID] = Chidori
			
			
		end,
		
		["ChidoriParticleOff"] = function(Data)
			local Character = Data.Character
			local UID = Data.UID
		
			
			if JunkTable["Chidori"..UID] ~= nil then
				EnableAll(false,JunkTable["Chidori"..UID])
				JunkTable["Chidori"..UID]:Destroy()
				JunkTable["Chidori"..UID] = nil
			end

		end,
		["ChidoriHit"] = function(Data)
			local Character = Data.Character
			local Victim = Data.Victim
			local UID = Data.UID

			local Chidori = JunkTable["Chidori"..UID]

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
	["UltimateSkill"] = {
		["ChidoriParticleOn"] = function(Data)
			local Character = Data.Character
			local UID = Data.UID
			
			
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

			if JunkTable["ChidoriUlt"..Character.Name..UID] then
				JunkTable["ChidoriUlt"..Character.Name..UID]:Destory()
				JunkTable["ChidoriUlt"..Character.Name..UID] = nil
			end
			JunkTable["ChidoriUlt"..Character.Name..UID] = Chidori
			
			
			local WindPartcle = script["Wind stuff"]:Clone()
			
			if JunkTable["ChidoriUltWind"..Character.Name..UID] then
				JunkTable["ChidoriUltWind"..Character.Name..UID]:Destroy()
				JunkTable["ChidoriUltWind"..Character.Name..UID] = nil
			end
			JunkTable["ChidoriUltWind"..Character.Name..UID] = WindPartcle
			
			WindPartcle.CFrame = CFrame.new(RayCheck(Character.PrimaryPart.CFrame.p))
			WindPartcle.Transparency = 1
			EnableAll(false,WindPartcle)
			WindPartcle.Parent = workspace.World.Effects
			EnableAll(true,WindPartcle)
			
		end,
		["ChidoriHit"] = function(Data)
			local Character = Data.Character
			local Victim = Data.Victim
			local UID = Data.UID

			local Chidori = JunkTable["ChidoriUlt"..Character.Name..UID]

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

			JunkTable["ChidoriUlt"..Character.Name..UID] = nil



		end,
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
		["UltAuraOff"] = function(Data)
			local Character = Data.Character
			local UID = Data.UID

			for i,x in pairs(Character:GetDescendants()) do
				if x.Name == "KakaAura" then
					x:Destroy()
				end
			end
		end,
		["WindOff"] = function(Data)
			local Character = Data.Character
			local UID = Data.UID
			
			if JunkTable["ChidoriUltWind"..Character.Name..UID] ~= nil then
				JunkTable["ChidoriUltWind"..Character.Name..UID]:Destroy()
				JunkTable["ChidoriUltWind"..Character.Name..UID] = nil
			end
			
		end,
		["PlayCamera"] = function(Data)
			local Character = Data.Character
			local UID = Data.UID
			local Player = Players.LocalPlayer
			
			local ClientManager = require(Player.PlayerScripts:WaitForChild("Client"):WaitForChild("ClientHandler"))
			ClientManager.CameraService:RunCameraPath("KakaUlt",true,Data.Origin)
		end,
		["CameraOff"] = function(Data)
			local Player = Players.LocalPlayer
			
			local ClientManager = require(Player.PlayerScripts:WaitForChild("Client"):WaitForChild("ClientHandler"))
			ClientManager.CameraService:ChangeFlag(true)
			task.wait(.1)
			ClientManager.CameraService:ChangeFlag(false)
		end,
	}
}

return OldKakashi
