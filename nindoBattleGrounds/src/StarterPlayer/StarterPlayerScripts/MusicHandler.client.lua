--〔 Services 〕--
local Players = game:GetService("Players")

--〔 Variables 〕--
local Player = Players.LocalPlayer

local Music = Player:GetAttribute("Music")

--〔 Functions 〕--
local function Change()
	if Player:GetAttribute("Music") then
		workspace:WaitForChild("CurrentTrack").Volume = .75
	else
		workspace:WaitForChild("CurrentTrack").Volume = 0
	end
end

--〔 Changed 〕--
Change()

workspace.ChildAdded:Connect(Change)
Player:GetAttributeChangedSignal("Music"):Connect(Change)