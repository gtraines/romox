local ReplicatedStorage = game:GetService("ReplicatedStorage")

local rq = require(ReplicatedStorage
	:WaitForChild("Scripts", 2):WaitForChild("SharedLibs", 2):WaitForChild("rquery", 2))
local uuid = require(ReplicatedStorage
	:WaitForChild("Scripts", 2):WaitForChild("SharedLibs", 2):WaitForChild("uuid", 2))


local stateProto = {
	__type = "state",
	StateId = nil,
	Name = nil,
	InternalData = {},
	NextStatesNames = {},
	NextStates = {},
	Wait = 0.2,
	IsRunning = false
}
local stateMeta = { __index = stateProto }

function stateProto.new(name)
	local self = setmetatable({}, stateMeta)
	self.Name = name or "UNNAMED_STATE"
	uuid.seed()
	self.StateId = uuid()
	return self
end

function stateProto:PrintInternalDataTable()
    print("------------------------------------")
    print("  Internal data for " .. self.Name)
    for name, value in pairs(self.InternalData) do
        print("    - " .. tostring(name) .. ": ".. tostring(value))
    end
    print("------------------------------------")
end
function stateProto:CanTransitionFrom(previousState, data)
	error("No transition func specified")
end

function stateProto:StateStoppedCallback()
	return
end

function stateProto:CanPerformAction(data)
	error(self.Name .. " missing CanPerformAction() implementation")
end

function stateProto:Action()
	error(self.Name .. " missing Action() implementation")
	return false
end

function stateProto:Init()
	print("Initializing State: " .. self.Name)
end

local machineProto = {
	MachineId = "nil",
	CurrentState = {},
	States = {}
}
local machineMeta = { __index = machineProto }

function machineProto.new()
	local self = setmetatable({}, machineMeta)
	self.MachineId = uuid()
	return self
end

function machineProto:Stop(stateToStop)
	--print("Stopping " .. state.Name)
	stateToStop.IsRunning = false
	stateToStop:StateStoppedCallback()
end

function machineProto:AddState(state)
	self.States[state.Name] = state
	for _, nextStateName in pairs(state.NextStatesNames) do
		if self.States[nextStateName] ~= nil then
			state.NextStates[nextStateName] = self.States[nextStateName]
		end
	end

	for _, existingState in pairs(self.States) do
		for _, nextStateName in pairs(existingState.NextStatesNames) do
			if nextStateName == state.Name then
				existingState.NextStates[nextStateName] = state
			end
		end
	end
end

function machineProto:TryTransition(data)
	local stateMemo = self.CurrentState
	for _, nextState in pairs(self.CurrentState.NextStates) do
		if nextState:CanTransitionFrom(self.CurrentState, data) then
			self:Stop(stateMemo)
			self.CurrentState = nextState
			self:Start(self.CurrentState)
			return true
		end
	end
	return false
end

function machineProto:Next(data)
	if self.CurrentState:CanPerformAction(data) then
		self.CurrentState:Action()
	else
		self:Update()
	end
	--wait(state.WaitTime)
end

function machineProto:Start()
	print("Starting " .. self.CurrentState.Name)
	self.CurrentState:Init()
	local runDelegate = function()
		self:Next()
	end
	local thread = coroutine.create(runDelegate)
	local success, errorMsg = coroutine.resume(thread)
	if success then
		self.CurrentState.IsRunning = true
	else
		error(errorMsg)
	end
end

function machineProto:Update( data )
	if self:TryTransition(data) then
		return true
	else
		self:Next(data)
	end
	--wait(self.CurrentState.WaitTime)
end

local machineMachine = {
	_machineProto = machineProto,
	_stateProto = stateProto
}

function machineMachine.NewStateMachine()
	local machineInstance = rq.DeepCopyTable(machineMachine._machineProto.new())
	uuid.seed()
	machineInstance.MachineId = uuid()
	return machineInstance
end

function machineMachine.NewState( newStateName )
	local stateInstance = rq.DeepCopyTable(machineMachine._stateProto.new())
	stateInstance.Name = newStateName
	return stateInstance
end

return machineMachine