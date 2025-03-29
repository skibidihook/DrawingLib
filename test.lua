local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local parent = (typeof(gethui) == "function" and gethui()) or game.CoreGui

local Library = {}
Library.Flags = {}
Library.FolderName = "FallenSurvivalPanicHook11"

local function ensureFolderExists(folderPath)
    if not isfolder(Library.FolderName) then
        makefolder(Library.FolderName)
    end
    if folderPath and folderPath ~= "" then
        local full = Library.FolderName.."/"..folderPath
        if not isfolder(full) then
            makefolder(full)
        end
    end
end
ensureFolderExists("")
ensureFolderExists("Configs")

local function CreateFlag(options)
    local flag = {
        Name = options.Name or "Unnamed",
        Value = options.Default,
        Callback = options.Callback or function(_) end,
        Get = function(self)
            return self.Value
        end,
        Set = function(self, newValue)
            self.Value = newValue
            self.Callback(newValue)
        end,
    }
    Library.Flags[options.Flag] = flag
    return flag
end

function Library:Notify(message, duration, color)
    print("[Notify]", message, "(for "..tostring(duration or "default").."s)", color)
end

function Library:SaveConfig(configName)
    local config = {}
    for flagName, flagObj in pairs(Library.Flags) do
        config[flagName] = flagObj.Value
    end
    local jsonData = HttpService:JSONEncode(config)
    local fileName = self.FolderName.."/Configs/"..configName..".json"
    writefile(fileName, jsonData)
    print("[Config] Saved config:", configName)
end

function Library:DeleteConfig(configName)
    local fileName = self.FolderName.."/Configs/"..configName..".json"
    if isfile(fileName) then
        delfile(fileName)
        print("[Config] Deleted config:", configName)
    end
end

function Library:LoadConfig(jsonData)
    local config = HttpService:JSONDecode(jsonData)
    for flagName, value in pairs(config) do
        if Library.Flags[flagName] then
            Library.Flags[flagName]:Set(value)
        end
    end
    print("[Config] Loaded config.")
end

function Library:JSONEncode(tbl)
    return HttpService:JSONEncode(tbl)
end

function Library:JSONDecode(str)
    return HttpService:JSONDecode(str)
end

function Library:KeybindList()
    local KeybindList = {
        Visible = true,
        SetVisibility = function(self, vis)
            self.Visible = vis
            print("[KeybindList] Visibility set to:", vis)
        end
    }
    self.KeybindList = KeybindList
    return KeybindList
end

function Library:Watermark(options)
    local watermark = {
        Name = options.Name or "Watermark",
        Visible = true,
        SetVisibility = function(self, vis)
            self.Visible = vis
            print("[Watermark] Visibility set to:", vis)
        end
    }
    print("[Watermark] Created with name:", watermark.Name)
    return watermark
end

local function createScreenGui(name)
    local gui = Instance.new("ScreenGui")
    gui.Name = name
    gui.ResetOnSpawn = false
    gui.Parent = parent
    return gui
end

local function clampToScreen(frame)
    local parentGui = frame.Parent
    if not parentGui or not parentGui:IsA("ScreenGui") then return end
    
    local screenSize = parentGui.AbsoluteSize
    local x = math.clamp(frame.AbsolutePosition.X, 0, screenSize.X - frame.AbsoluteSize.X)
    local y = math.clamp(frame.AbsolutePosition.Y, 0, screenSize.Y - frame.AbsoluteSize.Y)
    frame.Position = UDim2.fromOffset(x, y)
end

local function makeDraggable(frame, dragBar)
    local dragging = false
    local dragStart, startPos
    
    dragBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    dragBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
            task.defer(clampToScreen, frame)
        end
    end)
end

local function applyBlueGradient(obj)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 20, 60)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 50, 100))
    })
    gradient.Rotation = 90
    gradient.Parent = obj
    return gradient
end

local Section = {}
Section.__index = Section

