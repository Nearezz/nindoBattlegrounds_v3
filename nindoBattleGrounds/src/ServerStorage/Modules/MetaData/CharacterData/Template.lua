local RunService = game:GetService("RunService")
local Players =  game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")

return {
	ID = "KidSasuke",
	M1Data = require(SS.Modules.MetaData.M1DefaultCharData),
	DisplayName = "Kid Sasuke",
	Desc = [[
		NARRRRRUTTTTTOOOOOOOOOOOOOOO
	]],
	Cost = 300,
	SkillData = {
		UltPointsRequired = 400,
		FirstSkill = {
			Cooldown = 5,
			Damage = 20,
			Stun = 1,
			Points = 15,
			Name = 'Fireball',
		},
		SecondSkill = {
			Cooldown = 20,
			Damage = 20,
			Stun = 1,
			Points = 15,
			Name = 'Chidori',
		},
		ThirdSkill = {
			Cooldown = 20,
			Damage = 20,
			Stun = 1,
			Points = 15,
			Name = 'Chidori',
		},
		FourthSkill = {
			Cooldown = 20,
			Damage = 20,
			Stun = 1,
			Points = 15,
			Name = 'Chidori',
		},
		Ultimate = {
			Cooldown = 20,
			Damage = 20,
			Stun = 1,
			Points = 15,
			Name = 'Chidori',
		}
	},
}