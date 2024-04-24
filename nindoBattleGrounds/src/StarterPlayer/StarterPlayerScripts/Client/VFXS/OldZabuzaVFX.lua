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

local CameraShaker = require(RS.Modules.Utility.CameraShaker)

local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value,
	function(shakeCf)
		local camera = game.Workspace.Camera
		camera.CFrame = camera.CFrame * shakeCf
	end
)


local CharacterID = "OldZabuza"

local Effects = RS.Assets.Effects

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
local waterCast = false

local OldZabuza; OldZabuza = {
	["FirstSkill"] = {
		["WaterCast"] = function(Data)
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

			local WaterBullet = RS.Assets.Effects.OldZabuza.WaterBulletJutsu:Clone()
			JunkTable["WaterBullet_Zabuza"..Character.Name..UID] = WaterBullet

			local start = tick()
			local con = nil

			WaterBullet.CFrame = Character.PrimaryPart.CFrame * CFrame.new(0,0,-3)
			WaterBullet.Parent = workspace.World.Effects

			EnableAll(true, WaterBullet.Spray)
			waterCast = true
			
			con = RunService.RenderStepped:Connect(function()
				if tick()-start < Data.Duration and waterCast then
					WaterBullet.CFrame = Character.PrimaryPart.CFrame * CFrame.new(0,0,-3)
				else
					con:Disconnect()
					if WaterBullet then
						WaterBullet:Destroy()
					end
					waterCast = false
				end
			end)

		end,
		
		["WaterEnd"] = function()
			waterCast = false
		end,
	},
	["SecondSkill"] = {
		['Cast'] = function(Character)
			local Root = Character.Torso

			local ColorCorrection = Instance.new("ColorCorrectionEffect")
			ColorCorrection.Parent = game.Lighting
			local Bloom = Instance.new("BloomEffect")
			Bloom.Parent = game.Lighting

			local Dust = Effects.Zabuza:WaitForChild("Dust"):Clone()
			Dust.CFrame = Root.CFrame
			Dust.Parent = workspace.World.Effects
			EnableAll(true, Dust)

			task.delay(.5, function()
				EnableAll(false, Dust)
				Debris:AddItem(Dust, 1)

				for _, v in ipairs(Character:GetDescendants()) do 
					if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
						local vTween = TweenService:Create(v, TweenInfo.new(.7, Enum.EasingStyle.Exponential), {["Transparency"] = 1})
						vTween:Play()
						vTween:Destroy()
					end
				end
			end)

			task.wait(.5)

			local Mist = Effects.Zabuza:WaitForChild("Mist"):Clone()
			Mist:SetPrimaryPartCFrame(Root.CFrame * CFrame.new(0,-2,0) * CFrame.Angles(0,0,math.rad(90)))
			Mist.Parent = workspace.World.Effects
			EnableAll(true, Mist)	

			local CCTween = TweenService:Create(ColorCorrection,TweenInfo.new(0.35,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{
				["Brightness"] 	= -0.2;
				["Contrast"] 		= 0.2;
				["Saturation"] 	= 0.3;
				["TintColor"]   =  Color3.fromRGB(156, 156, 156)
			})
			CCTween:Play()
			CCTween:Destroy()

			local BloomTween = TweenService:Create(Bloom,TweenInfo.new(0.1,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{
				["Intensity"] 	= 2;
				["Size"] 		= 24;
				["Threshold"] 	= 2;
			})
			BloomTween:Play()
			BloomTween:Destroy()

			local Active = true
			local State = false

			local invis = true

			task.defer(function()
				while Active do
					if Character.Humanoid.Health < 100 or Character:FindFirstChild('M1') then
						invis = false
						for _, v in ipairs(Character:GetDescendants()) do 
							if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
								local VanishTween = TweenService:Create(v, TweenInfo.new(.7, Enum.EasingStyle.Exponential), {["Transparency"] = 0})
								VanishTween:Play()
								VanishTween:Destroy()
							end
						end
					elseif invis == false and not Character:FindFirstChild('M1') then
						invis = true

						for _, v in ipairs(Character:GetDescendants()) do 
							if not Active then break end
							if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
								local AppearTween = TweenService:Create(v, TweenInfo.new(.7, Enum.EasingStyle.Exponential), {["Transparency"] = 1})
								AppearTween:Play()
								AppearTween:Destroy()
							end
						end
					end
					task.wait(.1)
				end
			end)

			task.delay(6, function()
				if Active == true then
					Active = false
				end
			end)

			task.delay(5, function()
				EnableAll(false, Mist)
				Debris:AddItem(Mist, 3)
				Debris:AddItem(ColorCorrection, 1)
				Debris:AddItem(Bloom, 1)
				local CCTween1 = TweenService:Create(ColorCorrection,TweenInfo.new(0.35,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{
					["Brightness"] 	= 0;
					["Contrast"] 		= 0;
					["Saturation"] 	= 0;
					["TintColor"]   =  Color3.fromRGB(255,255,255)
				})
				CCTween1:Play()
				CCTween1:Destroy()

				local BloomTween1 = TweenService:Create(Bloom,TweenInfo.new(0.1,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{
					["Intensity"] 	= 1;
					["Size"] 		= 24;
					["Threshold"] 	= 2;
				})
				BloomTween1:Play()
				BloomTween1:Destroy()

				if not State then 
					Active = false	
					for _, v in ipairs(Character:GetDescendants()) do 
						if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
							local IfVanish = TweenService:Create(v, TweenInfo.new(.7, Enum.EasingStyle.Exponential), {["Transparency"] = 0})
							IfVanish:Play()
							IfVanish:Destroy()
						end
					end
				end	
			end)
		end,
	},
	["ThirdSkill"] = {
		['Striking Stab'] = function(Character)

			local Root = Character.HumanoidRootPart
			local CraterEffects = RS.Modules.Utility.KolsVFX.CraterEffects
			local CircularDebris = RS.Modules.Utility.KolsVFX.CircularDebris

			local Sword = Character:FindFirstChild("Sword",true)
			local Clone = Effects.Zabuza:WaitForChild("ZabuzaSwordClone"):Clone()
			Clone.CFrame = Character["Right Arm"].CFrame * CFrame.Angles(0,math.rad(180),math.rad(180)) *CFrame.new(0,3,0)
			Clone.Orientation = Vector3.new(0,0,math.rad(30))
			Clone.SwordWeld.Part0 = Character["Right Arm"]
			Clone.Parent = Character
			Clone.Transparency = 0
			Sword.Transparency = 1	
			

			--shared.CachedModules.SoundManager.AddSound('Zabuza Swoosh', {Volume = .7, Looped = false, Parent = Clone},'Client')
			--shared.CachedModules.SoundManager.AddSound('Zabuza Stab Dash', {Volume = .7, Looped = false, Parent = Clone},'Client')

			local Params = RaycastParams.new()
			Params.FilterType = Enum.RaycastFilterType.Blacklist
			Params.FilterDescendantsInstances = {Character, workspace.World.Map, Sword, Clone}

			local Goal = Root.CFrame * CFrame.new(0,0,-20)

			local Forward = TweenService:Create(Root, TweenInfo.new(.1, Enum.EasingStyle.Linear), {["CFrame"] = Goal})
			Forward:Play()	
			
			local params = OverlapParams.new()
			Params.FilterType = Enum.RaycastFilterType.Blacklist
			Params.FilterDescendantsInstances = {Character, workspace.World.Map, Sword, Clone}
			
			

			if workspace:GetPartBoundsInBox(Clone.CFrame, Vector3.new(10,10,10),params) then
				
				local Victims = workspace:GetPartBoundsInBox(Clone.CFrame, Vector3.new(10,10,10),params)

				if not Victims then return end
				if next(Victims) == nil then return end

				for _, parts in ipairs(Victims) do
					print(Victims)
					if parts.Parent:FindFirstChild("Humanoid") and parts.Parent ~= Players.LocalPlayer.Character then
					local	Victim = parts.Parent
						local vRoot = Victim.Torso

						Forward:Pause()
						Forward:Destroy()

						local WeldConstraint = Instance.new("WeldConstraint")
						WeldConstraint.Part0 = vRoot
						WeldConstraint.Part1 = Clone
						WeldConstraint.Part1.CFrame = Clone.CFrame
						WeldConstraint.Name = "StrikingStabWeld"
						WeldConstraint.Parent = Clone
						Root.Anchored = true
						vRoot.Massless = true

						local Float = TweenService:Create(Root, TweenInfo.new(1, Enum.EasingStyle.Quad), {["CFrame"] = Root.CFrame * CFrame.new(0,4,0)})
						Float:Play()
						Float:Destroy()

						--emotes.Server:FireServer('Zabuza', 'FirstAbility', true, {Character, Victims, Clone.CFrame}, 'Striking Stab_Hit')

						task.delay(1.3, function()
							OldZabuza["ThirdSkill"].Striking_Stab_Hit(Character, Root, Clone, Sword, vRoot, WeldConstraint)
						end)
					end
				end	
			else
				Forward:Destroy()
				--Remotes.Server:FireServer('Zabuza', 'FirstAbility', true, {Character}, 'Cancel')

				task.delay(.3,function()
					Clone:Destroy()
					Sword.Transparency = 0
				end)
			end
		end,

		['Striking_Stab_Hit'] = function(Character, Root, Clone, Sword, vRoot, WeldConstraint)

			local CraterEffects = RS.Modules.Utility.KolsVFX.CraterEffects
			local CircularDebris = require(RS.Modules.Utility.KolsVFX.CircularDebris)

			local Params = RaycastParams.new()
			Params.FilterType = Enum.RaycastFilterType.Blacklist
			Params.FilterDescendantsInstances = {workspace.World.Map, Character, Clone, Sword}

			local Results = workspace:Raycast(Root.Position, -Root.CFrame.UpVector * 10, Params)

			local Dust = Effects.Zabuza:WaitForChild("Dust"):Clone()
			Dust.Position = vRoot.Position
			Dust.Parent = workspace.World.Effects
			EmitAll(Dust)
			Debris:AddItem(Dust, 1)

			camShake:ShakeOnce(15,7,0.2,0.6)
			camShake:Start()

			task.defer(function()
				CircularDebris({
					CF = CFrame.new(vRoot.Position),
					Radius = 10,
					Amount = 15,
					Size = {Min = 1, Max = 2},
					Lifetime = .5
				})
			end)
			vRoot.Massless = false
			Root.Anchored = false
			Clone:Destroy()
			Sword.Transparency = 0 
			WeldConstraint:Destroy()
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
	}
}

return OldZabuza
