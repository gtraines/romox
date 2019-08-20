local libs = game:GetService("ReplicatedStorage"):WaitForChild("Scripts", 5):WaitForChild("SharedLibs", 5)

local rq = require(libs:FindFirstChild("rquery"))
local linq = require(libs:FindFirstChild("linq"))

local component = {
    __type = "component"
}

local mt = { __index = component }

function component:Execute(gameObject) 
    error(self.Name .. ": Execute: NO RUBER")
    return nil
end

function component:TryExecute(gameObject)
    local components = rq.ComponentsFolderOrNil(gameObject)
    
    if components ~= nil and #components > 0 then
        for _, value in pairs(self.Requires) do
            local componentCount = #components
            if componentCount == 0 then return false end
            if componentCount > 0 then
                local foundComponent = linq(components):firstOrDefault(function(val) return val.Name == value end)
                if foundComponent == nil then
                    return false
                end
            end
        end
        self:Execute(gameObject)
        return true
    end
    return false
end

function component.new(componentName, requiredComponentAttributes)
    local self = setmetatable({}, mt)
    self.Name = componentName or "UNNAMED_COMPONENT"
    self.Requires = requiredComponentAttributes or {}
    return self
end

return component