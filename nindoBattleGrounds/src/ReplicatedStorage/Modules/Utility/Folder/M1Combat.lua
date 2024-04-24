local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local RS = game:GetService("ReplicatedStorage")
local PhysicsService = game:GetService("PhysicsService")
local DamageInaMod = require(RS.Modules.Effects.damage_indicator)
local RunService = game:GetService("RunService")
--local CurrentCamera = workspace.CurrentCamera
--local CameraShaker = require(RS.Modules.Effects.CameraShaker)
--local CameraShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
--	CurrentCamera.CFrame = CurrentCamera.CFrame * shakeCFrame
--end)	


local module = {
	["CameraShake"] = function(Data)
		--local Type = Data.Type
		--local Time = Data.Time

		--if not Type then

		--	CameraShake:Start()
		--	CameraShake:ShakeOnce(Data.V1, Data.V2,Data.V3,Data.V4)
		--elseif Type == "Loop" then
		--	for Number = 1,Data.Amount do
		--		CameraShake:Start()
		--		CameraShake:ShakeOnce(Data.V1, Data.V2,Data.V3,Data.V4)
		--		wait(Time)
		--	end
		--end	
	end,
	["Blur"] = function(Data)
		local Blur = Instance.new("BlurEffect")
		Blur.Size = 0
		Blur.Parent = game.Lighting

		local Info = TweenInfo.new(Data.Length,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,true,0) 

		local Tween = TweenService:Create(Blur,Info,{Size = Data.Size})
		Tween:Play()
		Tween:Destroy()

		Debris:AddItem(Blur,Data.Length * 2)
	end,
	["DownSlamCrater"] = function(Data)
		if shared.ClientHandler.VfxMode == "smexy" then
			local Rings = Data[1][1]
			local RocksPerRing = Data[1][2]
			local IncreaseRate = Data[1][6]
			local SizeRate = Data[1][7]
			local Origin = Data[1][3]
			local Size = Data[1][4]
			local HoleSize = Data[1][5]

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

			local function tweenModel(model, CF,info)
				local CFrameValue = Instance.new("CFrameValue")
				CFrameValue.Value = model:GetPrimaryPartCFrame()

				CFrameValue:GetPropertyChangedSignal("Value"):Connect(function()
					model:SetPrimaryPartCFrame(CFrameValue.Value)
				end)

				local tween = TweenService:Create(CFrameValue, info, {Value = CF})
				tween:Play()

				tween.Completed:Connect(function()
					CFrameValue:Destroy()
				end)
			end

			local Crater = Instance.new("Model",workspace.World.Effects)
			
			task.spawn(function()
				for h = 1,Rings,1 do
					local Counter = RocksPerRing * (IncreaseRate * h)
					if h == 1 then
						Counter = RocksPerRing
					end
					Counter = math.round(Counter)
					for i = 1,Counter,1 do
						local Rock = script.CraterCustom["RockModel"..math.random(1,6)]:Clone()

						local YOffset = 0

						if Rock.Name == "RockModel1" then
							YOffset = 2.689
						elseif Rock.Name == "RockModel2" then
							YOffset = 2.431
						elseif Rock.Name == "RockModel3" then
							YOffset = 3.631
						elseif Rock.Name == "RockModel4" then
							YOffset = 3.731
						elseif Rock.Name == "RockModel5" then
							YOffset = 3.131
						elseif Rock.Name == "RockModel6" then
							YOffset = 3.131
						end

						local ZSize = Size + (SizeRate * h)
						if h == 1 then
							ZSize = Size
						end
						local Pos = CFrame.new(Origin + Vector3.new(0,-YOffset,0)) * CFrame.Angles(math.rad(0),math.rad((360/Counter) * i),math.rad(0)) * CFrame.new(0,0,ZSize)
						local Rotation = CFrame.Angles(math.rad(math.random(15,30)),math.rad((360/Counter) * i),math.rad(0))

						local Mats = RayCheck(Pos.Position)

						Rock.Land.Material = Mats[1]
						Rock.Land.Color = Mats[2]


						local FCrame = Pos * Rotation

						local X,Y,Z = FCrame:ToEulerAnglesXYZ()



						Rock:SetPrimaryPartCFrame(Pos * Rotation)

						local BeforeCFrame = CFrame.new(FCrame.Position + Vector3.new(0,-10,0)) * CFrame.Angles(X,Y,Z)
						local AfterCFrame = CFrame.new(FCrame.Position + Vector3.new(0,2.5,0)) * CFrame.Angles(X,Y,Z)

						Rock:SetPrimaryPartCFrame(BeforeCFrame)
						tweenModel(Rock,AfterCFrame,TweenInfo.new(.001,Enum.EasingStyle.Linear,Enum.EasingDirection.Out))

						delay(10,function()
							tweenModel(Rock,BeforeCFrame,TweenInfo.new(.35,Enum.EasingStyle.Linear,Enum.EasingDirection.Out))
						end)


						Rock.Parent = Crater


					end
				end
			end)
			
			task.spawn(function()
				if Data[2] then
					local DBSize = Data[2][1]
					local DBAmount = Data[2][2]
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
			
			local crash_smoke = RS.Assets.Effects.Misc.Smoke:Clone()
			crash_smoke.Position = Origin + Vector3.new( 0, crash_smoke.Size.Y / 2.5, 0 )
			crash_smoke.Parent = workspace.World.Effects
			Debris:AddItem(crash_smoke, 20)

			local Mats = RayCheck(Origin)

			for _, v in pairs(crash_smoke.Attachment:GetChildren()) do
				v.Color = ColorSequence.new( Mats[2] )
				v:Emit(v:GetAttribute('EmitCount'))
			end


			delay(13,function()
				Crater:Destroy()
			end)


			
		elseif shared.ClientHandler.VfxMode == "Normal" then
			local Rings = Data[1][1]
			local RocksNumber = Data[1][2]
			local IncreaseRate = Data[1][6]
			local SizeRate = Data[1][7]
			local Origin = Data[1][3]
			local Size = Data[1][4]
			local HoleSize = Data[1][5]
			local PartSize = Data[1][8]
			
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
					local Rotation = CFrame.Angles(math.rad(math.random(-360,360)),math.rad(math.random(-360,360)),math.rad(math.random(-360,360)))
					
					
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
					local DBSize = Data[2][1]
					local DBAmount = Data[2][2]
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
			
			delay(15,function()
				Crater:Destroy()
			end)
			
		elseif shared.ClientHandler.VfxMode == "Potato" then
			local Rings = Data[1][1]
			local RocksNumber = Data[1][2]
			local IncreaseRate = Data[1][6]
			local SizeRate = Data[1][7]
			local Origin = Data[1][3]
			local Size = Data[1][4]
			local HoleSize = Data[1][5]
			local PartSize = Data[1][8]



			if not PartSize then
				PartSize = Vector3.new(4.207, 2.04, 2.199)
			end

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

			--RocksNumber = math.round(RocksNumber/1.5)
			Size = math.round(Size * 1.295)

			task.spawn(function()
				for i = 1,RocksNumber,1 do
					local rock = script.CraterPart:Clone()
					rock.Size = PartSize
					local Pos = CFrame.new(Origin + Vector3.new(0,PartSize.Y - (PartSize.Y/2),0)) * CFrame.Angles(math.rad(0),math.rad((360/RocksNumber) * i),math.rad(0)) * CFrame.new(0,0,Size)

					local Rotation = CFrame.Angles(math.rad(-35),math.rad(0),math.rad(0))

					local X,Y,Z = Pos:ToEulerAnglesXYZ()

					local BeforeCFrame = (CFrame.new(Pos.Position - Vector3.new(0,20,0)) * CFrame.Angles(X,Y,Z)) * Rotation
					local AfterCFrame = (CFrame.new(Pos.Position - Vector3.new(0,1.5,0)) * CFrame.Angles(X,Y,Z)) * Rotation

					local Mats = RayCheck(AfterCFrame.Position + Vector3.new(0,5,0))



					rock.Material = Mats[1]
					rock.Color = Mats[2]
					rock.CFrame = BeforeCFrame
					local Tween = TweenService:Create(rock,TweenInfo.new(.001,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{["CFrame"] = AfterCFrame})
					rock.Parent = Crater
					Tween:Play()
					Tween:Destroy()
					delay(10,function()
						local Tween2 = TweenService:Create(rock,TweenInfo.new(.35,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{["CFrame"] = BeforeCFrame})
						Tween2:Play()
						Tween2:Destroy()
					end)
				end
			end)

			task.spawn(function()
				if Data[2] then
					local DBSize = Data[2][1]
					local DBAmount = Data[2][2]
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

			local crash_smoke = RS.Assets.Effects.Misc.Smoke:Clone()
			crash_smoke.Position = Origin + Vector3.new( 0, crash_smoke.Size.Y / 2.5, 0 )
			crash_smoke.Parent = workspace.World.Effects
			Debris:AddItem(crash_smoke, 20)

			local Mats = RayCheck(Origin)

			for _, v in pairs(crash_smoke.Attachment:GetChildren()) do
				v.Color = ColorSequence.new( Mats[2] )
				v:Emit(v:GetAttribute('EmitCount'))
			end

			delay(15,function()
				--	Crater:Destroy()
			end)
		end
	end,
	["M1HitEffect"] = function(Data)
		local EffectAttach = RS.Assets.Effects.Combat.Hit.Punchedf:Clone()
		EffectAttach.Parent = Data[1]
		for i,x in ipairs(EffectAttach:GetChildren()) do
			x:Emit(x:GetAttribute("EmitCount"))
		end
		Debris:AddItem(EffectAttach,2)
	end,	
	["M1HitEffect5"] = function(Data)
		local EffectAttach = RS.Assets.Effects.Combat.Hit.Punchedf:Clone()
		EffectAttach.Parent = Data[1]
		for i,x in ipairs(EffectAttach:GetChildren()) do
			x:Emit(x:GetAttribute("EmitCount"))
		end
		Debris:AddItem(EffectAttach,2)
		
		local dust_effect = script.DirtStep.Attachment:Clone()
		dust_effect.Parent = Data[1]

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
	["GuardBreak"] = function(Data)
		local EffectAttach = RS.Assets.Effects.Combat["Block Break"].Attachment:Clone()
		EffectAttach.Parent = Data[1]
		EffectAttach.Position = Vector3.new(0,-2.796,0)
		for i,x in ipairs(EffectAttach:GetChildren()) do
			x:Emit(x:GetAttribute("EmitCount")*2)
		end
		Debris:AddItem(EffectAttach,2)
	end,
	["DamageIna"] = function(Data)
		DamageInaMod(Data[2],Data[1])
	end,
	["M1BlockEffect"] = function(Data)
		local EffectAttach = RS.Assets.Effects.Combat.MeleeBlockhit.Attachment:Clone()
		EffectAttach.Parent = Data[1]
		for i,x in pairs(EffectAttach:GetChildren()) do
			x:Emit(x:GetAttribute("EmitCount")*2)
		end
		Debris:AddItem(EffectAttach,2)
	end,
	["Subeffects"] = function(Data)
		local Log = RS.Assets.Effects.Misc.Log:Clone()
		Log.CFrame = Data[1] * CFrame.new(0, 10, 0) * CFrame.Angles( math.rad(math.random(-180,180)), math.rad(math.random(-180,180)), math.rad(math.random(-180,180)) )
		Log.Parent = workspace.World.Effects
		PhysicsService:SetPartCollisionGroup(Log, "FlyingRocks")
		PhysicsService:SetPartCollisionGroup(Log.Part, "FlyingRocks")
		Debris:AddItem(Log, 4)

		local smoke = script.Sub:Clone()
		smoke.CFrame = Data[1]
		smoke.Parent = workspace.World.Effects
		smoke.ParticleEmitter:Emit(smoke.ParticleEmitter:GetAttribute('EmitCount'))
		Debris:AddItem(smoke, 1)

	end,

}

return module
