local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local SS2 = game:GetService("ServerScriptService")

local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")
local Joint = Root:WaitForChild("RootJoint")
local OldCFrame = Joint.C0

local Mouse = Player:GetMouse()

local CanClick = true
local CanBlock = true
local CanDash = true
local CanUseSkill = true

local Sprinting = false

local ClientHandler = {}
ClientHandler.Events = {}
ClientHandler.CharVFXS = {}

ClientHandler.CameraService = require(script.CameraService).new()
ClientHandler.CamShaker = ""

local CurrentCamera = workspace.CurrentCamera
local CameraShaker = require(RS.Modules.Utility.CameraShaker)
ClientHandler.CamShaker = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
	CurrentCamera.CFrame = CurrentCamera.CFrame * shakeCFrame
end)

local DashKeys = {Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D}

Player.CharacterAdded:Connect(function(NewCharacter)
	Character = NewCharacter
	Root = Character:WaitForChild("HumanoidRootPart")
	Humanoid = Character:WaitForChild("Humanoid")
	Joint = Root:WaitForChild("RootJoint")
	OldCFrame = Joint.C0
end)

local function GetKeysPressed(Keys, Type)
	local Pressed = {}

	for Index, Key in pairs(Keys) do
		if UserInputService:IsKeyDown(Key) then
			if Type == "All" then
				Pressed[UserInputService:GetStringForKeyCode(Key)] = true
			else
				return UserInputService:GetStringForKeyCode(Key)
			end
		end
	end

	return Pressed
end

