--// services
local players = game:GetService('Players')
local replicated_storage = game:GetService('ReplicatedStorage')
local run_service = game:GetService('RunService')
local TweenService = game:GetService("TweenService")

--// variables
local player = players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local Hum = character:WaitForChild('Humanoid')
local Root = character:WaitForChild('HumanoidRootPart')

local MenuChars = script.Parent:WaitForChild("Selection").Frame
MenuChars.Position = UDim2.new(1.5,0,0.5,0)
local MenuButton = script.Parent:WaitForChild("HealthBarUI").Charecters

local ClientManager = require(player.PlayerScripts:WaitForChild("Client").ClientHandler)

local Skills = script.Parent:WaitForChild("Skills").Holder

ClientManager:GenerateEvent("CooldownFire",function(Data)
	local Slot = Data.Slot
	Slot = string.gsub(Slot, "Skill", "Ability")
	local Time = Data.Time
	local CooldownHold = Data.Hold
	
	
	if CooldownHold ~= nil then
		if CooldownHold == true then
			if Skills:FindFirstChild(Slot) then
				if Skills:FindFirstChild(Slot):FindFirstChild("CooldownTempH") then
					Skills:FindFirstChild(Slot):FindFirstChild("CooldownTempH"):Destroy()
				end
				local Clone = script.CooldownTempH:Clone()
				Clone.Name = "CooldownTempH"
				Clone.Parent = Skills:FindFirstChild(Slot)
			end
		elseif CooldownHold == false then
			if Skills:FindFirstChild(Slot) then
				if Skills:FindFirstChild(Slot):FindFirstChild("CooldownTempH") then
					Skills:FindFirstChild(Slot):FindFirstChild("CooldownTempH"):Destroy()
				end
			end
		end
	else
		if Skills:FindFirstChild(Slot) and Time and Time ~= 0 then
			if Skills:FindFirstChild(Slot):FindFirstChild("CooldownTempH") then
				Skills:FindFirstChild(Slot):FindFirstChild("CooldownTempH"):Destroy()
			end
			local Panel = Skills:FindFirstChild(Slot)
			local Clone = script.CooldownTempH:Clone()
			Clone.Parent = Panel
			
			Clone.UIGradient.Offset = Vector2.new(0,-0.6)
			
			local Tween = TweenService:Create(Clone.UIGradient,TweenInfo.new(Time,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{
				Offset = Vector2.new(0,0.5)
			})
			
			Tween:Play()
			Tween.Completed:Connect(function()
				Tween:Destroy()
				Clone:Destroy()
			end)
		end
	end
	
end)


local MenuOpen = false
local canclick = true

local OGPos = UDim2.new(0.5,0,0.5,0)

local TweenPos = UDim2.new(1.5,0,0.5,0)

MenuButton.MouseButton1Click:Connect(function()
	if canclick == false then return end
	if MenuOpen == false then
		canclick = false
		script.Parent:WaitForChild("Selection").Enabled = true
		local Tween = TweenService:Create(MenuChars,TweenInfo.new(.75,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut),{
			["Position"] = OGPos
		})
		Tween:Play()
		Tween.Completed:Connect(function()
			Tween:Destroy()
			canclick = true
		end)
		MenuOpen = true
	elseif MenuOpen == true then
		canclick = false
		local Tween = TweenService:Create(MenuChars,TweenInfo.new(.75,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut),{
			["Position"] = TweenPos
		})
		Tween:Play()
		Tween.Completed:Connect(function()
			Tween:Destroy()
			script.Parent:WaitForChild("Selection").Enabled = false
			canclick = true
		end)
		MenuOpen = false
	end
end)

script.Current.Changed:Connect(function(Value)
	
end)

function render_stepped()
	if character.Parent ~= nil and not character:FindFirstChild('Land_Stun') and not character:FindFirstChild('DoubleJump') or character.Parent ~= nil then	
		if character:FindFirstChild('Blocking') then
			Hum.WalkSpeed = 9
			Hum.JumpPower = 25
		end	
	end
end


run_service.RenderStepped:Connect(render_stepped)