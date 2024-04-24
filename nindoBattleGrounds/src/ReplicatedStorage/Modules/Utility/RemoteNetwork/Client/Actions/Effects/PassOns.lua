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

local module = {}

function module:PlaySound(Data)
	local SoundManager = require(RS.Modules.Services.SoundService)
	SoundManager:PlaySound(Data.SoundName,Data.SoundProperties,Data.CustomData)
end

function module:PlaySoundAt(Data)
	local SoundManager = require(RS.Modules.Services.SoundService)
	SoundManager:PlaySoundAt(Data.SoundName,Data.SoundProperties,Data.CustomData)
end


function module:StopSound(Data)
	local SoundManager = require(RS.Modules.Services.SoundService)
	SoundManager:StopSound(Data.SoundName,Data.SoundProperties,Data.CustomData)
end

function module:StopSoundAt(Data)
	local SoundManager = require(RS.Modules.Services.SoundService)
	SoundManager:StopSoundAt(Data.SoundName,Data.SoundProperties,Data.CustomData)
end


function module:SkillScreentoPoint(Data)
	local ReturnTable = {}
	local Camera = workspace.CurrentCamera
	local screenCenter = Vector2.new(Camera.ViewportSize.X / 2,Camera.ViewportSize.Y / 2 -(game:GetService("GuiService"):GetGuiInset().Y/2))
	for i,x in pairs(Data[1]) do
		local vector, onScreen = Camera:WorldToScreenPoint(x.Position)
		local partScreenPoint = Vector2.new(vector.X, vector.Y)
		local Mag = (screenCenter - partScreenPoint).Magnitude

		if onScreen then
			table.insert(ReturnTable,{x,Camera:WorldToViewportPoint(x.Position),Mag})
		end
	end
	return ReturnTable
end

function module:AnimationService(Data)
	local AnimationService = require(RS.Modules.Services.AnimationService)
	AnimationService[Data.Task]("Null",Player.Character or Player.CharacterAdded:Wait(),Data.AnimationData)
end

function module:VFX(Data)
	local VFXHandle = require(RS.Modules.Utility.VFXHandler)
	if VFXHandle[Data.FName] then
		VFXHandle[Data.FName](Data.FData)
	end
end

function module:UISKeyDown(Data)
	return UIS:IsKeyDown(Data[1])
end

function module:GetMouse(Data)
	return Player:GetMouse().Hit
end

function module:SkillVFX(Data)
	if type(ClientManager.CharVFXS[Data.CharacterID.."VFX"] == "table") and type(ClientManager.CharVFXS[Data.CharacterID.."VFX"][Data.SkillSlot][Data.FuncName] == "function") then
		ClientManager.CharVFXS[Data.CharacterID.."VFX"][Data.SkillSlot][Data.FuncName](Data.Data)
	end
end


return module
