local ServerScriptService = game:GetService("ServerScriptService")
local libFinder = require(ServerScriptService:WaitForChild("Finders",2):WaitForChild("LibFinder",2))

local rq = libFinder:FindLib("rquery")

local npcAiProto = {}

local npcAiMeta = { __index = npcAiProto }

function npcAiProto.GetIdleState(StateMachine)
	local IdleState = StateMachine.NewState()
	IdleState.Name = "Idle"
	IdleState.Action = function() end
	IdleState.Init = function() end
	return IdleState
end

local aiBaseModule = {}

function aiBaseModule.new()
    local npcAiInstance = setmetatable({}, npcAiMeta)
    return npcAiInstance
end

return aiBaseModule