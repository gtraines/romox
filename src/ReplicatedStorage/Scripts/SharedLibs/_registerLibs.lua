local EzConfig = require(script.Parent:WaitForChild("easyconfig", 5))
local Linq = require(script.Parent:WaitForChild("linq", 5))
local RoType = require(script.Parent:WaitForChild("rotype", 5))
local RQuery = require(script.Parent:WaitForChild("rquery", 5))
local Wraptor = require(script.Parent:WaitForChild("wraptor", 5))

local module = {}

module["EzConfig"] = EzConfig
module["Linq"] = Linq
module["RoType"] = RoType
module["RQuery"] = RQuery
module["Wraptor"] = Wraptor
module["uuid"] = require(script.Parent:WaitForChild("uuid", 10))
module["PubSubClient"] = require(script.Parent:WaitForChild("pubsubclient",5))
module["gooey"] = require(script.Parent:WaitForChild("gooey",5))
module["randumb"] = require(script.Parent:WaitForChild("randumb", 5))
module["componentbase"] = require(script.Parent:WaitForChild("componentbase", 5))

return module
