local ParameterTrack = {}
ParameterTrack.__index = ParameterTrack

local Group = require(script.Group)

local function CleanString(Text)
    local RemoveSlash = string.gsub(Text, "/", "")
    local Result = string.gsub(RemoveSlash, " +", " ")
    local RemoveSpacesBeforeComma = string.gsub(Result, "%s*,%s*", ",")
    local RemoveTrailing = string.gsub(RemoveSpacesBeforeComma, "%s+$", "")

   return RemoveTrailing
end

function ParameterTrack.New(Parameters, SuggestionBar)
    local self = setmetatable({}, ParameterTrack)

    self.LastIndexes = 1
    self.SuggestBar = SuggestionBar
    self.Parameters = Parameters
    return self
end

function ParameterTrack:Highlight(Parameter : string)
    local ClearAllHighliths = string.gsub(self.SuggestBar.Text, `<font color="#FFFF00">{".-"}</font>`, "")
    local NewHighlight = string.gsub(ClearAllHighliths, Parameter, `<font color="#FFFF00">{Parameter}</font>`)

    self.SuggestBar.Text = NewHighlight
end

function ParameterTrack:Parameter(Text)
    local CurrentParam = string.split(Text, ",")
 
end

function ParameterTrack:Group(Text)
    local Groups = string.split(Text, " ")

    self:Highlight()
end

function ParameterTrack:Track(Text)
    
    local CleanString = CleanString(Text)
    self:Group(CleanString)
end

return ParameterTrack