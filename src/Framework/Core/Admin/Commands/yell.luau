return function (self)
    self.Content = {Message = string.upper(self.Content), Type = "Yell", OverwriteWindow = true}
    return self
end