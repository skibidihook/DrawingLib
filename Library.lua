local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local UI = {}
UI.Drawings = {}

UI.Theme = {
    Background = Color3.fromRGB(52, 52, 52),
    Outline = Color3.fromRGB(255, 255, 255),
    Accent = Color3.fromRGB(2, 54, 8)
}

function UI:CreateDrawing(class, properties)
    local d = Drawing.new(class)
    for prop, value in pairs(properties) do
        d[prop] = value
    end
    table.insert(self.Drawings, d)
    return d
end

function UI:IsMouseOver(obj)
    local mousePos = UserInputService:GetMouseLocation()
    local pos = obj.Position
    local size = obj.Size
    return mousePos.X >= pos.X and mousePos.X <= pos.X + size.X and mousePos.Y >= pos.Y and mousePos.Y <= pos.Y + size.Y
end

function UI:CreateWindow(config)
    config = config or {}
    local win = {}
    win.Title = config.Title or "Window"
    win.Position = config.Position or Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    win.Size = config.Size or Vector2.new(300, 400)
    win.ListY = 40

    win.Background = self:CreateDrawing("Square", {
        Visible = true,
        Filled = true,
        Color = self.Theme.Background,
        Size = win.Size,
        Position = win.Position - win.Size/2,
        ZIndex = 10,
        Transparency = 1
    })
    win.Outline = self:CreateDrawing("Square", {
        Visible = true,
        Filled = false,
        Color = self.Theme.Outline,
        Thickness = 1,
        Size = win.Size,
        Position = win.Background.Position,
        ZIndex = 10,
        Transparency = 1
    })
    win.TitleText = self:CreateDrawing("Text", {
        Visible = true,
        Size = 20,
        Center = true,
        Text = win.Title,
        Color = self.Theme.Outline,
        Position = win.Background.Position + Vector2.new(win.Size.X/2, 20),
        ZIndex = 10,
        Outline = false
    })

    win.Elements = {}

    local dragging = false
    local dragStart = nil
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if self:IsMouseOver(win.Background) then
                dragging = true
                dragStart = UserInputService:GetMouseLocation()
            end
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = UserInputService:GetMouseLocation() - dragStart
            dragStart = UserInputService:GetMouseLocation()
            win.Background.Position = win.Background.Position + delta
            win.Outline.Position = win.Outline.Position + delta
            win.TitleText.Position = win.TitleText.Position + delta
            for _, elem in pairs(win.Elements) do
                if elem.Background then
                    elem.Background.Position = elem.Background.Position + delta
                end
                if elem.Text then
                    elem.Text.Position = elem.Text.Position + delta
                end
                if elem.SliderFill then
                    elem.SliderFill.Position = elem.SliderFill.Position + delta
                end
                if elem.ColorRect then
                    elem.ColorRect.Position = elem.ColorRect.Position + delta
                end
                if elem.DropdownButton then
                    elem.DropdownButton.Position = elem.DropdownButton.Position + delta
                end
                if elem.DropdownList then
                    for _, d in pairs(elem.DropdownList) do
                        d.Position = d.Position + delta
                    end
                end
            end
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    function win:AddElement(element)
        table.insert(self.Elements, element)
        self.ListY = self.ListY + 35
    end

    function win:AddToggle(name, initial, callback)
        local toggle = {}
        toggle.State = initial or false
        toggle.Background = UI:CreateDrawing("Square", {
            Visible = true,
            Filled = true,
            Color = toggle.State and UI.Theme.Accent or UI.Theme.Background,
            Size = Vector2.new(120, 25),
            Position = win.Background.Position + Vector2.new(20, win.ListY)
        })
        toggle.Text = UI:CreateDrawing("Text", {
            Visible = true,
            Size = 16,
            Center = true,
            Text = name,
            Color = UI.Theme.Outline,
            Position = toggle.Background.Position + Vector2.new(toggle.Background.Size.X/2, toggle.Background.Size.Y/2 - 8),
            Outline = false
        })
        win:AddElement(toggle)
        UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and UI:IsMouseOver(toggle.Background) then
                toggle.State = not toggle.State
                toggle.Background.Color = toggle.State and UI.Theme.Accent or UI.Theme.Background
                if callback then callback(toggle.State) end
            end
        end)
    end

    function win:AddSlider(name, min, max, initial, callback)
        local slider = {}
        slider.Value = initial or min
        slider.Min = min
        slider.Max = max
        slider.Background = UI:CreateDrawing("Square", {
            Visible = true,
            Filled = true,
            Color = UI.Theme.Background,
            Size = Vector2.new(200, 25),
            Position = win.Background.Position + Vector2.new(20, win.ListY)
        })
        slider.SliderFill = UI:CreateDrawing("Square", {
            Visible = true,
            Filled = true,
            Color = UI.Theme.Accent,
            Size = Vector2.new(200 * ((slider.Value - min) / (max - min)), 25),
            Position = slider.Background.Position,
            ZIndex = 11
        })
        slider.Text = UI:CreateDrawing("Text", {
            Visible = true,
            Size = 16,
            Center = true,
            Text = name .. ": " .. tostring(slider.Value),
            Color = UI.Theme.Outline,
            Position = slider.Background.Position + Vector2.new(100, 12.5) - Vector2.new(0, 8),
            Outline = false,
            ZIndex = 11
        })
        win:AddElement(slider)

        local draggingSlider = false
        UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and UI:IsMouseOver(slider.Background) then
                draggingSlider = true
            end
        end)
        UserInputService.InputChanged:Connect(function()
            if draggingSlider then
                local mouseX = UserInputService:GetMouseLocation().X
                local rel = (mouseX - slider.Background.Position.X) / slider.Background.Size.X
                rel = math.clamp(rel, 0, 1)
                slider.Value = math.floor(min + (max - min) * rel)
                slider.SliderFill.Size = Vector2.new(slider.Background.Size.X * rel, slider.Background.Size.Y)
                slider.Text.Text = name .. ": " .. tostring(slider.Value)
                if callback then callback(slider.Value) end
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingSlider = false
            end
        end)
    end

    function win:AddColorPicker(name, initialColor, callback)
        local cp = {}
        cp.Color = initialColor or Color3.new(1, 1, 1)
        cp.Background = UI:CreateDrawing("Square", {
            Visible = true,
            Filled = true,
            Color = UI.Theme.Background,
            Size = Vector2.new(200, 25),
            Position = win.Background.Position + Vector2.new(20, win.ListY)
        })
        cp.ColorRect = UI:CreateDrawing("Square", {
            Visible = true,
            Filled = true,
            Color = cp.Color,
            Size = Vector2.new(25, 25),
            Position = cp.Background.Position + Vector2.new(175, 0)
        })
        cp.Text = UI:CreateDrawing("Text", {
            Visible = true,
            Size = 16,
            Center = false,
            Text = name,
            Color = UI.Theme.Outline,
            Position = cp.Background.Position + Vector2.new(5, 5),
            Outline = false
        })
        win:AddElement(cp)
        local colors = {
            Color3.new(1,0,0),
            Color3.new(0,1,0),
            Color3.new(0,0,1),
            Color3.new(1,1,0),
            Color3.new(1,0,1),
            Color3.new(0,1,1),
            Color3.new(1,1,1)
        }
        local idx = 1
        UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and UI:IsMouseOver(cp.ColorRect) then
                idx = (idx % #colors) + 1
                cp.Color = colors[idx]
                cp.ColorRect.Color = cp.Color
                if callback then callback(cp.Color) end
            end
        end)
    end

    function win:AddDropdown(name, options, callback)
        local dd = {}
        dd.Options = options or {}
        dd.Selected = dd.Options[1] or ""
        dd.Background = UI:CreateDrawing("Square", {
            Visible = true,
            Filled = true,
            Color = UI.Theme.Background,
            Size = Vector2.new(200, 25),
            Position = win.Background.Position + Vector2.new(20, win.ListY)
        })
        dd.Text = UI:CreateDrawing("Text", {
            Visible = true,
            Size = 16,
            Center = false,
            Text = name .. ": " .. dd.Selected,
            Color = UI.Theme.Outline,
            Position = dd.Background.Position + Vector2.new(5, 5),
            Outline = false
        })
        dd.DropdownButton = UI:CreateDrawing("Square", {
            Visible = true,
            Filled = true,
            Color = UI.Theme.Accent,
            Size = Vector2.new(25, 25),
            Position = dd.Background.Position + Vector2.new(175, 0)
        })
        win:AddElement(dd)
        dd.Expanded = false
        dd.DropdownList = {}

        UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and UI:IsMouseOver(dd.DropdownButton) then
                dd.Expanded = not dd.Expanded
                if dd.Expanded then
                    for i,option in ipairs(dd.Options) do
                        local optBox = UI:CreateDrawing("Square", {
                            Visible = true,
                            Filled = true,
                            Color = UI.Theme.Background,
                            Size = Vector2.new(200, 25),
                            Position = dd.Background.Position + Vector2.new(0, i*25)
                        })
                        local optText = UI:CreateDrawing("Text", {
                            Visible = true,
                            Size = 16,
                            Center = false,
                            Text = option,
                            Color = UI.Theme.Outline,
                            Position = optBox.Position + Vector2.new(5, 5),
                            Outline = false
                        })
                        table.insert(dd.DropdownList, optBox)
                        table.insert(dd.DropdownList, optText)
                        UserInputService.InputBegan:Connect(function(input2)
                            if input2.UserInputType == Enum.UserInputType.MouseButton1 and UI:IsMouseOver(optBox) then
                                dd.Selected = option
                                dd.Text.Text = name .. ": " .. option
                                dd.Expanded = false
                                if callback then callback(option) end
                                for _,d in pairs(dd.DropdownList) do
                                    d.Visible = false
                                end
                                dd.DropdownList = {}
                            end
                        end)
                    end
                else
                    for _,d in pairs(dd.DropdownList) do
                        d.Visible = false
                    end
                    dd.DropdownList = {}
                end
            end
        end)
    end

    return win
end

function UI:ShowNotification(message, duration)
    duration = duration or 3
    local notif = {}
    notif.Background = self:CreateDrawing("Square", {
        Visible = true,
        Filled = true,
        Color = self.Theme.Background,
        Size = Vector2.new(250, 40),
        Position = Vector2.new(10, 10),
        ZIndex = 20
    })
    notif.Text = self:CreateDrawing("Text", {
        Visible = true,
        Size = 18,
        Center = true,
        Text = message,
        Color = self.Theme.Outline,
        Position = notif.Background.Position + Vector2.new(125, 20) - Vector2.new(0, 8),
        Outline = false,
        ZIndex = 20
    })
    delay(duration, function()
        notif.Background.Visible = false
        notif.Text.Visible = false
    end)
end

return UI
