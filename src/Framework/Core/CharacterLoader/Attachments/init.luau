-- Creates custom attachments on humanoids, the purpose of this is to allow easier offsetting of holsters.
-- Rather than working in 3 dimensions, you only work with 2. Y and Z/X
local Core = script.Parent.Parent

local Datastore = require(Core.DataStore)
local Template = require(script.Template)

local Attachments = {}

function Attachments.Create(Character)
    local NewAttachment : Attachment = Instance.new("Attachment")

    NewAttachment.Parent = Character.Torso
    NewAttachment.CFrame = CFrame.new(0,0,0)
end

return Attachments