function Section:Toggle(opts)
    local toggleFlag = CreateFlag({
        Name = opts.Name,
        Flag = opts.Flag,
        Default = opts.Default or false,
        Callback = opts.Callback or function(_) end
    })
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 60)
    btn.TextColor3 = Color3.fromRGB(220,220,255)
    btn.Text = (opts.Name or "Toggle")..": "..(toggleFlag.Value and "ON" or "OFF")
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 18
    btn.Parent = self.SectionFrame

    applyBlueGradient(btn)
    
    btn.MouseButton1Click:Connect(function()
        local newVal = not toggleFlag.Value
        toggleFlag:Set(newVal)
        btn.Text = (opts.Name or "Toggle")..": "..(newVal and "ON" or "OFF")
    end)
    
    toggleFlag._section = self
    setmetatable(toggleFlag, {
        __index = function(t, k)
            return t._section[k]
        end
    })
    
    print("[UI] Created Toggle:", opts.Name or "Toggle")
    return toggleFlag
end

function Section:Dropdown(opts)
    local ddFlag = CreateFlag({
        Name = opts.Name,
        Flag = opts.Flag,
        Default = opts.Default,
        Callback = opts.Callback or function(_) end
    })
    
    local dropBtn = Instance.new("TextButton")
    dropBtn.Size = UDim2.new(1, -10, 0, 30)
    dropBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 60)
    dropBtn.TextColor3 = Color3.fromRGB(220,220,255)
    dropBtn.Text = (opts.Name or "Dropdown").." (Click)"
    dropBtn.Font = Enum.Font.SourceSans
    dropBtn.TextSize = 18
    dropBtn.Parent = self.SectionFrame
    
    applyBlueGradient(dropBtn)
    
    local open = false
    local function refreshText()
        dropBtn.Text = (opts.Name or "Dropdown")..": "..(tostring(ddFlag.Value) or "None")
    end
    refreshText()

    dropBtn.MouseButton1Click:Connect(function()
        if not opts.Options or #opts.Options == 0 then return end
        open = not open
        if open then
            local currentIndex = table.find(opts.Options, ddFlag.Value) or 0
            local nextIndex = (currentIndex % #opts.Options) + 1
            ddFlag:Set(opts.Options[nextIndex])
            refreshText()
        end
    end)
    
    print("[UI] Created Dropdown:", opts.Name or "Dropdown")
    return ddFlag
end

function Section:Slider(opts)
    local sliderFlag = CreateFlag({
        Name = opts.Name,
        Flag = opts.Flag,
        Default = opts.Default or 0,
        Callback = opts.Callback or function(_) end
    })
    
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, -10, 0, 40)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(30,30,50)
    sliderFrame.Parent = self.SectionFrame
    applyBlueGradient(sliderFrame)
    
    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Size = UDim2.new(1, 0, 0, 20)
    sliderLabel.Position = UDim2.new(0, 0, 0, 0)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.TextColor3 = Color3.fromRGB(220,220,255)
    sliderLabel.Text = (opts.Name or "Slider")..": "..tostring(sliderFlag.Value)
    sliderLabel.Font = Enum.Font.SourceSans
    sliderLabel.TextSize = 18
    sliderLabel.Parent = sliderFrame

    sliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local increment = opts.Increment or 1
            local newVal = sliderFlag.Value + increment
            local maxVal = opts.Max or 100
            local minVal = opts.Min or 0
            if newVal > maxVal then
                newVal = minVal
            end
            sliderFlag:Set(newVal)
            sliderLabel.Text = (opts.Name or "Slider")..": "..tostring(newVal)
        end
    end)
    
    print("[UI] Created Slider:", opts.Name or "Slider")
    return sliderFlag
end

