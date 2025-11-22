local resourceName = GetCurrentResourceName()

CreateThread(function()
    print(('[%s] server started'):format(resourceName))
end)
