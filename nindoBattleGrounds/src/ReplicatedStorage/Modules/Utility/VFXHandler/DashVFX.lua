return function(Data)
	local Character = Data.Character
	local ClientHandler = require(game:GetService("Players").LocalPlayer.PlayerScripts.Client.ClientHandler)
	
	--local CamShake = ClientHandler.CamShaker
	
	--CamShake:ShakeOnce(10,10,0,0.5)
	
	local HumRP = Character.HumanoidRootPart
	
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	raycastParams.FilterDescendantsInstances = {Character,workspace.World.VFX}
	raycastParams.IgnoreWater = true

	local RayOrigin = HumRP.Position
	local RayDirection = Vector3.new(0,-1,0) * 10
	local NewRay = workspace:Raycast(RayOrigin,RayDirection,raycastParams)

	if NewRay then
		local Dirt = script.Dirt:Clone()
		Dirt.Parent = workspace.World.VFX
		Dirt.Position = NewRay.Position
		local trueColor = NewRay.Instance.Color
		Dirt:WaitForChild("Attachment"):WaitForChild("Smoke").Color = ColorSequence.new{			
			ColorSequenceKeypoint.new(0,trueColor),
			ColorSequenceKeypoint.new(1,trueColor),				
		}
		Dirt:WaitForChild("Attachment"):WaitForChild("Smoke"):Emit(30)
		game.Debris:AddItem(Dirt,1.1)
	end
	
end