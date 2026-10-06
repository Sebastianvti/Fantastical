local SoundScape = {}
SoundScape.__index = SoundScape

local CollectionService = game:GetService("CollectionService")

-- In this system, "AddTag" is used to play the audio. The client tracks new items being added to the tag, and plays the sound after it does calculations.
-- This allows you to play sounds normally if you dont want to add the soundscape tag

function SoundScape.New(IDs)
    local self = setmetatable({}, SoundScape)

    self.Attachment = Instance.new("Attachment")

    self:Play()
end

function SoundScape:Play()
    self.Attachment.Position = workspace.SpawnLocation.Position
    self.Attachment.Parent = workspace
    self.Sound.Parent = self.Attachment

    CollectionService:AddTag(self.Sound, "SoundScape")
end


return SoundScape