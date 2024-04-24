local l__LocalPlayer__1 = game.Players.LocalPlayer;
while true do
	wait();
	if l__LocalPlayer__1.Character then
		break;
	end;
end;
local u1 = l__LocalPlayer__1.Character;
local l__Bar__2 = script.Parent:WaitForChild("Bar");
local l__HP__3 = script.Parent:WaitForChild("HP");
local u4 = nil;
local function u5()
	local l__Humanoid__2 = u1:WaitForChild("Humanoid");
	l__Bar__2:TweenSize(UDim2.new(l__Humanoid__2.Health / l__Humanoid__2.MaxHealth, 0, 1, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quint, 0.1, true);
	l__HP__3.Text = l__Humanoid__2.Health .. "/" .. l__Humanoid__2.MaxHealth .. "";
	if l__Humanoid__2.Health == 0 then
		l__Bar__2.Visible = false;
		return;
	end;
	l__Bar__2.Visible = true;
end;
local u6 = nil;
local function u7()
	local l__Humanoid__3 = u1:WaitForChild("Humanoid");
	u4 = l__Humanoid__3:GetPropertyChangedSignal("Health"):Connect(u5);
	u6 = l__Humanoid__3:GetPropertyChangedSignal("MaxHealth"):Connect(u5);
	u5();
end;
l__LocalPlayer__1.CharacterAdded:Connect(function(p1)
	u1 = p1;
	if u4 then
		u4:Disconnect();
	end;
	if u6 then
		u6:Disconnect();
	end;
	u7();
end);
u7();
