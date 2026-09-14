return function (self)
    self.Content = {Text = string.upper(self.Content), Type = "Yell", WindowOverwrite = true}
    return self
end