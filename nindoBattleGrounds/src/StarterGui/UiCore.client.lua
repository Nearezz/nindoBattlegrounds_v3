--〔 Services 〕--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

--〔 Variables 〕--
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

local ClientManager = require(Player.PlayerScripts:WaitForChild("Client").ClientHandler)

local UltimatePoints = Player:WaitForChild("UltimatePoints")

local Interface = script.Parent:WaitForChild("Interface")

local Bars = Interface:WaitForChild("Bars")
local HealthBar = Bars:WaitForChild("HealthBar"):WaitForChild("Progress")
local UltimateBar = Bars:WaitForChild("UltimateBar"):WaitForChild("Progress")
local PressG = Bars:WaitForChild("UltimateBar"):WaitForChild("Label")

local Skills = Interface:WaitForChild("Abilities")

local LeftButtons = Interface:WaitForChild("LeftButtons")
local Settings = LeftButtons:WaitForChild("Settings")
local Profile = LeftButtons:WaitForChild("Profile")
local Store = LeftButtons:WaitForChild("Store")

local MenuButton = Interface:WaitForChild("RightButtons"):WaitForChild("Menu")
local CharactersButton = Interface:WaitForChild("RightButtons"):WaitForChild("Characters")

local Characters = Interface:WaitForChild("Characters")
local ExitButton = Characters:WaitForChild("CloseButton")

local SettingsPage = Interface:WaitForChild("Settings")
local SettingsExit = SettingsPage:WaitForChild("CloseButton")

local ProfilePage = Interface:WaitForChild("Profile")
local ProfileExit = ProfilePage:WaitForChild("CloseButton")

local StorePage = Interface:WaitForChild("Store")
local StoreExit = StorePage:WaitForChild("CloseButton")

local GameVersion = Interface:WaitForChild("GameVersion")
GameVersion.Text = "Ver. "..ReplicatedStorage:WaitForChild("GameVersion").Value

local PunchButton = Interface:WaitForChild("PunchButton")
local DashButton = Interface:WaitForChild("DashButton")
local BlockButton = Interface:WaitForChild("BlockButton")
local SprintButton = Interface:WaitForChild("RunButton")
local UltButton = Interface:WaitForChild("UltButton")

local SkillOne = Interface:WaitForChild("SkillOne")
local SkillTwo = Interface:WaitForChild("SkillTwo")
local SkillThree = Interface:WaitForChild("SkillThree")
local SkillFour = Interface:WaitForChild("SkillFour")

--〔 Auxiliary 〕--
task.spawn(function()
	if UserInputService.TouchEnabled and not UserInputService.MouseEnabled and not UserInputService.KeyboardEnabled then
		PunchButton.Visible = true
		DashButton.Visible = true
		BlockButton.Visible = true
		SprintButton.Visible = true
		UltButton.Visible = true
		
		PunchButton.TouchTap:Connect(function()
			ClientManager["ControlActions"]["Combat"]["M1"]["InputBegan"]()
		end)
		
		DashButton.TouchTap:Connect(function()
			ClientManager["ControlActions"]["Movement"]["Dash"]["InputBegan"]()
		end)
		
		BlockButton.TouchTap:Connect(function()
			if Humanoid.WalkSpeed > 3 then
				ClientManager["ControlActions"]["Combat"]["Block"]["InputBegan"]()
			else
				ClientManager["ControlActions"]["Combat"]["Block"]["InputEnded"]()
			end
		end)
		
		SprintButton.TouchTap:Connect(function()
			if Humanoid.WalkSpeed < 28 then
				ClientManager["ControlActions"]["Movement"]["Sprint"]["InputBegan"]()
			else
				ClientManager["ControlActions"]["Movement"]["Sprint"]["InputEnded"]()
			end
		end)
		
		SkillOne.TouchTap:Connect(function()
			ClientManager["ControlActions"]["Skills"]["FirstSkill"]["InputBegan"]()
		end)
		
		SkillTwo.TouchTap:Connect(function()
			ClientManager["ControlActions"]["Skills"]["SecondSkill"]["InputBegan"]()
		end)
		
		SkillThree.TouchTap:Connect(function()
			ClientManager["ControlActions"]["Skills"]["ThirdSkill"]["InputBegan"]()
		end)
		
		SkillFour.TouchTap:Connect(function()
			ClientManager["ControlActions"]["Skills"]["FourthSkill"]["InputBegan"]()
		end)
		
		UltButton.TouchTap:Connect(function()
			ClientManager["ControlActions"]["Skills"]["UltimateSkill"]["InputBegan"]()
		end)
	else
		PunchButton.Visible = false
		DashButton.Visible = false
		BlockButton.Visible = false
		SprintButton.Visible = false
		UltButton.Visible = false
	end
end)

