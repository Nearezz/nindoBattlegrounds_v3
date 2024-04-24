--〔 Services 〕--
local PhysicsService = game:GetService("PhysicsService")
local RunService = game:GetService("RunService")

--〔 Variables 〕--
local CollisionService = {
	["Container"] = {},
	["Functions"] = {}
}

CollisionService.Functions.__index = CollisionService.Functions

--〔 Module Functions 〕--
CollisionService["CreateCollisionGroup"] = function(Name, Collidable)
	if RunService:IsServer() then
		if not CollisionService.Container[Name] then
			local Collidable = Collidable or false
			
			PhysicsService:CreateCollisionGroup(Name)
			
			CollisionService.Container[Name] = setmetatable({
				["Name"] = Name,
				["PreviousCollisionGroups"] = {}
			}, CollisionService.Functions)
			
			PhysicsService:CollisionGroupSetCollidable(Name, Name, Collidable)
			
			return CollisionService.Container[Name]
		end
	end
end

CollisionService["RemoveCollisionGroup"] = function(Name)
	if RunService:IsServer() then
		if CollisionService.Container[Name] then
			CollisionService.Container[Name] = nil
			PhysicsService:RemoveCollisionGroup(Name)
		end
	end
end

function CollisionService:GetCollisionGroup(Name)
	if RunService:IsServer() then
		return CollisionService.Container[Name] or CollisionService.CreateCollisionGroup(Name)
	end
end

function CollisionService.Functions:AddPart(Object)
	if RunService:IsServer() then
		if Object:IsA("BasePart") then
			if not PhysicsService:CollisionGroupContainsPart(self.Name, Object) then
				self.PreviousCollisionGroups[Object] = Object.CollisionGroupId
				PhysicsService:SetPartCollisionGroup(Object, self.Name)
			end
		end
	end
end

function CollisionService.Functions:RemovePart(Object)
	if RunService:IsServer() then
		if Object:IsA("BasePart") then
			if PhysicsService:CollisionGroupContainsPart(self.Name, Object) then
				local PreviousCollisionGroupId = self.PreviousCollisionGroups[Object]
				local PreviousCollisionGroupName = PhysicsService:GetCollisionGroupName(PreviousCollisionGroupId)
				
				PhysicsService:SetPartCollisionGroup(Object, PreviousCollisionGroupName)
				self.PreviousCollisionGroups[Object] = nil
			end
		end
	end
end

--〔 Return 〕--
return CollisionService