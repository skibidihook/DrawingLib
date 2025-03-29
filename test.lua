local HttpService = game:GetService("HttpService")


local parent = (typeof(gethui) == "function" and gethui()) or game.CoreGui

local Library = {}
Library.Flags = {}
Library.FolderName = "FallenSurvivalPanicHook11
"

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
    deletefile(fileName)
    print("[Config] Deleted config:", configName)
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
        end
    end)
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
    btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Text = (opts.Name or "Toggle")..": "..(toggleFlag.Value and "ON" or "OFF")
    btn.Parent = self.SectionFrame
    
    btn.MouseButton1Click:Connect(function()
        local newVal = not toggleFlag.Value
        toggleFlag:Set(newVal)
        btn.Text = (opts.Name or "Toggle")..": "..(newVal and "ON" or "OFF")
    end)
    
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
    dropBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    dropBtn.TextColor3 = Color3.fromRGB(255,255,255)
    dropBtn.Text = (opts.Name or "Dropdown").." (Click)"
    dropBtn.Parent = self.SectionFrame
    
    local open = false
    local function refreshText()
        dropBtn.Text = (opts.Name or "Dropdown")..": "..(tostring(ddFlag.Value) or "None")
    end
    refreshText()
    
    dropBtn.MouseButton1Click:Connect(function()
        open = not open
        if open and #opts.Options > 0 then
            ddFlag:Set(opts.Options[1])
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
    sliderFrame.Size = UDim2.new(1, -10, 0, 30)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
    sliderFrame.Parent = self.SectionFrame
    
    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Size = UDim2.new(1, 0, 1, 0)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.TextColor3 = Color3.fromRGB(255,255,255)
    sliderLabel.Text = (opts.Name or "Slider")..": "..tostring(sliderFlag.Value)
    sliderLabel.Parent = sliderFrame

    sliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local newVal = sliderFlag.Value + (opts.Increment or 1)
            if newVal > (opts.Max or 100) then
                newVal = (opts.Max or 100)
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
    cpFrame.Size = UDim2.new(1, -10, 0, 60)
    cpFrame.BackgroundColor3 = Color3.fromRGB(45,45,45)
    cpFrame.Parent = self.SectionFrame
    
    local cpLabel = Instance.new("TextLabel")
    cpLabel.Size = UDim2.new(1, 0, 0, 20)
    cpLabel.BackgroundTransparency = 1
    cpLabel.TextColor3 = Color3.new(1,1,1)
    cpLabel.Text = opts.Name or "Colorpicker"
    cpLabel.Parent = cpFrame
    
    local cpButton = Instance.new("TextButton")
    cpButton.Size = UDim2.new(0, 50, 0, 20)
    cpButton.Position = UDim2.new(0, 5, 0, 30)
    cpButton.BackgroundColor3 = cpFlag.Value
    cpButton.Text = ""
    cpButton.Parent = cpFrame
    
    local currentColor = cpFlag.Value
    
    cpButton.MouseButton1Click:Connect(function()
        if currentColor == Color3.fromRGB(255,0,0) then
            currentColor = Color3.fromRGB(0,0,255)
        else
            currentColor = Color3.fromRGB(255,0,0)
        end
        cpFlag:Set(currentColor)
        cpButton.BackgroundColor3 = currentColor
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
    kbBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    kbBtn.TextColor3 = Color3.fromRGB(255,255,255)
    kbBtn.Text = (opts.Name or "Keybind")..": "..tostring(kbFlag.Value.Name or kbFlag.Value)
    kbBtn.Parent = self.SectionFrame

    kbBtn.MouseButton1Click:Connect(function()
        kbFlag:Set(Enum.KeyCode.F)
        kbBtn.Text = (opts.Name or "Keybind")..": F"
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
    lbLabel.BackgroundColor3 = Color3.fromRGB(60,60,60)
    lbLabel.TextColor3 = Color3.fromRGB(255,255,255)
    lbLabel.Text = "[Listbox] "..listbox.Name
    lbLabel.Parent = self.SectionFrame
    
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
    tb.BackgroundColor3 = Color3.fromRGB(60,60,60)
    tb.TextColor3 = Color3.fromRGB(255,255,255)
    tb.Text = textbox.Default
    tb.PlaceholderText = textbox.Placeholder
    tb.Parent = self.SectionFrame
    
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
    btn.BackgroundColor3 = Color3.fromRGB(80,80,80)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Text = button.Name
    btn.Parent = self.SectionFrame
    
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
    secFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
    secFrame.Size = UDim2.new(1, 0, 0, 200)
    secFrame.Parent = self.TabFrame
    
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0,5)
    layout.Parent = secFrame
    
    local secTitle = Instance.new("TextLabel")
    secTitle.Size = UDim2.new(1, 0, 0, 20)
    secTitle.BackgroundTransparency = 1
    secTitle.TextColor3 = Color3.fromRGB(255,255,255)
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
    tabBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
    tabBtn.TextColor3 = Color3.fromRGB(255,255,255)
    tabBtn.Text = tab.Name
    tabBtn.Parent = self.WindowFrame

    local tabFrame = Instance.new("Frame")
    tabFrame.Size = UDim2.new(1, -10, 1, -40)
    tabFrame.Position = UDim2.new(0, 5, 0, 35)
    tabFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
    tabFrame.Visible = false
    tabFrame.Parent = self.WindowFrame
    
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
    print("Rendering Window:", self.Name)
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
    mainFrame.Size = UDim2.new(0, 500, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
    mainFrame.Parent = gui
    
    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 30)
    topBar.BackgroundColor3 = Color3.fromRGB(15,15,15)
    topBar.Parent = mainFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.Text = win.Name
    title.Parent = topBar
    
    makeDraggable(mainFrame, topBar)
    
    win.WindowFrame = mainFrame
    win.Gui = gui
    
    print("[UI] Created Window:", win.Name)
    return win
end

return Library
