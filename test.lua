local HttpService = game:GetService("HttpService")

-------------------------------------------------------------------
-- Try to parent to gethui(), fallback to CoreGui
-------------------------------------------------------------------
local parent = (typeof(gethui) == "function" and gethui()) or game.CoreGui

-------------------------------------------------------------------
-- Create the main Library table
-------------------------------------------------------------------
local Library = {}
Library.Flags = {}                   -- All element states go here
Library.FolderName = "MyUILibraryConfigs"

-------------------------------------------------------------------
-- Utility: create a "Flag object" in Library.Flags
-------------------------------------------------------------------
local function CreateFlag(opts)
    local flagObj = {
        Name = opts.Name or "Unnamed",
        Value = opts.Default,
        Callback = opts.Callback or function(_) end,
        Get = function(self)
            return self.Value
        end,
        Set = function(self, val)
            self.Value = val
            self.Callback(val)
        end,
    }
    -- Store by Flag name
    Library.Flags[opts.Flag] = flagObj
    return flagObj
end

-------------------------------------------------------------------
-- Dummy notifications, config I/O
-------------------------------------------------------------------
function Library:Notify(message, duration, color)
    warn("[Notify]", message, "(for "..tostring(duration or "N/A").."s)", color)
end

function Library:SaveConfig(configName)
    local config = {}
    for flagName, flagObj in pairs(Library.Flags) do
        config[flagName] = flagObj.Value
    end
    local jsonData = HttpService:JSONEncode(config)
    local fileName = self.FolderName.."/Configs/"..configName..".json"
    writefile(fileName, jsonData)
    print("[Config] Saved:", configName)
end

function Library:DeleteConfig(configName)
    local fileName = self.FolderName.."/Configs/"..configName..".json"
    deletefile(fileName)
    print("[Config] Deleted:", configName)
end

function Library:LoadConfig(jsonData)
    local config = HttpService:JSONDecode(jsonData)
    for flagName, val in pairs(config) do
        if Library.Flags[flagName] then
            Library.Flags[flagName]:Set(val)
        end
    end
    print("[Config] Loaded config.")
end

function Library:KeybindList()
    local KeybindList = {
        Visible = true,
        SetVisibility = function(self, v)
            self.Visible = v
            print("[KeybindList] Visibility:", v)
        end
    }
    self.KeybindList = KeybindList
    return KeybindList
end

function Library:Watermark(options)
    local watermark = {
        Name = options.Name or "Watermark",
        Visible = true,
        SetVisibility = function(self, v)
            self.Visible = v
            print("[Watermark] Visibility:", v)
        end
    }
    print("[Watermark] Created:", watermark.Name)
    return watermark
end

-------------------------------------------------------------------
-- Internal UI creation helpers
-------------------------------------------------------------------
local function createScreenGui(name)
    local gui = Instance.new("ScreenGui")
    gui.Name = name
    gui.ResetOnSpawn = false
    gui.Parent = parent
    return gui
end

-- Quick function to make a "draggable" top bar for the window
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

-------------------------------------------------------------------
-- Section class
-------------------------------------------------------------------
local Section = {}
Section.__index = Section

function Section:Toggle(opts)
    local flagObj = CreateFlag({
        Name = opts.Name,
        Flag = opts.Flag,
        Default = opts.Default or false,
        Callback = opts.Callback or function(_) end
    })
    
    -- Create a button to show toggle state
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1, -10, 0, 30)
    toggleBtn.Position = UDim2.new(0, 5, 0, self.CurrentY)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
    toggleBtn.Text = (opts.Name or "Toggle")..": "..(flagObj.Value and "ON" or "OFF")
    toggleBtn.Parent = self.SectionFrame
    
    self.CurrentY = self.CurrentY + 35
    
    toggleBtn.MouseButton1Click:Connect(function()
        local newVal = not flagObj.Value
        flagObj:Set(newVal)
        toggleBtn.Text = (opts.Name or "Toggle")..": "..(newVal and "ON" or "OFF")
    end)
    
    return flagObj
end

function Section:Dropdown(opts)
    local flagObj = CreateFlag({
        Name = opts.Name,
        Flag = opts.Flag,
        Default = opts.Default,
        Callback = opts.Callback or function(_) end
    })
    
    local dropBtn = Instance.new("TextButton")
    dropBtn.Size = UDim2.new(1, -10, 0, 30)
    dropBtn.Position = UDim2.new(0, 5, 0, self.CurrentY)
    dropBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    dropBtn.TextColor3 = Color3.fromRGB(255,255,255)
    dropBtn.Text = (opts.Name or "Dropdown").." (Click)"
    dropBtn.Parent = self.SectionFrame
    
    self.CurrentY = self.CurrentY + 35
    
    -- Minimal demonstration
    local open = false
    local function refreshText()
        dropBtn.Text = (opts.Name or "Dropdown")..": "..
            (tostring(flagObj.Value) ~= "nil" and tostring(flagObj.Value) or "None")
    end
    refreshText()
    
    dropBtn.MouseButton1Click:Connect(function()
        open = not open
        if open then
            -- Fake pick the first option
            if #opts.Options > 0 then
                flagObj:Set(opts.Options[1])
            end
        end
        refreshText()
    end)
    
    return flagObj
