
local HttpService = game:GetService("HttpService")

local Library = {}
Library.Flags = {}
Library.FolderName = "MyUILibraryConfigs"

local function CreateFlag(options)
    local flag = {
        Name = options.Name or "Unnamed",
        Value = options.Default,
        Callback = options.Callback or function(newValue) end,
        Get = function(self)
            return self.Value
        end,
        Set = function(self, newValue)
            self.Value = newValue
            if self.Callback then
                self.Callback(newValue)
            end
        end,
    }
    Library.Flags[options.Flag] = flag
    return flag
end

function Library:Notify(message, duration, color)
    print("[Notify]", message, "(for "..(duration or "default").." seconds)", color)
end

function Library:SaveConfig(configName)
    local config = {}
    for key, flag in pairs(Library.Flags) do
        config[key] = flag.Value
    end
    local jsonData = self:JSONEncode(config)
    local filename = Library.FolderName .. "/Configs/" .. configName .. ".json"
    writefile(filename, jsonData)
    print("[Config] Saved config:", configName)
end

function Library:DeleteConfig(configName)
    local filename = Library.FolderName .. "/Configs/" .. configName .. ".json"
    deletefile(filename)
    print("[Config] Deleted config:", configName)
end

function Library:LoadConfig(jsonData)
    local config = self:JSONDecode(jsonData)
    for key, value in pairs(config) do
        if Library.Flags[key] then
            Library.Flags[key]:Set(value)
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

local Window = {}
Window.__index = Window

function Window:Tab(options)
    local tab = { Name = options.Name or "Tab", Sections = {} }

    function tab:Section(sectionOptions)
        local section = { Name = sectionOptions.Name or "Section", Side = sectionOptions.Side or "Left", Elements = {} }

        function section:Toggle(opts)
            local toggle = {
                Name = opts.Name or "Toggle",
                Flag = opts.Flag,
                Default = opts.Default or false,
                Callback = opts.Callback or function(newState) end
            }
            toggle.FlagObject = CreateFlag({
                Name = opts.Name,
                Flag = opts.Flag,
                Default = toggle.Default,
                Callback = toggle.Callback
            })
            table.insert(self.Elements, {Type = "Toggle", Object = toggle})
            print("[UI] Created Toggle:", toggle.Name, "Default:", toggle.Default)
            return toggle
        end

        function section:Dropdown(opts)
            local dropdown = {
                Name = opts.Name or "Dropdown",
                Flag = opts.Flag,
                Options = opts.Options or {},
                Default = opts.Default,
                Callback = opts.Callback or function(selected) end
            }
            dropdown.FlagObject = CreateFlag({
                Name = opts.Name,
                Flag = opts.Flag,
                Default = dropdown.Default,
                Callback = dropdown.Callback
            })
            table.insert(self.Elements, {Type = "Dropdown", Object = dropdown})
            print("[UI] Created Dropdown:", dropdown.Name, "Default:", dropdown.Default)
            return dropdown
        end

        function section:Slider(opts)
            local slider = {
                Name = opts.Name or "Slider",
                Flag = opts.Flag,
                Default = opts.Default or 0,
                Min = opts.Min or 0,
                Max = opts.Max or 100,
                Increment = opts.Increment or 1,
                Decimals = opts.Decimals or 0,
                Sub = opts.Sub or "",
                Callback = opts.Callback or function(value) end
            }
            slider.FlagObject = CreateFlag({
                Name = opts.Name,
                Flag = opts.Flag,
                Default = slider.Default,
                Callback = slider.Callback
            })
            table.insert(self.Elements, {Type = "Slider", Object = slider})
            print("[UI] Created Slider:", slider.Name, "Default:", slider.Default)
            return slider
        end

        function section:Colorpicker(opts)
            local colorpicker = {
                Name = opts.Name or "Colorpicker",
                Flag = opts.Flag,
                Default = opts.Default or Color3.new(1,1,1),
                Callback = opts.Callback or function(color) end
            }
            colorpicker.FlagObject = CreateFlag({
                Name = opts.Name,
                Flag = opts.Flag,
                Default = colorpicker.Default,
                Callback = colorpicker.Callback
            })
            table.insert(self.Elements, {Type = "Colorpicker", Object = colorpicker})
            print("[UI] Created Colorpicker:", colorpicker.Name, "Default:", colorpicker.Default)
            return colorpicker
        end

        function section:Keybind(opts)
            local keybind = {
                Name = opts.Name or "Keybind",
                Flag = opts.Flag,
                Default = opts.Default or Enum.KeyCode.RightShift,
                Mode = opts.Mode or "Toggle",
                Hidden = opts.Hidden or false,
                Callback = opts.Callback or function() end
            }
            keybind.FlagObject = CreateFlag({
                Name = opts.Name,
                Flag = opts.Flag,
                Default = keybind.Default,
                Callback = keybind.Callback
            })
            table.insert(self.Elements, {Type = "Keybind", Object = keybind})
            print("[UI] Created Keybind:", keybind.Name, "Default:", keybind.Default)
            return keybind
        end
        
        -- Listbox
        function section:Listbox(opts)
            local listbox = {
                Name = opts.Name or "Listbox",
                Flag = opts.Flag,
                Options = opts.Options or {},
                Selected = nil,
                AddOption = function(self, option)
                    table.insert(self.Options, option)
                end,
                RemoveOption = function(self, option)
                    for i, v in ipairs(self.Options) do
                        if v == option then
                            table.remove(self.Options, i)
                            break
                        end
                    end
                end
            }
            table.insert(self.Elements, {Type = "Listbox", Object = listbox})
            print("[UI] Created Listbox:", listbox.Name)
            return listbox
        end
        
        -- Textbox
        function section:Textbox(opts)
            local textbox = {
                Name = opts.Name or "Textbox",
                Flag = opts.Flag,
                Placeholder = opts.Placeholder or "",
                Compact = opts.Compact or false,
                Default = opts.Default or "",
                Value = opts.Default or ""
            }
            function textbox:Set(val)
                self.Value = val
            end
            table.insert(self.Elements, {Type = "Textbox", Object = textbox})
            print("[UI] Created Textbox:", textbox.Name)
            return textbox
        end
    
        function section:Button(opts)
            local button = {
                Name = opts.Name or "Button",
                Callback = opts.Callback or function() end,
                SubButtons = {}
            }
            function button:Sub(subOpts)
                local subButton = {
                    Name = subOpts.Name or "SubButton",
                    Callback = subOpts.Callback or function() end
                }
                table.insert(self.SubButtons, subButton)
                print("[UI] Created Sub Button:", subButton.Name, "for Button:", self.Name)
                return subButton
            end
            table.insert(self.Elements, {Type = "Button", Object = button})
            print("[UI] Created Button:", button.Name)
            return button
        end
        
        self.Sections[#self.Sections+1] = section
        return section
    end
    
    self.Tabs = self.Tabs or {}
    table.insert(self.Tabs, tab)
    print("[UI] Created Tab:", tab.Name)
    return tab
end

function Window:Render()
    print("Rendering Window: " .. self.Name)
end

function Library:Window(options)
    local win = setmetatable({}, Window)
    win.Name = options.Name or "Window"
    win.Tabs = {}
    print("[UI] Created Window:", win.Name)
    return win
end
return Library
