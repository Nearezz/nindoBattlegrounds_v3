local RS = game:GetService("ReplicatedStorage")

local AnimationsFolder = RS:WaitForChild("Assets"):WaitForChild("Animations"):WaitForChild("Shared"):WaitForChild("Combat")

return {
	["AnimationTable"] = {
		["Hit1"] = AnimationsFolder.Melee_1,
		["Hit2"] = AnimationsFolder.Melee_2,
		["Hit3"] = AnimationsFolder.Melee_3,
		["Hit4"] = AnimationsFolder.Melee_4,
		["Hit5"] = AnimationsFolder.Melee_5,
		["Hit1CL"] = 0.22,
		["Hit2CL"] = 0.22,
		["Hit3CL"] = 0.22,
		["Hit4CL"] = 0.22,
		["Hit5CL"] = 0.22,
		["AirCL"] = 0.35,
		["AirCL2"] = 0.25,
		["BlockingAnim"] = AnimationsFolder.Melee_Block,
	},
	["StunTimes"] = {
		[1] = .75,
		[2] = .75,
		[3] = .75,
		[4] = .75,
		[5] = .75,
	},
	["Damage"] = {
		["Reg"] = 2,
		["Kb"] = 3,
		["Downslam"] = 3,
	},
	["HitBoxData"] = {
		Size = Vector3.new(6,7,6),
		Offset = CFrame.new(0,0,-4)
	},
}