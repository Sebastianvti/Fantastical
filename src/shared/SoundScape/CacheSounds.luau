local CacheSounds = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Shared = ReplicatedStorage.Shared
local Cache = require(Shared.Cache)

local function SerializeSound(sound: Sound, Parent)
    local soundData = {
        Name = sound.Name,
        SoundId = sound.SoundId,
        Volume = sound.Volume,
        Pitch = sound.PlaybackSpeed,
        Looped = sound.Looped,
        TimePosition = sound.TimePosition,
        Parent = Parent
    }
    return soundData
end

local function DeserializeSound(soundData: {Name: string, SoundId: string, Volume: number, Pitch: number, Looped: boolean, TimePosition: number})
    local sound = Instance.new("Sound")
    sound.Name = soundData.Name
    sound.SoundId = soundData.SoundId
    sound.Volume = soundData.Volume
    sound.PlaybackSpeed = soundData.Pitch
    sound.Looped = soundData.Looped
    sound.TimePosition = soundData.TimePosition
    return sound
end

local function GetAllSounds()
    for _,Audio in ServerStorage:GetDescendants() do
        if Audio:IsA("Sound") and Audio:FindFirstAncestorOfClass("Model") then
            local Seraliazed = SerializeSound(Audio, Audio:FindFirstAncestorOfClass("Model"))
            Cache.Sound[Seraliazed.Name] = Seraliazed
        end
    end
    print(Cache)
end


function CacheSounds.Start() 
    GetAllSounds()
end

return CacheSounds