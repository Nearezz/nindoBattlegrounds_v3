local RunService = game:GetService("RunService")
local Players =  game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")

return {
	ID = "KidNaruto",
	M1Data = require(SS.Modules.MetaData.M1DefaultCharData),
	DisplayName = "Kid Naruto",
	Desc = [[
		And my future dream is to be the greatest Hokage!
		Then the whole village will stop disrespecting me and start treating me like I'm somebody. 
		Somebody important!
	]],
	Cost = 0,
	SkillData = {
		UltPointsRequired = 150,
		FirstSkill = {
			Cooldown = 10,
			Damage = 15,
			Stun = 1,
			Points = 15,
			Name = 'Rasangun',
			-----
			ChargeTime = 1,
			SpeedBoost = 45,
			Length = 8,
		},
		SecondSkill = {
			Cooldown = 5,
			Damage = 5,
			Stun = .75,
			Points = 15,
			Name = 'Shadow Clone',
			
			Length = 5,
		},
		ThirdSkill = {
			Cooldown = 20,
			Damage = 20,
			Stun = 1.5,
			Points = 10,
			Name = 'Uzumaki Combo',
			
			GrabHitBox = Vector3.new(3.5,3.5,5.5),
		},
		FourthSkill = {
			Cooldown = 25,
			Damage = 20,
			Stun = 2,
			Points = 25,
			Name = 'Transform',
			
			Range = 25,
		},
		Ultimate = {
			Cooldown = 20,
			Damage = 60,
			Stun = 1.5,
			Points = 50,
			Name = 'Odama Rasangun',
			
			ChargeTime = 1,
			SpeedBoost = 55,
			Length = 8,
		}
	},
}