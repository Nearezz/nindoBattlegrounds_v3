local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local SS2 = game:GetService("ServerScriptService")

local Debris = game:GetService("Debris")


local module = {}

module.__index = module

function module.new()
	local T = {}
	T.HitTask = require(script.Parent.HitTask).new()
	setmetatable(T,module)
	return T
end

function module:Destroy()
	self = nil
end

function module:StartProjectile(Data)
	local RayStuff = require(script.RayStuff)
	
	local BreakOnHit = Data.BreakOnHit
	local Points = Data.Points
	local Dur = Data.Dur
	local Direction = Data.Direction
	local Velocity = Data.Velocity
	local Visual = Data.VisualizeHitBox or false
	local IgnoreList = Data.IgnoreList
	local Iterations = Data.Iterations or 50
	local Acceleration = Data.Acceleration or 0
	local BreakOnMap = Data.BreakOnMap
	
	local Start = os.clock()
	local Hc = {}
	local HitPoint
	
	local BreakBox = false
	
	local LastCast = nil
	local Interception = false
	local CastInterval = Dur / Iterations
	
	local OgPos = Vector3.new(0,1,0) + Points[1].Position Vector3.new(0,-1,0)
	local LastTestPoint
	
	task.spawn(function()
		while os.clock() - Start < Dur and ((BreakOnHit and not Interception) or not BreakOnHit) and BreakBox == false do
			local Dt = LastCast and os.clock() - LastCast or CastInterval
			
			if not LastCast or Dt >= CastInterval then
				if LastCast and Acceleration ~= 0 then
					local timepassed = (os.clock() - LastCast)
					local Velotoadd = Acceleration * timepassed
					Velocity += Velotoadd
				end
				
				local Distance = Velocity * Dt
				LastCast = os.clock()
				
				for Index, Point in pairs(Points) do
					local StartPosition = Point.Position
					local EndPosition = Point.Position + Direction * Distance
					local RayResults = RayStuff:Cast(EndPosition,StartPosition,Enum.RaycastFilterType.Exclude,IgnoreList,true)
					
					if Visual then
						RayStuff:CreateVis(StartPosition, EndPosition)					
					end
					
					if RayResults then
						table.insert(Hc,RayResults)
						Interception = true
						
						if BreakOnHit then
							self.HitTask:Fire({
								Position = RayResults.Position,
								HitInstance = RayResults.Instance,
								Results = RayResults,
								Dt = Dt,
								BreakHit = true,
							})
							
							BreakBox = true
							break
						else
							local IsMap = RayResults.Instance:IsDescendantOf(workspace.World.Map)
							
							if BreakOnMap == true and IsMap == true then 
								self.HitTask:Fire({
									Position = RayResults.Position,
									HitInstance = RayResults.Instance,
									Results = RayResults,
									Dt = Dt,
									BreakHit = true,
								})
								
								BreakBox = true
								break
							else
								self.HitTask:Fire({
									Position = RayResults.Position,
									HitInstance = RayResults.Instance,
									Results = RayResults,
									Dt = Dt,
								})
							end
						end
					end
					
					Points[Index] = CFrame.new(EndPosition)
					LastTestPoint = EndPosition
				end
			end
			RunService.Stepped:Wait()
		end
		
		if LastTestPoint then

		end
	end)
end

function module:GetRayCastSquarePoints(CF: CFrame,x,y,acc)
	if acc == nil then
		acc = 2
	end
	
	local hSizex, hSizey = 2,2
	local splitx, splity = acc + math.floor(x/hSizex), acc + math.floor(y/hSizey)
	
	local PerPointX = x / splitx
	local PerPointY = y / splity
	local startpoint = CF * CFrame.new(-x/2 -PerPointX/2 ,-y/2 -PerPointY/2,0)
	local points = {CF}
	
	for x = 1, splitx do
		for y = 1, splity do
			points[#points + 1] = startpoint * CFrame.new(PerPointX*x, PerPointY*y,0)
		end
	end
	
	return points
end

return module