--Bezier and I really locked in fr yall dont know

local RunService = game:GetService("RunService")

local Eqs = {}
for _, module:ModuleScript in pairs(script:GetChildren()) do
    Eqs[module.Name] = require(module)
end

local ScheduleInfo:{[number]:{Eq:string, Callback:(CFrame | Vector3?, CFrame | Vector3?) -> nil?, Start:number, Duration:number, Points:{[number]:CFrame | Vector3?}}} = {}

local CurrentTime
local function Run()
    if #ScheduleInfo == 0 then RunService:UnbindFromRenderStep("SarinBezier") end
    CurrentTime = os.clock()
    for i, v in next, ScheduleInfo do
        if v.Callback(Eqs[v.Eq]((CurrentTime - v.Start)/v.Duration, unpack(v.Points)), Eqs[v.Eq]((CurrentTime - v.Start)/v.Duration + 1/60, unpack(v.Points))) or (CurrentTime - v.Start)/v.Duration >= 1 then
            table.remove(ScheduleInfo, i)
        end
    end
end

return function(Eq:string, Callback:(CFrame | Vector3?, CFrame | Vector3?) -> nil?, Duration:number, ...) -- ... is the points
    ScheduleInfo[#ScheduleInfo+1] = {Eq = Eq, Callback = Callback, Start = os.clock(), Duration = Duration, Points = {...}}
    if #ScheduleInfo == 1 then
        RunService:BindToRenderStep("SarinBezier", Enum.RenderPriority.Last.Value, Run)
    end
end