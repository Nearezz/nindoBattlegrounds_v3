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

local Player = Players.LocalPlayer


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

local function EmitAll(Ins)
	for _, ins in pairs(Ins:GetDescendants()) do
		if ins:IsA("ParticleEmitter") then
			ins:Emit(ins:GetAttribute("EmitCount"))
		end
	end
end

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


local function EnableAll(bool, obj)
	for _, v in ipairs(obj:GetDescendants()) do
		if v:IsA("ParticleEmitter") or v:IsA('Beam') or v:IsA('Trail') then
			v.Enabled = bool			
		end
	end 
end

local CharacterID = "KidNeji"

local function GenerateJunkTable(CharacterID)
	local CleanUpService = require(RS.Modules.Services.CleanupService)
	return CleanUpService:GenerateJunkTable(CharacterID)
end

local JunkTable = GenerateJunkTable(CharacterID)

local KidNeji; KidNeji = {
	["FirstSkill"] = {
		["SpawnRotation"] = function(Data)
			local Character = Data.Character
			if not Character.PrimaryPart then return end
			
			local UID = Data.UID
			
			local RotationSphere = RS.Assets.Effects.Neji.Rotation:Clone()
			RotationSphere.CFrame = Character.PrimaryPart.CFrame
			RotationSphere.Parent = workspace.World.Effects

			for i,x in ipairs(RotationSphere:GetDescendants()) do
				if x:IsA("ParticleEmitter") then
					x.Enabled = true
				end
				if x:IsA("SpotLight") then
					x.Brightness = 0
					x.Enabled = true
					TweenService:Create(x,TweenInfo.new(.75,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{
						["Brightness"] = 10
					}):Play()
				end
			end

			task.delay(1.65,function()
				for i,x in pairs(RotationSphere:GetDescendants()) do
					if x:IsA("ParticleEmitter") then
						x.Enabled = false
					end
					if x:IsA("SpotLight") then
						local Tween = TweenService:Create(x,TweenInfo.new(.75,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{
							["Brightness"] = 0
						})
						Tween.Completed:Connect(function()
							Tween:Destroy()
							x.Enabled = false
						end)
						Tween:Play()
					end
				end
			end)
			
			Debris:AddItem(RotationSphere,6)
		end,
		["CameraEffect"] = function(Data)
			local Character = Data.Character
			local UID = Data.UID
			
			local ClientManager = require(Player.PlayerScripts:WaitForChild("Client"):WaitForChild("ClientHandler"))
			
			local Camera = workspace.CurrentCamera
			local Tween = TweenService:Create(Camera,TweenInfo.new(.45,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut),{
				["FieldOfView"] = 55
			})
			local Tween2 = TweenService:Create(Camera,TweenInfo.new(.75,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut),{
				["FieldOfView"] = 75
			})
			local Tween3 = TweenService:Create(Camera,TweenInfo.new(1.45,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut),{
				["FieldOfView"] = 70
			})
			Tween.Completed:Connect(function()
				Tween:Destroy()
				Tween2:Play()
				Tween2:Destroy()
				task.delay(1.65,function()
					Tween3:Play()
					Tween3:Destroy()
				end)
			end)
			Tween:Play()
			task.delay(.45,function()
				ClientManager.CamShaker:StartShake(5.5,11,0.4)
				task.delay(2,function()
					ClientManager.CamShaker:StopSustained()
				end)
			end)
		end,
	},
	["SecondSkill"] = {
		["SpawnPlam"] = function(Data)
			local Character = Data.Character
			local UID = Data.UID
			
			local Cirle64 = RS.Assets.Effects.Neji["Trigram 64"]:Clone()
			JunkTable["KidNeji64Plams"..Character.Name..UID] = Cirle64
			
			for _, Circle64 in ipairs(Cirle64:GetChildren()) do
				Circle64.Transparency = 1
			end
			
			Cirle64.PrimaryPart.CFrame = CFrame.new(RayCheck(Character.PrimaryPart.CFrame.Position))
			
			for _, Circle64 in ipairs(Cirle64:GetChildren()) do
				Circle64.Transparency = 1
			end
			
			Cirle64.Parent = workspace.World.Effects
			
			local Tween = TweenService:Create(Cirle64.PrimaryPart,TweenInfo.new(.75,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{
				["CFrame"] = CFrame.new(Cirle64.PrimaryPart.CFrame.p) * CFrame.Angles(math.rad(0),math.rad(180),math.rad(0)),
			})

			local Tween2 = TweenService:Create(Cirle64.Trigram1,TweenInfo.new(.75,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{
				["Transparency"] = 0,
			})

			local Tween3 = TweenService:Create(Cirle64.Trigram2,TweenInfo.new(.75,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{
				["Transparency"] = 0,
			})
			
			local Tween4 = TweenService:Create(Cirle64.Trigram1Glow,TweenInfo.new(.75,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{
				["Transparency"] = 0,
			})

			local Tween5 = TweenService:Create(Cirle64.Trigram2Glow,TweenInfo.new(.75,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{
				["Transparency"] = 0,
			})

			Tween:Play()
			Tween:Destroy()
			Tween2:Play()
			Tween2:Destroy()
			Tween3:Play()
			Tween3:Destroy()
			Tween4:Play()
			Tween4:Destroy()
			Tween5:Play()
			Tween5:Destroy()
		end,
		["RemovePlam"] = function(Data)
			local Character = Data.Character
			local UID = Data.UID
			if JunkTable["KidNeji64Plams"..Character.Name..UID] ~= nil then
				JunkTable["KidNeji64Plams"..Character.Name..UID]:Destroy()
				JunkTable["KidNeji64Plams"..Character.Name..UID] = nil
			end
			
		end,
	},
	["ThirdSkill"] = {
		["SpawnKunai"] = function(Data)
			local Character = Data.Character
			local UID = Data.UID

			local Shuriken = RS.Assets.Effects.Neji["Explosive Kunai"]:Clone()
			JunkTable["NejiKunai"..Character.Name.."_"..Data.UID] = Shuriken

			Shuriken.PrimaryPart.CFrame = Data.StartPoint
			Shuriken.Parent = workspace.World.Effects
			Shuriken.MeshPart.Trail.Enabled = true


			local FinalVelocity = Data.Velocity + (Data.Acceleration * Data.Duration)

			local Velocity = Instance.new("BodyVelocity")
			Velocity.Velocity = (Data.Direction * Data.Velocity)
			Velocity.MaxForce = Vector3.new(math.huge,math.huge,math.huge)

			local AccelTween = TweenService:Create(Velocity,TweenInfo.new(Data.Duration),{
				Velocity = (Data.Direction * FinalVelocity)
			})

			Velocity.Parent = Shuriken.PrimaryPart
			Shuriken.PrimaryPart.Anchored = false
			AccelTween:Play()
			Debris:AddItem(Velocity,Data.Duration)
			task.delay(Data.Duration + 0.01,function()
				if JunkTable["NejiKunai"..Character.Name.."_"..Data.UID] ~= nil then
					JunkTable["NejiKunai"..Character.Name.."_"..Data.UID]:Destroy()
					JunkTable["NejiKunai"..Character.Name.."_"..Data.UID] = nil
				end
			end)
			
			if Data.TargetPlayer then
				local HighLight = Instance.new("Highlight")
				HighLight.Parent = Data.TargetPlayer
				Debris:AddItem(HighLight,2)
			end
			
		end,
		["ExpKunai"] = function(Data)
			local Character = Data.Character
			local UID = Data.UID
			if JunkTable["NejiKunai"..Character.Name.."_"..Data.UID] ~= nil then
				JunkTable["NejiKunai"..Character.Name.."_"..Data.UID]:Destroy()
				JunkTable["NejiKunai"..Character.Name.."_"..Data.UID] = nil
			end
			
			local ExplosionEffect = RS.Assets.Effects.Neji.ExplosionEffect:Clone()
			ExplosionEffect.CFrame = CFrame.new(Data.Location)
			
			ExplosionEffect.Parent = workspace.World.Effects
			
			local Tween = TweenService:Create(ExplosionEffect.Attachment.PointLight,TweenInfo.new(1),{ Brightness = 5})
			Tween:Play()
			Tween.Completed:Connect(function()
				Tween:Destroy()
				local Tween2 = TweenService:Create(ExplosionEffect.Attachment.PointLight,TweenInfo.new(1),{ Brightness = 0})
				Tween2:Play()
				Tween2.Completed:Connect(function()
					Tween2:Destroy()
				end)
			end)
			EmitAll(ExplosionEffect.Attachment)
		end,
	},
	["FourthSkill"] = {
		["Hold"] = function(Data)

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
		["EyeOn"] = function(Data)
			local Character = Data.Character
			local UID = Data.UID
			
			local EyeEffect = Instance.new("ColorCorrectionEffect")
			EyeEffect.Name = Character.Name.." NejiUltEffect"..UID
			EyeEffect.Parent = game:GetService("Lighting")
			
			local Tween = TweenService:Create(EyeEffect,TweenInfo.new(1.25,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut),{
				Brightness = script.EyeColor.Brightness,
				Contrast = script.EyeColor.Contrast,
				Saturation = script.EyeColor.Saturation,
				TintColor = script.EyeColor.TintColor
			})
			
			Tween.Completed:Connect(function()
				JunkTable[UID..Character.Name.."NejiUlt"] = RunService.RenderStepped:Connect(function()
					for _,Char in pairs(workspace.World.Entities:GetChildren()) do
						if not Char:FindFirstChild("NejiEyeUlt") and Char ~= Character then
							local NejiEyeUlt = script.Neji:Clone()
							NejiEyeUlt.Name = "NejiEyeUlt"
							NejiEyeUlt.Parent = Char
						end
					end
				end)
			end)
			
			Tween:Play()
			
		end,
		["EyeOff"] = function(Data)
			local Character = Data.Character
			local UID = Data.UID
			
			local Lighting = game:GetService("Lighting")
			
			if Lighting:FindFirstChild(Character.Name.." NejiUltEffect"..UID) then
				Lighting:FindFirstChild(Character.Name.." NejiUltEffect"..UID):Destroy()
			end
			
			if JunkTable[UID..Character.Name.."NejiUlt"] ~= nil then
				JunkTable[UID..Character.Name.."NejiUlt"]:Disconnect()
				JunkTable[UID..Character.Name.."NejiUlt"] = nil
			end
			for _,Char in ipairs(workspace.World.Entities:GetChildren()) do
				if Char:FindFirstChild("NejiEyeUlt") then
					Char:FindFirstChild("NejiEyeUlt"):Destroy()
				end
			end

		end,
		["UltAuraOff"] = function(Data)
			local Character = Data.Character
			local UID = Data.UID
			
			for i,x in ipairs(Character:GetDescendants()) do
				if x.Name == "NejiAura" then
					x:Destroy()
				end
			end
		end,
	}
}

return KidNeji
