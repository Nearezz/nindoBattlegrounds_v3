local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Mod = require(script.Actions)()

local ClientNetwork = {}
ClientNetwork.Key = HttpService:GenerateGUID()
ClientNetwork.Remotes = {}
ClientNetwork.LastFired = ""
ClientNetwork.LastFiredFunc = ""
ClientNetwork.Active = false

task.spawn(function()
	for Index, Remote in ipairs(ReplicatedStorage.Remotes:GetDescendants()) do
		if Remote:IsA("RemoteEvent") or Remote:IsA("RemoteFunction") then
			table.insert(ClientNetwork.Remotes, Remote)
		end
	end
end)

function ClientNetwork:Init()
	if not ClientNetwork.Active then
		ClientNetwork.Active = true
		
		for Index, Remote in ipairs(ClientNetwork.Remotes) do
			if Remote:IsA("RemoteEvent")  then
				Remote.OnClientEvent:Connect(function(ModuleData, TransferData)
					local Function = (type(Mod) == "table") and (type(Mod[ModuleData.FunctionName]) == "function")
					
					if Function then
						Mod[ModuleData.FunctionName](true, TransferData)
					end
				end)
			elseif Remote:IsA("RemoteFunction") then
				Remote.OnClientInvoke = function(ModuleData, TransferData)
					local Function = (type(Mod) == "table") and (type(Mod[ModuleData.FunctionName]) == "function")
					
					if Function then
						return Mod[ModuleData.FunctionName](true, TransferData)
					end
				end
			end
		end
	end
end

function ClientNetwork:FireServerEvent(ModuleData, TransferData)
	local Table = {}
	
	for Index, Remote in ipairs(ClientNetwork.Remotes) do
		if Remote:IsA("RemoteEvent") then
			table.insert(Table, Remote)
		end
	end
	
	for Index, Remote in ipairs(Table) do
		if Remote:IsA("RemoteEvent") then
			if Remote.Name == ClientNetwork.LastFired then
				table.remove(Table, Index)
			end
		end
	end
	
	local Remote = Table[math.random(1, #Table)]
	ClientNetwork.LastFired = Remote.Name
	Remote:FireServer(ModuleData, TransferData, ClientNetwork.Key)
end

function ClientNetwork:FireServerFunction(ModuleData, TransferData, Return)
	local Table = {}
	
	for Index, Remote in ipairs(ClientNetwork.Remotes) do
		if Remote:IsA("RemoteFunction") then
			table.insert(Table, Remote)
		end
	end
	
	for Index, Remote in ipairs(Table) do
		if Remote:IsA("RemoteFunction") then
			if Remote.Name == ClientNetwork.LastFiredFunc then
				table.remove(Table, Index)
			end
		end
	end
	
	local Remote = Table[math.random(1,#Table)]
	ClientNetwork.LastFiredFunc = Remote.Name
	
	if Return then
		return Remote:InvokeServer(ModuleData, TransferData, ClientNetwork.Key)
	else
		Remote:InvokeServer(ModuleData, TransferData)
	end
end

return ClientNetwork