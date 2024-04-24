local module = {}

for i,x in pairs(script:GetDescendants()) do
	if x:IsA("ModuleScript") and not x:FindFirstChild("DontImp") then
		local Mod = require(x)
		if type(Mod) == "table" then
			for index,func in pairs(Mod) do
				module[index] = func
			end
		elseif type(Mod) == "function" then
			module[x.Name] = Mod
		end
	end
end


return module