end

function Section:Slider(opts)
    local flagObj = CreateFlag({
        Name = opts.Name,
        Flag = opts.Flag,
        Default = opts.Default or 0,
        Callback = opts.Callback or function(_) end
    })
    
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, -10, 0, 30)
    sliderFrame.Position = UDim2.new(0, 5, 0, self.CurrentY)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
    sliderFrame.Parent = self.SectionFrame
    
    self.CurrentY = self.CurrentY + 35
    
    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Size = UDim2.new(1, 0, 1, 0)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.TextColor3 = Color3.fromRGB(255,255,255)
    sliderLabel.Text = (opts.Name or "Slider")..": "..tostring(flagObj.Value)
    sliderLabel.Parent = sliderFrame
    
    -- Minimal: on click, increment by 1
    sliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local newVal = flagObj.Value + (opts.Increment or 1)
            if newVal > (opts.Max or 100) then
                newVal = (opts.Max or 100)
            end
            flagObj:Set(newVal)
            sliderLabel.Text = (opts.Name or "Slider")..": "..tostring(newVal)
        end
    end)
    
    return flagObj
end

function Section:Colorpicker(opts)
    local flagObj = CreateFlag({
        Name = opts.Name,
        Flag = opts.Flag,
        Default = opts.Default or Color3.fromRGB(255,255,255),
        Callback = opts.Callback or function(_) end
    })
    
    local cpBtn = Instance.new("TextButton")
    cpBtn.Size = UDim2.new(1, -10, 0, 30)
    cpBtn.Position = UDim2.new(0, 5, 0, self.CurrentY)
    cpBtn.BackgroundColor3 = flagObj.Value
    cpBtn.TextColor3 = Color3.fromRGB(255,255,255)
    cpBtn.Text = opts.Name or "Colorpicker"
    cpBtn.Parent = self.SectionFrame
    
    self.CurrentY = self.CurrentY + 35
    
    -- Minimal example: just toggles between red and blue on click
    local current = flagObj.Value
    
    cpBtn.MouseButton1Click:Connect(function()
        if current == Color3.fromRGB(255,0,0) then
            current = Color3.fromRGB(0,0,255)
        else
            current = Color3.fromRGB(255,0,0)
        end
        flagObj:Set(current)
        cpBtn.BackgroundColor3 = current
    end)
    
    return flagObj
end

function Section:Keybind(opts)
    local flagObj = CreateFlag({
        Name = opts.Name,
        Flag = opts.Flag,
        Default = opts.Default or Enum.KeyCode.RightShift,
        Callback = opts.Callback or function(_) end
    })
    
    local kbBtn = Instance.new("TextButton")
    kbBtn.Size = UDim2.new(1, -10, 0, 30)
    kbBtn.Position = UDim2.new(0, 5, 0, self.CurrentY)
    kbBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    kbBtn.TextColor3 = Color3.fromRGB(255,255,255)
    kbBtn.Text = (opts.Name or "Keybind")..": "..tostring(flagObj.Value.Name or flagObj.Value)
    kbBtn.Parent = self.SectionFrame
    
    self.CurrentY = self.CurrentY + 35
    
    -- Minimal: on click, set to "F"
    kbBtn.MouseButton1Click:Connect(function()
        flagObj:Set(Enum.KeyCode.F)
        kbBtn.Text = (opts.Name or "Keybind")..": F"
    end)
    
    return flagObj
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
    
    -- Minimal UI: Just a label
    local lbLabel = Instance.new("TextLabel")
    lbLabel.Size = UDim2.new(1, -10, 0, 30)
    lbLabel.Position = UDim2.new(0, 5, 0, self.CurrentY)
    lbLabel.BackgroundColor3 = Color3.fromRGB(60,60,60)
    lbLabel.TextColor3 = Color3.fromRGB(255,255,255)
    lbLabel.Text = "[Listbox] "..(listbox.Name or "")
    lbLabel.Parent = self.SectionFrame
    
    self.CurrentY = self.CurrentY + 35
    
    table.insert(self.Elements, {Type = "Listbox", Object = listbox})
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
    tb.Position = UDim2.new(0, 5, 0, self.CurrentY)
    tb.BackgroundColor3 = Color3.fromRGB(60,60,60)
    tb.TextColor3 = Color3.fromRGB(255,255,255)
    tb.Text = textbox.Default
    tb.PlaceholderText = textbox.Placeholder
    tb.Parent = self.SectionFrame
    
    self.CurrentY = self.CurrentY + 35
    
    tb.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            textbox.Value = tb.Text
        end
    end)
    
    table.insert(self.Elements, {Type = "Textbox", Object = textbox})
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
    btn.Position = UDim2.new(0, 5, 0, self.CurrentY)
    btn.BackgroundColor3 = Color3.fromRGB(80,80,80)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Text = button.Name
    btn.Parent = self.SectionFrame
    
    self.CurrentY = self.CurrentY + 35
    
    btn.MouseButton1Click:Connect(function()
        button.Callback()
    end)
    
    function button:Sub(subOpts)
        local subButton = {
            Name = subOpts.Name or "SubButton",
            Callback = subOpts.Callback or function() end
        }
        table.insert(self.SubButtons, subButton)
        
        -- Just print to demonstrate
        print("[UI] Created Sub Button:", subButton.Name, "for Button:", self.Name)
        return subButton
    end
    
    table.insert(self.Elements, {Type = "Button", Object = button})
    return button
