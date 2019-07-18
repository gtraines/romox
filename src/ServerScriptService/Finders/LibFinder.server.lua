--[[
    Usage example: 
    	local libFinder = require(game
	:GetService("ServerScriptService")
	:WaitForChild("Finders")
	:WaitForChild("LibFinder"))
    local rq = svcFinder:FindLib("RQuery")
]]

local ServerScriptService = game:GetService("ServerScriptService")
local sharedLibs = ServerScriptService:WaitForChild("SharedLibs")

local registrationModuleScript = sharedLibs:FindFirstChild("_registerLibs", false)

local dedupedModules = {}
if registrationModuleScript ~= nil then
    local registrationModule = require(registrationModuleScript)

    for key,mod in pairs(registrationModule) do
        if dedupedModules[key] == nil then
            dedupedModules[key] = mod
        end
    end
end
local module = {}
module["RegisteredLibs"] = dedupedModules

function module:FindService(libName)
    if self.RegisteredLibs ~= nil then
        -- First try
        local foundLib = self.RegisteredLibs[libName]
        if foundLib ~= nil then
            return foundLib
        end

        -- Take another shot
        foundLib = self.RegisteredLibs[string.lower(libName)]
        if foundLib ~= nil then
            return foundLib
        end

        error("Library " .. libName .. " not found")
        return nil
    end
end

return module