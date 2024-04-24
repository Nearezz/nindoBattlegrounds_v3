local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local SS2 = game:GetService("ServerScriptService")

local UIS = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local ClientManager = require(Player.PlayerScripts:WaitForChild("Client").ClientHandler)

local camera = workspace.CurrentCamera

local module = {}

function module:CooldownSet(Data)
	local CooldownTime = Data.CooldownTime
	local CooldownHold = Data.Hold
	local Slot = Data.Slot
	
	ClientManager:FireEvent("CooldownFire",{
		Slot = Slot,
		Time = CooldownTime,
		Hold = CooldownHold
	})
	
	
end





function module:PlayCashSound(Data)
	local CashSound = RS.Assets.NotUsedSounds.Misc.Cash
	CashSound:Play()
end

function module:RunFov(Data)
	local function tweenFov(duration, bool)
		local fov = 70
		if bool == true then
			fov = 80
		end
		
		
		local tween = TweenService:Create(camera, TweenInfo.new(duration, Enum.EasingStyle.Quad), {FieldOfView = fov})
		tween:Play()

		spawn(function()
			tween.Completed:Wait()
			tween:Destroy()
		end)

	end
	tweenFov(0.25,Data.Val)
end


return module