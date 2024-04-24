local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local RayCastParams = RaycastParams.new()
RayCastParams.FilterType = Enum.RaycastFilterType.Whitelist
RayCastParams.FilterDescendantsInstances = {workspace.World.Map}

export type Params = {
	CF:CFrame, 
	Radius:number?, 
	Lifetime:number?, 
	Size:number | {Min:number, Max:number}?, 
	Amount:number?,
	GroundAllowance:number?, 
}

return function(Params:Params)
	setmetatable(Params, {
		__index = {
			Radius = 10, 
			Lifetime = 3, 
			Size = 3, 
			Amount = 18, 
			GroundAllowance = -20
		}
	})

	local CF = Params.CF

	if not CF then return false end

	local ActualSize

	local RayCastResult, X, Z, Part, PTween

	local Parts = {}
	for i = 1, Params.Amount do
		X = Params.Radius * math.cos(math.rad(i * (360/Params.Amount)))
		Z = Params.Radius * math.sin(math.rad(i * (360/Params.Amount)))

		RayCastResult = workspace:Raycast(
			(CF * CFrame.new(X, 10, Z)).Position, 
			((CF * CFrame.new(X, Params.GroundAllowance, Z)).Position - (CF * CFrame.new(X, 0, Z)).Position),	
			RayCastParams
		)

		if RayCastResult then
			ActualSize = typeof(Params.Size) == "table" and math.random(Params.Size.Min, Params.Size.Max)

			Part = Instance.new("Part")
			Part.CFrame = CFrame.new(RayCastResult.Position) * CFrame.Angles(math.rad(math.random(-180, 180)), math.rad(math.random(-180, 180)), math.rad(math.random(-180, 180)))
			Part.TopSurface = Enum.SurfaceType.Smooth
			Part.BottomSurface = Enum.SurfaceType.Smooth
			Part.Material = RayCastResult.Material
			Part.Size = Vector3.new(0, 0, 0)
			Part.Color = RayCastResult.Instance.Color
			Part.Anchored = true
			Part.CanCollide = false
			for _, Texture:Texture in next, RayCastResult.Instance:GetChildren() do
				if not Texture:IsA("Texture") then continue end

				Texture:Clone().Parent = Part

			end
			Part.Parent = workspace.World.Effects

			PTween = TweenService:Create(Part, TweenInfo.new(0.2), {Size = Vector3.new(1, 1, 1) * (ActualSize or Params.Size), CFrame = Part.CFrame * CFrame.Angles(math.rad(math.random(-180, 180)), math.rad(math.random(-180, 180)), math.rad(math.random(-180, 180)))})
			PTween:Play()
			PTween:Destroy()

			Parts[#Parts + 1] = Part
		end
	end

	task.wait(Params.Lifetime)

	for _, Part in pairs(Parts) do
		PTween = TweenService:Create(Part, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = Vector3.new(0, 0, 0), CFrame = Part.CFrame * CFrame.Angles(math.rad(math.random(-180, 180)), math.rad(math.random(-180, 180)), math.rad(math.random(-180, 180)))})
		PTween:Play()
		PTween:Destroy()

		Debris:AddItem(Part, 0.6)

		task.wait(0.01)
	end
end