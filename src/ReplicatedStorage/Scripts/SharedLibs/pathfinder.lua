local ReplicatedStorage = game:GetService("ReplicatedStorage")
local rq = require(ReplicatedStorage
	:WaitForChild("Scripts"):WaitForChild("SharedLibs"):WaitForChild("rquery"))
local PathfindingService = game:GetService("PathfindingService")
PathfindingService.EmptyCutoff = .3

local PathfindingUtility = {}

local TargetOffsetMax = 10--5
local JumpThreshold = 1.5 --2.5
local NextPointThreshold = 4

function PathfindingUtility.new()
	local this = {
		CurrentTargetPos = nil,
		LastTargetPos = nil,
		Path = nil,
		CurrentPointIndex = 1
	}

	this.LastTargetPos = Vector3.new(math.huge, math.huge, math.huge)
	this.Path = nil
	this.CurrentPointIndex = 1

	function this:MoveToTarget(character, target, showPath)
		local targetOffset = (this.LastTargetPos - target).magnitude
		--
--		local targetOffsetVector = (lastTargetPos - target)
--		if targetOffsetVector.magnitude < math.huge then
--			targetOffsetVector = (lastTargetPos - target) * Vector3.new(1,0,1)
--		end

		if targetOffset > TargetOffsetMax then
		--if targetOffsetVector.magnitude > TargetOffsetMax then
			--print("moveto")
			local startPoint = character.Torso.Position
			local humanoidState = character.Humanoid:GetState()
			if humanoidState == Enum.HumanoidStateType.Jumping or 
				humanoidState == Enum.HumanoidStateType.Freefall then
				--print("this")				
				local ray = Ray.new(character.Torso.Position, Vector3.new(0, -100, 0))
				local hitPart, hitPoint = game.Workspace:FindPartOnRay(ray, character)
				if hitPart then
					startPoint = hitPoint
				end
			end
			--print("making new path")
			local newTarget = target
			local ray = Ray.new(target + Vector3.new(0,-3,0), Vector3.new(0, -100, 0))			
			local hitPart, hitPoint = game.Workspace:FindPartOnRay(ray, character)
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
			if showPath then
				local pointsFolder = rq.GetOrAddItem( "Points", "Folder", game.Workspace )

				pointsFolder:ClearAllChildren()
				local ps = this.Path:GetPointCoordinates()
				for _, point in pairs(ps) do
					local part = Instance.new("Part", pointsFolder)
					part.CanCollide = false
					part.Anchored = true
					part.FormFactor = Enum.FormFactor.Custom
					part.Size = Vector3.new(1,1,1)
					part.Position = point
				end
			end
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
return PathfindingUtility