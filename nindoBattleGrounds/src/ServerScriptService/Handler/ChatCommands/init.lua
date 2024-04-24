local Commands = {}
local Users = {
	488190704, -- Taida
	397463373, -- Near
	3312005827, -- Near #2
}

task.spawn(function()
	for Index, Module in ipairs(script:GetDescendants()) do
		if Module:IsA("ModuleScript") then
			Commands[Module.Name] = require(Module)
		end
	end
end)

return function(Type)
	if Type == "GetPrefix" then
		return "/"
	elseif Type == "GetCommands" then
		return Commands
	elseif Type == "GetUsers" then
		return Users
	end
end