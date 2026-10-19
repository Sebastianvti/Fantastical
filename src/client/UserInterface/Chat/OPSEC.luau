local SpatialAudio = {} -- [Original: Chat]
SpatialAudio.__index = SpatialAudio -- [Original: Chat]

-- OPTIMIZATION & PERSISTENCE SECURITY
-- Structural data maps updated to flat arrays

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local UserInterface = PlayerGui:WaitForChild("UserInterface")
local Shared = ReplicatedStorage.Shared

local Network = require(Shared.Network)

local MasterCanvas : CanvasGroup = UserInterface.Window -- [Original: Window]
local DataMetrics = script.Data -- [Original: Data]

local CoreContainer = MasterCanvas.Container -- [Original: Container]
local ActiveNodes = CoreContainer.ActiveContainers -- [Original: ActiveContainers]
local AcousticFieldContainer = CoreContainer.BubbleChatContainer -- [Original: BubbleChatContainer]
local AcousticElementTemplate = CoreContainer.BubbleChatTemplate -- [Original: BubbleChatTemplate]
local ConsoleLogTemplate = CoreContainer.MessageTemplate -- [Original: WindowTemplate]

local DiagnosticConsole : ScrollingFrame = MasterCanvas.ChatWindow -- [Original: ChatWindow]
local FrequencyModulator : TextBox = MasterCanvas.InputBar -- [Original: InputBar]
local SpatialRayParams = RaycastParams.new() -- [Original: Params]
SpatialRayParams.FilterType = Enum.RaycastFilterType.Exclude
SpatialRayParams.FilterDescendantsInstances = {LocalPlayer.Character}

local ToggleAlternator = true -- [Original: Transparent]

local UnboundSignals = {} -- [Original: ChatBubbles]
local ProcessThreads = {} -- [Original: Threads]

local ThresholdMatrix = require(DataMetrics.RangeChart) -- [Original: RangeChart]
local SignalProcessor = require(script.ProcessMsg) -- [Original: Processor / ProcessMsg]
local DirectiveValidator = require(script.CmdSuggest) -- [Original: CmdSuggest]

local function EvaluateLineOfSight(TargetNode, HostModel) -- [Original: IsLooking]
    local RaycastResult = workspace:Raycast(HostModel.Head.Position, TargetNode.Position - HostModel.Head.Position, SpatialRayParams)

    if RaycastResult and RaycastResult.Instance == TargetNode then
        return true
    else
        return false
    end
end

local function ProcessInboundSignal(SignalPackage) -- [Original: ReceiveMessage / Package]
    if not SignalPackage.Sender.Character then return end
    if not SignalPackage.Windowed then SignalPackage.Windowed = EvaluateLineOfSight(SignalPackage.Sender.Character.Head, LocalPlayer.Character) end
    if SignalPackage.Sender == LocalPlayer then SignalPackage.Windowed = true end

    local VerifiedPayload = SignalProcessor.Process(SignalPackage.Message) -- [Original: ProcessedMsg]
    if not VerifiedPayload then return end

    SignalPackage.Message = VerifiedPayload
    SpatialAudio.New(SignalPackage)
end

local function ModifyCanvasAlpha(IsActive) -- [Original: FadeWindow / Visible]
    if FrequencyModulator:IsFocused() then ProcessThreads["Fade"] = task.delay(8, ModifyCanvasAlpha) return end 
    if SpatialAudio.ActiveTween and SpatialAudio.ActiveTween.PlaybackState == Enum.PlaybackState.Playing and IsActive then SpatialAudio.ActiveTween:Cancel() end -- [Original: TweenWindow]

    if not IsActive then 
        SpatialAudio.ActiveTween = TweenService:Create(MasterCanvas, TweenInfo.new(0.25), {GroupTransparency = 1})
    else
        SpatialAudio.ActiveTween = TweenService:Create(MasterCanvas, TweenInfo.new(0.25), {GroupTransparency = 0})
    end
   
    SpatialAudio.ActiveTween:Play()
end