end

-------------------------------------------------------------------
-- Tab class
-------------------------------------------------------------------
local Tab = {}
Tab.__index = Tab

function Tab:Section(sectionOptions)
    local section = setmetatable({}, Section)
    section.Name = sectionOptions.Name or "Section"
    section.Side = sectionOptions.Side or "Left"
    section.Elements = {}
    
    -- Create a frame for the section
    local secFrame = Instance.new("Frame")
    secFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
    secFrame.Size = UDim2.new(1, -10, 0, 200) -- expand as needed
    secFrame.Position = UDim2.new(0, 5, 0, self.CurrentY)
    secFrame.Parent = self.TabFrame
    
    local secTitle = Instance.new("TextLabel")
    secTitle.Size = UDim2.new(1, 0, 0, 20)
    secTitle.BackgroundTransparency = 1
    secTitle.TextColor3 = Color3.fromRGB(255,255,255)
    secTitle.Text = section.Name
    secTitle.Parent = secFrame
    
    section.SectionFrame = secFrame
    section.CurrentY = 25
    
    self.CurrentY = self.CurrentY + 205  -- make space for next section
    table.insert(self.Sections, section)
    return section
end

-------------------------------------------------------------------
-- Window class
-------------------------------------------------------------------
local Window = {}
Window.__index = Window

function Window:Tab(options)
    local tab = setmetatable({}, Tab)
    tab.Name = options.Name or "Tab"
    tab.Sections = {}
    tab.CurrentY = 0
    
    -- Make a simple button for the tab
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0, 100, 0, 30)
    tabBtn.Position = UDim2.new(0, #self.Tabs*110, 0, 0)
    tabBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
    tabBtn.TextColor3 = Color3.fromRGB(255,255,255)
    tabBtn.Text = tab.Name
    tabBtn.Parent = self.WindowFrame
    
    -- Frame that holds this tab’s sections
    local tabFrame = Instance.new("Frame")
    tabFrame.Size = UDim2.new(1, -10, 1, -40)
    tabFrame.Position = UDim2.new(0, 5, 0, 35)
    tabFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
    tabFrame.Visible = false
    tabFrame.Parent = self.WindowFrame
    
    tab.TabButton = tabBtn
    tab.TabFrame = tabFrame
    
    -- Show/hide on button click
    tabBtn.MouseButton1Click:Connect(function()
        for _,otherTab in ipairs(self.Tabs) do
            otherTab.TabFrame.Visible = false
        end
        tabFrame.Visible = true
    end)
    
    table.insert(self.Tabs, tab)
    print("[UI] Created Tab:", tab.Name)
    return tab
end

function Window:Render()
    -- We just make the first tab visible by default
    if self.Tabs[1] then
        self.Tabs[1].TabFrame.Visible = true
    end
    print("Rendering Window:", self.Name)
end

-------------------------------------------------------------------
-- Library:Window(options)
-------------------------------------------------------------------
function Library:Window(options)
    -- Handle if user passes just a string
    if typeof(options) == "string" then
        options = {Name = options}
    end
    
    local win = setmetatable({}, Window)
    win.Name = options.Name or "Window"
    win.Tabs = {}
    
    -- Create a new ScreenGui for this window
    local gui = createScreenGui(win.Name.."_GUI")
    
    -- Main window frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 500, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
    mainFrame.Parent = gui
    
    -- A top bar for dragging
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

-------------------------------------------------------------------
-- Return the Library
-------------------------------------------------------------------
return Library
