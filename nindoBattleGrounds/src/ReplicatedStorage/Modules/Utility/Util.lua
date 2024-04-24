local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")


local Util = {}

function Util.CopyTable(Table)
	local Copy = {}
	for Index, Value in pairs(Table) do
		local IndexType, ValueType = type(Index), type(Value)
		if IndexType == "table" and ValueType == "table" then
			Index, Value = Util.CopyTable(Index), Util.CopyTable(Value)
		elseif ValueType == "table" then
			Value = Util.CopyTable(Value)
		elseif IndexType == "table" then
			Index = Util.CopyTable(Index)
		end
		Copy[Index] = Value
	end
	return Copy
end

function Util.Filter(Table,ClassName)
	local NewTable = {}
	
	for i,x in pairs(Table) do
		if x:IsA(ClassName) then
			table.insert(NewTable,x)
		end
	end
	
	return NewTable
end

function Util:SignalMarker(Animation,Name,Speed)
	local Dummy = script.Dummy:Clone()
	Dummy.Parent = workspace.World.Effects
	local A = Dummy.Humanoid.Animator:LoadAnimation(Animation)
	A:Play()
	if Speed then
		A:AdjustSpeed(Speed)
	end
	A.Stopped:Connect(function()
		Dummy:Destroy()
	end)
	return A:GetMarkerReachedSignal(Name)
end

function Util:StopMarker(Animation,Speed)
	local Dummy = script.Dummy:Clone()
	Dummy.Parent = workspace.World.Effects
	local A = Dummy.Humanoid.Animator:LoadAnimation(Animation)
	A:Play()
	if Speed then
		A:AdjustSpeed(Speed)
	end
	A.Stopped:Connect(function()
		Dummy:Destroy()
	end)
	return A.Stopped
end

if RunService:IsClient() then
	local TweenService = game:GetService("TweenService")
	local Debris = game:GetService("Debris")
	function Util.Blur(Size,Length)
		local Blur = Instance.new("BlurEffect")
		Blur.Size = 0
		Blur.Parent = game:GetService("Lighting")

		local TweenInf = TweenInfo.new(Length,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,true,0) 

		local Tween = TweenService:Create(Blur,TweenInf,{Size = Size})
		Tween:Play()
		Tween:Destroy()

		Debris:AddItem(Blur,Length * 2)
	end
end

return Util