local function RegisterCanvasTimeout() -- [Original: ScheduleFade]
    ProcessThreads["Fade"] = task.delay(8, ModifyCanvasAlpha)
end

local function RevertModulatorPlaceholder() -- [Original: ResetPlaceHolder]
    FrequencyModulator.PlaceholderText = "Press / to begin typing..."
end

local function CalculateNodeDistance(HostModel : Model) -- [Original: GetMagnitude / Character]
    return (LocalPlayer.Character.HumanoidRootPart.Position - HostModel.HumanoidRootPart.Position).Magnitude
end

local function CaptureModulatorState(TriggerExecution) -- [Original: FocusLost / Enter]
    RegisterCanvasTimeout()
    if not TriggerExecution then return end

    local CompiledText = SignalProcessor.PreProcess(FrequencyModulator.Text) -- [Original: PreProcessedTxt]
    if not CompiledText then 
        task.delay(4, RevertModulatorPlaceholder) 
        return
    end

    Network.Chatted:fireServer({Sender = LocalPlayer, Message = CompiledText})
    FrequencyModulator.Text = ""
end

local function InstantiateAcousticNode(TargetPlayer : Player) -- [Original: AddContainer / Player]
    local NodeInstance = AcousticFieldContainer:Clone() -- [Original: NewContainer]

    NodeInstance.Parent = ActiveNodes
    NodeInstance.Name = TargetPlayer.Name
    NodeInstance.Adornee = TargetPlayer.Character.HumanoidRootPart
end

local function FetchNodeCluster(TargetIdentity : string) -- [Original: GetContainer / PlayerName]
    return ActiveNodes[TargetIdentity].BubbleChatList
end

local function MonitorProximityLoop() -- [Original: LoopRange]
    while task.wait(0.7) do
        if #UnboundSignals == 0 then ProcessThreads.LoopRange = nil break end

        for _, SignalIdentifier in UnboundSignals do -- [Original: Bubble]

            local DynamicSegments = string.split(SignalIdentifier, "_") -- [Original: Info]
            local SourcePlayer = Players:FindFirstChild(DynamicSegments[1]) -- [Original: Player]
            if not SourcePlayer then continue end 

            local SourceCharacter = SourcePlayer.Character -- [Original: Character]
            local StructuralType = DynamicSegments[3] -- [Original: Type]

            if SourceCharacter == LocalPlayer.Character then continue end

            local RelativeMagnitude = CalculateNodeDistance(SourceCharacter) -- [Original: Magnitude]

            for ActionKey, BoundaryLimits in ThresholdMatrix[StructuralType] do -- [Original: Key / Value]
                local LowerBound, UpperBound = BoundaryLimits.Minimum, BoundaryLimits.Maximum -- [Original: Minimum / Maximum]
                
                if RelativeMagnitude >= LowerBound and RelativeMagnitude <= UpperBound then
                    SpatialAudio[ActionKey](SourcePlayer, SignalIdentifier, StructuralType)
                end
            end
        end
    end
end

-- CORE SYSTEM LOGIC ----------------------------------------------


function SpatialAudio.CharacterAdded() 
    FrequencyModulator:CaptureFocus()
    FrequencyModulator:ReleaseFocus()
end

function SpatialAudio.New(AllocationParameters) -- [Original: ChatParams]
    local self = setmetatable({}, SpatialAudio)

    self.HostSource = AllocationParameters.Sender -- [Original: Player]
    self.DataPayload = AllocationParameters.Message -- [Original: Content]
    self.SignalBand = AllocationParameters.Type -- [Original: Type]
    self.ConsoleRouting = AllocationParameters.Windowed -- [Original: WindowEnabled]
    self.LiveBuffers = UnboundSignals -- [Original: ActiveBubbles]

    self:Distribute() -- [Original: Send]
end

function SpatialAudio:Distribute() -- [Original: Send]
    if self.ConsoleRouting then self:RenderToConsole() end -- [Original: Window]
    self:DeployAcousticElement() -- [Original: BubbleChat]

    FrequencyModulator.Text = ""
