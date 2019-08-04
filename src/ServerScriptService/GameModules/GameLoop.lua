local GameManager = require(script.Parent.GameManager)

local loopModule = {
    __gameManager = GameManager
}

function loopModule:RunForever()
    self.__gameManager:Initialize()

    while true do
        repeat
            self.__gameManager:RunIntermission()
        until self.__gameManager:GameReady()
        
        self.__gameManager:StopIntermission()
        self.__gameManager:StartRound()	
        
        repeat
            self.__gameManager:Update()
            wait()
        until self.__gameManager:RoundOver()
        
        self.__gameManager:RoundCleanup()
    end
end

return loopModule