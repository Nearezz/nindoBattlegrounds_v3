local RunService = game:GetService("RunService")
local Players =  game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")

return {
	ID = "OldZabuza",
	M1Data = require(SS.Modules.MetaData.M1SwordCharData),
	DisplayName = "Zabuza",
	Desc = [[
		When you've hovered between life and death so many times that it doesn't faze you, you may be called a ninja.
	]],
	Cost = 1000,
	SkillData = {
		UltPointsRequired = 4,
		FirstSkill = {
			Cooldown = 15,
			Damage = 1,
			Stun = 1.25,
			Points = 1,
			Name = 'Water Bullet',
			--Custom Data For the Skill
			Duration = 3,
			AOEDamage = 5,
			WaterSpeed = 150,
			WaterAcceleration = 10, -- Studs/s^2
		},
		SecondSkill = {
			Cooldown = 10,
			Damage = 4.5, -- Per Shuriken Total Damage is 13.5
			Stun = 1.25,
			Points = 2, 
			Name = 'Hidden Mist',
			--Custom Data For the Skill
			Speed = 250,
			Acceleration = 40,
			Duration = 4,
		},
		ThirdSkill = {
			Cooldown = 20,
			Damage = 20,
			Stun = 1,
			Points = 15,
			Name = 'Striking Stab',
		},
		FourthSkill = {
			Cooldown = 20,
			Damage = 5,
			Stun = 1,
			Points = 15,
			Name = 'Water Clone',

			Length = 10,
		},
		Ultimate = {
			Damage = 120,
			Stun = 3,
			Points = 0,
			Name = 'ChidoriUltNAme',

			--Custom Data For the Skill
			MaxRange = 100,

		}
	},
}
