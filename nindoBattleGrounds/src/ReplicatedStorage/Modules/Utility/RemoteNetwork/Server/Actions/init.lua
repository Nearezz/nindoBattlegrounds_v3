local Actions = require(game.ReplicatedStorage.Modules.Utility.Object):extend()

function Actions:new()
	for i,x in ipairs(script:GetDescendants()) do
		if x:IsA("ModuleScript") then
			self:implement(require(x))
		end
	end
end

return Actions