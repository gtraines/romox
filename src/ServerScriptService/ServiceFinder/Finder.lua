-- 
-- 
-- 

--[[
    Usage example: 
    	local svcFinder = require(game
	:GetService("ServerScriptService")
	:WaitForChild("ServiceFinder")
	:WaitForChild("Finder"))
    local rq = svcFinder:FindService("RQuery")
]]

local ServerScriptService = game:GetService("ServerScriptService")

local allChildFolders = ServerScriptService:GetChildren()
local dedupedModules = {}

for _, folder in pairs(allChildFolders) do
    local registrationModuleScript = folder:FindFirstChild("_registerModules", false)
    if registrationModuleScript ~= nil then
        local registrationModule = require(registrationModuleScript)
        
        for key,mod in pairs(registrationModule) do
            if dedupedModules[key] == nil then
                dedupedModules[key] = mod
            end
        end
    end
end

local module = {}

module["RegisteredServices"] = dedupedModules

function module:FindService(serviceName)
    if self.RegisteredServices ~= nil then
        -- First try
        local foundService = self.RegisteredServices[serviceName]
        if foundService ~= nil then
            return foundService
        end

        -- Take another shot
        foundService = self.RegisteredServices[string.lower(serviceName)]
        if foundService ~= nil then
            return foundService
        end

        error("Service " .. serviceName .. " not found")
        return nil
    end
end

return module