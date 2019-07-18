local module = {}

function module.BreadthFirst(entity, levelsRemaining, funcToRunOnEachEntity)
    -- @param [Instance] entity entity to start search
	-- @param [Number] levelsRemaining Levels of entities deep to continue searching
	-- @param [function] The function to run on each entity
	if (levelsRemaining <= 0 or entity == nil) then
		return
	end
	
	local entityChilds = entity:GetChildren()
	
	for idx, entitiesChild in pairs(entityChilds) do
		funcToRunOnEachEntity(entitiesChild)
		module.BreadthFirst(entitiesChild, levelsRemaining - 1, funcToRunOnEachEntity)
    end
end

function module.FindSiblingNamed( part, siblingName )
	if part.Parent ~= nil then
		if part.Parent:FindFirstChild( siblingName, false ) ~= nil then
			return part.Parent:FindFirstChild( siblingName, false )
		end
	end

	return nil
end

function module.AttachedHumanoidOrNil(part)
	if module.FindSiblingNamed(part, "Humanoid") ~= nil then
		return module.FindSiblingNamed(part, "Humanoid")
	elseif part:FindFirstAncestor("Humanoid") ~= nil then
		return part:FindFirstAncestor("Humanoid")
	elseif part:FindFirstChild( "Humanoid", false ) ~= nil then
		return part:FindFirstChild( "Humanoid", false )
	else
		return nil
	end
end

function module.itWorked(msg) 
	print(msg)
end
return module
