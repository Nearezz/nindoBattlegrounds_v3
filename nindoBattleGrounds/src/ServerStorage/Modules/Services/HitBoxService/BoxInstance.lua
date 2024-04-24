local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local SS2 = game:GetService("ServerScriptService")

local Debris = game:GetService("Debris")

local BoxInstance = {}

BoxInstance.__index = BoxInstance

function BoxInstance.NewHitInstance(Data,Type)
	local T = {}
	T.Data = Data
	T.Type = Type
	T.OnHit = require(script.Parent.HitTask).new()
	setmetatable(T,BoxInstance)
	return T
end

function BoxInstance:Start()
	if self.Type == "CRepeatCFrame" then
		self:StartCRepeatCFrame()
	end
end


function BoxInstance:StartCRepeatCFrame()
	local Data = self.Data
	local Frame = Data.CFrame
	local Size = Data.Size
	local Offset = Data.Offset or CFrame.new(0,0,0)
	local FilterList = Data.FilterList or {workspace.World.Entities}
	local FilterType = Data.FilterType or Enum.RaycastFilterType.Include
	local Caster = Data.Caster
	local OffsetPart = Data.OffsetPart

	local Dur = Data.Dur
	local Rate = Data.Rate

	local BreakOnHit = Data.BreakOnHit or false
	local HitOnce = Data.HitOnce or false
	local MultHit = Data.MultHit or false

	local Vis = Data.Visual or false

	task.spawn(function()
		local StartTick = os.clock()
		local AlrProcessed = {}
		local CheckHit = {}
		
		local TriggerBreak = false
		
		local VisPart
		
		if Vis then
			VisPart = Instance.new("Part")
			VisPart.Anchored = true
			VisPart.Material = Enum.Material.ForceField
			VisPart.CanCollide = false
			VisPart.CanQuery = false
			VisPart.CanTouch = false
			VisPart.Parent = workspace.World.Effects
			VisPart.Size = Size
		end
		
		repeat
			local Para = OverlapParams.new()
			Para.FilterType = FilterType
			Para.FilterDescendantsInstances = FilterList
			
			local TargetFrame = Frame
			
			if OffsetPart then
				TargetFrame = OffsetPart.CFrame * Data.Offset
			end
			
			if Vis then
				VisPart.CFrame = TargetFrame
			end
			
			if not TargetFrame then return end
			
			local HitBox = workspace:GetPartBoundsInBox(TargetFrame, Size, Para)
			local HitLar = false
			
			for _, Character in ipairs(HitBox) do
				if not string.find(Character.Name, " - Clone") and not (Character.Parent:FindFirstChild("IsShadowClone") and Character.Parent:FindFirstChild("Brain") and Character.Parent:FindFirstChild("Brain").Caster.Value == Caster ) and not CheckHit[Character.Parent] and Caster ~= Character.Parent and Character.Parent:FindFirstChild("Humanoid") and Character.Parent:FindFirstChild("Humanoid").Health > 0 and Character.Parent.PrimaryPart and HitLar == false then
					if HitOnce == true then
						table.insert(FilterList,Character.Parent)
						CheckHit[Character.Parent] = true
					end
					
					if MultHit == false then
						HitLar = false
					end
					
					if BreakOnHit == true then
						TriggerBreak = true
					end
					
					self.OnHit:Fire(Character.Parent)
				end
			end
			
			if Rate then
				task.wait(Rate)
			else
				RunService.Heartbeat:Wait()
			end
		until os.clock() - StartTick >= Dur or TriggerBreak == true
		
		if VisPart then
			VisPart:Destroy()
			VisPart = nil
		end
		
		self:Destroy()
	end)
end



function BoxInstance:Destroy()
	self.OnHit:Destroy()
	self = nil
end

return BoxInstance
