local EzConfig = require(script.Parent:WaitForChild("easyconfig"))
local Linq = require(script.Parent:WaitForChild("linq"))
local RoType = require(script.Parent:WaitForChild("rotype"))
local RQuery = require(script.Parent:WaitForChild("rquery"))
local Wraptor = require(script.Parent:WaitForChild("wraptor"))

local module = {}

module["EzConfig"] = EzConfig
module["Linq"] = Linq
module["RoType"] = RoType
module["RQuery"] = RQuery
module["Wraptor"] = Wraptor

return module
