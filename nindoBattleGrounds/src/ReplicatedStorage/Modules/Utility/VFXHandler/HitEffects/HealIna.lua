--// services
local replicatedStorage = game:GetService('ReplicatedStorage')
local tweenService = game:GetService('TweenService')

--// variables
local module = script
local damageIndicator = module.DamageIndicator

function tween(indicator)
	indicator.Damage.Size = UDim2.fromScale(.01, .01)
	
	task.delay(.1,function()
		tweenService:Create(indicator.Damage, TweenInfo.new(.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.fromScale(1, 1);
		}):Play()
	end)
	
	tweenService:Create(indicator, TweenInfo.new(.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
		StudsOffset = Vector3.new( Random.new():NextInteger(-2, 2), Random.new():NextInteger(-1, 2), Random.new():NextInteger(0, 2) );
	}):Play()
	
	local rotation = Random.new():NextInteger(-10, 10)
	
	tweenService:Create(indicator.Damage, TweenInfo.new(.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Rotation = rotation;
	}):Play()
	
	local cached = indicator:GetAttribute('Start')
	
	task.delay(1, function()
		if indicator:GetAttribute('Start') == cached then
			tweenService:Create(indicator.Damage, TweenInfo.new(.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = UDim2.fromScale(0, 0);
			}):Play()
			
			task.wait(.25)
			
			if indicator:GetAttribute('Start') ~= cached then return end
			
			indicator:Destroy()
		end
	end)
end

return function(victim, damage)
	if not victim:FindFirstChild('DamageIndicator') then
		local clone = damageIndicator:Clone()
		clone.Adornee = victim.HumanoidRootPart
		clone.Damage.Text = '-' .. damage
		clone:SetAttribute('Start', os.clock())
		clone:SetAttribute('Damage', damage)
		clone.Parent = victim
		
		tween(clone)
	else
		local indicator = victim:FindFirstChild('DamageIndicator')
		indicator:SetAttribute('Start', os.clock())
		indicator.Damage.Text = '-' .. indicator:GetAttribute('Damage') + damage
		indicator:SetAttribute('Damage', indicator:GetAttribute('Damage') + damage)
		
		tween(indicator)
	end
end