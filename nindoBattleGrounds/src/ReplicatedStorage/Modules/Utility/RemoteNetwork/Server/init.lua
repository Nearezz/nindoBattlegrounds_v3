local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Mod = require(script.Actions)()

local ServerNetwork = {}
ServerNetwork.Key = HttpService:GenerateGUID()
ServerNetwork.Remotes = {}
ServerNetwork.LastFired = ""
ServerNetwork.LastFiredFunc = ""
ServerNetwork.Active = false

task.spawn(function()
	for Index, Remote in ipairs(ReplicatedStorage.Remotes:GetDescendants()) do
		if Remote:IsA("RemoteEvent") or Remote:IsA("RemoteFunction") then
			table.insert(ServerNetwork.Remotes, Remote)
		end
	end
end)

function ServerNetwork:Init()
	if not ServerNetwork.Active then
		ServerNetwork.Active = true
		
		for Index, Remote in ipairs(ServerNetwork.Remotes) do
			if Remote:IsA("RemoteEvent") then
				Remote.OnServerEvent:Connect(function(Player, ModuleData, TransferData)
					local Function = (type(Mod) == "table") and (type(Mod[ModuleData.FunctionName]) == "function")
					
					if Function then
						Mod[ModuleData.FunctionName](true, Player, TransferData)
					end
				end)
			elseif Remote:IsA("RemoteFunction") then
				Remote.OnServerInvoke = function(Player, ModuleData, TransferData)
					local Function = (type(Mod) == "table") and (type(Mod[ModuleData.FunctionName]) == "function")
					
					if Function then
						return Mod[ModuleData.FunctionName](true, Player, TransferData)
					end
				end
			end
		end
	end
end

function ServerNetwork:FireClientEvent(Player, ModuleData, TransferData)
	if not Player then return end
	
	local Table = {}
	
	for Index, Remote in ipairs(ServerNetwork.Remotes) do
		if Remote:IsA("RemoteEvent")  then
			table.insert(Table, Remote)
		end
	end
	
	for Index, Remote in ipairs(Table) do
		if Remote:IsA("RemoteEvent")  then
			if Remote.Name == ServerNetwork.LastFired then
				table.remove(Table, Index)
			end
		end
	end
	
	local Remote = Table[math.random(1, #Table)]
	ServerNetwork.LastFired = Remote.Name
	Remote:FireClient(Player, ModuleData, TransferData, ServerNetwork.Key)
end

function ServerNetwork:FireClientsInRange(ModuleData, TransferData, Point, Range)
	for Index, Entity in ipairs(workspace.World.Entities:GetChildren()) do
		if Players:GetPlayerFromCharacter(Entity) then
			if Entity.PrimaryPart then
				local Dist = (Point - Entity.HumanoidRootPart.Position).Magnitude
				
				if Dist <= Range then
					local Player = Players:GetPlayerFromCharacter(Entity)
					local Table = {}
					
					for Index, Remote in ipairs(ServerNetwork.Remotes) do
						if Remote:IsA("RemoteEvent")  then
							table.insert(Table, Remote)
						end
					end
					
					for Index, Remote in ipairs(Table) do
						if Remote:IsA("RemoteEvent")  then
							if Remote.Name == ServerNetwork.LastFired then
								table.remove(Table, Index)
							end
						end
					end
					
					local Remote = Table[math.random(1, #Table)]
					ServerNetwork.LastFired = Remote.Name
					Remote:FireClient(Player, ModuleData,TransferData, ServerNetwork.Key)
				end
			end
		end
	end
end

function ServerNetwork:FireAllClientsEvent(ModuleData,TransferData)
	local Table = {}
	
	for Index, Remote in ipairs(ServerNetwork.Remotes) do
		if Remote:IsA("RemoteEvent")  then
			table.insert(Table, Remote)
		end
	end
	
	for Index, Remote in ipairs(Table) do
		if Remote:IsA("RemoteEvent")  then
			if Remote.Name == ServerNetwork.LastFired then
				table.remove(Table, Index)
			end
		end
	end
	
	local Remote = Table[math.random(1, #Table)]
	ServerNetwork.LastFired = Remote.Name
	Remote:FireAllClients(ModuleData, TransferData, ServerNetwork.Key)
end

function ServerNetwork:FireClientFunction(Player, ModuleData, TransferData, Return)
	local Table = {}
	
	for Index, Remote in ipairs(ServerNetwork.Remotes) do
		if Remote:IsA("RemoteFunction")  then
			table.insert(Table, Remote)
		end
	end
	
	for Index, Remote in ipairs(Table) do
		if Remote:IsA("RemoteFunction")  then
			if Remote.Name == ServerNetwork.LastFiredFunc then
				table.remove(Table, Index)
			end
		end
	end
	
	local Remote = Table[math.random(1, #Table)]
	ServerNetwork.LastFiredFunc = Remote.Name
	
	if Return then
		return Remote:InvokeClient(Player, ModuleData, TransferData, ServerNetwork.Key)
	else
		Remote:InvokeClient(Player, ModuleData,TransferData)
	end
end

return ServerNetwork