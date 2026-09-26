return function (self)
    local ServerScriptService = game:GetService("ServerScriptService")
    local ServerStorage = game:GetService("ServerStorage")
    local StoreHouse = ServerStorage.StoreHouse
    local Framework = ServerScriptService.Framework
    local DataStore = require(Framework.DataStore)

    local Arguement = string.lower(self.Args[1])
    local NewTool

    for _,Tool in StoreHouse.Tools:GetChildren() do
        if string.lower(Tool.Name) ~= Arguement then continue end
            NewTool = Tool.Name
    end

    if not NewTool then return end
        
    for _,Player in self.Players do
       table.insert(DataStore.Profiles[Player].Data.ToolBar, NewTool)
    end

    return
end