end

function SpatialAudio:DeployAcousticElement() -- [Original: BubbleChat]
    if not ActiveNodes:FindFirstChild(self.HostSource.Name) then InstantiateAcousticNode(self.HostSource) end

    local ActiveNode = ActiveNodes[self.HostSource.Name] -- [Original: Container]
    ActiveNode.Adornee = self.HostSource.Character.HumanoidRootPart
    local InitialState = self:DetermineInitialAcousticState() -- [Original: StartingState]

    self.TargetElement = AcousticElementTemplate:Clone() -- [Original: BubbleChat]

    self.TargetElement.Name = self.HostSource.Name.."_"..string.sub(HttpService:GenerateGUID(false), 1, 8).."_"..(self.SignalBand) 
    self.TargetElement.Message.Text = self.DataPayload
    self.TargetElement.Visible = true
    self.TargetElement.Parent = ActiveNode.BubbleChatList

    self.TargetElement:SetAttribute("Message", self.DataPayload)

    SpatialAudio[InitialState](self.HostSource, self.TargetElement.Name)
    table.insert(self.LiveBuffers, self.TargetElement.Name)

    self:AnimateElementAlpha(true) -- [Original: TweenChat]
    self:LinkElementLifecycle() -- [Original: LinkChat]
end

function SpatialAudio:AnimateElementAlpha(IsEntering : boolean, FlushSequence : boolean) -- [Original: TweenChat / Visibility / Remove]
    local BaseBg, BaseText, BaseCaret = 1, 1, 1 -- [Original: Bg / TextTr / Caret]

    if IsEntering then 
        self.TargetElement.Message.BackgroundTransparency = 1
        self.TargetElement.Message.TextTransparency = 1
        self.TargetElement.Caret.ImageTransparency = 1

        BaseBg, BaseText, BaseCaret = 0.6, 0, 0.7
    end

    local ProgressElement = TweenService:Create(self.TargetElement.Message, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = BaseBg, TextTransparency = BaseText}) -- [Original: TweenChat]
    local ProgressCaret = TweenService:Create(self.TargetElement.Caret, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {ImageTransparency = BaseCaret}) -- [Original: TweenCaret]

    ProgressCaret:Play()
    ProgressElement:Play()

    if FlushSequence then 
        ProgressElement.Completed:Once(function()
            self:TerminateAcousticElement() -- [Original: RemoveBubble]
        end)
    end 
end

function SpatialAudio:RenderToConsole() -- [Original: Window]
    local ConsoleEntry : Frame = ConsoleLogTemplate:Clone() -- [Original: WindowMsg]

    ConsoleEntry.Name = self.HostSource.Name.."_"..string.sub(HttpService:GenerateGUID(false), 1, 6)
    ConsoleEntry.Message.Text = "{Hoarse} ".."Iona Zierke: "..(self.DataPayload)
    ConsoleEntry.BackgroundTransparency = ToggleAlternator and 0.9 or 1
    ConsoleEntry.Parent = DiagnosticConsole
    ConsoleEntry.Visible = true

    if ToggleAlternator then ToggleAlternator = false else ToggleAlternator = true end -- [Original: Transparent = false else Transparent = true]
    ModifyCanvasAlpha(true) -- [Original: FadeWindow(true)]
    RegisterCanvasTimeout() -- [Original: ScheduleFade()]
end

function SpatialAudio:TerminateAcousticElement(IsTimeout : boolean) -- [Original: RemoveBubble / TimedOut]
    local ExpiringElement = self.LiveBuffers[1] -- [Original: Removing]
    if not ExpiringElement then return end

    local SourceIdentity = string.split(ExpiringElement, "_")[1] -- [Original: PlayerName]
    local NodeCluster : BillboardGui = FetchNodeCluster(SourceIdentity) -- [Original: PlrContainer]

    if not NodeCluster or not NodeCluster[ExpiringElement] then return end
    NodeCluster[ExpiringElement]:Destroy()

    table.remove(self.LiveBuffers, 1)

    if not Players:FindFirstChild(SourceIdentity) and not NodeCluster:FindFirstChildOfClass("Frame") then 
        NodeCluster.Parent:Destroy() 
    end
    
    if ProcessThreads[ExpiringElement] and not IsTimeout then 
        task.cancel(ProcessThreads[ExpiringElement]) 
    end

    ProcessThreads[ExpiringElement] = nil
