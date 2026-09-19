local ParameterTrack = {}
ParameterTrack.__index = ParameterTrack

function ParameterTrack.CleanString(Text)
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
    local NewHighlight = string.gsub(self.SuggestBar.Text, Parameter, `<font color="#FFFF00">{Parameter}</font>`)
    self.SuggestBar.Text = NewHighlight
end

function ParameterTrack:GetParameters(Text)
    local CurrentParam = string.split(Text, ",")
    return #CurrentParam + 1
end

function ParameterTrack:Group(Text)
    local Groups = string.split(Text, " ")
    if #Groups == 1 then self:Highlight("/"..Groups[1]) return end
    if #Groups == 2 then self:Highlight(self.Parameters[1]) return end
    
    local ArguementFields = self:GetParameters(Groups[#Groups])
    if not self.Parameters[ArguementFields] then ArguementFields = #self.Parameters end 

    self:Highlight(self.Parameters[ArguementFields])
end

function ParameterTrack:Track(Text)
    local CleanString = ParameterTrack.CleanString(Text)
    
    self:Group(CleanString)
end

return ParameterTrack