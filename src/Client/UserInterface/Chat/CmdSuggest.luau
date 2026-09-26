local CmdParameter = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Misc = ReplicatedStorage.Shared.Misc

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local Data = script.Parent.Data
local UserInterface = PlayerGui:WaitForChild("UserInterface")

local Window : CanvasGroup = UserInterface.Window

local InputBar : TextBox = Window.InputBar
local CmdBox : Frame = Window.CmdSuggest
local CmdText : TextLabel = CmdBox.Suggest
local Connection

local ParameterTrack = require(Misc.ParameterTrack)
local Commands = require(Data.Commands)


function CmdParameter.Update(Packet)
    Commands = Packet
end

local function TweenBar(Open : boolean)
    if CmdParameter.TweenBar and CmdParameter.TweenBar.PlaybackState == Enum.PlaybackState.Playing then CmdParameter.TweenBar:Cancel() end

    if not Open then 
        CmdParameter.TweenBar = TweenService:Create(CmdBox, TweenInfo.new(0.25), {Size = UDim2.new(0,537,0,0), BorderSizePixel = 0})
    else
        CmdParameter.TweenBar = TweenService:Create(CmdBox, TweenInfo.new(0.25), {Size = UDim2.new(0,537,0,27), BorderSizePixel = 2})
    end
   
    CmdParameter.TweenBar:Play()
end

local function ClearSuggest()
    CmdText.Text = ""
    TweenBar(false)
    
    if Connection then Connection:Disconnect() end
end

local function Suggest(Cmd : string, Parameters)
    TweenBar(true)
    local Tracker = ParameterTrack.New(Parameters, CmdText)

    CmdText.Text = ("/"..Cmd.." "..table.concat(Parameters, ", ")) Tracker:Track(InputBar.Text) 
    if Connection then Connection:Disconnect() end

    Connection = InputBar:GetPropertyChangedSignal("Text"):Connect(function()
        CmdText.Text = ("/"..Cmd.." "..table.concat(Parameters, ", "))
        local NoCommandMsg = InputBar.Text

       Tracker:Track(NoCommandMsg)
    end)

end

local function AssumeCommand(Text)
    local NoSlash = string.sub(Text, 2)
    local ClosestMatch, MatchValue
    if not Commands.CommandParams then return end

    for Key,Value in Commands.CommandParams do
        if string.len(NoSlash) > string.len(Key) then continue end
        if string.lower(NoSlash) == string.lower(Key) then Suggest(Key,Value) return end

        local SubString = string.sub(string.lower(Key), 1, string.len(NoSlash))
        if SubString ~= string.lower(NoSlash) or SubString == "" then continue end

        ClosestMatch, MatchValue = Key,Value
    end
    if ClosestMatch then print(ClosestMatch) Suggest(ClosestMatch, MatchValue) return end

    ClearSuggest()
end

local function Changed()
    if not InputBar:IsFocused() then return end
    if string.len(InputBar.Text) == 0 then return end
    
    local NoSpace = string.gsub(InputBar.Text, "^%s+", "")

    if string.sub(NoSpace, 1, 1) ~= "/" then return end
    local RemoveSpacesAfterSlash = string.gsub(NoSpace, "^/%s+", "")

    AssumeCommand(string.split(RemoveSpacesAfterSlash, " ")[1])
end

InputBar.FocusLost:Connect(ClearSuggest)
InputBar:GetPropertyChangedSignal("Text"):Connect(Changed)

return CmdParameter