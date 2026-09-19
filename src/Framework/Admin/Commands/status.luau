return function (self)
    local ServerScriptService = game:GetService("ServerScriptService")
    local StatusManager = require(ServerScriptService.Framework.StatusManager)

    for _,Player in self.Players do
       StatusManager.New(Player, string.lower(self.Args[1])):Batch()
       
    end
    
    return
end