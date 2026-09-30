local Service = {}
local Players = game:GetService("Players")

function Service.GetEnums(Parent : any)
    local Enums = {}

    if type(Parent) ~= "string" then
        for _,Value in Parent:GetChildren() do
            table.insert(Enums, Value.Name)
        end
        return Enums
    end

    local Folder = script.Parent:FindFirstChild(Parent)
    if not Folder then warn("Could not find enum parent") return end

    for _,Value in Folder:GetAttributes() do
        table.insert(Enums, Value)
    end

    return Enums
end

function Service.GetPlayerAudiences()
    
end


return Service