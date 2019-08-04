local agent = {
    _playerProto = {}
}

local playerProto = {
    Name = "",
    Character = {
        Humanoid = {}
    }
}

local proto = Instance.new("Player")

agent._playerProto = playerProto:Clone()

function agent.new( name, humanoid )
    -- body
    local agentInstance = agent._playerProto:Clone()
    agentInstance.Name = name
    agentInstance.Character.Humanoid = humanoid:Clone()

    return agentInstance
end


return agent