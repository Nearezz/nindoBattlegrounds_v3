return {
	["ShadowClone"] = {
		Type = "CustomState",
		Value = false,
	},
	["RunID"] = {
		Type = "CustomState",
		Name = "DfRun"
	},
	["NejiUlt"] = {
		Bool = false,
		Type = "Boolean",
	},
	["ZabuzaUlt"] = {
		Bool = false,
		Type = "Boolean",
	},
	["Guardbroken"] = {
		Type = "NumberValue",
		
		
		StartTime = os.clock(),
		Duration =  0,
	},
	["Dashing"] = {
		Type = "NumberValue",


		StartTime = os.clock(),
		Duration =  0,
	},
	["IFrame"] = {
		Type = "UniqueNumberValue",
		StartTime = os.clock(),
		Duration = 0,
		LastPriority = 0,
	},
	["JumpCooldown"] = {
		Type = "UniqueNumberValue",
		StartTime = os.clock(),
		Duration = 0,
		LastPriority = 0,
	},
	["LandStun"] = {
		Type = "UniqueNumberValue",
		StartTime = os.clock(),
		Duration = 0,
		LastPriority = 0,
	},
	["DoubleJump"] = {
		Type = "UniqueNumberValue",
		StartTime = os.clock(),
		Duration = 0,
		LastPriority = 0,
	},
	["Counter"] = {
		Type = "UniqueNumberValue",
		StartTime = os.clock(),
		Duration = 0,
		LastPriority = 0,
		
		CounterID = "",
		Projectiles = false,
		ProjectilesOnly = false,
		Range = 5,
	},
	["Attacking"] = {
		Type = "NumberValue",


		StartTime = os.clock(),
		Duration =  0,
		
		
		CanUse = {}
	},
	["Blocking"] = {
		Type = "UniqueBoolean",


		Bool = false,
		MaxBar = 30,
		Bar = 30,
		
		LastRegenTick = os.clock(),
		


		CanUse = {}
	},
	["Running"] = {
		Bool = false,
		Type = "Boolean",
	},
	["Stunned"] = {
		Type = "UniqueNumberValue",
		StartTime = os.clock(),
		Duration = 0,
		LastPriority = 0,
	},
	["CanJump"] = {
		Type = "UniqueNumberValue",
		StartTime = os.clock(),
		Duration = 0,
		LastPriority = 0,
	},
	["PerfectBlock"] = {
		Type = "UniqueNumberValue",
		StartTime = os.clock(),
		Duration = 0,
		LastPriority = 0,
		CD = 0,
		AllOn = false,
		CDTick = os.clock(),
	},
	["CantRun"] = {
		Type = "UniqueNumberValue",
		StartTime = os.clock(),
		Duration = 0,
		LastPriority = 0,
	},
	["CantDash"] = {
		Type = "UniqueNumberValue",
		StartTime = os.clock(),
		Duration = 0,
		LastPriority = 0,
	},
	["CantBlock"] = {
		Type = "UniqueNumberValue",
		StartTime = os.clock(),
		Duration = 0,
		LastPriority = 0,
	},
	["CantM1"] = {
		Type = "UniqueNumberValue",
		StartTime = os.clock(),
		Duration = 0,
		LastPriority = 0,
	},
	["M1Cooldown"] = {
		Type = "UniqueNumberValue",
		StartTime = os.clock(),
		Duration = 0,
		LastPriority = 0,
	},
	["Swing"] = {
		Type = "UniqueNumberValue",
		StartTime = os.clock(),
		Duration = 0,
		LastPriority = 0,
	},
	["UsingSkill"] = {
		Type = "UniqueNumberValue",
		StartTime = os.clock(),
		Duration = 0,
		LastPriority = 0,
	},
	["DashCooldown"] = {
		Type = "UniqueNumberValue",
		StartTime = os.clock(),
		Duration = 0,
		LastPriority = 0,
	},
	["BlockCooldown"] = {
		Type = "UniqueNumberValue",
		StartTime = os.clock(),
		Duration = 0,
		LastPriority = 0,
	},
	["M1Count"] = {
		Type = "SPNumberValue",
		Count = 1,
	},
	["LastAttacker"] = {
		Type = "CustomState",
		LastAttackTime = os.clock(),
		LastAttackMove = "",
		LastAttacker = "None",
	},
	["AirCombo"] = {
		Bool = false,
		HitConnect = false,
	},
}