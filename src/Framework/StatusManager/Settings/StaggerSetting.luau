return function(Package)
    if not Package.Setting.Staggered then return {Result = true} end
    return {Result = true}
end
