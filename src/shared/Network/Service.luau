local Service = {}

function Service.GetEnums(Parent : string)
    local Folder = script.Parent:FindFirstChild(Parent)
    if not Folder then warn("Could not find enum parent") return end

    local Enums = {}
    for Key,Value in Folder:GetAttributes() do
        table.insert(Enums, Value)
    end

    return Enums
end

return Service