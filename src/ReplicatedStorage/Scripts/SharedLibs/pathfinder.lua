local ReplicatedStorage = game:GetService("ReplicatedStorage")
local rq = require(ReplicatedStorage
	:WaitForChild("Scripts"):WaitForChild("SharedLibs"):WaitForChild("rquery"))
local PathfindingService = game:GetService("PathfindingService")
PathfindingService.EmptyCutoff = .3

local pathProgressProto = {
	CurrentTargetPos = nil,
	LastTargetPos = nil,
	Waypoints = {},
	CurrentWaypointIndex = 1
}

local pathProgressMeta = { __index = pathProgressProto }

local module = {
	DefaultPersonageMovementParams = {
		TargetOffsetMax = 10, --5
		JumpThreshold = 1.5, --2.5
		NextPointThreshold = 4,
	},
	DefaultPathParams = {
		AgentRadius = 2,
		AgentHeight = 5
	}
}


function module.GetPathForPersonage(personage, destinationObject, pathParams)
	if pathParams == nil then 
		 pathParams = module.DefaultPathParams
	end
	
	local path = PathfindingService:CreatePath(pathParams)

	local personageRootPart = personage:FindFirstChild("HumanoidRootPart")
	-- Compute and check the path
	path:ComputeAsync(personageRootPart.Position, destinationObject.Position)

	if path.Status == Enum.PathStatus.Success then
		return path
	else
		warn("Unable to find path for " .. personage.Name .. " to " .. destinationObject.Name)
		return nil
	end
end

function module.ClearPathWaypoints( path )
	local pointsFolder = rq.GetOrAddItem( "Points", "Folder", game.Workspace )
	pointsFolder:ClearAllChildren()
end

function module.DisplayPathWaypoints(path)

	local pointsFolder = rq.GetOrAddItem( "Points", "Folder", game.Workspace )
	pointsFolder:ClearAllChildren()
	local waypoints = path:GetWaypoints()

	-- Loop through waypoints
	for _, waypoint in pairs(waypoints) do
		local part = Instance.new("Part")
		part.Shape = "Ball"
		part.Material = "Neon"
		part.Size = Vector3.new(0.6, 0.6, 0.6)
		part.Position = waypoint.Position
		part.Anchored = true
		part.CanCollide = false
		part.Parent = pointsFolder
	end
end

-- Adapted from zombie
function module.MovePersonageOnPath(personage,
	path,
	onWaypointReachedDelegate,
	pathProgressData, personageMovementParams)

	if path == nil or path.Status ~= Enum.PathStatus.Success then
		error("PATH NOT FOUND!!!")
	end

	if personageMovementParams == nil then
		personageMovementParams = rq.DeepCopyTable(module.DefaultPersonageMovementParams)
	end

	if pathProgressData == nil then 
		pathProgressData = setmetatable({}, pathProgressMeta)
	end
	
 	local humanoid = personage:FindFirstChild("Humanoid")
	
	pathProgressData.Waypoints = path:GetWaypoints()
	local personageTorso = rq.PersonageTorsoOrEquivalent(personage)
	
	if pathProgressData.CurrentWaypointIndex < #pathProgressData.Waypoints then
		local currentPoint = pathProgressData.Waypoints[pathProgressData.CurrentWaypointIndex]
		local distance = (personageTorso.Position - currentPoint).magnitude
		if distance < personageMovementParams.NextPointThreshold then
			pathProgressData.CurrentWaypointIndex = pathProgressData.CurrentWaypointIndex + 1
		end

		humanoid:MoveTo(pathProgressData.Waypoints[pathProgressData.CurrentWaypointIndex])
		if pathProgressData.Waypoints[pathProgressData.CurrentPointIndex].Y - 
			personageTorso.Position.Y > personageMovementParams.JumpThreshold then
			humanoid.Jump = true
		end
	end
	humanoid:MoveTo(
			pathProgressData.Waypoints[pathProgressData.CurrentWaypointIndex].Position)

	humanoid.MoveToFinished:Connect(onWaypointReachedDelegate)

	return pathProgressData
end

function module.new()

	local this = {
		CurrentTargetPos = nil,
		LastTargetPos = nil,
		Path = nil,
		CurrentWaypointIndex = 1
	}

	this.LastTargetPos = Vector3.new(math.huge, math.huge, math.huge)
	this.Path = nil
	this.CurrentPointIndex = 1

	function this:MoveToTarget(personage, target, onTargetReachedDelegate, pathProgressData, personageMovementParams)
		local targetOffset = (this.LastTargetPos - target).magnitude
		--
--		local targetOffsetVector = (lastTargetPos - target)
--		if targetOffsetVector.magnitude < math.huge then
--			targetOffsetVector = (lastTargetPos - target) * Vector3.new(1,0,1)
--		end

		if targetOffset > TargetOffsetMax then
		--if targetOffsetVector.magnitude > TargetOffsetMax then
			--print("moveto")
			local personageTorso = rq.PersonageTorsoOrEquivalent(personage)

			local startPoint = personageTorso.Position
			
			local humanoidState = personage.Humanoid:GetState()
			if humanoidState == Enum.HumanoidStateType.Jumping or 
				humanoidState == Enum.HumanoidStateType.Freefall then
				--print("this")				
				local ray = Ray.new(personageTorso.Position, Vector3.new(0, -100, 0))
				local hitPart, hitPoint = game.Workspace:FindPartOnRay(ray, personageTorso)
				if hitPart then
					startPoint = hitPoint
				end
			end

			local newTarget = target
			local ray = Ray.new(target + Vector3.new(0,-3,0), Vector3.new(0, -100, 0))			
			
			local hitPart, hitPoint = game.Workspace:FindPartOnRay(ray, personage)
			if hitPoint then
				if (hitPoint - target).magnitude > 4 then
					newTarget = newTarget * Vector3.new(1,0,1) + Vector3.new(0,3,0)
				end
			end
			
			--local newTarget = Vector3.new(1,0,1) * target + Vector3.new(0, 2, 0)
			this.Path = PathfindingService:ComputeSmoothPathAsync(startPoint, newTarget, 500)
			if this.Path.Status ~= Enum.PathStatus.Success then
				-- StateMachine move back to get path
				--print(tostring(path.Status))
			end
			--path = PathfindingService:ComputeRawPathAsync(startPoint, target, 500)			

			this.CurrentPointIndex = 1
			this.LastTargetPos = target
		end
		
		if this.Path then
			local personageTorso = rq.PersonageTorsoOrEquivalent(character)
			local points = this.Path:GetPointCoordinates()
			if this.CurrentPointIndex < #points then
				local currentPoint = points[this.CurrentPointIndex]
				local distance = (personageTorso.Position - currentPoint).magnitude
				if distance < NextPointThreshold then
					this.CurrentPointIndex = this.CurrentPointIndex + 1
				end

				character.Humanoid:MoveTo(points[this.CurrentPointIndex])
				if points[this.CurrentPointIndex].Y - personageTorso.Position.Y > JumpThreshold then
					character.Humanoid.Jump = true
				end
			else
				character.Humanoid:MoveTo(target)
			end
		end
	end

	return this
end

return module