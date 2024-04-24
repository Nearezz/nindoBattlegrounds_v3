local RunService = game:GetService("RunService")
local Players =  game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")

return {
	ID = "KidNeji",
	M1Data = require(SS.Modules.MetaData.M1DefaultCharData),
	DisplayName = "Kid Neji",
	Desc = [[
		Even if my enemy is far stronger, even if my body should fail me, 
		I cannot lose, there is a reason I cannot lose… …I was always known as a genius so I cannot lose. 
		Especially for the sake of those who believed I was a genius being my weak and powerless self
	]],
	Cost = 0,
	SkillData = {
		UltPointsRequired = 250,
		FirstSkill = {
			Cooldown = 15,
			Damage = .2,
			Stun = 1.25,
			Points = 1,
			Name = 'Revolving Heaven',
			
			--Custom Data
			TickRate = .025,
			HitboxSize = Vector3.new(15,15,15),
		},
		SecondSkill = {
			Cooldown = 15,
			Damage = .75,
			Stun = 1,
			Points = 0.25,
			Name = 'Eight Trigrams Sixty-Four Palms',
			
			PalmRange = 12,
			Rate = 0.1,
		},
		ThirdSkill = {
			Cooldown = 12,
			Damage = 15,
			Stun = .5,
			Points = 15,
			Name = 'Explosive Kunai',
			
			AoeDamage = 5,
			Speed = 150,
			Acceleration = 60,
			Duration = 4,
			HitboxSize = Vector3.new(17,17,17),
			
			SpeedUlt = 200,
			AccelerationUlt = 80,
			DurationUlt = 5.5,
		},
		FourthSkill = {
			Cooldown = 20,
			Damage = 25,
			Stun = 1.5,
			Points = 15,
			Name = 'Gentle Fist: Shōtei',
		},
		Ultimate = {
			Cooldown = 20,
			Damage = 20,
			Stun = 1,
			Points = 15,
			Name = 'Byakgun',
		}
	},
}