function Section:Colorpicker(opts)
    local cpFlag = CreateFlag({
        Name = opts.Name,
        Flag = opts.Flag,
        Default = opts.Default or Color3.fromRGB(255,255,255),
        Callback = opts.Callback or function(_) end
    })

    local cpFrame = Instance.new("Frame")
    cpFrame.Size = UDim2.new(1, -10, 0, 100)
    cpFrame.BackgroundColor3 = Color3.fromRGB(30,30,50)
    cpFrame.Parent = self.SectionFrame
    applyBlueGradient(cpFrame)

    local cpLabel = Instance.new("TextLabel")
    cpLabel.Size = UDim2.new(1, 0, 0, 20)
    cpLabel.BackgroundTransparency = 1
    cpLabel.TextColor3 = Color3.new(1,1,1)
    cpLabel.Text = opts.Name or "Colorpicker"
    cpLabel.Font = Enum.Font.SourceSans
    cpLabel.TextSize = 18
    cpLabel.Parent = cpFrame

    local cpButton = Instance.new("TextButton")
    cpButton.Size = UDim2.new(0, 40, 0, 20)
    cpButton.Position = UDim2.new(0, 5, 0, 30)
    cpButton.BackgroundColor3 = cpFlag.Value
    cpButton.Text = ""
    cpButton.Parent = cpFrame
    applyBlueGradient(cpButton)

    local hueBar = Instance.new("Frame")
    hueBar.Size = UDim2.new(0, 15, 0, 60)
    hueBar.Position = UDim2.new(0, 50, 0, 30)
    hueBar.BorderSizePixel = 1
    hueBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    hueBar.Parent = cpFrame

    local hueGradient = Instance.new("UIGradient")
    hueGradient.Rotation = 90
    hueGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,0,0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255,0,255)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,0,255)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0,255,255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,255,0)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,255,0)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255,0,0))
    })
    hueGradient.Parent = hueBar

    local satValBox = Instance.new("Frame")
    satValBox.Size = UDim2.new(0, 100, 0, 60)
    satValBox.Position = UDim2.new(0, 70, 0, 30)
    satValBox.BorderSizePixel = 1
    satValBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    satValBox.Parent = cpFrame

    local satGradient = Instance.new("UIGradient")
    satGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
        ColorSequenceKeypoint.new(1, Color3.new(1,1,1))
    })
    satGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    })
    satGradient.Rotation = 0
    satGradient.Parent = satValBox

    local valGradient = Instance.new("Frame")
    valGradient.Size = UDim2.new(1, 0, 1, 0)
    valGradient.BackgroundColor3 = Color3.new(0,0,0)
    valGradient.Parent = satValBox

    local valUIGrad = Instance.new("UIGradient")
    valUIGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(0,0,0)),
        ColorSequenceKeypoint.new(1, Color3.new(0,0,0))
    })
    valUIGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0)
    })
    valUIGrad.Rotation = 90
    valUIGrad.Parent = valGradient

    local hue, sat, val = 0, 0, 1

    local function colorToHSV(col)
        return Color3.toHSV(col)
    end
    local function hsvToColor(h, s, v)
        return Color3.fromHSV(h, s, v)
    end

    local function updateColor(newHue, newSat, newVal)
        hue, sat, val = newHue, newSat, newVal
        local c = hsvToColor(hue, sat, val)
        cpFlag:Set(c)
        cpButton.BackgroundColor3 = c
        satValBox.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
    end

    do
        local h, s, v = colorToHSV(cpFlag.Value)
        hue, sat, val = h, s, v
        cpButton.BackgroundColor3 = cpFlag.Value
        satValBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
    end

    hueBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local moveConn
            local releaseConn

            local function updateHue(inputPos)
                local relY = math.clamp(inputPos.Y - hueBar.AbsolutePosition.Y, 0, hueBar.AbsoluteSize.Y)
                local newH = relY / hueBar.AbsoluteSize.Y
                updateColor(newH, sat, val)
            end

            updateHue(input.Position)

            moveConn = UserInputService.InputChanged:Connect(function(mInput)
                if mInput.UserInputType == Enum.UserInputType.MouseMovement then
                    updateHue(mInput.Position)
                end
            end)
            releaseConn = UserInputService.InputEnded:Connect(function(eInput)
                if eInput.UserInputType == Enum.UserInputType.MouseButton1 then
                    if moveConn then moveConn:Disconnect() end
                    if releaseConn then releaseConn:Disconnect() end
                end
            end)
        end
    end)

    satValBox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local moveConn
            local releaseConn

            local function updateSV(inputPos)
                local relX = math.clamp(inputPos.X - satValBox.AbsolutePosition.X, 0, satValBox.AbsoluteSize.X)
                local relY = math.clamp(inputPos.Y - satValBox.AbsolutePosition.Y, 0, satValBox.AbsoluteSize.Y)
                local newS = relX / satValBox.AbsoluteSize.X
                local newV = 1 - (relY / satValBox.AbsoluteSize.Y)
                updateColor(hue, newS, newV)
            end

            updateSV(input.Position)

            moveConn = UserInputService.InputChanged:Connect(function(mInput)
                if mInput.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSV(mInput.Position)
                end
            end)
            releaseConn = UserInputService.InputEnded:Connect(function(eInput)
                if eInput.UserInputType == Enum.UserInputType.MouseButton1 then
                    if moveConn then moveConn:Disconnect() end
                    if releaseConn then releaseConn:Disconnect() end
                end
            end)
        end
    end)

    cpButton.MouseButton1Click:Connect(function()
        updateColor(0, 0, 1)
    end)

    print("[UI] Created Colorpicker:", opts.Name or "Colorpicker")
    return cpFlag
