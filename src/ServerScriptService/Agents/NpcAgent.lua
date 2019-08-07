local ServerScriptService = game:GetService("ServerScriptService")
local libFinder = require(ServerScriptService
    :WaitForChild("Finders", 2)
    :WaitForChild("LibFinder", 2))

local uuid = libFinder:FindLib("uuid")

local agent = {
    ManagedEntities = {}
}

function agent._getOrAddEntityIdToObj(object)
    local entityIdObj = object:FindFirstChild("EntityId")
    if entityIdObj == nil then
        entityIdObj = Instance.new("StringValue")
        entityIdObj.Name = "EntityId"
        entityIdObj.Parent = createdItem
    end
    entityIdObj.Value = uuid()
    return entityIdObj.Value
end

function agent._wrapPersonage(name, personage)
    local nonPlayerModel = Instance.new("Model", game.Workspace)
    
    nonPlayerModel.Name = name
    personage.Name = "Personage"
    personage.Parent = nonPlayerModel
    return nonPlayerModel
end

function agent.new( name, personage )
    -- body
    local nonPlayer = agent._wrapPersonage(name, personage)
    local entityId = agent._getOrAddEntityIdToObj(nonPlayer)
    agent.ManagedEntities[entityId] = nonPlayer
    return nonPlayer
end

return agent