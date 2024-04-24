--〔 Services 〕--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

--〔 Variables 〕--
local Player = Players.LocalPlayer

local FastMode = Player:GetAttribute("FastMode")

local Max = 60

--〔 Functions 〕--
local function ScanGraphics()
	if Player:GetAttribute("FastMode") then
		local Batch = 0
		local Ammount = 0
		local Start = tick()
		
		for Index, BasePart in ipairs(workspace:WaitForChild("World"):WaitForChild("Map"):GetDescendants()) do
			if BasePart:IsA("BasePart") then
				Ammount += 1
				Batch += 1
				BasePart.Material = Enum.Material.SmoothPlastic
			elseif BasePart:IsA("Texture") then
				Ammount += 1
				Batch += 1
				BasePart:Destroy()
			end
			
			if Batch >= Max then
				Batch = 0
				RunService.Heartbeat:Wait()
			end
		end
		
		local Time = tostring(tick() - Start)
		print("Fast Mode was enabled. Took "..string.sub(Time, 1, 5).." seconds. [Parts: "..Ammount.."]")
	end
end

--〔 Changed 〕--
ScanGraphics()

Player:GetAttributeChangedSignal("FastMode"):Connect(ScanGraphics)