local function UpdateMotor(NewCFrame)
	local Info = TweenInfo.new(.25,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
	local Tween = TweenService:Create(Joint, Info, {["C0"] = NewCFrame})

	if NewCFrame == OldCFrame then
		--Humanoid.AutoRotate = true
	else
		--Humanoid.AutoRotate = false
	end

	pcall(function()
		Tween:Play()
	end)
end

local function UpdateFacing()
	if Humanoid.Health <= 0 then return end
	if UserInputService.MouseBehavior ~= Enum.MouseBehavior.LockCenter then UpdateMotor(OldCFrame) return end
	if Humanoid.WalkSpeed == 3 then UpdateMotor(OldCFrame) return end
	local KeyCode = GetKeysPressed(DashKeys, "All")

	if KeyCode.W and not KeyCode.S then
		if KeyCode.A and not KeyCode.D then
			UpdateMotor(OldCFrame * CFrame.Angles(0,0,math.rad(45)))
		elseif not KeyCode.A and KeyCode.D then
			UpdateMotor(OldCFrame * CFrame.Angles(0,0,math.rad(-45)))
		else
			UpdateMotor(OldCFrame)
		end
	elseif not KeyCode.W and KeyCode.S then
		if KeyCode.A and not KeyCode.D then
			UpdateMotor(OldCFrame * CFrame.Angles(0,0,math.rad(-225)))
		elseif not KeyCode.A and KeyCode.D then
			UpdateMotor(OldCFrame * CFrame.Angles(0,0,math.rad(-135)))
		else
			UpdateMotor(OldCFrame * CFrame.Angles(0,0,math.rad(-180)))
		end
	else
		if KeyCode.A and not KeyCode.D then
			UpdateMotor(OldCFrame * CFrame.Angles(0,0,math.rad(90)))
		elseif not KeyCode.A and KeyCode.D then
			UpdateMotor(OldCFrame * CFrame.Angles(0,0,math.rad(-90)))
		else
			UpdateMotor(OldCFrame)
		end
	end
end

ClientHandler.CamShaker:Start()

ClientHandler.ControlActions = {
	["Movement"] = {
		["Dash"] = {},
		["Sprint"] = {},
		["FaceFront"] = {},
		["FaceLeft"] = {},
		["FaceBack"] = {},
		["FaceRight"] = {},
		["MouseLock"] = {}
	},
	["Combat"] = {
		["M1"] = {

		},
		["Block"] = {

		},
	},
	["Skills"] = {
		["FirstSkill"] = {

		},
		["SecondSkill"] = {

		},
		["ThirdSkill"] = {

		},
		["FourthSkill"] = {

		},
		["UltimateSkill"] = {

		},
	}
}

task.spawn(function()
	for i, x in ipairs(script.Parent.VFXS:GetDescendants()) do
		if x:IsA("ModuleScript") and not x:FindFirstChild("DontImp") then
			local Mod = require(x)
			ClientHandler.CharVFXS[x.Name] = Mod
		end
	end

	for Index, Skill in pairs(ClientHandler.ControlActions.Skills) do
		function Skill:InputBegan()
			local RemoteComs = require(RS.Modules.Utility.RemoteNetwork)
			RemoteComs:FireServerEvent({FunctionName = "InputBeganSkill"}, {Slot = Index, Type = "Hold"})
		end
		
		function Skill:InputEnded()
			local RemoteComs = require(RS.Modules.Utility.RemoteNetwork)
			RemoteComs:FireServerEvent({FunctionName = "InputBeganSkill"}, {Slot = Index, Type = "Release"})
		end
	end
end)

function ClientHandler.ControlActions.Movement.Dash:InputBegan()
	if CanDash then
		CanDash = false
		
		local RemoteComs = require(RS.Modules.Utility.RemoteNetwork)
		local Dir = "FrontDash"
		
		if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then
				Dir = "BackDash"
			elseif UserInputService:IsKeyDown(Enum.KeyCode.A) then
				Dir = "RightDash"
			elseif UserInputService:IsKeyDown(Enum.KeyCode.D) then
				Dir = "LeftDash"
			end
		end
		
		RemoteComs:FireServerEvent({FunctionName = "Dash"},{Dir})
		
		task.wait(.5)
		CanDash = true
	end
end

function ClientHandler.ControlActions.Movement.Sprint:InputBegan()
	local RemoteComs = require(RS.Modules.Utility.RemoteNetwork)
	RemoteComs:FireServerEvent({FunctionName = "SprintStart"},{})
	
	task.spawn(function()
		repeat
			task.wait()
		until Humanoid.WalkSpeed == 28
		UpdateFacing()
	end)
end

function ClientHandler.ControlActions.Movement.Sprint:InputEnded()
	local RemoteComs = require(RS.Modules.Utility.RemoteNetwork)
	RemoteComs:FireServerEvent({FunctionName = "SprintEnd"},{})
	
	task.spawn(function()
		repeat
			task.wait()
		until Humanoid.WalkSpeed < 28
		UpdateFacing()
	end)
end

function ClientHandler.ControlActions.Movement.MouseLock:InputBegan()
	UpdateFacing()
end

function ClientHandler.ControlActions.Movement.MouseLock:InputEnded()
	UpdateFacing()
end

Mouse.Move:Connect(function()
	if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
		UpdateMotor(OldCFrame)
		--UpdateFacing()
	end
	task.wait(.5)
end)

Mouse.Idle:Connect(function()
	if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
		--UpdateMotor(OldCFrame)
		UpdateFacing()
	end
	task.wait(.5)
end)

-- Front
function ClientHandler.ControlActions.Movement.FaceFront:InputBegan()
	UpdateFacing()
end

function ClientHandler.ControlActions.Movement.FaceFront:InputEnded()
	UpdateFacing()
end

-- Left
function ClientHandler.ControlActions.Movement.FaceLeft:InputBegan()
	UpdateFacing()
end

function ClientHandler.ControlActions.Movement.FaceLeft:InputEnded()
	UpdateFacing()
end

-- Back
function ClientHandler.ControlActions.Movement.FaceBack:InputBegan()
	UpdateFacing()
end

function ClientHandler.ControlActions.Movement.FaceBack:InputEnded()
	UpdateFacing()
end

-- Right
function ClientHandler.ControlActions.Movement.FaceRight:InputBegan()
	UpdateFacing()
end

function ClientHandler.ControlActions.Movement.FaceRight:InputEnded()
	UpdateFacing()
end

-- Others
function ClientHandler.ControlActions.Combat.M1:InputBegan()
	if CanClick then
		CanClick = false
		
		local RemoteComs = require(RS.Modules.Utility.RemoteNetwork)
		RemoteComs:FireServerEvent({FunctionName = "Swing"}, {["SwingDelay"] = os.clock()})
		
		task.wait(.2)
		CanClick = true
	end
end

function ClientHandler.ControlActions.Combat.Block:InputBegan()
	if CanBlock then
		CanBlock = false
		
		local RemoteComs = require(RS.Modules.Utility.RemoteNetwork)
		RemoteComs:FireServerEvent({FunctionName = "Block"},{})
		
		task.spawn(function()
			repeat
				task.wait()
			until Humanoid.WalkSpeed == 3
			UpdateFacing()
		end)
	end
end

function ClientHandler.ControlActions.Combat.Block:InputEnded()
	if not CanBlock then
		local RemoteComs = require(RS.Modules.Utility.RemoteNetwork)
		RemoteComs:FireServerEvent({FunctionName = "BlockEnd"},{})
		
		task.spawn(function()
			repeat
				task.wait()
			until Humanoid.WalkSpeed > 3
			UpdateFacing()
		end)
		
		task.wait(.2)
		CanBlock = true
	end
end

function ClientHandler:GenerateEvent(Name,Func)
	ClientHandler.Events[Name] = Func
end

function ClientHandler:FireEvent(Name,...)
	if ClientHandler.Events[Name] then
		ClientHandler.Events[Name](...)
	end
end

return ClientHandler