local MenuOpen = false
local Debounce = false
local Cooldown = .5

local CharactersOpen = false
local Debounce2 = false

local SettingsOpen = false
local ProfileOpen = false
local StoreOpen = false

LeftButtons.Visible = true
Characters.Visible = true
Characters.Position = UDim2.new(-1,0,0.518,0)
Settings.Position = UDim2.new(-20,0,0,0)
Profile.Position = UDim2.new(25,0,0.4,0)
Store.Position = UDim2.new(-20,0,0.8,0)
SettingsPage.Visible = true
SettingsPage.Position = UDim2.new(-1,0,0.5,0)
ProfilePage.Visible = true
ProfilePage.Position = UDim2.new(-1,0,0.5,0)
StorePage.Visible = true
StorePage.Position = UDim2.new(-1,0,0.5,0)

--〔 Functions 〕--
local function UpdateHealth()
	local Percentage = Humanoid.Health/Humanoid.MaxHealth
	HealthBar:TweenSize(UDim2.new(Percentage,0,1,0),Enum.EasingDirection.Out,Enum.EasingStyle.Sine,.2,true)
end

local function UpdateUltimate()
	local Percentage = UltimatePoints.Value/UltimatePoints.MaxValue
	UltimateBar:TweenSize(UDim2.new(Percentage,0,1,0),Enum.EasingDirection.Out,Enum.EasingStyle.Sine,.2,true)
	
	if UltimatePoints.Value == UltimatePoints.MaxValue then
		PressG.Visible = true
	else
		PressG.Visible = false
	end
end

local function DisplayMenu(State)
	MenuOpen = State
	
	local Info = TweenInfo.new(.5,Enum.EasingStyle.Linear,Enum.EasingDirection.Out)
	
	if State then
		local Tween = TweenService:Create(Settings, Info, {Position = UDim2.new(8.7,0,0,0)})
		Tween:Play()
		
		local Tween2 = TweenService:Create(Profile, Info, {Position = UDim2.new(8.7,0,0.4,0)})
		Tween2:Play()
		
		local Tween3 = TweenService:Create(Store, Info, {Position = UDim2.new(8.7,0,0.8,0)})
		Tween3:Play()
	else
		local Tween = TweenService:Create(Settings, Info, {Position = UDim2.new(-20,0,0,0)})
		Tween:Play()
		
		local Tween2 = TweenService:Create(Profile, Info, {Position = UDim2.new(25,0,0.4,0)})
		Tween2:Play()
		
		local Tween3 = TweenService:Create(Store, Info, {Position = UDim2.new(-20,0,0.8,0)})
		Tween3:Play()
	end
end

local function DisplayCharacters(State)
	CharactersOpen = State
	
	local Info = TweenInfo.new(.5,Enum.EasingStyle.Linear,Enum.EasingDirection.Out)
	
	if State then
		local Tween = TweenService:Create(Characters, Info, {Position = UDim2.new(0.5,0,0.518,0)})
		Tween:Play()
	else
		local Tween = TweenService:Create(Characters, Info, {Position = UDim2.new(-1,0,0.518,0)})
		Tween:Play()
	end
end