end

function Section:Keybind(opts)
    local kbFlag = CreateFlag({
        Name = opts.Name,
        Flag = opts.Flag,
        Default = opts.Default or Enum.KeyCode.RightShift,
        Callback = opts.Callback or function(_) end
    })
    
    local kbBtn = Instance.new("TextButton")
    kbBtn.Size = UDim2.new(1, -10, 0, 30)
    kbBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 60)
    kbBtn.TextColor3 = Color3.fromRGB(220,220,255)
    kbBtn.Text = (opts.Name or "Keybind")..": "..tostring(kbFlag.Value.Name or kbFlag.Value)
    kbBtn.Font = Enum.Font.SourceSans
    kbBtn.TextSize = 18
    kbBtn.Parent = self.SectionFrame
    applyBlueGradient(kbBtn)

    kbBtn.MouseButton1Click:Connect(function()
        kbBtn.Text = "Press any key..."
        local conn
        conn = UserInputService.InputBegan:Connect(function(input, gp)
            if not gp then
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    kbFlag:Set(input.KeyCode)
                    kbBtn.Text = (opts.Name or "Keybind")..": "..tostring(input.KeyCode.Name)
                    conn:Disconnect()
                end
            end
        end)
    end)
    
    print("[UI] Created Keybind:", opts.Name or "Keybind")
    return kbFlag
end

function Section:Listbox(opts)
    local listbox = {
        Name = opts.Name or "Listbox",
        Flag = opts.Flag,
        Options = opts.Options or {},
        Selected = nil,
        AddOption = function(self, option)
            table.insert(self.Options, option)
        end,
        RemoveOption = function(self, option)
            for i,v in ipairs(self.Options) do
                if v == option then
                    table.remove(self.Options, i)
                    break
                end
            end
        end
    }
    
    local lbLabel = Instance.new("TextLabel")
    lbLabel.Size = UDim2.new(1, -10, 0, 30)
    lbLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 60)
    lbLabel.TextColor3 = Color3.fromRGB(220,220,255)
    lbLabel.Text = "[Listbox] "..listbox.Name
    lbLabel.Font = Enum.Font.SourceSans
    lbLabel.TextSize = 18
    lbLabel.Parent = self.SectionFrame
    applyBlueGradient(lbLabel)
    
    print("[UI] Created Listbox:", listbox.Name)
    return listbox
end

function Section:Textbox(opts)
    local textbox = {
        Name = opts.Name or "Textbox",
        Flag = opts.Flag,
        Placeholder = opts.Placeholder or "",
        Compact = opts.Compact or false,
        Default = opts.Default or "",
        Value = opts.Default or ""
    }
    
    local tb = Instance.new("TextBox")
    tb.Size = UDim2.new(1, -10, 0, 30)
    tb.BackgroundColor3 = Color3.fromRGB(35, 35, 60)
    tb.TextColor3 = Color3.fromRGB(220,220,255)
    tb.Text = textbox.Default
    tb.PlaceholderText = textbox.Placeholder
    tb.Font = Enum.Font.SourceSans
    tb.TextSize = 18
    tb.Parent = self.SectionFrame
    applyBlueGradient(tb)
    
    tb.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            textbox.Value = tb.Text
        end
    end)
    
    print("[UI] Created Textbox:", textbox.Name)
    return textbox
end

