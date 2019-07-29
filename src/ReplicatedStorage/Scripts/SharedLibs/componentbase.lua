local libs = game:GetService("ReplicatedStorage"):WaitForChild("SharedLibs")

local rq = require(libs:WaitForChild("rquery"))
local linq = require(libs:WaitForChild("rquery"))

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
    if components ~= nil then
        for _, value in self.Requires do
            if linq(components):firstOrDefault(function(val) return val.Name == value end) == nil then
                return false
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

