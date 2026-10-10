-- Creates custom attachments on humanoids, the purpose of this is to allow easier offsetting of holsters.
-- Rather than working in 3 dimensions, you only work with 2. Y and Z/X
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Core = script.Parent.Parent
local Shared = ReplicatedStorage.Shared
local Misc = Shared.Misc

local Cache = require(Misc.Cache).New("Attachment", 5, true)

local Datastore = require(Core.DataStore)
local Template = require(script.Template)

local Attachments = {}

function Attachments.Create(Character)
    for Name,Location in Template do
        local NewAttachment : Attachment = Cache:GetInstance()
        NewAttachment.Name = Name
        NewAttachment.CFrame = Location
    end
    print(Cache)
end


function Attachments.Prove()
    return Cache
end

return Attachments