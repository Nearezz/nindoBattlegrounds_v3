local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local Humanoid = Character.Humanoid
local HumRP = Character.PrimaryPart

local ClientControls = require(ReplicatedStorage.Modules.MetaData.ClientControls)
local ClientManager = require(Player.PlayerScripts:WaitForChild("Client").ClientHandler)

local Typing = false

UserInputService.TextBoxFocused:Connect(function()
	Typing = true
end)

UserInputService.TextBoxFocusReleased:Connect(function()
	Typing = false
end)

UserInputService.InputBegan:Connect(function(Input, GameProcessedEvent)
	if Typing then return end
	
	local InputType = Input.KeyCode ~= Enum.KeyCode.Unknown and Input.KeyCode or Input.UserInputType
	local InputName = InputType.Name
	
	local IsControl = (ClientControls["Combat"][InputName] and "Combat") or (ClientControls["Movement"][InputName] and "Movement") or (ClientControls["Skills"][InputName] and "Skills")
	if not IsControl then return end
	
	local Action = ClientControls[IsControl][InputName]
	local HasFunction = type(ClientManager["ControlActions"][IsControl][Action]["InputBegan"])
	if HasFunction ~= "function" then return end
	
	ClientManager["ControlActions"][IsControl][Action]["InputBegan"]()
end)

UserInputService.InputEnded:Connect(function(Input, GameProcessedEvent)
	if Typing then return end
	
	local InputType = Input.KeyCode ~= Enum.KeyCode.Unknown and Input.KeyCode or Input.UserInputType
	local InputName = InputType.Name
	
	local IsControl = (ClientControls["Combat"][InputName] and "Combat") or (ClientControls["Movement"][InputName] and "Movement") or (ClientControls["Skills"][InputName] and "Skills")
	if not IsControl then return end
	
	local Action = ClientControls[IsControl][InputName]
	local HasFunction = type(ClientManager["ControlActions"][IsControl][Action]["InputEnded"])
	if HasFunction ~= "function" then return end
	
	ClientManager["ControlActions"][IsControl][Action]["InputEnded"]()
end)

--local DJ = os.clock()
--local CD = 0
--local CanJump = true
--local MaxAmount = 2
--local AnimationService = require(RS.Modules.Services.AnimationService)

--AnimationService:PlayAnimation(Character,{
--	Name = RS.Assets.Animations.Shared.Combat.Land.Name,
--	AnimationSpeed = 1,
--	Weight = 1,
--	FadeTime = 0.25,
--	Looped = false,
--})

--Humanoid.StateChanged:Connect(function(newstate,oldstate)
--	if newstate == Enum.HumanoidStateType.Landed then
--		CD = 2
--		MaxAmount = 2
--		AnimationService:PlayAnimation(Character,{
--			Name = RS.Assets.Animations.Shared.Combat.Land.Name,
--			AnimationSpeed = 1,
--			Weight = 1,
--			FadeTime = 0.25,
--			Looped = false,
--		})
--	end
--end)

--UIS.JumpRequest:Connect(function()
--	if os.clock() - DJ >= CD and MaxAmount > 0 and CanJump == true then
--		Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
--		MaxAmount -= 1
--		CD = 0.1
--		if MaxAmount == 0 then
--			AnimationService:PlayAnimation(Character,{
--				Name = RS.Assets.Animations.Shared.Combat.DoubleJump.Name,
--				AnimationSpeed = 1,
--				Weight = 1,
--				FadeTime = 0.25,
--				Looped = false,
--			})
--		end
--		DJ = os.clock()	
--	end
--end)

