local ServerScriptService = game:GetService("ServerScriptService")
local libFinder = require(ServerScriptService:WaitForChild("Finders",2):WaitForChild("LibFinder",2))

local rq = libFinder:FindLib("rquery")

local utility = {}

function utility:GetIdleState(StateMachine)
	local IdleState = StateMachine.NewState()
	IdleState.Name = "Idle"
	IdleState.Action = function() end
	IdleState.Init = function() end
	return IdleState
end

return utility