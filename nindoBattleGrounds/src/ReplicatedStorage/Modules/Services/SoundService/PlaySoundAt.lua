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

return function(LoadedSounds,SoundName,SoundProperties,CustomData)
	if not LoadedSounds[SoundName] then warn(SoundName.." Does Not Extist or is Bugged") return end
	if not CustomData.CFrame then return end

	local Sound = LoadedSounds[SoundName]:Clone()

	if SoundProperties then
		for Property, Value in next, SoundProperties do
			Sound[Property] = Value;
		end
	end
	
	local Part = Instance.new("Part")
	Part.CanQuery = false
	Part.CanCollide = false
	Part.CanTouch = false
	Part.Anchored = true
	Part.Transparency =  1
	Part.CFrame = CustomData.CFrame
	Part.Parent = workspace.World.SFX
	
	Sound.Parent = Part
	Sound:Play()
	if not SoundProperties.Looped then
		local Connection; Connection = Sound.Ended:Connect(function()
			Sound:Destroy()
			Part:Destroy()
			Connection:Disconnect()
			Connection = nil
		end)
	elseif SoundProperties.Looped then
		if not CustomData or not CustomData.Duration then return end
		Debris:AddItem(Part, CustomData.Duration)
	end
	if SoundProperties.Playing then
		task.spawn(function()
			task.wait(Sound.TimeLength - CustomData.TweenTime)

			local SoundTween = TweenService:Create(Sound,TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{["Volume"] = 0})
			SoundTween:Play()
			SoundTween:Destroy()

			SoundTween.Completed:Wait()
			Sound:Destroy()
			Part:Destroy()
		end)
	end
end