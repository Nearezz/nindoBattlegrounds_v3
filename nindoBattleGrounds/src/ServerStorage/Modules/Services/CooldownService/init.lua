local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local SS2 = game:GetService("ServerScriptService")


local CooldownService = {}

CooldownService.Profiles = {
	
}

function CooldownService.GenerateProfile(Character)
	if CooldownService.Profiles[Character] then
		CooldownService.Profiles[Character] = nil
	end
	CooldownService.Profiles[Character] = {
		Cooldowns = require(script.Instance)()
	}
end

function CooldownService:RemoveProfile(Character)
	if CooldownService.Profiles[Character] then
		CooldownService.Profiles[Character] = nil
	end
end

function CooldownService:CheckCooldown(Character,CharID: string,SkillSlot: string)
	if not CooldownService.Profiles[Character] then return end
	local Profile = CooldownService.Profiles[Character]
	if not Profile.Cooldowns[CharID] and Profile.Cooldowns[CharID][SkillSlot] then return end
	
	if os.clock() - Profile.Cooldowns[CharID][SkillSlot].StartTime > Profile.Cooldowns[CharID][SkillSlot].Cooldown and Profile.Cooldowns[CharID][SkillSlot].HoldCooldown == false then
		return true
	else
		return nil
	end
end

function CooldownService:SetCooldown(Character,CharID: string,SkillSlot: string,Data)
	if not CooldownService.Profiles[Character] then return end
	local Profile = CooldownService.Profiles[Character]
	if not Profile.Cooldowns[CharID] and Profile.Cooldowns[CharID][SkillSlot] then return end
	local RemoteComs = require(RS.Modules.Utility.RemoteNetwork)
	
	if Data["Hold"] and Data.Hold == true then
		Profile.Cooldowns[CharID][SkillSlot].HoldCooldown = true
		RemoteComs:FireClientEvent(Players:GetPlayerFromCharacter(Character),{FunctionName = "CooldownSet"},{
			CooldownTime = 0,
			Hold = true,
			Slot = SkillSlot
		})
	elseif Data["Hold"] ~= nil and Data.Hold == false then
		Profile.Cooldowns[CharID][SkillSlot].HoldCooldown = false
		RemoteComs:FireClientEvent(Players:GetPlayerFromCharacter(Character),{FunctionName = "CooldownSet"},{
			CooldownTime = 0,
			Hold = false,
			Slot = SkillSlot
		})
	else
		Profile.Cooldowns[CharID][SkillSlot].Cooldown = Data.CD
		Profile.Cooldowns[CharID][SkillSlot].StartTime = os.clock()
		RemoteComs:FireClientEvent(Players:GetPlayerFromCharacter(Character),{FunctionName = "CooldownSet"},{
			CooldownTime = Data.CD,
			Slot = SkillSlot
		})
	end	
end

return CooldownService