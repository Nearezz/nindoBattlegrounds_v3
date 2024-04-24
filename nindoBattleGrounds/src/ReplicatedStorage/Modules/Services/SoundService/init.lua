local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local SS2 = game:GetService("ServerScriptService")
local HTTPService = game:GetService("HttpService")
local Debris = game:GetService("Debris")

local ContentProvider = game:GetService("ContentProvider")

local SoundService = {
	LoadedSounds = {},
	QueuedSongs = {},	
}

if RunService:IsClient() then
	
	function SoundService:PlaySound(SoundName: string, SoundProperties,CustomData)
		require(script.PlaySound)(SoundService.LoadedSounds,SoundName,SoundProperties,CustomData)
	end
	
	function SoundService:PlaySoundAt(SoundName: string, SoundProperties,CustomData)
		require(script.PlaySoundAt)(SoundService.LoadedSounds,SoundName,SoundProperties,CustomData)
	end
	
	function SoundService:StopSound(SoundName: string, SoundProperties,CustomData)
		if not SoundService.LoadedSounds[SoundName] then warn(SoundName.." Does Not Extist or is Bugged") return end
		if not SoundProperties.Parent then return end
		for _,Object in ipairs(SoundProperties.Parent:GetDescendants()) do
			if Object:IsA("Sound") and Object.Name == SoundName then
				local Sound = Object
				Sound:Stop()
				Sound:Destroy()
			end
		end	
	end
	
	function SoundService:StopSoundAt(SoundName: string, SoundProperties,CustomData)
		if not SoundService.LoadedSounds[SoundName] then warn(SoundName.." Does Not Extist or is Bugged") return end
		for _,Object in ipairs(workspace.World.SFX:GetDescendants()) do
			if Object:IsA("Sound") and Object.Name == SoundName then
				local Sound = Object
				Sound:Stop()
				Sound:Destroy()
			end
		end	
	end
	
	function SoundService:QueueSong(SongName: string)

	end

	function SoundService:RemoveQueueSong(SongName: string)

	end

	function SoundService:ClearQueueSong(SongName: string)

	end
	
elseif RunService:IsServer() then
	
	local function GetPlayers(Origin,Radius)
		local Table = {}
		local PlayerList = Players:GetPlayers()

		for _,Player in ipairs(PlayerList) do
			local Character = Player.Character;
			if Character and Character:FindFirstChild("HumanoidRootPart") then
				local RootPart = Character.PrimaryPart;

				if (RootPart.Position - Origin).Magnitude <= Radius then
					Table[#Table + 1] = Player
				end
			end
		end
		return Table
	end
	
	function SoundService:PlaySound(SoundName: string, SoundProperties,CustomData,remoteSettings)
		local RemoteComs = require(RS.Modules.Utility.RemoteNetwork)
		if not remoteSettings.Range or not remoteSettings.Origin then return end	
		for _,Player in ipairs(GetPlayers(remoteSettings.Origin,remoteSettings.Range)) do
			RemoteComs:FireClientEvent(Player,{FunctionName = "PlaySound"},{SoundName = SoundName,SoundProperties = SoundProperties,CustomData = CustomData})
		end
	end
	
	function SoundService:PlaySoundAt(SoundName: string, SoundProperties,CustomData,remoteSettings,player)
		local RemoteComs = require(RS.Modules.Utility.RemoteNetwork)
		if not remoteSettings.Range or not remoteSettings.Origin then return end	
		for _,Player in ipairs(GetPlayers(remoteSettings.Origin,remoteSettings.Range)) do
			RemoteComs:FireClientEvent(Player,{FunctionName = "PlaySoundAt"},{SoundName = SoundName,SoundProperties = SoundProperties,CustomData = CustomData})
		end
	end
	
	function SoundService:StopSound(SoundName: string, SoundProperties,CustomData,remoteSettings)
		local RemoteComs = require(RS.Modules.Utility.RemoteNetwork)
		if not remoteSettings.Range or not remoteSettings.Origin then return end	
		for _,Player in ipairs(GetPlayers(remoteSettings.Origin,remoteSettings.Range)) do
			RemoteComs:FireClientEvent(Player,{FunctionName = "StopSound"},{SoundName = SoundName,SoundProperties = SoundProperties,CustomData = CustomData})
		end
	end

	function SoundService:StopSoundAt(SoundName: string, SoundProperties,CustomData,remoteSettings,player)
		local RemoteComs = require(RS.Modules.Utility.RemoteNetwork)
		if not remoteSettings.Range or not remoteSettings.Origin then return end	
		for _,Player in ipairs(GetPlayers(remoteSettings.Origin,remoteSettings.Range)) do
			RemoteComs:FireClientEvent(Player,{FunctionName = "StopSoundAt"},{SoundName = SoundName,SoundProperties = SoundProperties,CustomData = CustomData})
		end
	end
	
	function SoundService:QueueSong(SongName: string)

	end

	function SoundService:RemoveQueueSong(SongName: string)

	end

	function SoundService:ClearQueueSong(SongName: string)

	end

end

local AllSounds = RS.Assets.Sounds:GetDescendants()

for _,Sound in ipairs(AllSounds) do
	if Sound:IsA("Sound") then
		SoundService.LoadedSounds[Sound.Name] = Sound
	end
end

task.spawn(function()
	ContentProvider:PreloadAsync(AllSounds)
	warn("Loaded Sounds")
end)

return SoundService
