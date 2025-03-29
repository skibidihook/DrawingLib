local Library = {}
Library.Flags = {}
Library.Windows = {}

local function makeDraggable(frame, holdObject)
    local userinput = game:GetService("UserInputService")
    local dragging = false
    local dragStart, startPos
    holdObject.InputBegan:Connect(function(input)
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
    holdObject.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
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

local function createMainContainer(name)
    local sgui = Instance.new("ScreenGui")
    sgui.Name = "UI_" .. (name or "Untitled")
    sgui.ResetOnSpawn = false
    sgui.Parent = (gethui and gethui()) or game.CoreGui

    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 500, 0, 400)
    frame.Position = UDim2.new(0.5, -250, 0.5, -200)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    frame.Active = true
    frame.Draggable = false
    frame.Parent = sgui

    local dragBar = Instance.new("Frame")
    dragBar.Name = "DragBar"
    dragBar.Size = UDim2.new(1, 0, 0, 30)
    dragBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    dragBar.Parent = frame

    local label = Instance.new("TextLabel")
    label.Name = "Title"
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.Font = Enum.Font.SourceSans
    label.TextSize = 20
    label.TextColor3 = Color3.new(1,1,1)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = dragBar

    makeDraggable(frame, dragBar)
    return sgui, frame
end

function Library:Get(flag)
    local f = self.Flags[flag]
    if f then
        return f.Value
    end
end

function Library:Set(flag, value)
    local f = self.Flags[flag]
    if f then
        f.Value = value
        if f.Callback then
            f.Callback(value)
        end
    end
end

function Library:Window(cfg)
    local name = cfg.Name or "New Window"
    local sgui, mainFrame = createMainContainer(name)
    local newWindow = {
        Name = name,
        GuiObject = mainFrame,
        Tabs = {},
        _ScreenGui = sgui,
    }
    function newWindow:Tab(tc)
        local tabName = tc.Name or "Tab"
        local tab = {
            Name = tabName,
            Sections = {},
            Window = newWindow,
        }
        table.insert(newWindow.Tabs, tab)
        function tab:Section(sc)
            local sectionName = sc.Name or "Section"
            local side = sc.Side or "Left"
            local newSection = {
                Name = sectionName,
                Tab = tab,
                Items = {},
                Side = side,
            }
            table.insert(self.Sections, newSection)

            function newSection:Toggle(cfgT)
                local name = cfgT.Name or "Toggle"
                local flag = cfgT.Flag or (name:gsub(" ","_"):lower())
                local default = cfgT.Default or false
                local callback = cfgT.Callback or function() end
                Library.Flags[flag] = { Type = "Toggle", Value = default, Callback = callback }
                local item = {
                    Name = name,
                    Flag = flag,
                    Type = "Toggle",
                    Value = default,
                    Callback = callback,
                }
                item.Get = function()
                    return Library:Get(flag)
                end
                item.Set = function(val)
                    Library:Set(flag, val)
                end
                table.insert(self.Items, item)
                callback(default)
                return item
            end

            function newSection:Slider(cfgS)
                local name = cfgS.Name or "Slider"
                local flag = cfgS.Flag or (name:gsub(" ","_"):lower())
                local min = cfgS.Min or 0
                local max = cfgS.Max or 100
                local default = cfgS.Default or 0
                local callback = cfgS.Callback or function() end
                Library.Flags[flag] = { Type="Slider", Value=default, Callback=callback }
                local item = {
                    Name = name,
                    Flag = flag,
                    Type = "Slider",
                    Min = min,
                    Max = max,
                    Value = default,
                    Callback = callback,
                }
                item.Get = function()
                    return Library:Get(flag)
                end
                item.Set = function(val)
                    Library:Set(flag, val)
                end
                table.insert(self.Items, item)
                callback(default)
                return item
            end

            function newSection:Dropdown(cfgD)
                local name = cfgD.Name or "Dropdown"
                local flag = cfgD.Flag or (name:gsub(" ","_"):lower())
                local options = cfgD.Options or {}
                local default = cfgD.Default or options[1]
                local callback = cfgD.Callback or function() end
                Library.Flags[flag] = { Type="Dropdown", Value=default, Callback=callback }
                local item = {
                    Name = name,
                    Flag = flag,
                    Type = "Dropdown",
                    Options = options,
                    Value = default,
                    Callback = callback,
                }
                item.Get = function()
                    return Library:Get(flag)
                end
                item.Set = function(val)
                    Library:Set(flag, val)
                end
                table.insert(self.Items, item)
                callback(default)
                return item
            end

            function newSection:Colorpicker(cfgC)
                local name = cfgC.Name or "Colorpicker"
                local flag = cfgC.Flag or (name:gsub(" ","_"):lower())
                local default = cfgC.Default or Color3.fromRGB(255,255,255)
                local callback = cfgC.Callback or function() end
                Library.Flags[flag] = { Type="Colorpicker", Value=default, Callback=callback }
                local item = {
                    Name = name,
                    Flag = flag,
                    Type = "Colorpicker",
                    Value = default,
                    Callback = callback,
                }
                item.Get = function()
                    return Library:Get(flag)
                end
                item.Set = function(val)
                    Library:Set(flag, val)
                end
                table.insert(self.Items, item)
                callback(default)
                return item
            end

            function newSection:Keybind(cfgK)
                local name = cfgK.Name or "Keybind"
                local flag = cfgK.Flag or (name:gsub(" ","_"):lower())
                local default = cfgK.Default or Enum.KeyCode.RightShift
                local mode = cfgK.Mode or "Toggle"
                local callback = cfgK.Callback or function() end
                Library.Flags[flag] = { Type="Keybind", Value=default, Mode=mode, Callback=callback }
                local item = {
                    Name = name,
                    Flag = flag,
                    Type = "Keybind",
                    Value = default,
                    Mode = mode,
                    Callback = callback,
                }
                item.Get = function()
                    return Library:Get(flag)
                end
                item.Set = function(val)
                    Library:Set(flag, val)
                end
                table.insert(self.Items, item)
                callback(default)
                return item
            end

            return newSection
        end
        return tab
    end

    function newWindow:SetVisible(bool)
        newWindow.GuiObject.Visible = bool
    end

    table.insert(self.Windows, newWindow)
    return newWindow
end

function Library:KeybindList()
    local keybindList = { Visible = true }
    function keybindList:SetVisibility(bool)
        self.Visible = bool
    end
    self.KeybindList = keybindList
    return keybindList
end

function Library:Watermark(cfg)
    local name = cfg.Name or "Watermark"
    local watermarkObj = { Name = name, Visible = true }
    function watermarkObj:SetVisiblity(bool)
        self.Visible = bool
    end
    self.WatermarkObj = watermarkObj
    return watermarkObj
end

return Library
