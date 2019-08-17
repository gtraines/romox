local ServerScriptService = game:GetService("ServerScriptService")
local LibFinder = require(ServerScriptService:WaitForChild("Finders",2):WaitForChild("LibFinder",2))

local rq = LibFinder:FindLib("rquery")
local StateMachineMachine = LibFinder:FindLib("stateMachineMachine")

local npcAiProto = {
	_configs = {},
	StateMachine = nil
}

local npcAiMeta = { __index = npcAiProto }

function npcAiProto:GetNewState(stateName)
	return self.StateMachine.NewState(stateName)
end

function npcAiProto:GetIdleState()
	local idleState = self.StateMachine.NewState("Idle")
	idleState.Action = function() end
	idleState.Init = function() end
	return idleState
end

function npcAiProto:LoadConfig(configSource, configName, defaultValue)
	if configSource:FindFirstChild(configName) then
		self._configs[configName] = configSource:FindFirstChild(configName).Value
	else
		self._configs[configName] = defaultValue
	end
end

function npcAiProto:GetConfigValue(configName)
	if self._configs[configName] ~= nil then
		return self._configs[configName]
	else
		warn("No config found for key: " ..  configName)
		return nil
	end
end

local aiBaseModule = {}

function aiBaseModule.new()
	local npcAiInstance = setmetatable({}, npcAiMeta)
	npcAiInstance.StateMachine = StateMachineMachine.NewStateMachine()
    return npcAiInstance
end

return aiBaseModule