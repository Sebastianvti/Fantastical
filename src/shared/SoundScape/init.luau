local SoundScape = {}
SoundScape.__index = SoundScape

local CollectionService = game:GetService("CollectionService")

function SoundScape.New(IDs)
    local self = setmetatable({}, SoundScape)

    self.Attachment = Instance.new("Attachment")
    self.Sound = Instance.new("Sound")
    self.Sound.SoundId = ("rbxassetid://"..IDs)
    self.Sound.Volume = 0

    self:Play()
end

function SoundScape:Play()
    print("?")
    self.Attachment.Position = workspace.SpawnLocation.Position
    self.Attachment.Parent = workspace
    self.Sound.Parent = self.Attachment

    CollectionService:AddTag(self.Sound, "SoundScape")
end


return SoundScape