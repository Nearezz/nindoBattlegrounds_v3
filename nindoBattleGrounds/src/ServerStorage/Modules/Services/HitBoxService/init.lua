local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local SS2 = game:GetService("ServerScriptService")

local Debris = game:GetService("Debris")

local HitBoxService = {}


function HitBoxService:CRepeatCFrame(Data)
	local HitInstance = require(script.BoxInstance).NewHitInstance(Data,"CRepeatCFrame")
	return HitInstance
end

function HitBoxService:BoxCFrame()
	local HitInstance = require(script.OneInstance).new()
	return HitInstance
end

function HitBoxService:AoeProjectile()
	local Instances = require(script.AoeProjectile).new()
	return Instances
end

function HitBoxService:GetPlayersInRange(Data)
	local Table = {}
	
	for Index, Entity in ipairs(workspace.World.Entities:GetChildren()) do
		local RootPart = Entity.PrimaryPart
		
		if not RootPart or not Data.Caster.PrimaryPart then return end
		
		if (RootPart.Position - Data.Caster.PrimaryPart.Position).Magnitude <= Data.Range and Entity ~= Data.Caster then
			if Data.CasterFacing then
				local ObjectToZSpace = Data.Caster.PrimaryPart.CFrame:Inverse() * RootPart.CFrame
				
				if ObjectToZSpace.Z < 0 then
					table.insert(Table, RootPart)
				end
			else
				table.insert(Table, RootPart)
			end
		end
	end
	
	return Table
end

return HitBoxService