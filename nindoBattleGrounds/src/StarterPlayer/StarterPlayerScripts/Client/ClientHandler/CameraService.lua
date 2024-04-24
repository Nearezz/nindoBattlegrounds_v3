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

local Camera = workspace.CurrentCamera

local CameraService = {}

CameraService.__index = CameraService

function CameraService.new()
	local T = {}
	T.CameraFlag = false
	T.RunningID = "None"
	T.CameraRunning = false
	setmetatable(T,CameraService)
	return T
end

function CameraService:ChangeFlag(NewValue)
	self.CameraFlag = NewValue
end

function CameraService:RunCameraPath(PathName: string,Overwrite: boolean,Origin)
	if self.CameraRunning == true and Overwrite == false then return end
	
	local CameraPath = script:FindFirstChild(PathName)
	if not CameraPath then return end
	
	task.spawn(function()
		local Character = Players.LocalPlayer.Character
		Camera.CameraType = Enum.CameraType.Scriptable
		Camera.CameraSubject = nil
		
		local OldFov = Camera.FieldOfView
		
		for Index = 1, #CameraPath.Frames:GetChildren() + 1 do
			local CValue = CameraPath.Frames:FindFirstChild(Index-1)
			
			if CValue then
				if self.CameraFlag == true then break end
				Camera.CFrame = Origin * CValue.Value
				
				if CameraPath.FOV:FindFirstChild(tostring(Index-1)) then
					Camera.FieldOfView = CameraPath.FOV:FindFirstChild(tostring(Index-1)).Value
				end
				
				RunService.Heartbeat:Wait()
			end
		end
		
		Camera.CameraType = Enum.CameraType.Custom
		Camera.CameraSubject = Character.Humanoid
		Camera.FieldOfView = OldFov
	end)
end

return CameraService