local function DisplaySettings(State)
	SettingsOpen = State
	
	local Info = TweenInfo.new(.5,Enum.EasingStyle.Linear,Enum.EasingDirection.Out)
	
	if State then
		local Tween = TweenService:Create(SettingsPage, Info, {Position = UDim2.new(0.5,0,0.5,0)})
		Tween:Play()
	else
		local Tween = TweenService:Create(SettingsPage, Info, {Position = UDim2.new(-1,0,0.5,0)})
		Tween:Play()
	end
end

local function DisplayProfile(State)
	ProfileOpen = State
	
	local Info = TweenInfo.new(.5,Enum.EasingStyle.Linear,Enum.EasingDirection.Out)
	
	if State then
		local Tween = TweenService:Create(ProfilePage, Info, {Position = UDim2.new(0.5,0,0.5,0)})
		Tween:Play()
	else
		local Tween = TweenService:Create(ProfilePage, Info, {Position = UDim2.new(-1,0,0.5,0)})
		Tween:Play()
	end
end

local function DisplayStore(State)
	StoreOpen = State
	
	local Info = TweenInfo.new(.5,Enum.EasingStyle.Linear,Enum.EasingDirection.Out)
	
	if State then
		local Tween = TweenService:Create(StorePage, Info, {Position = UDim2.new(0.5,0,0.5,0)})
		Tween:Play()
	else
		local Tween = TweenService:Create(StorePage, Info, {Position = UDim2.new(-1,0,0.5,0)})
		Tween:Play()
	end
end

UpdateHealth()
UpdateUltimate()

Humanoid.HealthChanged:Connect(UpdateHealth)
UltimatePoints:GetPropertyChangedSignal("Value"):Connect(UpdateUltimate)

--〔 Menu Button 〕--
MenuButton.MouseButton1Down:Connect(function()
	if not Debounce and not MenuOpen then
		Debounce = true
		DisplayMenu(true)
		DisplayCharacters(false)
		DisplaySettings(false)
		DisplayProfile(false)
		DisplayStore(false)
		
		task.delay(Cooldown, function()
			Debounce2 = false
		end)
	elseif Debounce and MenuOpen then
		DisplayMenu(false)
		
		task.delay(Cooldown, function()
			Debounce = false
		end)
	end
end)

--〔 Characters Button 〕--
CharactersButton.MouseButton1Down:Connect(function()
	if not Debounce2 and not CharactersOpen then
		Debounce2 = true
		DisplayCharacters(true)
		DisplayMenu(false)
		DisplaySettings(false)
		DisplayProfile(false)
		DisplayStore(false)
		
		task.delay(Cooldown, function()
			Debounce = false
		end)
	elseif Debounce2 and CharactersOpen then
		DisplayCharacters(false)
		
		task.delay(Cooldown, function()
			Debounce2 = false
		end)
	end
end)

ExitButton.MouseButton1Down:Connect(function()
	if Debounce2 and CharactersOpen then
		DisplayCharacters(false)
		
		task.delay(Cooldown, function()
			Debounce2 = false
		end)
	end
end)

--〔 Other Buttons 〕--
Settings.MouseButton1Down:Connect(function()
	if not SettingsOpen then
		DisplaySettings(true)
		DisplayMenu(false)
		
		task.delay(Cooldown, function()
			Debounce = false
		end)
	else
		DisplaySettings(false)
	end
end)

SettingsExit.MouseButton1Down:Connect(function()
	DisplaySettings(false)
end)

Profile.MouseButton1Down:Connect(function()
	if not ProfileOpen then
		DisplayProfile(true)
		DisplayMenu(false)
		
		task.delay(Cooldown, function()
			Debounce = false
		end)
	else
		DisplayProfile(false)
	end
end)

ProfileExit.MouseButton1Down:Connect(function()
	DisplayProfile(false)
end)

Store.MouseButton1Down:Connect(function()
	if not StoreOpen then
		DisplayStore(true)
		DisplayMenu(false)
		
		task.delay(Cooldown, function()
			Debounce = false
		end)
	else
		DisplayStore(false)
	end
end)

