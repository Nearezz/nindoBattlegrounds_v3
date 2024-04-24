local ProfileService = require(script.ProfileService)
local Players = game:GetService("Players") 

local DataManager = {}

DataManager.Profiles = {}

local Key = "DataKey#0.002"
--local Key = "Testing#0.002"

local DefaultData = require(script.DefaultData)
DataManager.ProfileStore = ProfileService.GetProfileStore(Key,DefaultData)

function DataManager:UpdateDataVersion(Player)
	DataManager.Profiles[Player].Data.DataVersion = DefaultData.DataVersion
end

function DataManager:PlayerAdded(Player)
	local ID = "Player"..Player.UserId
	local profile = DataManager.ProfileStore:LoadProfileAsync(ID,"ForceLoad")
	
	if profile then
		profile:ListenToRelease(function()
			DataManager.Profiles[Player] = nil
			Player:Kick()
		end)

		if Player:IsDescendantOf(Players) then
			DataManager.Profiles[Player] = profile
			
			local Data = DataManager.Profiles[Player].Data
			
			if Data.DataVersion ~= DefaultData.DataVersion then
				DataManager:UpdateDataVersion(Player)
			end
		else
			profile:Release()
		end
	else
		Player:Kick("You dont got data bozo")
	end
end

function DataManager:PlayerRemoved(player)
	local profile = DataManager.Profiles[player]
	
	if profile then
		profile:Release()
	end
end

function DataManager:GetData(player)
	if not DataManager.Profiles[player] then
		warn(player.Name.."s Data has not been loaded yet. Please wait.")
		
		while not DataManager.Profiles[player] do
			task.wait()
		end
	end
	
	return DataManager.Profiles[player].Data
end

return DataManager