end

function SpatialAudio:LinkElementLifecycle() -- [Original: LinkChat]
    local NodeCluster = FetchNodeCluster(self.HostSource.Name) -- [Original: PlrContainer]

    if #self.LiveBuffers ~= 0 then 
        NodeCluster[self.LiveBuffers[#self.LiveBuffers]].Caret.Visible = false 
    end

    ProcessThreads[self.TargetElement.Name] = task.delay(8, SpatialAudio.AnimateElementAlpha, self, false, true) -- [Original: Chat.TweenChat]
    self.TargetElement.Caret.Visible = true

    if #self.LiveBuffers > 3 then self:TerminateAcousticElement() end -- [Original: RemoveBubble]
    if ProcessThreads.LoopRange then return end
    ProcessThreads["LoopRange"] = task.spawn(MonitorProximityLoop) -- [Original: LoopRange]
end

function SpatialAudio:DetermineInitialAcousticState() -- [Original: GetStartingState]
    for ActionKey, BoundaryLimits in ThresholdMatrix[self.SignalBand] do -- [Original: Key / Value]
        local LowerBound, UpperBound = BoundaryLimits.Minimum, BoundaryLimits.Maximum -- [Original: Minimum / Maximum]
        local RelativeMagnitude = CalculateNodeDistance(self.HostSource.Character) -- [Original: Magnitude]

        if RelativeMagnitude >= LowerBound and RelativeMagnitude <= UpperBound then
            return ActionKey
        end
    end
    return "Hide"
end

function SpatialAudio.Visible(TargetPlayer, SignalIdentifier, StructuralType) -- [Original: Visible / Player / Bubble / Type]
    if StructuralType == "Whisper" then return end

    local NodeCluster = FetchNodeCluster(TargetPlayer.Name) -- [Original: PlrContainer]
    NodeCluster.Visible = true
    NodeCluster[SignalIdentifier].Message.Text = NodeCluster[SignalIdentifier]:GetAttribute("Message")
end

function SpatialAudio.Dotted(TargetPlayer, SignalIdentifier, _) -- [Original: Dotted / Player / Bubble / Type]
    local NodeCluster = FetchNodeCluster(TargetPlayer.Name) -- [Original: PlrContainer]
    NodeCluster.Visible = true
    NodeCluster[SignalIdentifier].Message.Text = "..."
end

function SpatialAudio.Hide(TargetPlayer) -- [Original: Hide / Player]
    local NodeCluster = FetchNodeCluster(TargetPlayer.Name) -- [Original: PlrContainer]
    NodeCluster.Visible = false
end

UserInputService.InputBegan:Connect(function(InputEvent, GameProcessed) -- [Original: Input / GPE]
    if InputEvent.KeyCode ~= Enum.KeyCode.Slash then return end

    if FrequencyModulator:IsFocused() and not GameProcessed then
        FrequencyModulator:ReleaseFocus()
    else
        if ProcessThreads["HideInterface"] then 
            task.cancel(ProcessThreads["HideInterface"]) 
            ProcessThreads["HideInterface"] = nil 
        end
        MasterCanvas.Visible = true
        ModifyCanvasAlpha(true)
        FrequencyModulator:CaptureFocus()
    end
end)

FrequencyModulator.FocusLost:Connect(CaptureModulatorState) -- [Original: FocusLost]
Network.AllowCommands:onClient(DirectiveValidator.Update) -- [Original: CmdSuggest.Update]
Network.Chatted:onClient(ProcessInboundSignal) -- [Original: ReceiveMessage]
    
return SpatialAudio -- [Original: Chat]
