local StateService = require(game.ReplicatedStorage.Modules.Services.StateService)
local NPC = script.Parent

local RunService = game:GetService("RunService")
local RunService = game:GetService("RunService")
local Players =  game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")

local Caster = script.Caster.Value

local function CloneDispear()
	local RemoteComs = require(RS.Modules.Utility.RemoteNetwork)

	NPC.Parent = workspace.World.Effects
	StateService:ClearProfile(NPC)
	delay(0.5,function()
		RemoteComs:FireAllClientsEvent({FunctionName = "VFX"},{FName = "WaterSub",FData = {
			Pos = CFrame.new(NPC.PrimaryPart.CFrame.Position),
			Log = true,
		}})
		NPC:Destroy()
	end)
end

local function GetMoveToPoint(Pos1, Pos2, Range)
	local Difference = Pos1 - Pos2
	local Direction = Difference.Unit;
	return Pos2 + Direction * Range
end


local HitBoxSize = Vector3.new(5,5,5)
local AttackDamage = script.Damage.Value or 5
local Length = script.Length.Value or 10

StateService:GenerateProfile(NPC)
StateService:GetProfile(script.Parent).SelectedChar = "KidNaruto"
script.Parent.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
script.Parent.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

local InAttackRange = false
local Target = script.Target.Value


local RunAnimation = NPC.Humanoid:LoadAnimation(RS.Assets.Animations.Shared.Combat.DfRun)
local CombatService = require(game.ServerStorage.Modules.Services.CombatService)

NPC.Humanoid.MaxHealth = 200
NPC.Humanoid.Health = 200

local OgHealth = 200

NPC.Humanoid.HealthChanged:Connect(function()
	if NPC.Humanoid.Health <= 197 then
		CloneDispear()
	end
end)

local BodyGyro = Instance.new("BodyGyro")
BodyGyro.Parent = NPC.PrimaryPart

local IsShadowClone = Instance.new("BoolValue")
IsShadowClone.Name = "IsShadowClone"
IsShadowClone.Parent = NPC

local Start = os.clock()

while true do
	if NPC:FindFirstChildOfClass("ForceField") then
		NPC:FindFirstChildOfClass("ForceField"):Destroy()
	end
	if os.clock()	- Start >= Length then
		CloneDispear()
		break
	end
	if Target then
		local Difference = (Target.PrimaryPart.CFrame.p - NPC.PrimaryPart.CFrame.p).Magnitude
		if Difference <= 6.5 then
			InAttackRange = true 
		else 
			InAttackRange = false
		end	
		if InAttackRange == false then
			if not RunAnimation.IsPlaying then
				RunAnimation:Play(0.25)
			end
			NPC.Humanoid:MoveTo(GetMoveToPoint(NPC.PrimaryPart.Position, Target.PrimaryPart.Position, 4), Target.PrimaryPart)
			BodyGyro.CFrame = CFrame.new(NPC.PrimaryPart.Position, Target.PrimaryPart.Position)
			BodyGyro.MaxTorque = Vector3.new(0,1,1) * 50000
		elseif InAttackRange == true then
			BodyGyro.CFrame = CFrame.new(NPC.PrimaryPart.Position, Target.PrimaryPart.Position)
			BodyGyro.MaxTorque = Vector3.new(0,1,1) * 50000
			if RunAnimation.IsPlaying then
				RunAnimation:Stop(0.25)
			end
			CombatService:Swing(NPC,{
				Space = false,
				Return = true,
			})
			if StateService:GetProfile(script.Parent).StateData["ShadowClone"].Value == true then
				if Caster and Players:GetPlayerFromCharacter(Caster) then
					local PointsService = require(SS.Modules.Services.PointsService)
					local Player = Players:GetPlayerFromCharacter(Caster)
					PointsService:AddPoints(Player,3)
					PointsService:AddToCombo(Player,1)
				end
				CloneDispear()
				break
			end
		end
	else
		CloneDispear()
		break
	end
	task.wait(0.1)
end