StoreExit.MouseButton1Down:Connect(function()
	DisplayStore(false)
end)

--〔 Cooldowns 〕--
ClientManager:GenerateEvent("CooldownFire",function(Data)
	local Slot = Data.Slot
	Slot = string.gsub(Slot, "Skill", "Ability")
	local Time = Data.Time
	local CooldownHold = Data.Hold
	
	if CooldownHold ~= nil then
		if CooldownHold == true then
			if Skills:FindFirstChild(Slot) then
				local SkillSlot = Skills:FindFirstChild(Slot):WaitForChild("Ability")
				
				if SkillSlot.TextColor3 == Color3.fromRGB(0, 170, 255) then
					SkillSlot.TextColor3 = Color3.fromRGB(255, 255, 255)
				end
				
				local Info = TweenInfo.new(.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out)
				local Tween = TweenService:Create(SkillSlot, Info, {TextColor3 = Color3.fromRGB(0, 170, 255)})
				Tween:Play()
			end
		elseif CooldownHold == false then
			if Skills:FindFirstChild(Slot) then
				local SkillSlot = Skills:FindFirstChild(Slot):WaitForChild("Ability")
				
				if SkillSlot.TextColor3 == Color3.fromRGB(0, 170, 255) then
					local Info = TweenInfo.new(.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out)
					local Tween = TweenService:Create(SkillSlot, Info, {TextColor3 = Color3.fromRGB(255, 255, 255)})
					Tween:Play()
				end
			end
		end
	else
		local Done = false
		local SkillName = ""
		
		if Skills:FindFirstChild(Slot) and Time and Time ~= 0 then
			local SkillSlot = Skills:FindFirstChild(Slot):WaitForChild("Ability")
			
			if SkillSlot.TextColor3 == Color3.fromRGB(0, 170, 255) then
				SkillSlot.TextColor3 = Color3.fromRGB(255, 255, 255)
			end
			
			local Info = TweenInfo.new(.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out)
			local Tween = TweenService:Create(SkillSlot, Info, {TextColor3 = Color3.fromRGB(255, 0, 0)})
			Tween:Play()
			
			local Connection; Connection = SkillSlot:GetPropertyChangedSignal("Text"):Connect(function()
				if tonumber(SkillSlot.Text) then return end
				
				Tween:Destroy()
				
				local Info = TweenInfo.new(.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out)
				local Tween = TweenService:Create(SkillSlot, Info, {TextColor3 = Color3.fromRGB(255, 255, 255)})
				Tween:Play()
				
				Done = true
				
				Connection:Disconnect()
				Connection = nil
			end)
			
			SkillName = SkillSlot.Text
			
			task.spawn(function()
				local Start = os.clock()
				local Current = Time
				
				local Split = string.split(Current, ".")
				
				SkillSlot.Text = Current
				
				while (os.clock() - Start) < Time do
					if Done then
						break
					else
						task.wait(0.1)
						
						if not Done then
							Current -= 0.1
							SkillSlot.Text = string.sub(Current, 1, #Split[1] + 2)
						end
					end
				end
			end)
			
			task.delay(Time, function()
				if Done then return end
				
				local Info = TweenInfo.new(.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out)
				local Tween = TweenService:Create(SkillSlot, Info, {TextColor3 = Color3.fromRGB(255, 255, 255)})
				Tween:Play()
				
				Done = true
				SkillSlot.Text = SkillName
			end)
		end
	end
end)

--〔 User Input 〕--
UserInputService.InputBegan:Connect(function(Input, GameProcessedEvent)
	if GameProcessedEvent then return end
	
	if Input.KeyCode == Enum.KeyCode.M then
		if not Debounce and not MenuOpen then
			Debounce = true
			DisplayMenu(true)
			DisplayCharacters(false)
			DisplaySettings(false)
			DisplayProfile(false)
			DisplayStore(false)
		elseif Debounce and MenuOpen then
			DisplayMenu(false)
			
			task.delay(Cooldown, function()
				Debounce = false
			end)
		end
	end
end)