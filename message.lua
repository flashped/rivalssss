local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- 📌 GUI
local screenGui = Instance.new("ScreenGui", PlayerGui)
screenGui.Name = "CheatMenu"
screenGui.ResetOnSpawn = false

-- 📌 Paramètres
local Settings = {
    AimbotEnabled = false,
    ShowFOV = true,
    FOVRadius = 200,
    ESPEnabled = true,
    ESPRainbow = true,
    ESPColor = Color3.fromRGB(255, 255, 255)
}

-- 📌 FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Radius = Settings.FOVRadius
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Visible = Settings.ShowFOV

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = workspace.CurrentCamera.ViewportSize / 2
    FOVCircle.Visible = Settings.ShowFOV
    FOVCircle.Radius = Settings.FOVRadius
end)

-- 📌 Frame principal avec dragabilité
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 300)
frame.Position = UDim2.new(0, 20, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Visible = true
frame.Parent = screenGui

-- 📌 Animation d'apparition et disparition
frame:TweenPosition(UDim2.new(0, 20, 0.5, -150), "Out", "Quad", 0.5, true)

-- 📌 Titre du menu
local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 220, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
title.Text = "Cheat Menu"
title.TextSize = 20
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextStrokeTransparency = 0.5
title.TextAlign = Enum.TextXAlignment.Center
title.Parent = frame

-- 📌 Bouton de réduction
local collapseButton = Instance.new("TextButton")
collapseButton.Size = UDim2.new(0, 220, 0, 30)
collapseButton.Position = UDim2.new(0, 0, 0, 30)
collapseButton.Text = "▲ Cacher Menu"
collapseButton.TextSize = 14
collapseButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
collapseButton.TextColor3 = Color3.new(1, 1, 1)
collapseButton.Parent = frame

local collapsed = false
collapseButton.MouseButton1Click:Connect(function()
    collapsed = not collapsed
    collapseButton.Text = collapsed and "▼ Ouvrir Menu" or "▲ Cacher Menu"
    for _, child in ipairs(frame:GetChildren()) do
        if child:IsA("TextButton") and child.Name ~= "collapseButton" then
            child.Visible = not collapsed
        end
    end
end)

-- 📌 Fonction pour créer un bouton avec un style moderne
local function createButton(name, parent, text, position, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 200, 0, 40)
    button.Position = position
    button.Text = text
    button.Name = name
    button.TextSize = 16
    button.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextStrokeTransparency = 0.6
    button.BorderSizePixel = 0
    button.Parent = parent
    button.MouseButton1Click:Connect(function()
        callback(button)
    end)
    return button
end

-- 📌 Tabs (Onglets)
local tab = "aimbot"

local function updateTabs()
    for _, obj in pairs(frame:GetChildren()) do
        if obj:IsA("TextButton") and obj.Name ~= "TabAimbot" and obj.Name ~= "TabESP" and obj.Name ~= "collapseButton" then
            obj.Visible = (tab == "aimbot" and obj.Name:match("^Aimbot")) or (tab == "esp" and obj.Name:match("^ESP"))
        end
    end
end

createButton("TabAimbot", frame, "🎯 Aimbot", UDim2.new(0, 10, 0, 70), function()
    tab = "aimbot"
    updateTabs()
end)

createButton("TabESP", frame, "🧿 ESP", UDim2.new(0, 110, 0, 70), function()
    tab = "esp"
    updateTabs()
end)

-- 📌 Boutons Aimbot
createButton("AimbotToggle", frame, "Aimbot: OFF", UDim2.new(0, 10, 0, 110), function(self)
    Settings.AimbotEnabled = not Settings.AimbotEnabled
    self.Text = "Aimbot: " .. (Settings.AimbotEnabled and "ON" or "OFF")
end)

createButton("AimbotFOVToggle", frame, "FOV: ON", UDim2.new(0, 10, 0, 150), function(self)
    Settings.ShowFOV = not Settings.ShowFOV
    self.Text = "FOV: " .. (Settings.ShowFOV and "ON" or "OFF")
end)

createButton("AimbotFOVPlus", frame, "FOV +", UDim2.new(0, 10, 0, 190), function()
    Settings.FOVRadius = Settings.FOVRadius + 20
end)

createButton("AimbotFOVMinus", frame, "FOV -", UDim2.new(0, 110, 0, 190), function()
    Settings.FOVRadius = math.max(20, Settings.FOVRadius - 20)
end)

-- 📌 Boutons ESP
createButton("ESPToggle", frame, "ESP: ON", UDim2.new(0, 10, 0, 230), function(self)
    Settings.ESPEnabled = not Settings.ESPEnabled
    self.Text = "ESP: " .. (Settings.ESPEnabled and "ON" or "OFF")
end)

createButton("ESPRainbowToggle", frame, "Rainbow: ON", UDim2.new(0, 10, 0, 270), function(self)
    Settings.ESPRainbow = not Settings.ESPRainbow
    self.Text = "Rainbow: " .. (Settings.ESPRainbow and "ON" or "OFF")
end)

createButton("ESPColorPicker", frame, "Couleur: Rouge", UDim2.new(0, 10, 0, 310), function(self)
    local colors = {
        Color3.fromRGB(255, 0, 0),
        Color3.fromRGB(0, 255, 0),
        Color3.fromRGB(0, 0, 255),
        Color3.fromRGB(255, 255, 0),
        Color3.fromRGB(255, 255, 255)
    }
    local names = {"Rouge", "Vert", "Bleu", "Jaune", "Blanc"}
    local index = table.find(colors, Settings.ESPColor) or 0
    index = index + 1 > #colors and 1 or index + 1
    Settings.ESPColor = colors[index]
    self.Text = "Couleur: " .. names[index]
end)

updateTabs()
