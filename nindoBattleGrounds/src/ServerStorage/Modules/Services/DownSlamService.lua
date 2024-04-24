local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local SS2 = game:GetService("ServerScriptService")
local Debris = game:GetService("Debris")

local DownSlamService = {}

DownSlamService.__index = DownSlamService

function DownSlamService.new(Settings)
	local T = {}
	T.Settings = Settings
	if Settings.Connect then
		T.HitTask = require(SS.Modules.Services.HitBoxService.HitTask).new()
	end
	setmetatable(T,DownSlamService)
	return T
end

function DownSlamService:Start()
	local Settings = self.Settings
	local Vector = Settings.Vector
	local StartPos = Settings.StartCFrame
	local Speed = Settings.Speed
	local MaxDist = Settings.MaxDist
	local MaxTime = Settings.MaxTime
	local Character = Settings.Character
	
	local SoundService = require(RS.Modules.Services.SoundService)
	local StateService = require(RS.Modules.Services.StateService)
	
	local StateProfile = StateService:GetProfile(Character)
	if not StateProfile then return end
	
	local HumRP = Character.PrimaryPart
	local X,Y,Z = HumRP.CFrame:ToEulerAnglesXYZ()
	
	
	local function RayCheck(Ori)
		local Para = RaycastParams.new()
		Para.FilterType = Enum.RaycastFilterType.Whitelist
		Para.FilterDescendantsInstances = {workspace.World.Map}
		local EndPoint = StartPos.Position + (Vector * 1000)
		local RayCast = workspace:Raycast(Ori,EndPoint - Ori,Para)
		if RayCast then
			return RayCast.Position + Vector3.new(0,3,0)
		else 
			return nil
		end
	end
	

	local function RayCheck3(Ori)
		local Para = RaycastParams.new()
		Para.FilterType = Enum.RaycastFilterType.Whitelist
		Para.FilterDescendantsInstances = {workspace.World.Map}
		local RayCast = workspace:Raycast(Ori,Vector3.new(0,-10000,0),Para)
		if RayCast then
			return RayCast.Position + Vector3.new(0,0.25,0)
		else 
			return Ori
		end
	end
	
	local function RayCheck2(Ori)
		local Para = RaycastParams.new()
		Para.FilterType = Enum.RaycastFilterType.Whitelist
		Para.FilterDescendantsInstances = {workspace.World.Map}
		local EndPoint = StartPos.Position + (Vector * 1000)
		local RayCast = workspace:Raycast(Ori,EndPoint - Ori,Para)
		if RayCast then
			return (RayCast.Position - Ori).Magnitude
		else 
			return 10000000
		end
	end
	
	local EndPoint = RayCheck(StartPos.Position)
	
	if not EndPoint then
		EndPoint = StartPos.Position + (Vector * MaxDist) + Vector3.new(0,3,0)
	end
	
	local RemoteComs = require(RS.Modules.Utility.RemoteNetwork)
	
	local Time = (StartPos.Position - EndPoint).Magnitude/Speed
	HumRP.Anchored = true
	task.spawn(function()
		local Tween = TweenService:Create(HumRP,TweenInfo.new(Time,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{
			["CFrame"] = CFrame.new(EndPoint) * CFrame.Angles(X,Y,Z)
		})
		local Playing = true
		Tween.Completed:Connect(function()
			Playing = false
			Tween:Destroy()
		end)
		local StartTime = os.clock()
		task.spawn(function()
			local AnimPlaying = false
			repeat
				StateService:SetState(Character,"Stunned",{
					LP = 65,
					Dur = 1
				})
				HumRP.Anchored = true
				RunService.Heartbeat:Wait()
			until Playing == false or os.clock() - StartTime >= MaxDist or RayCheck2(HumRP.CFrame.Position) <= 3
			if Playing == true then
				Tween:Pause()
				Tween:Destroy()
			end
			local CraterPos = RayCheck3(CFrame.new(HumRP.Position + Vector3.new(0,1,0)).Position)
			local FinalPos = CFrame.new(HumRP.Position + Vector3.new(0,0.5,0)) * CFrame.Angles(X,Y,Z)
			HumRP.AssemblyLinearVelocity = Vector3.new(0,0,0)
			HumRP.Anchored = true
			HumRP.Anchored = false
			HumRP.AssemblyLinearVelocity = Vector3.new(0,0,0)
			HumRP.Anchored = true
			HumRP.AssemblyLinearVelocity = Vector3.new(0,0,0)
			HumRP.CFrame = FinalPos
			HumRP.Anchored = false
			Character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
			HumRP.CFrame = FinalPos
			HumRP.AssemblyLinearVelocity = Vector3.new(0,0,0)
			SoundService:PlaySound("KnockbackCrash",{
				Parent = Character.PrimaryPart,
				Volume = 1,
			},{},{
				Range = 100,
				Origin = Character.PrimaryPart.CFrame.p
			})
			StateService:SetState(Character,"Stunned",{
				LP = 66,
				Dur = Settings.EndStun
			})
			RemoteComs:FireAllClientsEvent({FunctionName = "VFX"},{FName = "DownSlamCrater",FData = {
				Origin = CraterPos
			}})
			if not Settings.Anim then
				if Players:GetPlayerFromCharacter(Character) then
					RemoteComs:FireClientEvent(Players:GetPlayerFromCharacter(Character),{FunctionName = "AnimationService" },{
						Task = "StopAllAnimation",
						AnimationData = {

						}
					})
					RemoteComs:FireClientEvent(Players:GetPlayerFromCharacter(Character),{FunctionName = "AnimationService" },{
						Task = "PlayAnimation",
						AnimationData = {
							Name = RS.Assets.Animations.Shared.Combat.Stun5.Name,
							AnimationSpeed = 1,
							Weight = 100,
							FadeTime = 0.25,
							Looped = false,
						}
					})
				else
					for i,v in pairs(Character.Humanoid.Animator:GetPlayingAnimationTracks()) do
						v:Stop()
					end
					Character.Humanoid.Animator:LoadAnimation(RS.Assets.Animations.Shared.Combat.Stun5):Play()
				end
			end
			if Settings.Connect then
				self.HitTask:Fire()
			end
			self:Destroy()
		end)
		Tween:Play()
	end)
	
end

function DownSlamService:Destroy()
	if self.HitTask then
		self.HitTask:Destroy()
	end
	self = nil
end

return DownSlamService