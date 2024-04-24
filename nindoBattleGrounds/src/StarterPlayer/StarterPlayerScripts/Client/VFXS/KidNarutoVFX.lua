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
local function GenerateJunkTable(CharacterID)
	local CleanUpService = require(RS.Modules.Services.CleanupService)
	return CleanUpService:GenerateJunkTable(CharacterID)
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

local function Invis(char,Amount)
	for _, part in ipairs(char:GetDescendants()) do
		if part.Name ~= "HumanoidRootPart" and part:IsA('BasePart') or part:IsA('MeshPart') or part:IsA('Decal')  then
			part.Transparency = Amount
		end
	end
end

local JunkTable = GenerateJunkTable(CharacterID)

local OldKakashi; OldKakashi = {
	["FirstSkill"] = {
		["RaseHit"] = function(Data)
			local Character = Data.Character
			local UID = Data.UID
			
			local Victim = Data.Victim

			
			if JunkTable["KidNarutoRase"..UID..Character.Name] == nil then return end

			local Rasg = JunkTable["KidNarutoRase"..UID..Character.Name]
			JunkTable["KidNarutoRase"..UID..Character.Name] = nil
			EnableAll(false,Rasg)

			local Tween = TweenService:Create(Rasg.Attachment.PointLight,TweenInfo.new(0.25),{
				Range = 0,
				Brightness = 0
			})

			Tween:Play()
			Tween:Destroy()
			Debris:AddItem(Rasg,2)
			
			local VictimHit = RS.Assets.Effects.Naruto["Rasengan Explosion"]:Clone()
			VictimHit.Parent = workspace.World.Effects
			VictimHit.CFrame = CFrame.lookAt((Victim.PrimaryPart.CFrame * CFrame.new(0,0.01,-1.5)).Position,Victim.PrimaryPart.CFrame.Position)
			
			Weld(VictimHit,Victim["Torso"],Victim["Torso"].CFrame)
			
			local Tween2 = TweenService:Create(VictimHit.Attachment1.Spot1,TweenInfo.new(.25),{
				Range = 9,
				Brightness = 20.98,
			})
			
			local Tween3 = TweenService:Create(VictimHit.Attachment1.Spot1,TweenInfo.new(1),{
				Range = 0,
				Brightness = 0,
			})
			
			Tween2:Play()
			Tween2.Completed:Connect(function()
				Tween2:Destroy()
				Tween3:Play()
				Tween3:Destroy()
			end)
			
			
			EmitAll(VictimHit)
			Debris:AddItem(VictimHit,3)
			
		end,
		["CloneSpawn"] = function(Data)
			local Character = Data.Character
			local UID = Data.UID
			
			Character.Archivable = true
			local Clone = Character:Clone()
			Character.Archivable = false
			
			local ClonePoof = RS.Assets.Effects.Sasuke.ClonePoof:Clone()
			
			ClonePoof.Parent = workspace.World.Effects
			
			local CloneCFrame = Character.PrimaryPart.CFrame * CFrame.new(4.4, 0, 2, 0, 0, 5, 0, 1, 0, -1, 0, 0)
			CloneCFrame = CloneCFrame * CFrame.Angles(0, -0.02, 0)
			ClonePoof.CFrame = CloneCFrame

			
			EmitAll(ClonePoof)
			Debris:AddItem(ClonePoof,3)
			Clone.PrimaryPart.CFrame = CloneCFrame
			Clone.Parent = workspace.World.Effects
			local Anim = Clone.Humanoid:LoadAnimation(RS.Assets.Animations.Shared.KidNaruto.CloneChargeReg)
			Anim:Play()
			Anim.Looped = true
			
			
			task.delay(Data.ChargeTime,function()
				Anim:Stop()
				local ClonePoof2 = RS.Assets.Effects.Sasuke.ClonePoof:Clone()
				ClonePoof2.CFrame = CloneCFrame
				ClonePoof2.Parent = workspace.World.Effects
				EmitAll(ClonePoof2)
				Debris:AddItem(ClonePoof2,3)
				Clone:Destroy()
			end)
		end,
		["Rase"] = function(Data)
			local Character = Data.Character
			local UID = Data.UID
			
			if JunkTable["KidNarutoRase"..UID..Character.Name] ~= nil then
				JunkTable["KidNarutoRase"..UID..Character.Name]:Destroy()
				JunkTable["KidNarutoRase"..UID..Character.Name] = nil
			end
			
			local Rasg = RS.Assets.Effects.Naruto.Rasg:Clone()
			Rasg.CFrame = Character["Right Arm"].CFrame * CFrame.new(0,-1,0)
			Rasg.Parent = workspace.World.Effects
			
			Weld(Rasg,Character["Right Arm"],Character["Right Arm"].CFrame)
			EnableAll(true,Rasg)
			
			JunkTable["KidNarutoRase"..UID..Character.Name] = Rasg
			
			local Tween = TweenService:Create(Rasg.Attachment.PointLight,TweenInfo.new(0.25),{
				Range = 12,
				Brightness = 1.34
			})
			
			Tween:Play()
			Tween:Destroy()
		end,
		["RaseOff"] = function(Data)
			local Character = Data.Character
			local UID = Data.UID
			
			if JunkTable["KidNarutoRase"..UID..Character.Name] == nil then return end
				
			local Rasg = JunkTable["KidNarutoRase"..UID..Character.Name]
			JunkTable["KidNarutoRase"..UID..Character.Name] = nil
			EnableAll(false,Rasg)
			Debris:AddItem(Rasg,2)
		end,
	},
	["SecondSkill"] = {
		["Hold"] = function(Data)

		end,
	},
	["ThirdSkill"] = {
		["Start"] = function(Data)
			local Character = Data.Character
			local UID = Data.UID

			local Victim = Data.Victim
			
			local function Clone(char) 
				char.Archivable = true
				local clone = char:Clone()
				for i,x in pairs(clone:GetDescendants()) do
					if x:IsA("BasePart") or x:IsA("MeshPart") or x:IsA("Union") then
						PhysicsService:SetPartCollisionGroup(x,"ShadowClone")
					end
				end
				char.Archivable = false
				return clone
			end
			
			local CloneLPos = Data.CloneLPos
			local CloneRPos = Data.CloneRPos
			
			local CloneL = Clone(Character)
			local CloneR = Clone(Character)
			
			CloneL.PrimaryPart.CFrame = CloneLPos
			CloneR.PrimaryPart.CFrame = CloneRPos
			
			
			CloneL.Parent = workspace.World.Effects
			CloneR.Parent = workspace.World.Effects
			
			local Anim = CloneL.Humanoid.Animator:LoadAnimation(RS.Assets.Animations.Shared.KidNaruto.CloneL)
			Anim:Play()
			Anim.Stopped:Connect(function()
				local smoke = script.Sub:Clone()
				smoke.CFrame = CloneLPos
				smoke.Parent = workspace.World.Effects
				smoke.ParticleEmitter:Emit(smoke.ParticleEmitter:GetAttribute('EmitCount'))
				Debris:AddItem(smoke, 1)
				CloneL:Destroy()
			end)
			
			local Anim2 = CloneR.Humanoid.Animator:LoadAnimation(RS.Assets.Animations.Shared.KidNaruto.CloneR)
			Anim2:Play()
			Anim2.Stopped:Connect(function()
				local smoke = script.Sub:Clone()
				smoke.CFrame = CloneRPos
				smoke.Parent = workspace.World.Effects
				smoke.ParticleEmitter:Emit(smoke.ParticleEmitter:GetAttribute('EmitCount'))
				Debris:AddItem(smoke, 1)
				CloneR:Destroy()
			end)

		end,
	},
	["FourthSkill"] = {
		["Love"] = function(Data)
			local Character = Data.Character
			local UID = Data.UID
			
			Character.Archivable = true
			local Clone = Character:Clone()
			Character.Archivable = false
			
			Invis(Character,1)
			Clone.Parent = workspace.World.Effects
			Clone.PrimaryPart.CFrame = Character.PrimaryPart.CFrame
			for _,part in pairs(Character:GetDescendants()) do
				if part:IsA('BasePart') or part:IsA('MeshPart') then
					part.CanCollide = false
				end
			end
			
			local Sphere = Instance.new("Part")
			Sphere.Anchored = true
			Sphere.CanCollide = false
			Sphere.CanQuery = false
			Sphere.Material = Enum.Material.Neon
			Sphere.Color = Color3.new(0.980392, 0.466667, 1)
			Sphere.Shape = Enum.PartType.Ball
			Sphere.CFrame = CFrame.new(Character.PrimaryPart.CFrame.p + Vector3.new(0,1.5,0)) 
			
			Sphere.Size = Vector3.new(0.1,0.1,0.1)
			Sphere.Parent = workspace.World.Effects
			Sphere.Transparency = 0.35
			local tween = TweenService:Create(Sphere,TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut),{
				Size = Vector3.new(24,24,24),
				Transparency = 1
			})
			tween:Play()
			tween.Completed:Connect(function()
				Sphere:Destroy()
				tween:Destroy()
			end)
			
			local Anim = Clone.Humanoid.Animator:LoadAnimation(RS.Assets.Animations.Shared.KidNaruto.Transform4thDone)
			Anim:Play()
			

			
			Anim.Stopped:Connect(function()
				Invis(Character,0)
				Clone:Destroy()
			end)

			
			
			
			
		end,
		
		["LoveHit"] = function(Data)
			local Character = Data.Character
			local UID = Data.UID
			
			for _,Target in pairs(Data.HitTargets) do
				local heart = RS.Assets.Effects.Naruto.HeartFlurry:Clone()
				heart.CFrame = Target.Head.CFrame * CFrame.new(0,1,0)
				Weld(heart,Target["Head"],Target["Head"].CFrame)
				heart.Parent = workspace.World.Effects
				local Tween = TweenService:Create(heart,TweenInfo.new(2),{
					Orientation = Vector3.new(0, 1080, 0)
				})
				Tween:Play();Tween:Destroy()
				Debris:AddItem(heart,2)
			end
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
		["UltAuraOff"] = function(Data)
			local Character = Data.Character
			local UID = Data.UID

			for i,x in pairs(Character:GetDescendants()) do
				if x.Name == "KNariAura" then
					x:Destroy()
				end
			end
		end,
		["RaseHit"] = function(Data)
			local Character = Data.Character
			local UID = Data.UID

			local Victim = Data.Victim
			
			task.spawn(function()
				if JunkTable["KidNarutoUltRase"..UID..Character.Name] == nil then return end

				local Rasg = JunkTable["KidNarutoUltRase"..UID..Character.Name]
				JunkTable["KidNarutoUltRase"..UID..Character.Name] = nil
				EnableAll(false,Rasg)
				
				local Tween = TweenService:Create(Rasg.Attachment.PointLight,TweenInfo.new(0.25),{
					Range = 0,
					Brightness = 0
				})

				Tween:Play()
				Tween:Destroy()
				Debris:AddItem(Rasg,2)
			end)
			
			

			local VictimHit = RS.Assets.Effects.Naruto["Rasengan Explosion"]:Clone()

			VictimHit.Parent = workspace.World.Effects

			VictimHit.CFrame = CFrame.lookAt((Victim.PrimaryPart.CFrame * CFrame.new(0,0.01,-1.5)).Position,Victim.PrimaryPart.CFrame.Position)

			Weld(VictimHit,Victim["Torso"],Victim["Torso"].CFrame)


			local Tween2 = TweenService:Create(VictimHit.Attachment1.Spot1,TweenInfo.new(.25),{
				Range = 9,
				Brightness = 20.98,
			})

			local Tween3 = TweenService:Create(VictimHit.Attachment1.Spot1,TweenInfo.new(1),{
				Range = 0,
				Brightness = 0,
			})

			Tween2:Play()
			Tween2.Completed:Connect(function()
				Tween2:Destroy()
				Tween3:Play()
				Tween3:Destroy()
			end)


			EmitAll(VictimHit)
			Debris:AddItem(VictimHit,3)

		end,
		["CloneSpawn"] = function(Data)
			local Character = Data.Character
			local UID = Data.UID

			task.spawn(function()
				Character.Archivable = true
				local Clone = Character:Clone()
				Clone.Name = Character.Name.." - Clone"
				Character.Archivable = false
				
				local ClonePoof = RS.Assets.Effects.Sasuke.ClonePoof:Clone()
				ClonePoof.Parent = workspace.World.Effects
				
				local CloneCFrame = Character.PrimaryPart.CFrame * CFrame.new(4.4, 0, 2, 0, 0, 5, 0, 1, 0, -1, 0, 0)
				ClonePoof.CFrame = CloneCFrame
				
				EmitAll(ClonePoof)
				Debris:AddItem(ClonePoof,3)
				Clone.PrimaryPart.CFrame = CloneCFrame
				Clone.Parent = workspace.World.Effects
				local Anim = Clone.Humanoid:LoadAnimation(RS.Assets.Animations.Shared.KidNaruto.CloneChargeReg)
				Anim:Play()
				Anim.Looped = true


				task.delay(Data.ChargeTime,function()
					Anim:Stop()
					local ClonePoof2 = RS.Assets.Effects.Sasuke.ClonePoof:Clone()
					ClonePoof2.CFrame = CloneCFrame
					ClonePoof2.Parent = workspace.World.Effects
					EmitAll(ClonePoof2)
					Debris:AddItem(ClonePoof2,3)
					Clone:Destroy()
				end)
			end)

		end,
		["Rase"] = function(Data)
			local Character = Data.Character
			local UID = Data.UID

			if JunkTable["KidNarutoUltRase"..UID..Character.Name] ~= nil then
				JunkTable["KidNarutoUltRase"..UID..Character.Name]:Destroy()
				JunkTable["KidNarutoUltRase"..UID..Character.Name] = nil
			end

			task.spawn(function()
				local Rasg = RS.Assets.Effects.Naruto.BigRasg:Clone()
				Rasg.CFrame = Character["Right Arm"].CFrame * CFrame.new(0,-1,0)
				Rasg.Parent = workspace.World.Effects

				Weld(Rasg,Character["Right Arm"],Character["Right Arm"].CFrame)
				EnableAll(true,Rasg)

				JunkTable["KidNarutoUltRase"..UID..Character.Name] = Rasg

				local Tween = TweenService:Create(Rasg.Attachment.PointLight,TweenInfo.new(0.25),{
					Range = 12,
					Brightness = 1.34
				})

				Tween:Play()
				Tween:Destroy()

			end)
			
		
		end,
		["RaseOff"] = function(Data)
			local Character = Data.Character
			local UID = Data.UID

			task.spawn(function()
				if JunkTable["KidNarutoUltRase"..UID..Character.Name] == nil then return end

				local Rasg = JunkTable["KidNarutoUltRase"..UID..Character.Name]
				JunkTable["KidNarutoUltRase"..UID..Character.Name] = nil
				EnableAll(false,Rasg)
				Debris:AddItem(Rasg,2)
			end)
			task.spawn(function()
				if JunkTable["KidNarutoUltRase2"..UID..Character.Name] == nil then return end

				local Rasg = JunkTable["KidNarutoUltRase2"..UID..Character.Name]
				JunkTable["KidNarutoUltRase2"..UID..Character.Name] = nil
				EnableAll(false,Rasg)
				Debris:AddItem(Rasg,2)
			end)
		end,
	}
}

return OldKakashi