function Section:Button(opts)
    local button = {
        Name = opts.Name or "Button",
        Callback = opts.Callback or function() end,
        SubButtons = {}
    }
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 75)
    btn.TextColor3 = Color3.fromRGB(220,220,255)
    btn.Text = button.Name
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 18
    btn.Parent = self.SectionFrame
    applyBlueGradient(btn)
    
    btn.MouseButton1Click:Connect(function()
        button.Callback()
    end)
    
    function button:Sub(subOpts)
        local subButton = {
            Name = subOpts.Name or "SubButton",
            Callback = subOpts.Callback or function() end
        }
        table.insert(self.SubButtons, subButton)
        print("[UI] Created Sub Button:", subButton.Name, "for Button:", self.Name)
        return subButton
    end
    
    print("[UI] Created Button:", button.Name)
    return button
end

local Tab = {}
Tab.__index = Tab

function Tab:Section(sectionOptions)
    local section = setmetatable({}, Section)
    section.Name = sectionOptions.Name or "Section"
    section.Side = sectionOptions.Side or "Left"
    section.Elements = {}
    
    local secFrame = Instance.new("Frame")
    secFrame.BackgroundColor3 = Color3.fromRGB(25,25,45)
    secFrame.Size = UDim2.new(1, 0, 0, 200)
    secFrame.Parent = self.TabFrame
    applyBlueGradient(secFrame)

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0,5)
    layout.Parent = secFrame
    
    local secTitle = Instance.new("TextLabel")
    secTitle.Size = UDim2.new(1, 0, 0, 20)
    secTitle.BackgroundTransparency = 1
    secTitle.TextColor3 = Color3.fromRGB(255,255,255)
    secTitle.Font = Enum.Font.SourceSansBold
    secTitle.TextSize = 20
    secTitle.Text = section.Name
    secTitle.Parent = secFrame
    
    section.SectionFrame = secFrame
    print("[UI] Created Section:", section.Name)
    table.insert(self.Sections, section)
    return section
end

local Window = {}
Window.__index = Window

function Window:Tab(options)
    local tab = setmetatable({}, Tab)
    tab.Name = options.Name or "Tab"
    tab.Sections = {}

    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0, 100, 0, 30)
    tabBtn.Position = UDim2.new(0, #self.Tabs * 110, 0, 0)
    tabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 60)
    tabBtn.TextColor3 = Color3.fromRGB(220,220,255)
    tabBtn.Text = tab.Name
    tabBtn.Font = Enum.Font.SourceSans
    tabBtn.TextSize = 18
    tabBtn.Parent = self.WindowFrame
    applyBlueGradient(tabBtn)

    local tabFrame = Instance.new("Frame")
    tabFrame.Size = UDim2.new(1, -10, 1, -40)
    tabFrame.Position = UDim2.new(0, 5, 0, 35)
    tabFrame.BackgroundColor3 = Color3.fromRGB(20,20,35)
    tabFrame.Visible = false
    tabFrame.Parent = self.WindowFrame
    applyBlueGradient(tabFrame)
    
    tab.TabButton = tabBtn
    tab.TabFrame = tabFrame

    tabBtn.MouseButton1Click:Connect(function()
        for _, otherTab in ipairs(self.Tabs) do
            otherTab.TabFrame.Visible = false
        end
        tabFrame.Visible = true
    end)
    
    print("[UI] Created Tab:", tab.Name)
    table.insert(self.Tabs, tab)
    return tab
end

function Window:Render()
    if self.Tabs[1] then
        self.Tabs[1].TabFrame.Visible = true
    end
    print("[UI] Rendering Window:", self.Name)
end

function Library:Window(options)
    if typeof(options) == "string" then
        options = {Name = options}
    end
    
    local win = setmetatable({}, Window)
    win.Name = options.Name or "Window"
    win.Tabs = {}
    
    local gui = createScreenGui(win.Name.."_GUI")

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 650, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -325, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15,15,30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = gui
    applyBlueGradient(mainFrame)

    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 30)
    topBar.BackgroundColor3 = Color3.fromRGB(10,10,25)
    topBar.BorderSizePixel = 0
    topBar.Parent = mainFrame
    applyBlueGradient(topBar)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 20
    title.Text = win.Name
    title.Parent = topBar
    
    makeDraggable(mainFrame, topBar)
    
    win.WindowFrame = mainFrame
    win.Gui = gui
    
    print("[UI] Created Window:", win.Name)
    return win
end

return Library
