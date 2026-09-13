local CmdParameter = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local Charts = script.Parent.Charts
local UserInterface = PlayerGui:WaitForChild("UserInterface")

local Messaging = UserInterface.Messaging
local Window : CanvasGroup = Messaging.Window

local InputBar : TextBox = Window.InputBar
local CmdBox : Frame = Window.CmdSuggest
local CmdText : TextLabel = CmdBox.Suggest

local Commands = require(Charts.Commands)
CmdParameter.TweenBar = TweenService:Create(CmdBox, TweenInfo.new(0.7), {Size = UDim2.new(0,537,0,27)})

function  CmdParameter.Update(Packet)
    Commands = Packet
    print(Commands)
end

local function TweenBar()
    if CmdParameter.TweenBar.PlaybackState == Enum.PlaybackState.Playing then
        CmdParameter.TweenBar:Cancel()
    end
    CmdParameter.TweenBar:Play()
end

local function ClearSuggest()
    CmdText.Text = ""
end

local function Suggest(Text, Parameters)
    CmdBox.Size = UDim2.new(0,537,0,0)
    TweenBar()
    CmdText.Text = ("[Cmd]: "..Text.." "..table.concat(Parameters, " "))
end

local function AssumeCommand(Text)
    local NoSlash = string.sub(Text, 2)
    for Key,Parameters in Commands.CommandParams do
        local SubString = string.sub(string.lower(Key), 1, string.len(NoSlash))
        if SubString ~= string.lower(NoSlash) or SubString == "" then continue end

        Suggest(Key, Parameters)
        return
    end
    ClearSuggest()
end

local function Changed()
    if string.len(InputBar.Text) == 0 then return end
    local NoSpace = string.gsub(InputBar.Text, "^%s+", "")

    if string.sub(NoSpace, 1, 1) ~= "/" then return end
    local RemoveSpacesAfterSlash = string.gsub(NoSpace, "^/%s+", "")

    AssumeCommand(string.split(RemoveSpacesAfterSlash, " ")[1])
end

InputBar.Changed:Connect(Changed)

return CmdParameter