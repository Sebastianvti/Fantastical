local ClientTest = {}

local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local LocalPlayer = Players.LocalPlayer
local SoundSpeed = 343

local function PlaySound(Sound : Sound)
    Sound.Volume = Sound:GetAttribute("Volume")
    Sound:Play()
end

CollectionService:GetInstanceAddedSignal("SoundScape"):Connect(function(Sound)
    local Magnitude = (LocalPlayer.Character.HumanoidRootPart.Position - Sound.Parent.Position).Magnitude
    local SoundWaveDuration = Magnitude / SoundSpeed

    print("Distance : "..Magnitude)
    print("Sound Delay : "..SoundWaveDuration)

    task.delay(SoundWaveDuration, PlaySound, Sound)
end)

return ClientTest