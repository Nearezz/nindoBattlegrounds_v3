local RunService = game:GetService("RunService")
local Players =  game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")

return {
	ID = "KidSasuke",
	M1Data = require(SS.Modules.MetaData.M1DefaultCharData),
	DisplayName = "Kid Sasuke",
	Desc = [[
		NARUTOOOOOOO!!!!!
	]],
	Cost = 350,
	SkillData = {
		UltPointsRequired = 200,
		FirstSkill = {
			Cooldown = 12,
			Damage = 12,
			Stun = .5,
			Points = 15,
			Name = 'Chidori',
			
			--Custom Data For the Skill
			Length = 8,
			SpeedBoost = 45,
		},
		SecondSkill = {
			Cooldown = 20,
			Damage = 15,
			Stun = .75,
			Points = 15,
			Name = 'Fireball',
			
			--Custom Data For the Skill
			Duration = 3.5,
			AOEDamage = 10,
			FireballSpeed = 200,
			FireballAcceleration = 20, -- Studs/s^2
		},
		ThirdSkill = {
			Cooldown = 30,
			Damage = 15,
			Stun = 1.5,
			
			Range = 15,
			Points = 20,
			
			Name = 'Lion Combo',
			
			Duration = 3,
			EndLag = 1.5,
			SpeedFactor = 2,
		},
		FourthSkill = {
			Cooldown = 20,
			Damage = 2,
			Stun = .75,
			
			Points = 5,
			
			Name = 'Demon Shirkun',
			
			Duration = 3,
			ShurikenSpeed = 150,
			
			KDamage = 2,
			KStun = .75,
			KDuration = 1.5,
			KunaiSpeed = 200,
		},
		Ultimate = {
			Cooldown = 20,
			Damage = 2, -- Per Tick
			TickRate = .2,
			
			HitboxSize = Vector3.new(45,10,45),
			
			Stun = 1,
			Points = 1,
			Name = 'Chidori Stream',
		}
	},
}