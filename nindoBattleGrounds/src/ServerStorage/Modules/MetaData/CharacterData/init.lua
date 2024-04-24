local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local SS2 = game:GetService("ServerScriptService")

local module = {}

for i,x in pairs(script:GetDescendants()) do
	if x:IsA("ModuleScript") and not x:FindFirstChild("DontImp") then
		local Mod = require(x)
		module[x.Name] = Mod
	end
end


return module
