local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local Interface = script.Parent.Parent
local Frame = script.Parent
local Counter = script.Parent:WaitForChild("Hits")
local Bar = Frame.BarShadow.Bar

local timeLength = 2
local visible = false
local current = "Number"
local upPos = UDim2.fromScale(0.5, -0.4)
local mainPos = UDim2.fromScale(0.5, 0.6)
local downPos = UDim2.fromScale(0.5, 1.4)

local visibilityTween = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local sizeReverseTween = TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true)
local rollOut = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local rollIn = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local last = os.clock()

Interface.Enabled = true

local function makeVisible()
	for _, UI in ipairs(Frame:GetDescendants()) do
		if UI:IsA("ImageLabel") then
			if UI.Name == "BarShadow" then
				TweenService:Create(UI, visibilityTween, {
					BackgroundTransparency = 0.3
				}):Play()
			else
				TweenService:Create(UI, visibilityTween, {
					BackgroundTransparency = 0
				}):Play()
			end
		elseif UI:IsA("TextLabel") then
			TweenService:Create(UI, visibilityTween, {
				TextTransparency = 0,
			}):Play()
		end
	end
end

local function makeInvisible()
	for _, UI in ipairs(Frame:GetDescendants()) do
		if UI:IsA("ImageLabel") then
			if UI.Name == "BarShadow" then
				TweenService:Create(UI, visibilityTween, {
					BackgroundTransparency = 1
				}):Play()
			else
				TweenService:Create(UI, visibilityTween, {
					BackgroundTransparency = 1
				}):Play()
			end
		elseif UI:IsA("TextLabel") then
			TweenService:Create(UI, visibilityTween, {
				TextTransparency = 1,
				TextStrokeTransparency = 1,
			}):Play()
		end
	end
end

local function sizeBounce()
	TweenService:Create(Frame, sizeReverseTween, {
		Size = UDim2.fromScale(0.18, 0.24)
	}):Play()
end

local function rollTo(newNumber)
	if current == "Number" then
		local otherNumber = Frame["Number2"]
		local currentNumber = Frame["Number"]
		
		otherNumber.Text = newNumber
		
		TweenService:Create(otherNumber, rollIn, {
			Position = mainPos
		}):Play()
		TweenService:Create(currentNumber, rollOut, {
			Position = downPos
		}):Play()
		
		current = "Number2"
		
		task.delay(0.4, function()
			currentNumber.Position = upPos
		end)
	else
		local otherNumber = Frame["Number"]
		local currentNumber = Frame["Number2"]
		
		otherNumber.Text = newNumber

		TweenService:Create(otherNumber, rollIn, {
			Position = mainPos
		}):Play()
		TweenService:Create(currentNumber, rollOut, {
			Position = downPos
		}):Play()

		current = "Number"

		task.delay(0.4, function()
			currentNumber.Position = upPos
		end)
	end
end

local function randomizePosition()
	local randomFactorX = math.random(20,35)/100
	local randomFactorY = math.random(40,60)/100
	Frame.Position = UDim2.fromScale(randomFactorX, randomFactorY)
end

function Changed(newNumber)
	task.wait(.1)
	if os.clock() - last <= .1 then
		Frame["Number"].Text = newNumber-1 > 0 and newNumber-1 or 0
		Frame["Number2"].Text = newNumber
		return
	end
	
	last = os.clock()
	
	if newNumber == 0 then
		makeInvisible()
		rollTo("0")
		visible = false
	else
		if not visible then
			sizeBounce()
			makeVisible()
			visible = true
		end
		rollTo(newNumber)
		randomizePosition()
		Bar.Size = UDim2.fromScale(1,1)
		Bar:TweenSize(UDim2.fromScale(0,1), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, timeLength, true)
		
		task.delay(timeLength, function()
			if Bar.Size == UDim2.fromScale(0,1) then
				makeInvisible()
				rollTo("0")
				visible = false
			end
		end)
	end
end

makeInvisible()
Counter.Changed:Connect(Changed)