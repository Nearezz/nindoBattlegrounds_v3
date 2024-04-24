local RunService = game:GetService("RunService")
local Players =  game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")

return {
	ID = "OldKakashi",
	M1Data = require(SS.Modules.MetaData.M1DefaultCharData),
	DisplayName = "(Pre Ship) Kakashi",
	Desc = [[
		Every day, I eat, I sleep, I worry about stupid things. My job is to make sure these kids have as many days as they can where they can be idiots like this.
	]],
	Cost = 500,
	SkillData = {
		UltPointsRequired = 300,
		FirstSkill = {
			Cooldown = 15,
			Damage = 15,
			Stun = .85,
			Points = 15,
			Name = 'Fireball',
			--Custom Data For the Skill
			Duration = 3.5,
			AOEDamage = 10,
			FireballSpeed = 200,
			FireballAcceleration = 20, -- Studs/s^2
		},
		SecondSkill = {
			Cooldown = 12,
			Damage = 5, -- Per Shuriken Total Damage is 13.5
			Stun = .75,
			Points = 2,
			Name = 'Shurikens',
			--Custom Data For the Skill
			Speed = 250,
			Acceleration = 40,
			Duration = 3,
		},
		ThirdSkill = {
			Cooldown = 20,
			Damage = 10,
			Stun = 1,
			Points = 15,
			Name = 'Earth Wall',
		},
		FourthSkill = {
			Cooldown = 20,
			Damage = 20,
			Stun = .75,
			Points = 15,
			--Custom Data For the Skill
			Length = 8,
			SpeedBoost = 45,
			
			Name = 'Chidori',
		},
		Ultimate = {
			Damage = 100,
			Stun = 3,
			Points = 0,
			Name = 'ChidoriUltNAme',
			
			--Custom Data For the Skill
			MaxRange = 100,
		}
	},
}
