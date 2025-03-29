local library = {}
library.__index = library

library.objects = {}

function library:Window(windowTitle)
    local window = {}
    setmetatable(window, {__index = self})

    local parent = (typeof(gethui) == "function" and gethui()) or game.CoreGui
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = windowTitle or "MyCustomUI"
    screenGui.Parent = parent

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 400, 0, 300)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    titleLabel.BorderSizePixel = 0
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Text = windowTitle or "Window"
    titleLabel.Parent = mainFrame

    window.ScreenGui = screenGui
    window.MainFrame = mainFrame

    window.NextControlY = 40
    
    return window
end
function library:Toggle(toggleName, defaultValue, callback)
    local toggleData = {}
    toggleData.Name = toggleName
    toggleData.Value = (typeof(defaultValue) == "boolean") and defaultValue or false
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = toggleName
    toggleButton.Size = UDim2.new(0, 120, 0, 30)
    toggleButton.Position = UDim2.new(0, 10, 0, self.NextControlY)
    toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.Text = toggleName..": "..(toggleData.Value and "ON" or "OFF")
    toggleButton.Parent = self.MainFrame
    
    self.NextControlY = self.NextControlY + 40
    
    toggleButton.MouseButton1Click:Connect(function()
        toggleData.Value = not toggleData.Value
        toggleButton.Text = toggleName..": "..(toggleData.Value and "ON" or "OFF")
        if callback then
            callback(toggleData.Value)
        end
    end)
    
    function toggleData:Get()
        return toggleData.Value
    end
    
    self.objects[toggleName] = toggleData
    return toggleData
end

function library:Colorpicker(pickerName, defaultColor, callback)
    local pickerData = {}
    pickerData.Name = pickerName
    pickerData.Value = defaultColor or Color3.fromRGB(255, 255, 255)
    
    local pickerButton = Instance.new("TextButton")
    pickerButton.Name = pickerName
    pickerButton.Size = UDim2.new(0, 120, 0, 30)
    pickerButton.Position = UDim2.new(0, 10, 0, self.NextControlY)
    pickerButton.BackgroundColor3 = pickerData.Value
    pickerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    pickerButton.Text = pickerName
    pickerButton.Parent = self.MainFrame
    
    self.NextControlY = self.NextControlY + 40
    
    local pickerFrame = Instance.new("Frame")
    pickerFrame.Size = UDim2.new(0, 180, 0, 120)
    pickerFrame.Position = UDim2.new(0, 140, 0, pickerButton.Position.Y.Offset)
    pickerFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    pickerFrame.Visible = false
    pickerFrame.Parent = self.MainFrame
    
    local confirmButton = Instance.new("TextButton")
    confirmButton.Size = UDim2.new(0, 100, 0, 30)
    confirmButton.Position = UDim2.new(0.5, -50, 0.5, -15)
    confirmButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    confirmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    confirmButton.Text = "Confirm"
    confirmButton.Parent = pickerFrame
    
    pickerButton.MouseButton1Click:Connect(function()
        pickerFrame.Visible = not pickerFrame.Visible
    end)

    local currentColor = pickerData.Value
    
    local function cycleColor()
        if currentColor == Color3.fromRGB(255, 0, 0) then
            currentColor = Color3.fromRGB(0, 0, 255)
        else
            currentColor = Color3.fromRGB(255, 0, 0)
        end
    end
    
    confirmButton.MouseButton1Click:Connect(function()
        cycleColor()
        pickerData.Value = currentColor
        pickerButton.BackgroundColor3 = currentColor
        pickerFrame.Visible = false
        if callback then
            callback(pickerData.Value)
        end
    end)
    
    function pickerData:Get()
        return pickerData.Value
    end
    
    self.objects[pickerName] = pickerData
    return pickerData
end

return library
