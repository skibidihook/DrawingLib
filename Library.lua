local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local UI = {}
UI.Drawings = {}
UI.Theme = {
	Background = Color3.fromRGB(52,52,52),
	Outline = Color3.fromRGB(255,255,255),
	Accent = Color3.fromRGB(2,54,8)
}

function UI:CreateDrawing(class, props)
	local obj = Drawing.new(class)
	for i,v in pairs(props) do
		obj[i] = v
	end
	table.insert(self.Drawings, obj)
	return obj
end

function UI:IsMouseOver(obj)
	local m = UserInputService:GetMouseLocation()
	local p = obj.Position
	local s = obj.Size
	return m.X >= p.X and m.X <= p.X+s.X and m.Y >= p.Y and m.Y <= p.Y+s.Y
end

function UI:CreateWindow(config)
	local window = {}
	window.Title = config.Title or "My UI"
	window.Position = config.Position or Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
	window.Size = config.Size or Vector2.new(320,480)
	window.Elements = {}
	window.ListY = 45
	
	window.Background = self:CreateDrawing("Square", {
		Visible = true,
		Filled = true,
		Color = self.Theme.Background,
		Size = window.Size,
		Position = window.Position - window.Size/2,
		Transparency = 1,
		ZIndex = 10
	})
	
	window.Outline = self:CreateDrawing("Square", {
		Visible = true,
		Filled = false,
		Color = self.Theme.Outline,
		Thickness = 1,
		Size = window.Size,
		Position = window.Background.Position,
		Transparency = 1,
		ZIndex = 11
	})
	
	window.TitleText = self:CreateDrawing("Text", {
		Visible = true,
		Text = window.Title,
		Center = true,
		Size = 20,
		Color = self.Theme.Outline,
		Position = window.Background.Position + Vector2.new(window.Size.X/2,20),
		Outline = false,
		ZIndex = 12
	})
	
	local dragging = false
	local dragStart
	UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if self:IsMouseOver(window.Background) then
				dragging = true
				dragStart = UserInputService:GetMouseLocation()
			end
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = UserInputService:GetMouseLocation() - dragStart
			dragStart = UserInputService:GetMouseLocation()
			window.Background.Position = window.Background.Position + delta
			window.Outline.Position = window.Outline.Position + delta
			window.TitleText.Position = window.TitleText.Position + delta
			for _,e in ipairs(window.Elements) do
				if e.Background then e.Background.Position = e.Background.Position + delta end
				if e.Text then e.Text.Position = e.Text.Position + delta end
				if e.SliderFill then e.SliderFill.Position = e.SliderFill.Position + delta end
				if e.ColorRect then e.ColorRect.Position = e.ColorRect.Position + delta end
				if e.DropdownButton then e.DropdownButton.Position = e.DropdownButton.Position + delta end
				if e.DropdownList then
					for _,d in ipairs(e.DropdownList) do
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
	
	function window:AddElement(el)
		table.insert(self.Elements, el)
		self.ListY = self.ListY + 35
	end
	
	function window:AddToggle(name, default, callback)
		local toggle = {}
		toggle.State = default or false
		toggle.Background = UI:CreateDrawing("Square", {
			Visible = true,
			Filled = true,
			Color = toggle.State and UI.Theme.Accent or UI.Theme.Background,
			Size = Vector2.new(120,25),
			Position = window.Background.Position + Vector2.new(20, window.ListY),
			ZIndex = 12
		})
		toggle.Text = UI:CreateDrawing("Text", {
			Visible = true,
			Size = 16,
			Center = true,
			Text = name,
			Color = UI.Theme.Outline,
			Position = toggle.Background.Position + Vector2.new(60,12.5-8),
			Outline = false,
			ZIndex = 13
		})
		window:AddElement(toggle)
		UserInputService.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 and UI:IsMouseOver(toggle.Background) then
				toggle.State = not toggle.State
				toggle.Background.Color = toggle.State and UI.Theme.Accent or UI.Theme.Background
				if callback then callback(toggle.State) end
			end
		end)
	end
	
	function window:AddSlider(name, min, max, default, callback)
		local slider = {}
		slider.Value = default or min
		slider.Min = min
		slider.Max = max
		slider.Background = UI:CreateDrawing("Square", {
			Visible = true,
			Filled = true,
			Color = UI.Theme.Background,
			Size = Vector2.new(200,25),
			Position = window.Background.Position + Vector2.new(20, window.ListY),
			ZIndex = 12
		})
		slider.SliderFill = UI:CreateDrawing("Square", {
			Visible = true,
			Filled = true,
			Color = UI.Theme.Accent,
			Size = Vector2.new(200 * ((slider.Value - min)/(max - min)),25),
			Position = slider.Background.Position,
			ZIndex = 13
		})
		slider.Text = UI:CreateDrawing("Text", {
			Visible = true,
			Size = 16,
			Center = true,
			Text = name..": "..tostring(slider.Value),
			Color = UI.Theme.Outline,
			Position = slider.Background.Position + Vector2.new(100,12.5-8),
			Outline = false,
			ZIndex = 14
		})
		window:AddElement(slider)
		local draggingSlider = false
		UserInputService.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 and UI:IsMouseOver(slider.Background) then
				draggingSlider = true
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
				local rel = (UserInputService:GetMouseLocation().X - slider.Background.Position.X)/slider.Background.Size.X
				rel = math.clamp(rel,0,1)
				slider.Value = math.floor(min + (max - min)*rel)
				slider.SliderFill.Size = Vector2.new(slider.Background.Size.X * rel, slider.Background.Size.Y)
				slider.Text.Text = name..": "..tostring(slider.Value)
				if callback then callback(slider.Value) end
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				draggingSlider = false
			end
		end)
	end
	
	function window:AddColorPicker(name, defaultColor, callback)
		local cp = {}
		cp.Color = defaultColor or Color3.new(1,1,1)
		cp.Background = UI:CreateDrawing("Square", {
			Visible = true,
			Filled = true,
			Color = UI.Theme.Background,
			Size = Vector2.new(200,25),
			Position = window.Background.Position + Vector2.new(20, window.ListY),
			ZIndex = 12
		})
		cp.ColorRect = UI:CreateDrawing("Square", {
			Visible = true,
			Filled = true,
			Color = cp.Color,
			Size = Vector2.new(25,25),
			Position = cp.Background.Position + Vector2.new(175,0),
			ZIndex = 13
		})
		cp.Text = UI:CreateDrawing("Text", {
			Visible = true,
			Size = 16,
			Center = false,
			Text = name,
			Color = UI.Theme.Outline,
			Position = cp.Background.Position + Vector2.new(5,12.5-8),
			Outline = false,
			ZIndex = 13
		})
		window:AddElement(cp)
		local presetColors = {
			Color3.fromRGB(255,0,0),
			Color3.fromRGB(0,255,0),
			Color3.fromRGB(0,0,255),
			Color3.fromRGB(255,255,0),
			Color3.fromRGB(255,0,255),
			Color3.fromRGB(0,255,255),
			Color3.fromRGB(255,255,255)
		}
		local index = 1
		UserInputService.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 and UI:IsMouseOver(cp.ColorRect) then
				index = (index % #presetColors) + 1
				cp.Color = presetColors[index]
				cp.ColorRect.Color = cp.Color
				if callback then callback(cp.Color) end
			end
		end)
	end
	
	function window:AddDropdown(name, options, callback)
		local dd = {}
		dd.Options = options or {}
		dd.Selected = dd.Options[1] or ""
		dd.Expanded = false
		dd.DropdownList = {}
		dd.Background = UI:CreateDrawing("Square", {
			Visible = true,
			Filled = true,
			Color = UI.Theme.Background,
			Size = Vector2.new(200,25),
			Position = window.Background.Position + Vector2.new(20, window.ListY),
			ZIndex = 12
		})
		dd.Text = UI:CreateDrawing("Text", {
			Visible = true,
			Size = 16,
			Center = false,
			Text = name..": "..dd.Selected,
			Color = UI.Theme.Outline,
			Position = dd.Background.Position + Vector2.new(5,12.5-8),
			Outline = false,
			ZIndex = 13
		})
		dd.DropdownButton = UI:CreateDrawing("Square", {
			Visible = true,
			Filled = true,
			Color = UI.Theme.Accent,
			Size = Vector2.new(25,25),
			Position = dd.Background.Position + Vector2.new(175,0),
			ZIndex = 13
		})
		window:AddElement(dd)
		UserInputService.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				if UI:IsMouseOver(dd.DropdownButton) then
					dd.Expanded = not dd.Expanded
					if dd.Expanded then
						for i, opt in ipairs(dd.Options) do
							local optBox = UI:CreateDrawing("Square", {
								Visible = true,
								Filled = true,
								Color = UI.Theme.Background,
								Size = Vector2.new(200,25),
								Position = dd.Background.Position + Vector2.new(0,i*25),
								ZIndex = 14
							})
							local optText = UI:CreateDrawing("Text", {
								Visible = true,
								Size = 16,
								Center = false,
								Text = opt,
								Color = UI.Theme.Outline,
								Position = optBox.Position + Vector2.new(5,12.5-8),
								Outline = false,
								ZIndex = 15
							})
							table.insert(dd.DropdownList, optBox)
							table.insert(dd.DropdownList, optText)
							UserInputService.InputBegan:Connect(function(input2)
								if input2.UserInputType == Enum.UserInputType.MouseButton1 then
									if UI:IsMouseOver(optBox) then
										dd.Selected = opt
										dd.Text.Text = name..": "..dd.Selected
										dd.Expanded = false
										if callback then callback(opt) end
										for _, dItem in ipairs(dd.DropdownList) do
											dItem.Visible = false
										end
										dd.DropdownList = {}
									end
								end
							end)
						end
					else
						for _, dItem in ipairs(dd.DropdownList) do
							dItem.Visible = false
						end
						dd.DropdownList = {}
					end
				end
			end
		end)
	end
	
	return window
end

function UI:ShowNotification(message, duration)
	duration = duration or 3
	local notif = {}
	notif.Background = self:CreateDrawing("Square", {
		Visible = true,
		Filled = true,
		Color = self.Theme.Background,
		Size = Vector2.new(250,40),
		Position = Vector2.new(10,60),
		ZIndex = 20
	})
	notif.Text = self:CreateDrawing("Text", {
		Visible = true,
		Size = 18,
		Center = true,
		Text = message,
		Color = self.Theme.Outline,
		Position = notif.Background.Position + Vector2.new(125,20) - Vector2.new(0,8),
		Outline = false,
		ZIndex = 21
	})
	delay(duration, function()
		notif.Background.Visible = false
		notif.Text.Visible = false
	end)
end

return UI
