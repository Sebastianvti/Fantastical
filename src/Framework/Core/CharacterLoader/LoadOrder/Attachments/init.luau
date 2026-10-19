-- Creates custom attachments on humanoids, the purpose of this is to allow easier offsetting of holsters.
-- Rather than working in 3 dimensions, you only work with 2. Y and Z/X
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Misc = Shared.Misc

local Cache = require(Misc.Cache).New("Attachment", 2850, "Increment", 2850 * 0.25) -- 2850 is the amount of attachments a 150 player server would have

local Template, AllAttachments = require(script.Template), require(script.AllAttachments)

local Attachments = {}

function Attachments.CharacterInit(Character : Model)
    local Size = Character:GetScale()
    for Name,Value in Template do
        local NewAttachment : Attachment = Cache:GetInstance()

        NewAttachment.Name = Name
        NewAttachment.CFrame = CFrame.new(Value.Location.Position * Size)
        NewAttachment.Parent = Character[Value.Parent]
    end
end

function Attachments.GetAttachments()
    return AllAttachments
end

return Attachments