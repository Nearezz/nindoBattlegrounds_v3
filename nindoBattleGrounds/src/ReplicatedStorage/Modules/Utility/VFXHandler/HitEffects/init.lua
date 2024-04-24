local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local SS2 = game:GetService("ServerScriptService")

local Player = Players.LocalPlayer
local ClientManager = require(Player.PlayerScripts:WaitForChild("Client"):WaitForChild("ClientHandler"))

local Debris = game:GetService("Debris")

local module; module = {
	["GuardBreak"] = function(Data)
		local Character = Data.Character
		local EffectAttach = RS.Assets.Effects.Combat["Block Break"].Attachment:Clone()
		EffectAttach.Parent = Character.PrimaryPart
		for i,x in pairs(EffectAttach:GetChildren()) do
			x:Emit(x:GetAttribute("EmitCount"))
		end
		Debris:AddItem(EffectAttach,2)
	end,
	["DB"] = function(Data)
		local Character = Data.Character
		local Humrp = Character:WaitForChild('HumanoidRootPart')
		local DashAssets = RS.Assets.Effects.Combat.Dash
		
		local Lifetime = Data.Lifetime
		
		local info = {
			['BottomLeft'] = {'BottomLeft1', 'BottomLeft2'},
			['BottomRight'] = {'BottomRight1', 'BottomRight2'},
			['TopLeft'] = {'TopLeft1', 'TopLeft2'},
			['TopRight'] = {'TopRight1', 'TopRight2'},
		}

		Lifetime = Players.LocalPlayer.Name == Character.Name and Lifetime or Lifetime + .3

		local trails = {}
		local attachments = {}

		for _, Value in ipairs(DashAssets:GetDescendants()) do
			if Value:IsA('Trail') then
				local trail = Value:Clone()
				trail.Parent = Character

				Debris:AddItem(trail, Lifetime + 1)

				table.insert( trails, trail )

				task.delay(Lifetime,function()
					trail.Enabled = false
				end)
			elseif Value:IsA('Attachment') then
				local Attachment = Value:Clone()
				Attachment.Parent = Humrp

				attachments[Attachment.Name] = Attachment

				Debris:AddItem(Attachment, Lifetime + 1)
			end
		end

		for _, trail in ipairs(trails) do
			trail.Attachment0 = attachments[info[trail.Name][1]]
			trail.Attachment1 = attachments[info[trail.Name][2]]
		end
	end,
	["RegM1Hit"] = function(Data)
		local Character = Data.Character
		local Victim = Data.Victim
		
		local EffectAttach = RS.Assets.Effects.Combat.Hit.Punchedf:Clone()
		EffectAttach.Parent = Victim.PrimaryPart
		for i,x in pairs(EffectAttach:GetChildren()) do
			x:Emit(x:GetAttribute("EmitCount"))
		end
		Debris:AddItem(EffectAttach,2)
		
	end,
	["RegM1HitSB"] = function(Data)
		--ClientManager.CamShaker:ShakeOnce(4,3,0.3,0.3)
		local Blur = Instance.new("BlurEffect")
		Blur.Size = 0
		Blur.Parent = game.Lighting

		local Info = TweenInfo.new(0.15,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,true,0) 

		local Tween = TweenService:Create(Blur,Info,{Size = 3})
		Tween:Play()
		Tween:Destroy()

		Debris:AddItem(Blur,0.15 * 2)

	end,
	["RegM5HitSB"] = function(Data)
		--ClientManager.CamShaker:ShakeOnce(12,8,0.15,0.35)
		local Blur = Instance.new("BlurEffect")
		Blur.Size = 0
		Blur.Parent = game.Lighting

		local Info = TweenInfo.new(0.2,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,true,0) 

		local Tween = TweenService:Create(Blur,Info,{Size = 8})
		Tween:Play()
		Tween:Destroy()

		Debris:AddItem(Blur,0.2 * 2)

	end,
	["DamageIna"] = function(Data)
		local Victim = Data.Victim
		local Damage = Data.Damage
		
		require(script.damage_indicator)(Victim,tostring(Damage))
		
	end,
	["M5ScreenShake"] = function(Data)
		ClientManager.CamShaker:ShakeOnce(12,8,0.15,0.35)
	end,
	["RegBlockEffect"] = function(Data)
		local EffectAttach = RS.Assets.Effects.Combat.MeleeBlockhit.Attachment:Clone()
		EffectAttach.Parent = Data.Victim.PrimaryPart
		for i,x in pairs(EffectAttach:GetChildren()) do
			x:Emit(x:GetAttribute("EmitCount"))
		end
		Debris:AddItem(EffectAttach,2)
	end,
	["RegM4Hit"] = function(Data)
		local character = Data.Character
		local Victim = Data.Victim

		local EffectAttach = RS.Assets.Effects.Combat.Hit.Punchedf:Clone()
		EffectAttach.Parent = Victim.PrimaryPart
		for i,x in pairs(EffectAttach:GetChildren()) do
			x:Emit(x:GetAttribute("EmitCount"))
		end
		Debris:AddItem(EffectAttach,2)
		
		local function Lines(Character)
			local lines = script.Lines:Clone()
			lines.CFrame = Character.PrimaryPart.CFrame
			lines.Parent = Character

			local weld = Instance.new("Weld",Character.PrimaryPart)
			weld.Part0 = Character.PrimaryPart
			weld.Part1 = lines

			local Children = lines:GetChildren()

			for i = 1, #Children do
				Children[i].Enabled = true
			end
			Debris:AddItem(lines,0.35)
			Debris:AddItem(weld,0.35)
		end
		
		Lines(character)
		Lines(Victim)
	end,
	["DownSlamCrater"] = function(Data)
		local Rings = 2
		local RocksNumber = 20
		local IncreaseRate = 1.25
		local SizeRate = 1.35
		local Origin = Data.Origin
		local Size = 5
		local HoleSize = 3

		local function RayCheck(Ori)
			local Para = RaycastParams.new()
			Para.FilterType = Enum.RaycastFilterType.Whitelist
			Para.FilterDescendantsInstances = {workspace.World.Map}
			local RayCas = workspace:Raycast(Ori + Vector3.new(0,5,0),Vector3.new(0,-100,0),Para)
			if RayCas then
				return {RayCas.Material,RayCas.Instance.Color}
			else
				return {Enum.Material.Grass,Color3.new(0.294118, 0.592157, 0.294118)}
			end
		end

		local Crater = Instance.new("Model",workspace.World.Effects)


		task.spawn(function()
			for i = 1,15,1 do
				local Rock = Instance.new("Part")
				local Attach = Instance.new("Attachment",Rock)
				PhysicsService:SetPartCollisionGroup(Rock,"FlyingRocks")
				Rock.Anchored = true
				Rock.CanCollide = false
				Rock.CanQuery = false
				Rock.CanTouch = true

				local RockPos = CFrame.new(Origin + Vector3.new(0,0.25,0)) * CFrame.Angles(math.rad(0),math.rad((360/15) * i),math.rad(0)) * CFrame.new(0,0,8)
				local Rotation = CFrame.Angles(math.rad(math.random(-90,90)),math.rad(math.random(-90,90)),math.rad(math.random(-90,90)))


				local Mats = RayCheck(RockPos.Position)
				Rock.Color = Mats[2]
				Rock.Material = Mats[1]
				local Factor = math.random(2,2.2)
				Rock.Size = Vector3.new(Factor,Factor,Factor)

				Rock.CFrame = CFrame.new(RockPos.Position - Vector3.new(0,0.5,0)) * Rotation
				Rock.Parent = Crater


			end
		end)

		task.spawn(function()
			if Data[2] then
				local DBSize = 2.3
				local DBAmount = 10
				local Mats = RayCheck(Origin)

				for i = 1,DBAmount,1 do
					local Rock = Instance.new("Part")
					local Attach = Instance.new("Attachment",Rock)
					PhysicsService:SetPartCollisionGroup(Rock,"FlyingRocks")
					Rock.CanQuery = false
					Rock.Color = Mats[2]
					Rock.Material = Mats[1]
					Rock.CanTouch = true

					Rock.CFrame = CFrame.new(Origin + Vector3.new(0,2,0))

					Rock.Size = Vector3.new(math.random(1,DBSize),math.random(1,DBSize),math.random(1,DBSize))


					local BV = Instance.new("BodyVelocity")
					BV.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
					BV.P = 20e4
					BV.Velocity = Vector3.new(math.random(-23,23),math.random(1,23),math.random(-23,23))

					local BA = Instance.new("AngularVelocity")
					BA.Enabled = false
					BA.Attachment0 = Attach
					BA.RelativeTo = Enum.ActuatorRelativeTo.World
					BA.MaxTorque = 20e6
					BA.AngularVelocity = Vector3.new(math.random(-20e4,20e4),math.random(-20e4,20e4),math.random(-20e4,20e4))
					BA.Enabled = true


					Rock.Parent = workspace.World.Effects
					BV.Parent = Rock
					Debris:AddItem(BV,.1)
					Debris:AddItem(BA,4)
					Debris:AddItem(Rock,5)
				end
			end
		end)

		local crash_smoke = RS.Assets.Effects.Misc.DownslamSmoke:Clone()
		crash_smoke.Position = Origin + Vector3.new( 0, crash_smoke.Size.Y / 2.5, 0 )
		crash_smoke.Parent = workspace.World.Effects
		Debris:AddItem(crash_smoke, 20)

		local Mats = RayCheck(Origin)

		for _, v in pairs(crash_smoke.Attachment:GetChildren()) do
			v.Color = ColorSequence.new( Mats[2] )
			v:Emit(v:GetAttribute('EmitCount'))
		end

		task.delay(4,function()
			for i,v in pairs(Crater:GetChildren()) do
				TweenService:Create(v,TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{CFrame = CFrame.new(v.Position + Vector3.new(0,-1.1,0))}):Play()
			end
		end)

		task.delay(5,function()
			Crater:Destroy()
		end)


		local Particles = script.Particles:Clone()
		Particles.Parent = workspace.World.Effects
		Particles.Position = Origin
		Particles.Orientation = Vector3.new(0,0,0)
		Particles.Attachment.Orientation = Vector3.new(0,0,0)
		for i,v in pairs(Particles:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				local EmitDelay = v:GetAttribute("EmitDelay")
				if EmitDelay and EmitDelay ~= 0 then
					task.delay(EmitDelay,function()
						v:Emit(v:GetAttribute("EmitCount"))
					end)
				else
					v:Emit(v:GetAttribute("EmitCount"))
				end
			end
		end
		--if (workspace.CurrentCamera.CFrame.Position - Origin).Magnitude < 50 then
		--	shared.CameraShake:StartShake(5,10)
		--	task.delay(0.25,function()
		--		shared.CameraShake:StopSustained()
		--	end)
		--end
		task.delay(2.55,function()
			Particles:Destroy()
		end)
	end,
	["RegM5Hit"] = function(Data)
		local Character = Data.Character
		local Victim = Data.Victim

		local EffectAttach = RS.Assets.Effects.Combat.Hit.Punchedf:Clone()
		EffectAttach.Parent = Victim.PrimaryPart
		for i,x in pairs(EffectAttach:GetChildren()) do
			x:Emit(x:GetAttribute("EmitCount"))
		end
		Debris:AddItem(EffectAttach,2)
		

		local dust_effect = script.DirtStep.Attachment:Clone()
		dust_effect.Parent = Victim.PrimaryPart
		

		local lifetime = .4

		Debris:AddItem(dust_effect, lifetime + 1)

		local start_time = os.clock()

		local last_hit_material = nil

		local emit_connection; emit_connection = RunService.Stepped:Connect(function()
			if os.clock() - start_time >= lifetime or dust_effect.Parent == nil then emit_connection:Disconnect() return end


			local new_ray = Ray.new(dust_effect.WorldPosition, Vector3.new(0,-3,0))
			local hit, pos, normal = workspace:FindPartOnRayWithIgnoreList(new_ray, {workspace.World.Effects,workspace.World.Entities})

			if hit and last_hit_material == hit.Material or hit and last_hit_material == nil then
				last_hit_material = hit.Material
				dust_effect.ParticleEmitter.Color = ColorSequence.new(hit.Color)
				dust_effect.ParticleEmitter:Emit(1)
			elseif hit and hit.Material ~= last_hit_material then
				last_hit_material = hit.Material

				dust_effect.ParticleEmitter.LockedToPart = false

				local new = dust_effect:Clone()
				new.Parent = Data[1]
				new.ParticleEmitter.Color = ColorSequence.new(hit.Color)
				dust_effect = new

				Debris:AddItem(dust_effect, (os.clock() - start_time) + 1)
			end
		end)
		
	end,
	["Sub"] = function(Data)
		if not Data.Log then
			local Log = RS.Assets.Effects.Misc.Log:Clone()
			Log.CFrame = Data.Pos * CFrame.new(0, 10, 0) * CFrame.Angles( math.rad(math.random(-180,180)), math.rad(math.random(-180,180)), math.rad(math.random(-180,180)) )
			Log.Parent = workspace.World.Effects
			PhysicsService:SetPartCollisionGroup(Log, "Clone")
			PhysicsService:SetPartCollisionGroup(Log.Part, "Clone")
			Debris:AddItem(Log, 4)
		end

		local smoke = script.Sub:Clone()
		smoke.CFrame = Data.Pos
		smoke.Parent = workspace.World.Effects
		smoke.ParticleEmitter:Emit(smoke.ParticleEmitter:GetAttribute('EmitCount'))
		Debris:AddItem(smoke, 1)
	end,
	["WaterSub"] = function(Data)
		if not Data.Log then
			local Log = RS.Assets.Effects.Misc.Log:Clone()
			Log.CFrame = Data.Pos * CFrame.new(0, 10, 0) * CFrame.Angles( math.rad(math.random(-180,180)), math.rad(math.random(-180,180)), math.rad(math.random(-180,180)) )
			Log.Parent = workspace.World.Effects
			PhysicsService:SetPartCollisionGroup(Log, "FlyingRocks")
			PhysicsService:SetPartCollisionGroup(Log.Part, "FlyingRocks")
			Debris:AddItem(Log, 4)
		end

		local smoke = script.WaterSub:Clone()
		smoke.CFrame = Data.Pos
		smoke.Parent = workspace.World.Effects
		for i,v: ParticleEmitter in smoke:GetDescendants() do
			if v:IsA("ParticleEmitter") then
				v:Emit(v:GetAttribute("EmitCount"))
			end
		end
		Debris:AddItem(smoke, 3)
	end,
}

return module


