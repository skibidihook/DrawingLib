local UILib = loadstring(game:HttpGet("https://raw.githubusercontent.com/YourUsername/YourRepo/main/UILib.lua"))()

local myWindow = UILib:CreateWindow({
    Title    = "My UI",
    Position = Vector2.new(400, 300),
    Size     = Vector2.new(320, 520)
})

myWindow:AddToggle("TeamCheck", {
    Text     = "Team Check",
    Default  = false,
    Callback = function(value)
        print("Team Check toggled:", value)
    end
})

myWindow:AddSlider("AimFOV", {
    Text     = "Aim FOV",
    Min      = 0,
    Max      = 600,
    Default  = 300,
    Callback = function(value)
        print("Aim FOV value:", value)
    end
})

myWindow:AddColorPicker("HitboxColor", {
    Text     = "Hitbox Color",
    Default  = Color3.new(1, 1, 1),
    Callback = function(color)
        print("Hitbox Color selected:", color)
    end
})

myWindow:AddDropdown("TargetMode", {
    Text     = "Target Mode",
    Options  = {"Nearest", "FOV", "Visible"},
    Default  = "Nearest",
    Callback = function(selection)
        print("Target Mode selected:", selection)
    end
})

UILib:ShowNotification("UI Loaded Successfully!", 5)
