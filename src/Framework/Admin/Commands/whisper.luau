return function (self)
    self.Content = {Message = "[W] "..(self.Content), Type = "Whisper"}
    return self
end