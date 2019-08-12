local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local findersFolders = ServerScriptService:WaitForChild("Finders", 2)
local LibFinder = require(findersFolders:WaitForChild("LibFinder", 2))
local SvcFinder = require(findersFolders:WaitForChild("ServiceFinder", 2))

local rq = LibFinder:FindLib("rq")
local uuid = LibFinder:FindLib("uuid")
local randumb = LibFinder:FindLib("randumb")
local pathfinder = LibFinder:FindLib("pathfinder")
local exNihilo = SvcFinder:FindService("exnihilo")

local agent = {
    ManagedEntities = {},
    MAX_FORCE = 75
}

function agent._getOrAddEntityIdToObj(object)
    local entityIdObj = object:FindFirstChild("EntityId")
    if entityIdObj == nil then
        entityIdObj = Instance.new("StringValue")
        entityIdObj.Name = "EntityId"
        entityIdObj.Parent = object
    end
    entityIdObj.Value = uuid()
    return entityIdObj.Value
end

function agent.GetRandomCFrameFromTableOfParts(candidatePartsTable)
	randumb:Init()
	print("Initialized randumb")

	local chosenPart = randumb:GetOneAtRandom(candidatePartsTable)

	if chosenPart ~= nil then
        return CFrame.new(chosenPart.Position)
    end
    error("Unable to select a part from candidates table")
    return nil
end

function agent.ChooseRandomSpawnLocation()
    local wsChildren = Workspace:GetChildren()
	local spawnLocations = {}
		
	for _, child in pairs(wsChildren) do
		if child.Name == "SpawnLocation" then 
			--print("Yes")
			table.insert(spawnLocations, child)
		end
	end

    return CFrame.new(agent.GetRandomCFrameFromTableOfParts(spawnLocations)) + Vector3.new(0, 10, 0)
end

function agent.SpawnPersonageAsAgent(storageFolder, personagePrototypeId, spawnLocation, onSpawnCompleteCallback)

    local spawnedPersonage = Instance.new("Model")

    exNihilo.CreateFromServerStorage(storageFolder, 
        personagePrototypeId,
        spawnLocation, 
        function(createdPersonage) 
            print("Personage spawned: " .. createdPersonage.Name)
            spawnedPersonage = createdPersonage
            spawnedPersonage.Parent = Workspace
            agent.ManagedEntities[rq.StringValueOrNil("EntityId", spawnedPersonage)] = spawnedPersonage
            onSpawnCompleteCallback(createdPersonage)
        end)
end

function agent.GetRepulsionVector(unitPosition, otherUnitsPositions, maxForce)
    if maxForce == nil or maxForce == 0 then
        maxForce = agent.MAX_FORCE
    end

    local repulsionVector = Vector3.new(0,0,0)
	local count = 0
	for _, other in pairs(otherUnitsPositions) do
		local fromOther = unitPosition - other 
		--fromOther = fromOther.unit * ((-maxForce / 5) * math.pow(fromOther.magnitude,2) + maxForce)
		fromOther = fromOther.unit * 1000 / math.pow((fromOther.magnitude + 1), 2)
		repulsionVector = repulsionVector + fromOther
	end
	return repulsionVector * maxForce
end

return agent