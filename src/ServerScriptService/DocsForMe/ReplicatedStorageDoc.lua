--[[
    breadthFirst = function(entity, levelsRemaining, funcToRunOnEachEntity)
	if (levelsRemaining <= 0 or entity == nil) then
		return
	end
	
	local entityChilds = entity:GetChildren()
	
	for idx, entitiesChild in pairs(entityChilds) do
		funcToRunOnEachEntity(entitiesChild)
		breadthFirst(entitiesChild, levelsRemaining - 1, funcToRunOnEachEntity)
	end
	
end
]]