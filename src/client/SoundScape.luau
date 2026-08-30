local ClientTest = {}

local CollectionService = game:GetService("CollectionService")

CollectionService:GetInstanceAddedSignal("SoundScape"):Connect(function()

    print("Sound added.")
end)

return ClientTest