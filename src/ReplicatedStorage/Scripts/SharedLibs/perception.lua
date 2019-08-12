local ReplicatedStorage = game:GetService("ReplicatedStorage")

local rq = require(ReplicatedStorage
	:WaitForChild("Scripts", 1)
	:WaitForChild("SharedLibs", 1)
	:WaitForChild("rquery", 1))

local module = {}

function module.IsSpaceEmpty(position)
	local region = Region3.new(position - Vector3.new(2,2,2), position + Vector3.new(2,2,2))
	return game.Workspace:IsRegion3Empty(region)
end

-- TODO: I can't vouch for the soundness or correctness of this logic
function module.FindCloseEmptySpace(model)
	local targetPos = Vector3.new(0,0,0)
	local count = 0
	math.randomseed(os.time())
	repeat
		local xoff = math.random(5,10)
		if math.random() > .5 then
			xoff = xoff * -1
		end
		local zoff = math.random(5, 10)
		if math.random() > .5 then
			zoff = zoff * -1
		end

		local modelTorso = rq.PersonageTorsoOrEquivalent(model)
		targetPos = Vector3.new(modelTorso.Position.X + xoff,
							modelTorso.Position.Y,
							modelTorso.Position.Z + zoff)
		if module.IsSpaceEmpty(targetPos) then
			return targetPos
		else
			targetPos = targetPos + Vector3.new(0,4,0)
		end
		
		if module.IsSpaceEmpty(targetPos) then
			return targetPos
		end
		count = count + 1
	until count > 10
	return nil
end

function module.WideRayCast(start, target, offset, ignoreList)
	local parts = {}
	
	local ray = Ray.new(start, target - start)
	local part, point = game.Workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
	if part then table.insert(parts, part) end
	
	local offsetVector = offset * (target - start):Cross(Vector3.FromNormalId(Enum.NormalId.Top)).unit
	local ray = Ray.new(start + offsetVector, target - start + offsetVector)
	local part, point = game.Workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
	if part then table.insert(parts, part) end
	
	local ray = Ray.new(start - offsetVector, target - start - offsetVector)
	local part, point = game.Workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
	if part then table.insert(parts, part) end
	
	return parts
end

function module.FindNearestPathPoint(path, point, start, target, ignoreList)
	local occludePoint = path:CheckOcclusionAsync(point)
	if occludePoint > 0 then
		module.WideRayCast(start)
	end
end

function module.GetClosestVisibleTarget(npcModel, characters, ignoreList, fieldOfView)
	local closestTarget = nil
	local closestDistance = math.huge
	for _, character in pairs(characters) do
		local targetTorso = rq.PersonageTorsoOrEquivalent(character)
		local npcTorso = rq.PersonageTorsoOrEquivalent(npcModel)
		
		local toTarget = targetTorso.Position - npcTorso.Position
		local toTargetWedge = toTarget * Vector3.new(1,0,1)
		local angle = math.acos(toTargetWedge:Dot(npcTorso.CFrame.lookVector)/toTargetWedge.magnitude)
		if math.deg(angle) < fieldOfView then
			local targetRay = Ray.new(npcTorso.Position, toTarget)
			local part, position = game.Workspace:FindPartOnRayWithIgnoreList(targetRay, ignoreList)
			if part and part.Parent == character then
				if toTarget.magnitude < closestDistance then
					closestTarget = character
					closestDistance = toTarget.magnitude
				end
			end
		end
	end
	return closestTarget
end
return module