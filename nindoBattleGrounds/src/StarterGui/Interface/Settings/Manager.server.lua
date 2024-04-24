local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local DataManager = require(ServerScriptService.Server.DataManager)

local Player = script.Parent.Parent.Parent.Parent

local Interface = script.Parent
local Frame = Interface:WaitForChild("ScrollingFrame")

local PlayerData = DataManager:GetData(Player)
local Music = PlayerData.Music
local FastMode = Player:GetAttribute("FastMode")
local Afk = Player:GetAttribute("AFK")

local function GetValue(Name)
	if Name == "Music" then
		return Music
	elseif Name == "FastMode" then
		return FastMode
	else
		return Afk
	end
end

local function SetValue(Name, NewValue)
	if Name == "Music" then
		PlayerData.Music = NewValue
		Music = PlayerData.Music
		Player:SetAttribute("Music", NewValue)
	elseif Name == "FastMode" then
		Player:SetAttribute("FastMode", NewValue)
		FastMode = Player:GetAttribute("FastMode")
	else
		Player:SetAttribute("AFK", NewValue)
		Afk = Player:GetAttribute("AFK")
	end
end

local function ChangeSetting(Name)
	local Holder = Frame:FindFirstChild(Name)
	local OnButton = Holder:WaitForChild("OnButton")
	local OffButton = Holder:WaitForChild("OffButton")
	
	if Holder then
		local NewValue = not GetValue(Name)
		SetValue(Name, NewValue)
		
		if NewValue then
			OnButton.ImageTransparency = 0
			OffButton.ImageTransparency = 0.5
		else
			OnButton.ImageTransparency = 0.5
			OffButton.ImageTransparency = 0
		end
	end
end

task.spawn(function()
	for Index, Setting in ipairs(Frame:GetChildren()) do
		if Setting:IsA("ImageLabel") then
			local OnButton = Setting:WaitForChild("OnButton")
			local OffButton = Setting:WaitForChild("OffButton")
			
			if GetValue(Setting.Name) then
				OnButton.ImageTransparency = 0
				OffButton.ImageTransparency = 0.5
			else
				OnButton.ImageTransparency = 0.5
				OffButton.ImageTransparency = 0
			end
			
			OnButton.MouseButton1Down:Connect(function()
				if not GetValue(Setting.Name) then
					ChangeSetting(Setting.Name)
				end
			end)
			
			OffButton.MouseButton1Down:Connect(function()
				if GetValue(Setting.Name) then
					ChangeSetting(Setting.Name)
				end
			end)
		end
	end
end)