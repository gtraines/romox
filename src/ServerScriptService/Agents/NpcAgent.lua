local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local findersFolders = ServerScriptService:WaitForChild("Finders", 2)
local LibFinder = require(findersFolders:WaitForChild("LibFinder", 2))
local SvcFinder = require(findersFolders:WaitForChild("ServiceFinder", 2))

local rq = LibFinder:FindLib("rquery")
local uuid = LibFinder:FindLib("uuid")
local randumb = LibFinder:FindLib("randumb")
local exNihilo = SvcFinder:FindService("exnihilo")

local npcAgentProto = {
    Personage = nil,
    Waypoints = {},
    CurrentWaypointIndex = 0
}

local npcAgentMeta = { __index = npcAgentProto }

function npcAgentMeta:_createPath(personage, destinationObject)
	local pathParams = {
			AgentRadius = 2,
			AgentHeight = 5
	}
	
	local path = PathfindingService:CreatePath(pathParams)

	local personageRootPart = personage:FindFirstChild("HumanoidRootPart")
	-- Compute and check the path
	path:ComputeAsync(personageRootPart.Position, destinationObject.Position)
	-- Empty waypoints table after each new path computation
	self.CurrentWaypointIndex = 2
	self.Personage = personage
 	local humanoid = personage:FindFirstChild("Humanoid")
	
	if path.Status == Enum.PathStatus.Success then
		-- Get the path waypoints and start zombie walking
		
		self.Waypoints = path:GetWaypoints()
		self["Personage"]:FindFirstChild("Humanoid"):MoveTo(
				self.Waypoints[self["CurrentWaypointIndex"]].Position)
		for _, waypunkt in pairs(self.Waypoints) do
			--print(waypunkt.Position)
		end
		humanoid.MoveToFinished:Connect(GameManager:getOnWaypointReachedDelegate())

		
	else
		-- Error (path not found); stop humanoid
		print("PATH NOT FOUND!!!")
		humanoid:MoveTo(noidRootPart.Position)
	end
end


local agent = {
    ManagedEntities = {},
    
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

    return CFrame.new(agent.GetRandomCFrameFromTableOfParts(spawnLocations)) + Vector3.new(0, 10, 0)
end

function agent.SpawnPersonageAsAgent(storageFolder, personagePrototypeId, spawnLocation, personageAi, onSpawnCompleteCallback)

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

return agent