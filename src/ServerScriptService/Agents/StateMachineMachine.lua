local ServerScriptService = game:GetService("ServerScriptService")

local libFinder = require(ServerScriptService
	:WaitForChild("Finders", 2):WaitForChild("LibFinder", 2))

local rq = libFinder:FindLib("rquery")

local stateProto = {
	Name = nil,
	NextStates = {},
	Wait = 0.2,
	_isRunning = false,
	CanTransition = function(data) error("No transition func specified") end,
	StateStoppedCallback = function() end
}

stateProto.Action = function() 
	error(stateProto.Name .. " missing Action() implementation")
end

function stateProto.Init()
	print("Initializing State: " .. stateProto.Name)
end

local machineProto = {
	CurrentState = nil,
	States = {}
}

machineProto.Stop = function(stateToStop)
	--print("Stopping " .. state.Name)
	stateToStop._isRunning = false
	stateToStop.StateStoppedCallback()
end

function machineProto:AddState(state)
	self.States[state.Name] = state
	for _, nextState in pairs(state.NextStates) do
		if self.States[nextState.Name] ~= nil then
			nextState = self.States[nextState.Name]
		end
	end

	for _, existingState in pairs(self.States) do
		for _, nextState in pairs(existingState.NextStates) do
			if nextState.Name == state.Name then
				nextState = state
			end
		end
	end
end

function machineProto:_checkState( state, data )
	if state.CanTransition(data) then
		self.CurrentState = state
		return true
	end
	return false
end

function machineProto:_tryTransition(data)
	local stateMemo = self.CurrentState
	for _, nextState in pairs(self.CurrentState.NextStates) do
		if self:_checkState(nextState, data) then
			self.Stop(stateMemo)
			self.Start(nextState)
			return true
		end
	end
	return false
end

function machineProto.Run(state)
	state._isRunning = true
	while state._isRunning do
		state.Action()
		wait(state.WaitTime)
	end
end

function machineProto.Start(stateToStart)
	print("Starting " .. stateToStart.Name)
	stateToStart.Init()
	local thread = coroutine.create(stateProto.Run)
	coroutine.resume(thread)
end

function machineProto:Update( data )
	self._tryTransition(data)
	self.Run(self.CurrentState)
end

local machineMachine = {
	_machineProto = machineProto,
	_stateProto - stateProto
}

function machineMachine.NewStateMachinefunction()
	local machineInstance = rq.DeepCopyTable(machineMachine._machineProto)
	return machineInstance
end

function machineMachine.NewState( newStateName )
	local stateInstance = rq.DeepCopyTable(machineMachine._stateProto)
	stateInstance.Name = newStateName
	return stateInstance
end

return machineMachine