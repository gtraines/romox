local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local findersFolder = ServerScriptService:WaitForChild("Finders", 2)
local LibFinder = require(findersFolder:WaitForChild("LibFinder", 2))
local DomainFinder = require(findersFolder:WaitForChild("DomainFinder", 2))

local rq = LibFinder:FindLib("rquery")
local randumb = LibFinder:FindLib("randumb")
local exNihilo = DomainFinder:FindDomain("exnihilo")

local agentsFolder = ServerScriptService:WaitForChild("Agents", 2)
local pathfindingAi = require(agentsFolder:WaitForChild("PathfindingAiBase"))

local agent = {
    ManagedEntities = {}
}

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

    return agent.GetRandomCFrameFromTableOfParts(spawnLocations) + Vector3.new(0, 10, 0)
end

function agent.SpawnPersonageAsAgent(storageFolder, 
	personagePrototypeId, 
	spawnLocation, 
	personageAi, 
	onSpawnCompleteCallback)

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

function agent.CreateFarmerCurtis()
	local storageFolder = "Noids"
	local personagePrototypeId = "FarmerCurtis"
	local spawnLocation = agent.ChooseRandomSpawnLocation()
	
	local destination = Workspace:FindFirstChild("Drooling Zombie"):WaitForChild("HumanoidRootPart")
	local onSpawnCompleteCallback = function (createdPersonage)
		local pathfindingAi = pathfindingAi.new(createdPersonage)
		local goGoGo = pathfindingAi:MoveTo(destination , true)
	end

	agent.SpawnPersonageAsAgent(storageFolder,
		personagePrototypeId,
		spawnLocation, 
		pathfindingAi, 
		onSpawnCompleteCallback)
end

return agent