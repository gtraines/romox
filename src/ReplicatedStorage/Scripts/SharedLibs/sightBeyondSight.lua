local module = {}

function module:WideRayCast(start, target, offset, ignoreList)
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

function module:FindNearestPathPoint(path, point, start, target, ignoreList)
	local occludePoint = path:CheckOcclusionAsync(point)
	if occludePoint > 0 then
		self:WideRayCast(start)
	end
end


return module