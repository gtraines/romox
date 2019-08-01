local ReplicatedStorage = game:GetService("ReplicatedStorage")

local module = {}

function module.CreateFolder( folderName, parentObjectInstance )
	local folderInst = Instance.new("Folder")
	folderInst.Name = folderName
	folderInst.Parent = parentObjectInstance
	return folderInst
end
-- Create topic folder
function module.GetOrCreateClientServerTopicCategory( categoryName )
	local eventTopicFolder = ReplicatedStorage:FindFirstChild("EventTopics")
	if eventTopicFolder == nil then
		eventTopicFolder = module.CreateFolder("EventTopics", ReplicatedStorage)
	end

	local categoryFolder = eventTopicFolder:FindFirstChild(categoryName)
	if categoryFolder == nil then
		categoryFolder = module.CreateFolder(categoryName, eventTopicFolder)
	end

	return categoryFolder
end

-- Create ClientServer topic in folder
function module.GetOrCreateClientServerTopicInCategory(categoryName, topicName)
	local categoryFolder = module.GetOrCreateClientServerTopicCategory(categoryName)

	local topic = categoryFolder:FindFirstChild(topicName)
	if topic == nil then
		topic = Instance.new("RemoteEvent")
		topic.Name = topicName
		topic.Parent = categoryFolder
	end
	return topic
end

return module
