local spieler = require(script.Parent:WaitForChild("Spieler"))
local lightManager = require(script.Parent:WaitForChild("LightManager"))
local exNihilo = require(script.Parent:WaitForChild("ExNihilo"))

local module = {}

module["Spieler"] = spieler
print("Line 8")
module["LightManager"] = lightManager
module["ExNihilo"] = exNihilo
module["PubSub"] = require(script.Parent:WaitForChild("PubSub", 2))
print("Line 12")
module["CarAndDriver"] = require(script.Parent:WaitForChild("CarAndDriver", 2))
print("Registermodules: Line 14")
return module
